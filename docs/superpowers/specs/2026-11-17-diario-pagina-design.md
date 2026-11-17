# Diario di viaggio, parte 2: la pagina e la barra — design

Data: 17 novembre 2026. Stato: **tavole approvate da Davide**, design da confermare. Branch `feat/diario-pagina`, sopra `feat/diario-registro`.

Mock-up: https://claude.ai/artifact/HUKaij9foXqCQnQyxvqbUQ, riga «La direzione scelta».

Parte dal design generale `2026-11-16-diario-di-viaggio-design.md` («Cosa si mostra», «La soglia», «La mappa per paese»). Dove questo documento dice altro, vale questo.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Il diario restituisce dove ti sei fermato ad ascoltare. Si guarda per un minuto, anche mentre la radio suona: per questo ha una barra del player sotto **[D]**. La mappa ha la priorità **[D]**.

## Approcci

Tre direzioni disegnate:
- **A, schermo ingrandito:** tutta la pagina è lo schermo verde.
- **B, quaderno:** carta chiara, con la mappa in uno schermo.
- **C, mappa prima di tutto:** mappa grande, scheda del paese dal basso, barra a pillola.

**Scelta: la linea di C con la logica di A** **[D]**. La mappa è in alto e grande; sotto ci sono la più ascoltata e la classifica; un tocco su un paese apre la sua scheda.

## La navigazione

- **La radio è sempre la base** **[D]**. Il diario si apre sopra di lei e non c'è mai più di una pagina sopra la radio. Nessun giro impila pagine.
- **Apertura:** si tocca l'etichetta «DIARIO ›» nell'angolo dello schermo della radio, oppure lo schermo fuori dalla riga del titolo. Il tocco sul titolo salva la canzone e la pressione lunga la copia, come oggi.
- **Il diario è un pannello con una fine** **[D]**: angoli in basso arrotondati. Sotto, su una striscia del colore della scocca, sta la barra, a parte.
- **Animazione d'apertura** **[C]**: il pannello si allarga dal rettangolo dello schermo della radio a tutta la pagina, poi la barra sale dal basso.
  - Non è un `Hero`: tutta la radio sta già dentro `RadioCabinetHero` (il passaggio del benvenuto), e Flutter non permette un `Hero` dentro un altro.
  - Si fa con una route a transizione propria, che legge il rettangolo dello schermo da una chiave globale.
- **Chiusura**, con il tocco sulla barra o con Indietro **[D]**: la barra scende e il pannello rientra nello schermo della radio. È la stessa animazione al contrario.
- **Riduzione del movimento attiva:** dissolvenza semplice, senza crescita.
- **Il modello è quello di Spotify** **[D]**: la barra è il player piccolo, la radio è il player grande. Toccare la barra vuol dire «torna al player».

## La pagina

Da cima a fondo, come nella tavola «Diario · la pagina»:

1. **Intestazione:**
   - tasto Indietro;
   - «DIARIO DI VIAGGIO», maiuscolo spaziato;
   - a destra, «23 paesi · 41 h» in carattere monospaziato.
2. **Periodi:** pillole selezionabili, 7 giorni, 30 giorni, Anno, Sempre.
   - All'apertura il periodo è sempre 30 giorni: non si ricorda la scelta precedente **[C]**.
3. **Mappa,** ferma nella metà alta del pannello **[D]**:
   - **si ingrandisce col pizzico e si sposta col dito** **[D]**, con i tasti + e − per chi non può usare due dita **[C]**;
   - ingrandimento da 1× a 6×, sempre dentro i bordi del mondo **[C]**;
   - **un tocco sceglie il paese del puntino più vicino** entro un raggio. Il paese scelto si colora con l'accento e si apre la sua scheda;
   - una pillola «Tocca un paese» resta finché il paese non è stato toccato almeno una volta in quell'apertura **[C]**;
   - **la riga che spiegava la soglia sparisce** **[D]**: ora la spiega la scheda.
4. **Sotto la mappa scorre l'elenco** **[D]**:
   - la più ascoltata, con «Volaci»;
   - la classifica dei paesi, i primi 10 e poi «Mostra tutti»;
   - il viaggio più lungo.

   Scorre solo questa parte. La mappa non scorre via, così il dito non deve scegliere tra spostare la mappa e scorrere la pagina **[D]**.
5. **Diario vuoto:** la mappa è tutta spenta e al posto dell'elenco compare una frase: «Il diario si riempie mentre ascolti: un paese si accende dopo 5 minuti».

### I colori della mappa

Ogni puntino prende il colore del suo paese:
- **mai ascoltato:** quasi spento;
- **di passaggio**, ascoltato ma sotto la soglia: appena acceso **[D]**;
- **fermato**, sopra la soglia: quattro intensità crescenti dell'inchiostro dello schermo, per quartili del tempo tra i paesi fermati;
- **scelto:** il colore d'accento chiaro (`#F0A47E` sullo schermo).

### La soglia **[D]**

- **5 minuti,** non più 10.
- Sui periodi lunghi sale: è il più grande tra 5 minuti e l'1% dell'ascolto totale del periodo, come nel design generale.
- La regola sta in un solo punto (`DiaryThreshold`) e va tarata con i dati veri.

## La scheda del paese

Sale dal basso **dentro il pannello del diario e non copre la barra**, che resta sempre visibile **[C]**. Si chiude trascinandola giù, con Indietro o toccando la mappa. I casi sono tre:

| Caso | Quando | Cosa mostra |
|---|---|---|
| **Fermato** | tempo ≥ soglia | codice e nome del paese, tempo e numero di radio; le stazioni sentite, dalla più ascoltata, ognuna con la regione se c'è, il tempo e «Volaci»: nel registro la città non c'è; l'ultimo ascolto |
| **Di passaggio** | 0 < tempo < soglia | «Qui solo N minuti: un paese si accende dopo 5 minuti di ascolto»; le stazioni sentite con «Volaci» |
| **Mai ascoltato** | nessun ascolto nel periodo | «Non sei ancora passato di qui»; il tasto «Vola in <paese>», che pesca una stazione a caso in quel paese |

- **«Volaci»** chiama `tuneTo` con la stazione salvata nel registro, così funziona anche senza rete fino all'aereo. **«Vola in <paese>»** chiama `tuneRandom(countries: {codice})`.
- In entrambi i casi **la scheda si chiude e si resta nel diario**: il volo si vede nella barra **[D]**.
- Il testo «di passaggio» usa la soglia del periodo, non sempre 5. Su «Anno» potrebbe dire 25 minuti.
- Un paese senza stazioni in Radio Browser: il volo fallisce come sempre, e la barra mostra «Nessun segnale».

## La barra, `RadioBar`

Un componente a sé in `lib/ui/` o nella feature radio, usato da ogni pagina che si apre sopra la radio, oggi solo il diario **[C]**. Non conosce il diario.

Il contenuto è una pillola verde:
- a sinistra, «stazione · paese» e sotto il titolo della canzone. Tutta questa zona è il tocco «torna alla radio»;
- poi i tasti: cuore, segnalibro, play/pausa;
- **niente avanti né indietro:** quelli sono della radio **[D]**.

| Stato della radio | Testo | Cuore | Segnalibro | Tasto principale |
|---|---|---|---|---|
| spenta | — | — | — | la barra non c'è |
| in volo | «In volo…» / SINTONIZZAZIONE | no | no | pausa, disattivato |
| in onda | stazione · paese / titolo | sì | solo se c'è un titolo | pausa |
| in pausa | stazione · paese / titolo | sì | solo se c'è un titolo | play |
| fallito | «Nessun segnale» / «Il volo non è riuscito» | no | no | riprova |

- **Lo stato della barra non si inventa nulla.** È una funzione pura della `RadioSession` e di ciò che la radio già mostra (`RadioDisplay`): il tasto principale fa esattamente quello che fa il tasto play della radio, e «riprova» è il suo comportamento nello stato fallito.
- **Cuore e segnalibro** usano gli stessi controller e gli stessi avvisi della radio: `favoritesProvider.toggle` e `saveSong`. Gli avvisi compaiono sopra la barra.

## Le macchine a stati

La regola dello starter distingue i flussi dai valori letti. Qui:

- **I flussi veri sono già macchine a stati esplicite:** la radio (`RadioSession` / `next`) e il registro (`Listening` / `nextListening`). La pagina non ne aggiunge di nascoste.
- **Valori derivati, come tipi sealed calcolati da funzioni pure,** con test a tabella **[C]**:
  - `DiarySummary`, `empty` | `filled`: il riassunto del periodo, cioè paesi con tempo e stazioni, totali, la più ascoltata, il viaggio più lungo, chi è fermato e chi è di passaggio;
  - `CountryCard`, `stopped` | `passing` | `unvisited`: il caso della scheda di un paese;
  - `RadioBarState`, `hidden` | `flying` | `onAir` | `paused` | `failed`: la barra, dalla `RadioSession`.
- **Il riassunto si legge in modo asincrono:** un `AsyncValue` nell'application, per periodo, che si aggiorna quando il registro scrive.
- **Stato dell'interfaccia,** che resta nei widget: periodo scelto, paese scelto, ingrandimento della mappa. Non hanno nomi di prodotto e non sopravvivono alla pagina **[C]**.

## Dati

- **Registro:** `DiaryRepository.watchListensSince(DateTime? since)`, uno stream (Drift `watch`), dove `null` vuol dire «Sempre». Si legge solo il periodo; il calcolo è in memoria, nel domain. Con lo stream, la pagina aperta si aggiorna da sola quando il registratore scrive **[C]**.
- **Periodi:** 7 giorni, 30 giorni, 365 giorni («Anno»), Sempre. Contano gli ascolti iniziati nel periodo.
- **La mappa per paese,** dal generatore dell'atlante (`tool/world_atlas/generate.py`):
  - `worldDotCountries`: per ogni cella di terra, il codice del paese che contiene il suo centro;
  - `countryNames`: nome italiano e inglese da Natural Earth (`NAME_IT`, `NAME_EN`), anche per i paesi mai ascoltati **[C]**;
  - un puntino in più al centroide per i paesi senza celle (Malta, Singapore, piccole isole).
- **Nome del paese mostrato:** quello dell'atlante nella lingua dell'app; se manca, il `country` di Radio Browser.
- **Viaggio più lungo:** la distanza massima tra due ascolti consecutivi di stazioni diverse, con `placeOf` (coordinate della stazione o centroide del paese), come nel design generale.

## Statistiche anonime

Tre eventi nuovi **[C]**, con i valori chiusi delle regole delle statistiche:
- `diary_opened` (`period`);
- `diary_country_opened` (`country`, `kind`: `stopped|passing|unvisited`);
- `diary_flight` (`source`: `top_station|country_station|random_in_country`).

Il volo stesso è già contato dagli eventi della radio. L'informativa li aggiunge all'elenco.

## Accessibilità

- **La mappa** ha un'etichetta riassuntiva («23 paesi, il più ascoltato è il Brasile»), e la classifica sotto è leggibile. Chi usa il lettore dello schermo arriva a ogni paese dalla classifica, che apre la stessa scheda **[C]**.
- **Tasti:** + e − per lo zoom; tutti i tasti della barra hanno un'etichetta; la scheda è un dialogo con il suo titolo.
- **Testo grande:** l'elenco scorre; la mappa si accorcia fino a un minimo **[C]**.

## Fuori da questo passo

- La collezione delle cartoline: la scheda del paese diventerà la sua cartolina.
- Il riepilogo annuale.
- Il salvataggio del periodo scelto.

## Lasciato a chi costruisce

- La transizione d'apertura: route, chiave globale dello schermo, durata (quella di `AppMotion`).
- Il raggio del tocco sulla mappa e la scelta del puntino più vicino.
- Dove vive `RadioBar`: `lib/ui/` se resta senza logica di prodotto, la feature radio se legge i provider.
- La forma della query per periodo.
