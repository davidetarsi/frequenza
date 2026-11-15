# Diario di viaggio — design

Data: 16 novembre 2026. Stato: **da approvare** (rivisto dopo il controllo di un revisore). Branch `docs/diario-di-viaggio`, da `develop`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Frequenza è una radio da viaggio. Il diario fa ricordare alla radio **dove ti sei fermato ad ascoltare** e te lo restituisce come un mappamondo che si accende, con pochi numeri accanto.

L'obiettivo non è collezionare paesi. Visitarne uno costa un tocco, quindi colorare la mappa a ogni passaggio sarebbe una ricompensa senza valore **[D]**. La sola fatica che conta è **il tempo passato ad ascoltare**.

## Obiettivi

- Registrare, solo sul telefono, quanto si ascolta ogni stazione e ogni paese.
- Una pagina «Diario di viaggio», che si apre dallo schermo della radio, con:
  - il mappamondo colorato per tempo di ascolto;
  - i numeri principali;
  - la stazione più ascoltata;
  - la classifica dei paesi.
- La scelta del periodo: 7 giorni, 30 giorni, anno, sempre.

## Non obiettivi

- Login, account, sincronizzazione tra telefoni **[D]**.
- Analytics o qualunque dato che lasci il telefono **[D]**. La scheda dello Store resta «nessun dato raccolto».
- Passaporto, timbri, collezioni **[D]**. Davide potrebbe usarli in PackLog.
- Riepilogo annuale stile Wrapped e cartolina da condividere: vengono dopo, e il registro li rende possibili senza cambiarlo.
- Recuperare gli ascolti precedenti all'aggiornamento: il diario parte vuoto.

## Da evitare (anti-obiettivi)

- Una mappa che si accende con un tocco: deve restare legata al tempo.
- Una pagina che sembri un'altra app: è lo schermo della radio, ingrandito.
- Perdere ascolti quando Android chiude l'app, oppure contarne di falsi (volo, pausa, buffering).

## Approcci

1. **Scelto: un registro degli ascolti in Drift** **[D]**.
   - Una riga per ogni ascolto continuo di una stazione.
   - Ogni periodo, soglia o statistica si calcola dopo con delle query, senza cambiare cosa si salva.
2. **Scartato: totali giornalieri per stazione.** Si perdono l'ora e i singoli ascolti, quindi niente statistiche future come gli ascolti serali o l'ultimo ascolto.
3. **Scartato: contatori per paese nelle preferenze.** Non permette né i periodi né la stazione più ascoltata.

## Cosa si registra

### Quando conta un ascolto **[C]**

Conta solo quando la stazione **suona davvero**, cioè con la sessione `OnAir` e la riproduzione `playing`.
- **Non contano:** volo, pausa, buffering, stream finito o rotto.
- **Contano:** schermo spento e app in background, perché la riproduzione è la stessa.

### Il registro **[C]**

Due tabelle.

**`stations`**: una riga per stazione ascoltata, aggiornata a ogni ascolto.

| Colonna | Tipo | Note |
|---|---|---|
| `id` | testo, chiave | l'id di Radio Browser |
| `json` | testo | la `RadioStation` intera (`toJson`), con stream, coordinate e logo |

Serve per due motivi:
- **«tocca per volarci»** chiama `tuneTo` con la stazione salvata, senza rete e anche se la stazione è sparita dall'elenco di Radio Browser. Se lo stream non risponde più, il volo fallisce come sempre;
- **«viaggio più lungo»** usa le coordinate vere tramite `placeOf`.

**`listens`**: una riga per ascolto continuo.

| Colonna | Tipo | Note |
|---|---|---|
| `id` | int, chiave | |
| `stationId` | testo | rimanda a `stations` |
| `countryCode` | testo | ISO alpha-2, vuoto se sconosciuto; copiato per le query per paese |
| `startedAt` | data e ora, UTC | |
| `seconds` | int | aggiornato mentre suona |

Più un indice su `startedAt`.

### Scrittura

- **Inizio:** quando si entra in «suona» parte il conteggio in memoria. La riga nasce al primo aggiornamento, oppure alla fine se l'ascolto ha superato i 5 secondi.
- **Mentre suona:** ogni **30 secondi** si scrive il totale dei `seconds`. Se Android chiude l'app si perdono al massimo 30 secondi. Si scrive anche quando l'app va in background.
- **Fine:** quando si esce da «suona» (pausa, nuova stazione, buffering, fine) si scrive il valore finale e si chiude la riga. Un ritorno a «suona» apre una riga nuova.
- **Tempo:** si misura con un orologio monotono (`Stopwatch`), non con l'ora di sistema, così un cambio d'ora non sporca i dati.

### Principi del registro **[D]**

Davide teme i registri a eventi: un evento vero spezzato in sotto-eventi, alcuni persi, e aggregazioni da rattoppare. Per questo il registro **non registra eventi, ma fotografie**.

1. **Una riga per ascolto, sempre valida.** Nessuna riga «aperta» in attesa di chiusura: dopo una chiusura brusca resta l'ultimo valore scritto, corretto e solo più corto. Niente da riparare.
2. **Si scrive il totale, non l'incremento:** `seconds = 120`, mai `seconds += 30`. Ripetere o saltare una scrittura non cambia il risultato.
3. **Stazione e primo ascolto in una sola transazione:** o entrambi, o nessuno.
4. **Nessuna tabella di totali, nessun lavoro di aggregazione.** Tutto si calcola alla lettura con una query (`SUM … GROUP BY`): nessun riepilogo può andare fuori sincrono.
5. **La logica decide in memoria, il database conserva.** Una macchina a stati pura (`ListenTracker`) decide inizio, aggiornamento e fine di un ascolto ed è testata senza database. Al database arrivano solo fotografie complete.
6. **Niente righe di rumore:** un ascolto si salva solo da **5 secondi** in su, al primo aggiornamento o alla fine. Girare la manopola non riempie il registro.
7. **Schema versionato dal primo giorno**, con lo schema della versione 1 salvato nel repo per i test di migrazione futuri.

### Dove vive **[C]**

- Una feature nuova, `lib/features/diary/`:
  - un `ListenRecorder` in `application/` ascolta `radioControllerProvider` e scrive nel registro;
  - un `DiaryRepository` in `data/` sopra Drift;
  - le query in `data/`.
- Il recorder parte con l'app, come `radioNotificationProvider`. Non tocca il controller della radio: legge soltanto lo stato.

### Pulizia **[C]**

Nessuna. Anche con ascolti quotidiani sono poche migliaia di righe l'anno.

## Cosa si mostra

### Apertura e chiusura **[D]**

- **Apertura:** si tocca **lo schermo della radio**, che ha nell'angolo l'etichetta discreta **«DIARIO ›»**. Lo schermo verde si stacca dalla radio e si allarga a tutta pagina (`Hero`, come il passaggio del benvenuto).
  - Si apre dallo schermo intero, non solo dalla mappa, perché su schermi bassi o con testo grande la radio nasconde la mappa (`compact`), mentre lo schermo e l'etichetta ci sono sempre **[C]**.
  - Il tocco lungo sul titolo della canzone, che oggi la copia, resta com'è.
- **Chiusura:** con Indietro torna dentro la radio, mentre la musica continua.
- **Riduzione del movimento attiva:** cambio di pagina semplice.

### La pagina **[D]**

È lo schermo della radio, ingrandito: stessi verdi, stessi caratteri, stessa mappa a puntini.

```
┌───────────────────────────────┐
│ ‹  DIARIO DI VIAGGIO          │
│ [7 giorni][30 giorni][Anno][Sempre]
│                               │
│   mappamondo a puntini:       │
│   più ascolto → più acceso    │
│                               │
│   23 paesi · 41 h · 187 radio │
│   e altri 40 di passaggio     │
│                               │
│ PIÙ ASCOLTATA                 │
│ Radio Paraíso · Brasile · 6 h │  ▶ tocca per volarci
│                               │
│ PAESI                         │
│ Brasile   ██████████  9 h     │
│ Germania  ██████      5 h     │
│                               │
│ Viaggio più lungo: 18.400 km  │
└───────────────────────────────┘
```

- **Periodo:** 7 giorni, 30 giorni, anno (gli ultimi 365 giorni), sempre. Preselezionato: 30 giorni **[C]**. Mappa, numeri e classifiche seguono il periodo.
- **Mappa:**
  - ogni puntino ha il colore del suo paese. **Fermato:** sopra la soglia, quattro intensità crescenti dell'inchiostro dello schermo, per quartili del tempo tra i paesi accesi. **Di passaggio:** ascoltato ma sotto la soglia, appena acceso. **Mai ascoltato:** spento;
  - toccando un paese compare una scheda con il nome, il tempo e le sue stazioni, ognuna toccabile per volarci **[C]**.
- **Numeri:**
  - **paesi in cui ti sei fermato**, ore di ascolto e stazioni diverse;
  - sotto, piccolo, «e altri N di passaggio».
- **Più ascoltata:** la stazione con più tempo nel periodo, con paese e tempo. Toccandola, la radio ci vola **[D]**.
- **Paesi:** classifica per tempo con una barra, i primi 10, poi «mostra tutti» **[C]**.
- **Viaggio più lungo:** la distanza massima **tra due ascolti consecutivi di stazioni diverse** nel periodo **[C]**.
  - Si calcola dal registro, in ordine di `startedAt`, con `placeOf` sulla stazione salvata. Quando la stazione non ha coordinate si usa il centroide del paese.
  - Restano fuori gli atterraggi senza ascolto e il primo tratto dall'Italia: il diario racconta gli ascolti, non i voli.
- **Diario vuoto:** la mappa spenta e una frase, «Il diario si riempie mentre ascolti: un paese si accende dopo 10 minuti».
- **Regola della soglia:** sempre spiegata in una riga, piccola, sotto la mappa.

### La soglia **[D]**

- **Minimo:** un paese conta come «fermato» con almeno **10 minuti** di ascolto nel periodo.
- **Periodi lunghi:** 10 minuti su un anno sono troppo poco, quindi la soglia sale con il periodo. Proposta: **il più grande tra 10 minuti e l'1% dell'ascolto totale nel periodo**.
- **Da tarare in implementazione con dati veri** **[D]**. La regola sta in un solo punto (`DiaryThreshold`) ed è coperta da test.

## La mappa per paese

- **Cosa serve:** la mappa a puntini (`worldDotRows`, una cella ogni 2,5°) oggi sa solo «terra o mare». Va saputo anche **di quale paese è ogni puntino**.
- **Lo script:** `tool/world_atlas/generate.py` legge già i confini di Natural Earth (admin-0 1:50m) per i centroidi. Ora scrive anche `worldDotCountries`, cioè per ogni cella di terra il codice del paese che contiene il suo centro **[C]**.
- **Celle di confine:** prendono il paese che contiene il centro della cella.
- **Paesi senza celle** (Malta, Singapore, Andorra, piccole isole): un puntino in più nel loro centroide, solo per il diario.
- **Il file generato cresce di qualche decina di KB:** accettabile.

## Vincoli

- Nessuna dipendenza di rete nuova. Drift e i suoi generatori sono l'unica dipendenza aggiunta **[C]**.
- **Privacy:** tutto resta sul telefono. La privacy policy aggiunge una riga: «gli ascolti restano sul telefono per il diario di viaggio».
- Dati e migrazioni Drift con versioni esplicite e test di migrazione dalla prima versione.
- Accessibilità:
  - mappa con un'etichetta riassuntiva («23 paesi, il più ascoltato è il Brasile»);
  - classifica leggibile;
  - periodi come pulsanti selezionabili.
- Tema chiaro e scuro, italiano e inglese.

## Ordine di costruzione **[C]**

1. **Prima registro e recorder**, anche in un rilascio da soli: il diario parte vuoto, quindi prima si comincia a registrare, più sarà pieno quando arriva la pagina.
2. **Poi** mappa per paese e pagina.

## Lasciato a chi costruisce

- La forma esatta delle query, mantenendo la logica pura testabile senza database dove si può.
- Il layout preciso della pagina dentro lo stile dello schermo.
- La scheda del paese toccato: un foglio dal basso o un riquadro sulla mappa.
- Come rendere toccabili i paesi sulla mappa: dal puntino più vicino al tocco.
