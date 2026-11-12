# Rotta sul mondo — design

Data: 12 novembre 2026. Stato: in revisione da Davide.
Mock-up di riferimento (tavola «2 · Rotta sul mondo»): https://claude.ai/artifact/Ng6gtkvtxvPeBBGwhp6zkH

Legenda: **[D]** = deciso da Davide; **[C]** = scelta proposta da Claude, da confermare leggendo. Il resto è vincolo derivato dal codice attuale.

## Intento

Ogni sintonizzazione diventa un viaggio. Il display della radio mostra una mappa del mondo a puntini. Durante la ricerca parte un volo che non rivela la meta. Quando la stazione suona davvero, l'arco atterra sulla destinazione e il display mostra dove sei arrivato. È la prima delle «animazioni avanzate» rinviate in `docs/status.md`. Rafforza l'idea «Prossima fermata: ovunque» senza cambiare scocca, manopola o comandi.

## Obiettivi

- Volo e atterraggio animati sulla mappa, identici per la manopola (Tune) e per la scelta da Preferiti **[D]**.
- Sincronia reale: l'atterraggio coincide con l'inizio dell'audio della stazione, qualunque sia la durata del collegamento **[D]**.
- Informazioni di viaggio sul display: Paese, distanza del tratto, ora locale (quando affidabile), contatore viaggi, ultime rotte **[D]**.
- Gestione esplicita del segnale perso, oggi assente **[D]**.

## Non obiettivi

- Nessun cambiamento a scocca, manopola, altoparlante, pulsanti Pausa e Salva, impostazioni.
- Nessuna persistenza del diario di viaggio tra un avvio e l'altro: storico e contatore valgono per la sessione **[C]**. Un eventuale salvataggio (Drift) è un passo futuro.
- Nessun permesso di posizione.
- Nessuna mappa interattiva (zoom, tocchi sulla mappa).

## Anti-obiettivi

Questi casi rendono il lavoro sbagliato anche se l'app «funziona».

- L'animazione finisce e l'audio arriva dopo, oppure l'audio parte mentre è ancora in volo.
- Testo o linea che rivelano la meta prima dell'atterraggio («In volo verso Tokyo», arco che punta già nella direzione giusta) **[D]**.
- Silenzio durante il caricamento dello stream. Oggi c'è: il fruscio si ferma alla risposta dell'API.
- Un volo che può durare per sempre.
- Overflow o testo tagliato nei layout già verificati (320×640 e 640×320 con testo al 200%).

## Comportamento

### Punto di partenza **[D]**

- Primo viaggio della sessione, o radio spenta senza stazioni atterrate: si parte dall'**Italia**, usando il centro dell'Italia dalla stessa tabella del fallback per Paese **[C]**.
- Viaggi successivi: si parte dall'ultima stazione **atterrata con successo**. Un volo interrotto o fallito non sposta il punto di partenza.

### Sequenza unica per Tune e Preferiti **[D]**

1. **Avvio.** Il tocco sulla manopola, o su una stazione nel pannello Preferiti, avvia lo stesso flusso. Dai Preferiti il pannello si chiude e il collegamento parte subito al tocco, senza aspettare la fine dell'animazione di chiusura **[C]**. Questo sostituisce la scelta precedente «la scelta dai preferiti resta immediata».
2. **Fase 1, il volo (durata aperta).**
   - Dal punto di partenza esce una scia che «cerca» senza una direzione verso la meta, per esempio un impulso radar o un segnale che si allarga. La forma esatta è lasciata al builder, con il vincolo di non suggerire la direzione.
   - Il fruscio suona per tutta la fase.
   - Testi: «In volo verso…» con i puntini animati. Nessun nome, Paese o coordinate. Il sottotitolo sopra la radio diventa «Prossima fermata: …».
   - Durata: almeno 1 s, e comunque fino a quando il player è davvero in riproduzione (`PlaybackStatus.playing`, non la risposta dell'API).
3. **Fase 2, l'atterraggio (breve, circa 0,6 s).**
   - Parte quando sono vere entrambe le condizioni: è passato almeno 1 s **e** il player è in riproduzione.
   - L'arco si traccia dalla partenza alla destinazione, il punto di arrivo pulsa, il fruscio si ferma e l'audio della stazione entra.
   - Il nome entra con l'effetto «sfocato → a fuoco».
   - Vincolo: l'audio della stazione non deve essere udibile prima dell'inizio dell'atterraggio, anche se lo stream è pronto prima di 1 s. Il meccanismo (volume a zero fino all'atterraggio, ritardo del play, …) è lasciato al builder.
4. **In onda.** Il punto di arrivo pulsa piano. Sul display compaiono Paese, distanza del tratto e ora locale. La rotta appena fatta entra nello storico e il contatore aumenta.
5. **In pausa.** Come in onda, ma senza pulsazione **[C]**.

### Interruzioni

- Una nuova sintonizzazione durante il volo (per esempio un preferito scelto mentre la manopola sta cercando) annulla il volo in corso con il token già usato dal controller. Il nuovo volo riparte dallo stesso punto di partenza.
- Spegnimento (`stop`) durante il volo: scia e fruscio si fermano, la mappa torna allo stato spento.

### Segnale perso **[D]**

- **Tempo massimo:** 12 s dal tocco **[C]** sul valore. Vale anche se lo stream resta bloccato in caricamento: oggi non esiste un limite, c'è solo il timeout di 8 s per ogni chiamata all'API.
- **Animazione:** la scia si spegne e torna al punto di partenza. Il display mostra «Segnale perso» per un momento.
- **Tune:** riprova da sola con un'altra stazione casuale, con un nuovo volo dallo stesso punto di partenza. Al massimo 2 tentativi automatici **[C]**, poi stato di errore come oggi, con la manopola che riprova.
- **Preferito:** nessun nuovo tentativo, perché la meta l'ha scelta l'utente. Stato di errore. Ritoccare il preferito riprova.
- Gli errori immediati (API non raggiungibile, nessuna stazione, stream in errore) seguono la stessa regola, senza aspettare i 12 s.

### Riduzione del movimento

Con `AppMotion.enabled == false` niente volo animato e niente pulsazioni. In volo il display mostra i testi e la mappa ferma. All'atterraggio l'arco compare già disegnato. Il fruscio resta, perché è audio e non movimento **[C]**.

## Display

- La mappa prende il posto dell'equalizzatore a barre nella parte centrale del display **[C]**. Le barre rimangono solo dove la mappa non entra (vedi Layout).
- **Testi in onda:**
  - Riga principale: nome della stazione.
  - Riga Paese: «Paese · 1.420 km». La distanza è la lunghezza del **tratto** dalla partenza, non da casa tua, visto che dopo il primo viaggio la partenza è la stazione precedente **[C]**.
  - Riga di dettaglio esistente: titolo ICY o tag, invariata.
  - Riga di stato: stato attuale, più l'ora locale a destra quando disponibile.
- La città non è disponibile. Radio Browser fornisce Paese ed eventualmente regione (`state`), non la città. Si mostra il Paese **[C]**. Il mock-up mostrava città inventate.
- **Ora locale:** si mostra solo quando il fuso è determinabile in modo affidabile, cioè Paesi con un solo fuso oppure coordinate sufficienti a scegliere il fuso. Altrimenti si nasconde: meglio niente che un'ora sbagliata **[C]**. Il metodo (tabella Paese → fuso, eventuale pacchetto `timezone` per l'ora legale) è del builder. Una nuova dipendenza va motivata nel piano, come chiede `AGENTS.md`.
- **Storico:** le ultime 5 rotte atterrate come tracce tratteggiate tenui. Contatore «Viaggio n. X» sulla scocca accanto a «F / RADIO», come nel mock-up. Entrambi valgono per la sessione.
- **Accessibilità:** la mappa è decorativa (`ExcludeSemantics`). Tutte le informazioni sono anche nel testo.
- **Localizzazione:** nuove chiavi IT/EN per «In volo verso…», «Prossima fermata: …», «Segnale perso», distanza, ora locale e contatore. Le attuali `exploring` e `findingPlace` vanno sostituite se non servono più.

## Dati

- **Coordinate della stazione:**
  - `RadioStation` riceve `latitude` e `longitude` facoltative, lette da `geo_lat` e `geo_long` di Radio Browser.
  - Vanno validate: valori fuori intervallo o la coppia 0,0 contano come assenti **[C]**.
- **Fallback per Paese:**
  - Senza coordinate si usa il centro del Paese da una tabella ISO 3166 alpha-2 → lat/lon inclusa nell'app, senza rete.
  - Senza coordinate e senza codice Paese: atterraggio senza arco né punto. I testi compaiono comunque.
- **Preferiti:** il salvataggio aggiunge le coordinate facoltative allo stesso record `frequenza.favorites.v1`. I record esistenti senza coordinate restano validi e usano il fallback per Paese, che è sempre salvato. Nessuna migrazione.
- **Mappa:**
  - Proiezione equirettangolare, ritagliata circa tra 80° N e 60° S come nel mock-up.
  - Terre a puntini generate da un dataset a bassa risoluzione di pubblico dominio (es. Natural Earth 110m), pre-elaborato in un asset statico leggero. Niente tile né rete.
  - L'arco è una curva che si piega verso nord e non attraversa il bordo del Pacifico **[C]**.

## Vincoli dal codice attuale

- `RadioController.tuneRandom` oggi ferma il fruscio alla risposta dell'API, prima di `playStation`. `tuneTo` non ha né fruscio né minimo di 1 s. Entrambi devono convergere sul flusso unico descritto sopra.
- `JustAudioService.playStation` avvia la riproduzione senza attenderla e segnala `buffering → playing` dal `playerStateStream`. L'atterraggio si aggancia a questo stato, non al ritorno di `playStation`.
- Restano valide le garanzie già verificate: token di annullamento, sottoscrizioni chiuse alla dismissione, `clearError` a ogni nuova sintonizzazione, fruscio fermato in background.
- Restano verdi la suite esistente (20 test), l'analisi e la build. I layout compatto e orizzontale con testo al 200% non devono andare in overflow.

## Lasciato al builder

- La forma della scia «che cerca» in fase 1, nei limiti degli anti-obiettivi.
- Il meccanismo per tenere muta la stazione fino all'atterraggio.
- Come rimpicciolire o nascondere la mappa nei layout compatto e orizzontale (le barre possono restare lì), purché le informazioni testuali restino.
- La struttura del codice: stato del viaggio nel controller o in un provider dedicato, `CustomPainter` per mappa e arco, formato dell'asset dei puntini.
- Le curve e le durate esatte, entro «circa 0,6 s» per l'atterraggio.
- I test. Come minimo:
  - controller: minimo di 1 s; atterraggio solo a riproduzione avviata; fruscio attivo durante il caricamento; timeout con nuovi tentativi per Tune e stop per i Preferiti; annullamento da una nuova sintonizzazione;
  - dati: lettura delle coordinate e fallback; compatibilità dei preferiti v1 con e senza coordinate;
  - widget: riduzione del movimento e layout limite.
