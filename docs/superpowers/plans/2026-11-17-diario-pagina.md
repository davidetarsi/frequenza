# Diario di viaggio, parte 2: la pagina e la barra — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** dalla radio si apre il diario: mappa per paese che si ingrandisce, classifica, scheda del paese in tre casi, e sotto la barra del player.

**Architecture:**
- l'atlante impara di quale paese è ogni puntino e come si chiamano i paesi;
- nel domain del diario, funzioni pure calcolano tipi sealed: `DiarySummary`, `CountryCard`;
- `RadioBarState`, sealed nella feature radio, deriva da `RadioSession`;
- la pagina legge il riassunto come `AsyncValue` da uno stream del registro;
- una route con transizione propria apre il diario dal rettangolo dello schermo della radio.

**Tech Stack:** Flutter 3.38.5, Riverpod (generatore), Freezed, Drift 2.28 (`watch`), `InteractiveViewer`, Python 3 per l'atlante.

**Spec:** `docs/superpowers/specs/2026-11-17-diario-pagina-design.md` (con `2026-11-16-diario-di-viaggio-design.md` per ciò che non cambia). Mock-up: https://claude.ai/artifact/HUKaij9foXqCQnQyxvqbUQ.

**Base:** branch `feat/diario-pagina`, sopra `feat/diario-registro`.

## Global Constraints

- **Macchine a stati e tipi sealed:** ogni stato con un nome di prodotto è un sealed Freezed nel domain, calcolato da funzioni pure, con test a tabella. Nessuna logica di prodotto nei widget.
- **Soglia:** `DiaryThreshold.of(totalSeconds)` = il più grande tra **300 s** e l'**1 %** del totale del periodo.
- **Periodi:** `DiaryPeriod { week (7 d), month (30 d), year (365 d), always }`. All'apertura c'è sempre `month`. Contano gli ascolti con `startedAt` nel periodo.
- **Intensità della mappa:** 4 livelli per quartili del tempo tra i paesi fermati. Gli altri casi: di passaggio, mai ascoltato, scelto.
- **Colori sullo schermo:**
  - inchiostro `#E4EBC5`;
  - schermo `#203C33`;
  - accento sullo schermo `#F0A47E`;
  - opacità dei puntini `0.16` (spento), `0.38` (passaggio), `0.55 / 0.7 / 0.85 / 1.0` (livelli). Vanno in `TravelRadioDesign`, non scritti nei widget.
- **Navigazione:** mai più di una pagina sopra la radio. La barra e Indietro chiudono il diario con `Navigator.pop`. Niente `Hero`, perché la radio è già dentro `RadioCabinetHero`.
- **Barra:**
  - niente avanti né indietro;
  - tasto principale = tasto play della radio (`RadioDisplay.playKeyOn` / `playKeyEnabled`);
  - in `Failed` o `OnAir(broken)`, «riprova» = `tuneRandom()`.
- **Eventi anonimi:** `diary_opened` (`period`: `week|month|year|always`), `diary_country_opened` (`country`, `kind`: `stopped|passing|unvisited`), `diary_flight` (`source`: `top_station|country_station|random_in_country`).
- **Testi IT/EN:** chiavi nuove in `assets/translations/{it,en}.json`, poi `bash tool/generate_l10n.sh`. Nessuna stringa nel codice.
- **Verifica di fine task:** `bash tool/check.sh`; l'ultimo con `--apk`, poi `rm -rf build/unit_test_assets` prima di rilanciare i test.

## Review Focus

1. **Tocco sulla mappa ingrandita:** il tocco sceglie il paese sotto il dito anche a 6× e dopo uno spostamento. Le coordinate vanno trasformate con la matrice dell'`InteractiveViewer`. Test nel Task 4.
2. **Periodo senza ascolti, o registro vuoto:** `DiarySummary.empty`, la mappa spenta, nessuna divisione per zero nei quartili o nell'1%. Test nel Task 2.
3. **Radio che cambia stato mentre il diario è aperto** (volo da «Volaci», pausa dalle cuffie, fallimento): la barra segue senza riaprire niente. Indietro torna sempre alla radio, mai a un altro diario. Test nei Task 3 e 5.
4. **Paese senza celle sulla mappa** (Malta, Singapore) e **stazione con paese vuoto:** il primo ha il suo puntino al centroide; la seconda non accende niente e finisce nei totali sotto «Paese sconosciuto». Test nei Task 1 e 2.
5. **Testo grande e schermi bassi:** la mappa si accorcia fino a 180 px e l'elenco scorre. La barra non si sovrappone alla scheda. Test nel Task 4.

---

### Task 1: l'atlante sa di chi è ogni puntino

**Files:**
- Modify: `tool/world_atlas/generate.py`, `lib/features/journey/data/world_atlas.g.dart` (rigenerato con `bash tool/world_atlas/generate.sh`)
- Test: `tool/test_world_atlas.py`, `test/features/journey/world_atlas_test.dart`

**Interfaces:**
- Produces, in `world_atlas.g.dart`:
  - `const worldDotCountries = <String>[…]`, una stringa per riga, parallela a `worldDotRows`: per ogni cella, due lettere del paese, oppure `'..'` per il mare;
  - `const extraCountryDots = <String, (double, double)>{…}`, per i paesi senza celle: (lat, lon) del centroide;
  - `const countryNames = <String, (String, String)>{…}`, codice → (italiano, inglese).

- [ ] **Step 1: test che falliscono.**
  - **Python:** `generate.py` espone le funzioni pure `dot_country(lon, lat, countries)` e `names(feature)`. I test:
    - un punto a Brasilia dà `BR`;
    - un punto in mare dà `None`;
    - `names` di una feature con `NAME_IT: 'Germania'`, `NAME_EN: 'Germany'` dà la coppia.
  - **Dart:**
    - `worldDotCountries` ha le stesse righe e lunghezze di `worldDotRows`;
    - ogni cella `'1'` ha un codice;
    - la cella di Brasilia è `BR`;
    - `extraCountryDots` contiene `MT` e `SG`;
    - `countryNames['DE']` è `('Germania', 'Germany')`.
- [ ] **Step 2:** eseguire `python3 -m unittest discover -s tool -p 'test_world_atlas.py'` e `flutter test test/features/journey/world_atlas_test.dart`. Expected: FAIL.
- [ ] **Step 3:** estendere `generate.py`, poi lanciare `bash tool/world_atlas/generate.sh`.
  - Le celle di confine prendono il paese che contiene il centro.
  - Il codice viene da `ISO_A2`, oppure da `ISO_A2_EH` quando vale `-99` (Francia, Norvegia).
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde. Il file generato cresce di qualche decina di KB.
- [ ] **Step 5:** commit `feat(atlante): di quale paese è ogni puntino, e i nomi dei paesi`.

### Task 2: il riassunto del diario, puro

**Files:**
- Create:
  - `lib/features/diary/domain/diary_period.dart`
  - `lib/features/diary/domain/diary_summary.dart` (sealed `DiarySummary`, `CountryCard`, `DiaryThreshold`, `summarize`, `cardFor`)
  - `lib/features/diary/application/diary_summary_provider.dart`
- Modify: `lib/features/diary/domain/diary_repository.dart`, `lib/features/diary/data/drift_diary_repository.dart` (`watchListensSince`)
- Test: `test/features/diary/diary_summary_test.dart`, `test/features/diary/diary_repository_test.dart`

**Interfaces:**
- `enum DiaryPeriod { week, month, year, always }` con `DateTime? since(DateTime now)`.
- `Stream<List<Listen>> watchListensSince(DateTime? since)` nel contratto e in Drift.
- `DiarySummary summarize(List<Listen> listens, Map<String, RadioStation> stations)`:
  - `DiarySummary.empty()`;
  - `DiarySummary.filled({required List<CountryTime> countries, required int totalSeconds, required int stationCount, required StationTime top, required int thresholdSeconds, required double? longestTripKm})`;
  - `CountryTime {code, seconds, stations: List<StationTime>, lastListen, level}`, dove `level` vale 0 per di passaggio e 1–4 per fermato;
  - `StationTime {station, seconds}`;
  - `countries` è ordinata per tempo.
- `CountryCard cardFor(DiarySummary summary, String code)` restituisce uno di tre casi:
  - `stopped(CountryTime)`;
  - `passing(CountryTime, thresholdSeconds)`;
  - `unvisited(code)`.
- `@riverpod Stream<DiarySummary> diarySummary(Ref ref, DiaryPeriod period)`.

- [ ] **Step 1:** test a tabella.
  - **Soglia:**
    - totale 0 → 300;
    - 41 h → 1476 (1%);
    - 5 h → 300.
  - **Riassunto:**
    - nessun ascolto → `empty`;
    - un ascolto di 10 minuti in BR → fermato, livello 4, `top` = quella stazione;
    - BR 9 h, DE 5 h, JP 4 h, PT 3 h → livelli per quartili 4, 3, 2, 1;
    - CL 3 min con soglia 300 → livello 0, conta tra i passaggi;
    - una stazione con `countryCode` vuoto → nei totali ma non in `countries`.
  - **Viaggio più lungo:**
    - due ascolti consecutivi Roma → Rio ≈ 9.200 km (± 100);
    - stessa stazione due volte di fila → nessun tratto;
    - un ascolto solo → `null`.
  - **Scheda:** `cardFor` per BR, CL e MN dà i tre casi.
  - **Repository:**
    - `watchListensSince(since)` emette solo gli ascolti con `startedAt >= since`;
    - dopo un `setSeconds` emette di nuovo.
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare. Le distanze usano `placeOf` e la stessa formula della rotta.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(diario): il riassunto del periodo, puro e testato`.

### Task 3: la barra del player

**Files:**
- Create: `lib/features/radio/domain/radio_bar_state.dart`, `lib/features/radio/presentation/radio_bar.dart`
- Modify: `assets/translations/{it,en}.json` (chiavi `barFlying`, `barConnecting`, `barNoSignal`, `barFlightFailed`, `barBackToRadio`, `retry` se manca)
- Test: `test/features/radio/radio_bar_state_test.dart`, `test/features/radio/radio_bar_test.dart`

**Interfaces:**
- `RadioBarState radioBarOf(RadioSession session)` restituisce:
  - `hidden()` per `Off`;
  - `flying()` per `Flying`;
  - `onAir(station, track, playing, connecting)` per `OnAir` playing, buffering, paused ed ended;
  - `failed()` per `Failed` e `OnAir(broken)`.
- `class RadioBar extends ConsumerWidget { const RadioBar({required VoidCallback onBackToRadio}); }` legge `radioControllerProvider`, `favoritesProvider` e `savedSongsProvider`.
  - Il tasto principale usa `RadioDisplay.of(session)`.
  - Il segnalibro è `SongBookmark` / `saveSong`, il cuore è `favoritesProvider.toggle`.
  - In `hidden` restituisce `SizedBox.shrink()`.

- [ ] **Step 1:** test.
  - **`radioBarOf`:** tabella con tutti gli stati della radio.
  - **Widget:**
    - in onda con titolo → cuore, segnalibro e pausa; il tocco su pausa chiama `pause`;
    - senza titolo → niente segnalibro;
    - in pausa → play chiama `play`;
    - in volo → niente cuore né segnalibro, tasto disattivato;
    - fallito → «Nessun segnale», e riprova chiama `tuneRandom`;
    - il tocco sul testo chiama `onBackToRadio`;
    - il cuore salva nei preferiti, il segnalibro salva la canzone;
    - tutte le etichette sono presenti per il lettore dello schermo.
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare: pillola verde, tasti da 44 px, colori da `TravelRadioDesign`.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(radio): la barra del player per le pagine sopra la radio`.

### Task 4: la pagina del diario e la mappa

**Files:**
- Create:
  - `lib/features/diary/presentation/diary_page.dart` (pannello, intestazione, periodi, elenco)
  - `lib/features/diary/presentation/diary_map.dart` (`InteractiveViewer` + painter + tocco)
  - `lib/features/diary/presentation/diary_route.dart` (transizione)
- Modify:
  - `lib/features/radio/presentation/radio_cabinet.dart` (etichetta «DIARIO ›» e tocco sullo schermo fuori dalla riga del titolo; chiave globale sullo schermo)
  - `lib/features/radio/presentation/radio_page.dart`
  - `lib/ui/theme/travel_radio_design.dart` (colori e opacità del diario)
  - traduzioni
- Test: `test/features/diary/diary_page_test.dart`, `test/features/diary/diary_map_test.dart`

**Interfaces:**
- `Future<void> openDiary(BuildContext context, GlobalKey screenKey)` apre la route: il pannello cresce dal rettangolo di `screenKey`, la barra sale dopo; con la riduzione del movimento è solo una dissolvenza.
- `String? countryAt(Offset local, Size mapSize, Matrix4 transform)`: il paese del puntino più vicino entro 1,5 celle, `null` se non ce n'è.

- [ ] **Step 1:** test.
  - **Apertura e chiusura:**
    - toccando «DIARIO ›» si apre il diario;
    - toccando il titolo della canzone non si apre (salva la canzone);
    - Indietro e il tocco sulla barra tornano alla radio, e dopo c'è una sola route;
    - riaprire e richiudere tre volte lascia una sola route.
  - **Pagina:**
    - con un registro finto (BR 9 h, DE 5 h, CL 3 min) mostra «2 paesi · 14 h», la più ascoltata e la classifica nell'ordine giusto;
    - il cambio di periodo ricalcola;
    - con il registro vuoto c'è la frase del diario vuoto;
    - l'etichetta della mappa per il lettore dello schermo dice «2 paesi, il più ascoltato è il Brasile».
  - **Mappa:**
    - `countryAt` al centro di Brasilia a 1× dà `BR`; dopo uno zoom 4× e uno spostamento dà ancora `BR`; nell'oceano dà `null`;
    - il tasto + ingrandisce;
    - un tocco su BR apre la scheda (Task 5: qui basta un callback).
  - **Testo grande (2×) su un telefono basso (360×640):** nessun overflow, la mappa è almeno 180 px, l'elenco scorre.
  - **Evento:** all'apertura parte `diary_opened` con `period: month`.
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare, seguendo la tavola «Diario · la pagina».
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(diario): la pagina con la mappa che si ingrandisce`.

### Task 5: la scheda del paese, i voli e i testi

**Files:**
- Create: `lib/features/diary/presentation/country_sheet.dart`
- Modify:
  - `lib/features/analytics/domain/app_event.dart` (tre eventi)
  - `docs/privacy.html` (IT/EN, elenco degli eventi)
  - `docs/status.md`
  - traduzioni
- Test: `test/features/diary/country_sheet_test.dart`, `test/features/analytics/app_event_test.dart`

**Interfaces:**
- `Future<void> showCountrySheet(BuildContext context, CountryCard card)`: la scheda sale dentro il pannello del diario, sopra la barra.
- `AppEvent.diaryOpened(DiaryPeriod)`, `AppEvent.diaryCountryOpened(String code, CountryCard card)`, `AppEvent.diaryFlight(DiaryFlightSource)`.

- [ ] **Step 1:** test.
  - **Fermato (BR):**
    - mostra nome, «9 h · 3 radio», stazioni in ordine e ultimo ascolto;
    - «Volaci» chiama `tuneTo(station)`, chiude la scheda e resta nel diario;
    - la barra passa a «In volo…».
  - **Di passaggio (CL, 3 min):** il testo con «3 minuti» e la soglia del periodo, la stazione con «Volaci».
  - **Mai ascoltato (MN):**
    - «Non sei ancora passato di qui»;
    - «Vola in Mongolia» chiama `tuneRandom(countries: {'MN'})`.
  - **Altro:**
    - la barra resta visibile con la scheda aperta;
    - Indietro chiude prima la scheda, poi il diario;
    - gli eventi `diary_country_opened` e `diary_flight` hanno i valori chiusi;
    - `app_event_test`: i tre eventi nel test «no event carries free text».
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare, seguendo le tre tavole delle schede. Informativa: «l'apertura del diario, il paese toccato, i voli partiti dal diario».
- [ ] **Step 4:** `bash tool/check.sh --apk`, poi `rm -rf build/unit_test_assets`. Expected: verde e APK costruita.
- [ ] **Step 5:** `docs/status.md`, con piano attivo e prove sul telefono. Commit `feat(diario): la scheda del paese e i voli dal diario`.
