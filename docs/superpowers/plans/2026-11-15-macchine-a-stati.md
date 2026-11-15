# Macchine a stati esplicite — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** la sessione radio diventa un tipo sealed nel dominio con transizioni pure, «in volo» ha una sola fonte, la schermata legge un `RadioDisplay`, e preferiti e tema condividono l'aiuto per il salvataggio.

**Architecture:** `Journey` + `RadioSession` + `RadioEvent` + `next()` in Dart puro (`lib/features/radio/domain/`). `RadioController` tiene una `RadioSession`: per ogni fatto (volo, atterraggio, stato audio, titolo) crea un evento, chiama `next()` ed esegue solo gli effetti (fruscio, stream, timer). Notifica, schermata e preferiti leggono la sessione.

**Tech Stack:** Flutter 3.38.5, Dart 3 sealed, Freezed 2.5, Riverpod 2.6 con annotazioni, easy_localization.

**Spec:** `docs/superpowers/specs/2026-11-15-macchine-a-stati-design.md`

## Global Constraints

- **Base:** `develop` dopo il merge di `fix/convenzioni-starter`, `feat/rifiniture-manopola`, `fix/radio-bloccata` e `docs/macchine-a-stati`. Il piano è scritto su quel codice: per esempio `errorMessage` non esiste più, `FlightTiming.stallTimeout` sì. Branch di lavoro: `refactor/macchine-a-stati`.
- **Comportamento visibile identico:** i test esistenti cambiano solo la sintassi, non cosa verificano (tabella in Task 3). Due eccezioni, decise qui:
  - la pagina di prova non raggiungibile viene cancellata (Task 3);
  - il test sul contratto interno di `showFlight` cambia (Task 4).
- **Dominio** in Dart puro, senza Flutter né Riverpod. `AsyncValue` resta in application.
- Nessuna dipendenza nuova.
- **Commit** in italiano, stile `refactor(radio): …`, con le righe di attribuzione della sessione.
- **Verifica di fine task:** `bash tool/check.sh` verde: format, analyze, test Python e Flutter.
- Per lanciare i comandi, mettere Flutter in testa al PATH: `export PATH=/srv/claude/workspaces/.tools/flutter-3.38.5/bin:$PATH`.

## Review Focus

1. **Nuova sintonia da una stazione in onda:** lo stop del vecchio stream non deve chiudere la notifica. Era il bug di PR #9, ora protetto solo dall'ordine «sessione `Flying` → bridge → stop». Test di integrazione in Task 4.
2. **Timer di stallo vecchio:** non deve dirottare un volo nuovo né riaccendere una radio spenta. Test in Task 3.
3. **Eventi audio del vecchio stream durante il volo** (idle, error, buffering): non cambiano `Flying`. Test in Task 1.
4. **Pausa di sistema in onda** (cuffie staccate): mette solo in pausa, non spegne. Test in Task 4.
5. **Ricostruzione del provider durante un salvataggio:** il risultato vecchio non sovrascrive quello nuovo. Test in Task 5.

---

### Task 1: Dominio — `Journey`, `RadioSession`, `RadioEvent`, `next()`

**Files:**
- Create: `lib/features/radio/domain/journey.dart`, `lib/features/radio/domain/radio_session.dart` (più i `.freezed.dart` generati)
- Test: `test/features/radio/journey_test.dart`, `test/features/radio/radio_session_test.dart`
- Modify: `AGENTS.md`, sezione «Convenzioni del template»: una riga con la regola sealed/`AsyncValue` della spec

**Interfaces:**
- Produces, in `journey.dart`:
  - `enum FlightKind { forward, back, reconnect }`
  - `@freezed class Journey`, con campi:
    - `StationPlace departure = homePlace`
    - `TravelLeg? leg`
    - `List<TravelLeg> history = []`
    - `int trips = 0`
    - `List<RadioStation> previous = []`
    - `RadioStation? landed`
  - `static const historyLength = 5`, `backStackLength = 10`
  - `bool get canGoBack`
  - `Journey leave({RadioStation? target})`
  - `Journey arrive(RadioStation station, FlightKind kind)`
  - `Journey switchOff()`
- Produces, in `radio_session.dart`:
  - `enum OnAirPlayback { playing, paused, buffering, ended, broken }`
  - `@freezed sealed class RadioSession`, con i casi:
    - `off(Journey journey) = Off`
    - `flying(Journey journey, {required FlightKind kind, @Default(0) int attempt, @Default(false) bool signalLost}) = Flying`
    - `onAir(Journey journey, RadioStation station, {required OnAirPlayback playback, String? trackTitle}) = OnAir`
    - `failed(Journey journey) = Failed`
  - `sealed class RadioEvent`, con le sottoclassi `final`:
    - `FlightStarted(FlightKind kind, {RadioStation? target})`
    - `AttemptFailed({required bool retrying})`
    - `RetryStarted()`
    - `Landed(RadioStation station, {required bool paused})`
    - `PlaybackChanged(PlaybackStatus status)`
    - `TrackChanged(String? title)`
    - `SwitchedOff()`
  - `RadioSession next(RadioSession session, RadioEvent event)`
  - `PlaybackStatus` arriva in Task 3 da `radio_audio_service.dart`. Fino ad allora si importa da `radio_player_state.dart`.

**Regole di `Journey`, prese dal controller attuale:**
- **`leave`:** se `landed != null` e `landed.id != target?.id`, mette `landed` in `previous` (massimo 10, si scartano i più vecchi) e azzera `landed`. Altrimenti `Journey` resta uguale.
- **`arrive` con `reconnect`:** cambia solo `landed = station`.
- **`arrive` negli altri casi:**
  - `leg = TravelLeg(from: departure, to: placeOf(station))`;
  - `departure` diventa `to`, se `to` esiste;
  - `history` aggiunge `leg` solo se `to` esiste, massimo 5;
  - `trips + 1`;
  - con `back` toglie l'ultimo di `previous`;
  - `landed = station`.
- **`switchOff`:** `leg = null`.

**Tabella di `next()`.** Va scritta come commento sopra la funzione: è la «tabella accanto al tipo» della spec.

| Da | Evento | A |
|---|---|---|
| qualsiasi | `FlightStarted(kind, target)` | `Flying(kind == forward ? journey.leave(target: target) : journey, kind: kind)` |
| `Flying` | `AttemptFailed(retrying: true)` | stesso volo, `signalLost: true` |
| `Flying` | `AttemptFailed(retrying: false)` | `Failed(journey)` |
| `Flying` | `RetryStarted` | `attempt + 1`, `signalLost: false` |
| `Flying` | `Landed(s, paused)` | `OnAir(journey.arrive(s, kind), s, playback: paused ? paused : playing)` |
| `OnAir` | `PlaybackChanged(st)` | stessa stazione, `playback` mappato, `trackTitle` invariato |
| `OnAir` | `TrackChanged(t)` | `trackTitle: t` |
| qualsiasi | `SwitchedOff` | `Off(journey.switchOff())` |
| ogni altra coppia | | `session` invariata (stessa istanza) |

Mappa di `PlaybackChanged`:

| `PlaybackStatus` | `OnAirPlayback` |
|---|---|
| `playing` | `playing` |
| `paused` | `paused` |
| `buffering` | `buffering` |
| `idle` | `ended` |
| `error` | `broken` |

`ended` e `broken` non sono nello schizzo della spec. Servono perché oggi una stazione in onda con stream finito o rotto resta mostrata con «Pronta» o «Riprova».

- [ ] **Step 1: Scrivere i test, tutti puri, nessun widget**
  - `journey_test.dart`:
    - «leaving stacks the station on air, at most 10»
    - «leaving towards the station on air keeps it»
    - «arriving records the leg, moves the departure and counts the trip»
    - «a place-less arrival keeps departure and history»
    - «arriving back pops the stack»
    - «a reconnect arrival only remembers the station»
    - «history keeps the last 5 legs»
    - «switching off clears the leg»
  - `radio_session_test.dart`: un test per riga della tabella, più questi casi del Review Focus:
    - «audio events from the old stream do not touch a flight»: `PlaybackChanged(idle)`, `(error)` e `(buffering)` su `Flying` restituiscono `same(session)`;
    - «a track title during a flight is dropped»;
    - «a new flight from on air clears station and title»;
    - «events on off or failed change nothing».

- [ ] **Step 2: Eseguire i test**

Run: `flutter test test/features/radio/journey_test.dart test/features/radio/radio_session_test.dart`
Expected: FAIL in compilazione, perché `Journey` e `RadioSession` non esistono.

- [ ] **Step 3: Implementare i due file e generare il codice**

Run: `dart run build_runner build --delete-conflicting-outputs`

Aggiungere la riga in `AGENTS.md`.

- [ ] **Step 4: Eseguire i test**

Stesso comando dello Step 2. Expected: PASS. Poi `bash tool/check.sh`: verde.

- [ ] **Step 5: Commit** `refactor(radio): sessione radio come tipo sealed con transizioni pure`

### Task 2: `RadioDisplay` — cosa mostra la radio, da una sessione

**Files:**
- Create: `lib/features/radio/presentation/radio_display.dart`
- Test: `test/features/radio/radio_display_test.dart`

**Interfaces:**
- Consumes: Task 1.
- Produces:
  - `sealed class DisplayText`, con:
    - `final class Translated(String key)`
    - `final class Verbatim(String text)`
  - `class RadioDisplay` con `factory RadioDisplay.of(RadioSession session)` e i campi:
    - `DisplayText title`, `country`
    - `String statusKey`, `knobKey`
    - `bool busy`, `flying`, `playing`, `knobEnabled`, `playKeyEnabled`, `playKeyOn`, `playKeyDown`, `saveEnabled`, `nextStopPending`
    - `FlightPhase phase`
    - `RadioStation? station`
    - `TravelLeg? leg`
    - `String? song`
  - Le chiavi sono costanti `LocaleKeys`: puro Dart, quindi testabile senza widget.
  - `FlightPhase` si sposta qui da `radio_player_state.dart` in Task 3. Fino ad allora si importa da lì.

**Valori.** Ricalcano i ternari di `radio_page.dart`.

| Campo | `Off` | `Flying` | `OnAir` | `Failed` |
|---|---|---|---|---|
| title | `whereTo` | `flyingTo`, o `signalLost` se `signalLost` | `Verbatim(station.name)` | `signalLost` |
| country | `worldAwaits` | `Verbatim('')` | `Verbatim(country)`, o `unknownCountry` se vuoto | `worldAwaits` |
| statusKey | `ready` | `searching` | per `playback`: `playing`, `paused`, `connecting` (buffering), `ready` (ended), `stationError` (broken) | `stationError` |
| knobKey | `powerOn` | `tuning` | `retry` se `broken`, altrimenti `tune` | `retry` |
| phase | grounded | `signalLost` se `signalLost`, altrimenti flying | grounded | signalLost |

Gli altri campi:
- **`busy`:** `Flying`, oppure `OnAir` con `buffering`.
- **`flying`:** `Flying` con `!signalLost`.
- **`playing`:** `OnAir` con `playing`.
- **`knobEnabled`:** `!Flying`.
- **`playKeyEnabled`:** `OnAir` e `!broken`.
- **`playKeyOn`:** `OnAir` con `playing` o `buffering`.
- **`playKeyDown`:** `OnAir` con `paused`.
- **`saveEnabled`:** `OnAir`.
- **`nextStopPending`:** `Flying`.
- **`station`, `leg`:** valorizzati solo in `OnAir`. `leg` è `journey.leg`.
- **`song`:** `trackTitle`, solo in `OnAir` con `playing` o `paused`.

- [ ] **Step 1: Scrivere i test**

Un test per colonna della tabella, più questi:
- «buffering on air keeps the controls but hides the song and the local time» (`busy` true, `knobEnabled` true, `playKeyOn` true, `song` null);
- «a broken stream on air offers retry and keeps the heart»;
- «a station without a country says so» (`Translated(unknownCountry)`).

- [ ] **Step 2: Eseguire il test**

Run: `flutter test test/features/radio/radio_display_test.dart`
Expected: FAIL in compilazione.

- [ ] **Step 3: Implementare `RadioDisplay.of`**

Un solo `switch` esaustivo su `session` che costruisce l'oggetto. Niente `default`, così un caso nuovo fa segnalare il compilatore.

- [ ] **Step 4: Eseguire il test**

Run: `flutter test test/features/radio/radio_display_test.dart`
Expected: PASS. Poi `bash tool/check.sh`: verde.

- [ ] **Step 5: Commit** `refactor(radio): RadioDisplay deriva i testi della radio dalla sessione`

### Task 3: Il controller usa `next()`; consumatori sulla sessione

**Files:**
- Modify:
  - `lib/features/radio/application/radio_controller.dart`: lo stato diventa `RadioSession`;
  - `lib/features/radio/domain/radio_audio_service.dart`: accoglie `enum PlaybackStatus { idle, buffering, playing, paused, error }`, senza `tuning`, che nessun motore emette;
  - `lib/features/radio/presentation/radio_page.dart`: legge `RadioDisplay`;
  - `lib/features/favorites/presentation/favorites_sheet.dart`;
  - `lib/features/radio/application/radio_notification.dart`;
  - `lib/features/journey/presentation/route_map.dart`: solo l'import di `FlightPhase`.
- Delete:
  - `lib/features/radio/domain/radio_player_state.dart` e il suo `.freezed.dart`;
  - `lib/features/radio/presentation/radio_proof_page.dart` e `test/features/radio/radio_proof_page_test.dart`;
  - le chiavi l10n usate solo dalla pagina di prova: `proof*`, `country*` tranne `unknownCountry`, `countrySelect`, `countryWorld`. Poi `tool/generate_l10n.sh`.
- Test:
  - `test/features/radio/radio_controller_test.dart`
  - `test/features/radio/radio_journey_page_test.dart`
  - `test/features/radio/radio_notification_test.dart`
  - `test/features/journey/route_map_test.dart`

**Interfaces:**
- Consumes: Task 1 e Task 2.
- Produces:
  - `RadioController extends _$RadioController` con `RadioSession build()`, che parte da `RadioSession.off(Journey())`;
  - metodi pubblici invariati: `tuneRandom`, `tuneTo`, `tuneBack`, `play`, `pause`, `stop`.
  - Task 4 usa `audio.systemPauses` al posto di `flightInterruptions`. In questo task resta il nome attuale.

**Cosa fa il controller:**
- Ogni cambio di stato è `state = next(state, evento)`. Non si scrive mai uno stato a mano.
- **Ascoltatori:**
  - lo stato audio diventa `PlaybackChanged`;
  - il titolo diventa `TrackChanged`;
  - `next()` ignora da solo gli eventi fuori da `OnAir`, quindi sparisce il blocco «`status != tuning`».
- **Voli:**
  - `_fly` invia `FlightStarted(kind, target)`, poi `RetryStarted` a ogni nuovo tentativo, `AttemptFailed(retrying: attempt < retries)` dopo un fallimento, `Landed(station, paused: currentStatus == paused)` all'atterraggio;
  - restano il token del volo (solo per annullare) e tutti gli effetti: fruscio, `playStation`, `land`, `stop`, attese, timeout.
- **`_landed` sparisce:** si legge `state.journey.landed`.
- **`tuneBack`:** se `journey.canGoBack`, vola su `previous.last` con `back`; altrimenti su `journey.landed` con `reconnect`; se non c'è nessuno dei due, non fa niente.
- **Stallo:** dopo ogni `PlaybackChanged`, il timer si azzera. Riparte se `state` è `OnAir` con `buffering`. Quando scade riconnette, ma solo se la sessione è ancora `OnAir` con `buffering` sulla stessa stazione.
- **`stop()`:** effetti come oggi, poi `SwitchedOff`.
- **`play()`:** solo in `OnAir`.

**Test esistenti, solo sintassi.** Aggiungere in `test/features/radio/radio_session_matchers.dart` dei matcher che leggono la sessione:

| Vecchia asserzione | Nuova |
|---|---|
| `status == tuning` | `isA<Flying>()` |
| `status == playing` / `paused` / `buffering` | `isA<OnAir>()` con quel `playback` |
| `status == error` con `station == null` | `isA<Failed>()` |
| `status == idle` dopo `stop` | `isA<Off>()` |
| `station` | `(state as OnAir).station`, o `null` fuori da `OnAir` |
| `flight == signalLost` | `Flying(signalLost: true)` oppure `Failed` |
| `previous`, `trips`, `leg`, `history`, `departure` | `state.journey.…` |

Nella pagina restano gli stessi testi e le stesse chiavi. I widget cambiano solo la fonte dei valori.

- [ ] **Step 1: Aggiungere il test del Review Focus 2 a `radio_controller_test.dart`**

«a stall timer left from the station on air does not hijack a new flight»:
- atterrare;
- emettere `buffering`;
- prima di `stallTimeout`, chiamare `tuneRandom()` verso un'altra stazione e atterrare;
- attendere oltre `stallTimeout`;
- `audioService.played` è esattamente `[a, b]`, senza un altro `a` da riconnessione. Lo stato è `OnAir` su `b`.

Aggiungere anche «a stall timer does not wake a radio switched off»: buffering, poi `stop()`, attesa oltre il timeout. Nessun nuovo `played`, stato `Off`.

- [ ] **Step 2: Eseguire i due test sul codice attuale**

Run: `flutter test test/features/radio/radio_controller_test.dart`
Expected: i due nuovi test passano già con il controller attuale. Fanno da rete per il refactor, quindi va annotato nel registro. Se uno fallisce, è un bug da correggere prima di procedere.

- [ ] **Step 3: Migrare i test esistenti alla sessione**

Usare la tabella sopra. Run: `flutter test test/features/radio/radio_controller_test.dart`
Expected: FAIL in compilazione, perché il controller espone ancora `RadioPlayerState`.

- [ ] **Step 4: Riscrivere il controller e adattare i consumatori**

Pagina, foglio dei preferiti, bridge della notifica, mappa. Cancellare la pagina di prova e le sue chiavi, poi rigenerare l10n e il codice.

- [ ] **Step 5: Verificare**

Run: `bash tool/check.sh`
Expected: verde. Il numero di test è quello di partenza meno i 3 della pagina di prova, più i nuovi dei Task 1–3.

- [ ] **Step 6: Commit** `refactor(radio): il controller decide con next() e la schermata legge RadioDisplay`

### Task 4: Una sola fonte per «in volo»

**Files:**
- Modify:
  - `lib/features/radio/data/radio_media_session.dart`, `lib/features/radio/data/radio_audio_handler.dart`: `showFlight()` imposta solo il segnaposto della notifica. `_flying` lo scrive solo `showControls`.
  - `lib/features/radio/domain/radio_audio_service.dart`, `lib/features/radio/data/just_audio_service.dart`: `flightInterruptions` diventa `Stream<void> get systemPauses`. Lo emettono soltanto gli ascoltatori di cuffie staccate e di interruzione (`begin`, tipo `pause` o `unknown`), sempre, prima di mettere in pausa. `pause()` non emette più niente. `_muted` resta solo per il volume.
  - `lib/features/radio/application/radio_controller.dart`: a ogni `systemPauses`, se `state is Flying` chiama `stop()`.
- Test:
  - `test/features/radio/radio_audio_handler_test.dart`
  - `test/features/radio/just_audio_service_test.dart`
  - `test/features/radio/radio_controller_test.dart`
  - `test/features/radio/radio_notification_test.dart`

**Interfaces:**
- Consumes: Task 3.
- Produces: `RadioAudioService.systemPauses`; `RadioMediaSession.showFlight()` con il nuovo contratto.

- [ ] **Step 1: Scrivere e aggiornare i test**
  - **handler:** «showFlight alone already keeps the notification up» diventa «showFlight only names the flight: the flag comes from showControls». Dopo `showFlight()` ed `emit(idle, playing: false)`, `processingState` è `idle`. È l'unico test di cui cambia il significato: lo vuole la spec («nessun `_flying` con due scrittori»).
  - **servizio audio:** «a pause during the flight is reported, after landing it is not» diventa due test:
    - «a system pause is reported and pauses the player»: interruzione `pause` con `begin`, `reported == 1`, giocatore in pausa;
    - «a pause asked by the app is not a system pause»: `pause()` in volo e in onda, `reported == 0`.
  - **controller (Review Focus 4):** «a system pause on air only pauses». Atterrare, emettere su `systemPauses` e poi `paused`: lo stato è `OnAir` in pausa, `stops` invariato. Il test esistente «a system pause during the flight cancels it» resta.
  - **notifica (Review Focus 1):** «a retune from a station on air keeps the notification up». Integrazione con `JustAudioService` e `RadioAudioHandler` veri, che condividono un `AudioPlayer` finto. Il finto pubblica `playbackEventStream` e `playerStateStream` e manda `idle` quando si chiama `stop()`.
    - atterrare su una stazione;
    - chiamare `tuneRandom()` con la stazione nuova in attesa;
    - `handler.playbackState.value.processingState` è `loading` e `playing` è vero subito dopo lo stop del vecchio stream.

- [ ] **Step 2: Eseguire i test**

Run: `flutter test test/features/radio/`
Expected: falliscono «showFlight only names…», i due test di `systemPauses` (per compilazione o per conteggio) e «a system pause on air only pauses». Il test della notifica deve passare: fa da rete. Se fallisce, c'è un bug da annotare e correggere.

- [ ] **Step 3: Implementare le modifiche ai tre file**

- [ ] **Step 4: Verificare**

Run: `bash tool/check.sh`
Expected: verde.

- [ ] **Step 5: Commit** `refactor(radio): «in volo» ha una sola fonte, la sessione`

### Task 5: Aiuto comune per il salvataggio di preferiti e tema

**Files:**
- Create: `lib/app/state/latest_save.dart`
- Modify:
  - `lib/features/favorites/application/favorites_controller.dart`
  - `lib/app/theme/app_theme_mode.dart`
  - `docs/status.md`: sezione «Macchine a stati esplicite — 15 novembre 2026»
  - `docs/superpowers/specs/2026-11-15-macchine-a-stati-design.md`: nello «Stato», «fatto in Frequenza; da portare nello starter»
- Test: `test/app/state/latest_save_test.dart`

**Interfaces:**
- Produces: `class LatestSave` con:
  - `void start(Ref ref)`: da chiamare in `build()`. Apre una generazione nuova e la chiude con `ref.onDispose`.
  - `Future<AsyncValue<T>> run<T>({required AsyncValue<T> shown, required void Function(AsyncValue<T>) emit, required Future<T> Function() action})`.

**Comportamento di `run`:**
- emette `AsyncLoading<T>().copyWithPrevious(shown)`;
- esegue `AsyncValue.guard(action)`;
- emette `result.copyWithPrevious(shown)` solo se nel frattempo non è partita un'altra generazione;
- restituisce sempre `result`.

**Uso:**
- **Preferiti:** `shown: state`.
- **Tema:** `shown: AsyncData(previous)` e `return !result.hasError`.

Lo schema `_generation` + `copyWithPrevious` sparisce dai due file.

- [ ] **Step 1: Scrivere i test**
  - «saving shows loading over the previous value»
  - «the result lands over the previous value»
  - «an error keeps the previous value visible»
  - «a rebuild during the save drops the stale result» (Review Focus 5): `start()` di nuovo prima che `action` finisca, poi niente `emit` finale

I test usano un `ProviderContainer` con un notifier minimo di prova.

- [ ] **Step 2: Eseguire il test**

Run: `flutter test test/app/state/latest_save_test.dart`
Expected: FAIL in compilazione.

- [ ] **Step 3: Implementare `LatestSave` e usarlo nei due controller**

- [ ] **Step 4: Verificare**

Run: `bash tool/check.sh`
Expected: verde, con i test di preferiti e tema invariati.

- [ ] **Step 5: Commit** `refactor: aiuto comune per i salvataggi con AsyncValue`
