# Diario di viaggio, parte 1: il registro degli ascolti — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** l'app registra sul telefono ogni ascolto (stazione, paese, inizio, secondi), pronto per la pagina del diario che verrà.

**Architecture:**
- un database Drift con le tabelle `stations` e `listens`, dietro un `DiaryRepository`;
- `ListenTracker`, una macchina a stati pura, decide inizio, aggiornamento e fine di un ascolto a partire dalla `RadioSession`;
- `ListenRecorder`, un provider avviato in `bootstrap`, collega tracker, orologio e repository.

**Tech Stack:** Flutter, Riverpod, Drift (+ `drift_flutter` per aprire il database, `drift_dev` per la generazione), `sqlite3` di sistema nei test.

**Spec:** `docs/superpowers/specs/2026-11-16-diario-di-viaggio-design.md`. Questa parte copre «Cosa si registra»; la pagina viene in un piano separato.

## Global Constraints

- **Principi del registro (spec):**
  - una riga per ascolto, sempre valida;
  - si scrive il totale assoluto (`seconds = N`);
  - stazione e primo ascolto in una sola transazione;
  - nessuna tabella di totali;
  - logica pura in memoria;
  - ascolti sotto i 5 s non salvati;
  - schema versionato.
- **Conta solo** `OnAir` con `playback == OnAirPlayback.playing`.
- **Scrittura del totale:** ogni **30 s**, e quando l'app va in background (`AppLifecycleState.paused`).
- **Tempo:** misurato con un orologio monotono, iniettabile per i test. `startedAt` in UTC dall'orologio di sistema, una volta sola.
- **Database:** file `frequenza.sqlite` nella cartella dati dell'app; `schemaVersion = 1`.
- **Verifica di fine task:** `bash tool/check.sh`; l'ultimo con `--apk`.

## Review Focus

1. **Cambio stazione senza pausa** (volo da una stazione che suona a un'altra): la prima chiude con i suoi secondi, la seconda apre una riga nuova (Task 2).
2. **Pausa e ripresa sulla stessa stazione:** due righe, nessun secondo contato durante la pausa (Task 2).
3. **App chiusa da Android:** l'ultima scrittura è valida, nessuna riga a zero o «aperta» (Task 1 e 3).
4. **Scritture ripetute:** lo stesso totale scritto due volte non raddoppia (Task 1).
5. **Una stazione già nel registro, ascoltata di nuovo:** aggiorna `stations` senza duplicare (Task 1).

---

### Task 1: Database e repository

**Files:**
- Create: `lib/features/diary/data/diary_database.dart` (tabelle e database), `lib/features/diary/data/diary_repository.dart`
- Create: `drift_schemas/diary/drift_schema_v1.json` (con `dart run drift_dev make-migrations` o `schema dump`)
- Modify: `pubspec.yaml` (`drift`, `drift_flutter`; dev: `drift_dev`)
- Test: `test/features/diary/diary_repository_test.dart` (database in memoria, `NativeDatabase.memory()`)

**Interfaces:**
- `class DiaryRepository`:
  - `Future<int> startListen(RadioStation station, {required DateTime startedAt, required int seconds})`: in una transazione fa l'upsert di `stations` (con `id` e `json`) e l'insert di `listens`; restituisce l'id dell'ascolto;
  - `Future<void> setSeconds(int listenId, int seconds)`: scrive il valore assoluto;
  - `Future<List<ListenRow>> listens()`: solo per i test e per la parte 2.
- `@Riverpod(keepAlive: true) DiaryRepository diaryRepository(Ref ref)`: apre il database e lo chiude in `onDispose`.

- [ ] **Step 1:** test:
  - «a listen saves its station and itself together»;
  - «setSeconds writes the total, twice is the same»;
  - «a station heard again is updated, not duplicated»;
  - «the schema is version 1».
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** aggiungere le dipendenze compatibili con `build_runner`, `freezed` e `riverpod_generator` già presenti; scrivere tabelle e repository, generare.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(diario): il registro degli ascolti in Drift`.

### Task 2: ListenTracker, la macchina a stati

**Files:**
- Create: `lib/features/diary/domain/listen_tracker.dart`
- Test: `test/features/diary/listen_tracker_test.dart`

**Interfaces:**
- `ListenTracker` è puro e senza I/O. Ingressi:
  - `void observe(RadioSession session, Duration now)`;
  - `void tick(Duration now)`.
  Uscita: una lista di `ListenWrite`:
  - `Start(station, startedAtUtc, seconds)`;
  - `Update(seconds)`;
  - `Finish(seconds)`.
- **Regole:**
  - l'ascolto parte quando la sessione diventa `OnAir.playing`;
  - finisce quando la sessione smette di esserlo, o cambia stazione;
  - `Start` arriva al primo `tick` o alla fine, solo se i secondi sono almeno 5;
  - dopo `Start`, un `tick` produce `Update` solo se i secondi sono cambiati;
  - `Finish` arriva solo se c'era stato `Start`, altrimenti `Start` con i secondi finali.
- L'ora UTC di inizio la passa il recorder, dall'orologio di sistema.

- [ ] **Step 1:** test sui casi della Review Focus 1 e 2, poi:
  - «under five seconds nothing is written»;
  - «a flight is not a listen»;
  - «buffering ends the listen»;
  - «ticks without change write nothing».
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde.
- [ ] **Step 5:** commit `feat(diario): la macchina a stati che decide cosa salvare`.

### Task 3: ListenRecorder e avvio

**Files:**
- Create: `lib/features/diary/application/listen_recorder.dart`
- Modify: `lib/app/bootstrap.dart` (avvio come `radioNotificationProvider`), `docs/privacy.html` (una riga in «Cosa resta sul telefono», it ed en), `docs/status.md`
- Test: `test/features/diary/listen_recorder_test.dart`

**Interfaces:**
- `@Riverpod(keepAlive: true) void listenRecorder(Ref ref)`:
  - ascolta `radioControllerProvider`;
  - un `Timer.periodic(30 s)` chiama `tick`;
  - un `AppLifecycleListener` chiama `tick` su `paused`;
  - traduce le `ListenWrite` in chiamate al `DiaryRepository`, una alla volta, in ordine (una coda), così uno `Start` è sempre scritto prima del suo `Update`.
- Orologio e ora UTC iniettabili (provider `diaryClockProvider`) per i test.

- [ ] **Step 1:** test con un repository finto e `fakeAsync`:
  - «a station played for a minute is saved with 60 seconds»;
  - «pausing finishes the listen»;
  - «going to the background writes the total».
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare e collegare in `bootstrap`; riga nell'informativa: «Gli ascolti (stazione, paese, durata) restano sul telefono per il diario di viaggio» / «Your listening (station, country, duration) stays on the phone for the travel diary».
- [ ] **Step 4:** `bash tool/check.sh --apk`. Expected: verde e APK costruita.
- [ ] **Step 5:** `docs/status.md`, sezione «Diario: il registro degli ascolti — 16 novembre 2026», con le prove sul telefono. Commit `feat(diario): l'app registra gli ascolti sul telefono`.
