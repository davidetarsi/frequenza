# Notifica in pausa — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:**
- in pausa la notifica si può togliere;
- dopo 10 minuti di pausa si chiude da sola;
- se l'app viene tolta dalle recenti in pausa, si chiudono servizio e notifica;
- play su una stazione ferma la riconnette.

**Architecture:**
- Il controller decide cosa significano pausa lunga e play su stream chiuso.
- La notifica (`RadioAudioHandler`) inoltra al controller i comandi che non sa eseguire da sola.
- La configurazione di `audio_service` smette di rendere la notifica sempre fissa.

**Tech Stack:** Flutter 3.38.5, audio_service 0.18.19, just_audio, Riverpod.

**Spec:** `docs/superpowers/specs/2026-11-15-notifica-in-pausa-design.md`

## Global Constraints

- **Base:** `refactor/macchine-a-stati`; branch `feat/notifica-in-pausa`.
- `pauseTimeout` = 10 minuti, in `FlightTiming` accanto a `stallTimeout`.
- La riconnessione usa `FlightKind.reconnect` con `autoRetries` tentativi.
- **Verifica di fine task:** `bash tool/check.sh` verde.
- **Commit** in italiano, con le righe di attribuzione della sessione.

## Review Focus

1. **Il timer di pausa non scatta se nel frattempo** la radio riprende, parte un volo o si spegne. Test in Task 1.
2. **App tolta dalle recenti durante un volo:** non ferma niente, perché in volo la notifica deve restare. Test in Task 2.
3. **Play dalle cuffie** con la radio spenta o fallita, quando non c'è una stazione da riconnettere: non fa nulla. Test in Task 1.
4. **Play su una stazione in pausa** con lo stream ancora aperto: riprende senza volo, come oggi. Test in Task 1 e Task 2.
5. **Play su uno stream finito** (`completed`): riparte dall'inizio come oggi, senza comando. Il test esistente resta valido.

---

### Task 1: Controller — pausa lunga e play su stazione ferma

**Files:**
- Modify: `lib/features/radio/application/flight_timing.dart`, `lib/features/radio/application/radio_controller.dart`
- Test: `test/features/radio/radio_controller_test.dart`. In `fastFlights` aggiungere `pauseTimeout: Duration(milliseconds: 100)`.

**Interfaces:**
- Produces:
  - `FlightTiming.pauseTimeout` (`Duration`, default `Duration(minutes: 10)`);
  - `RadioController.play()`: in `OnAir` con `ended`, vola con `reconnect`; in `OnAir` negli altri casi chiama `audio.play()`; altrove non fa nulla.

**Timer di pausa.** Va gestito come il timer di stallo:
- si annulla a ogni `PlaybackChanged`, all'inizio di ogni volo e in `stop()`;
- riparte se la sessione è `OnAir` in `paused`;
- alla scadenza chiama `audio.stop()`, solo se la sessione è ancora `OnAir` in `paused` sulla stessa stazione.

- [ ] **Step 1: Scrivere i test**
  - «a long pause closes the stream»: atterrare, `pause()`, attendere oltre 100 ms. `audioService.stops` aumenta di 1 e lo stato è `isOnAir(OnAirPlayback.ended)`.
  - «resuming before the timeout keeps the stream»: `pause()`, poi a 30 ms `play()`, poi attesa di 200 ms. `stops` invariato, stato `playing`.
  - «a flight or a stop cancels the pause timer»: due casi.
    - `pause()`, poi `tuneRandom()` verso un'altra stazione e attesa: `stops` aumenta solo per i voli, cioè uguale al conto senza timer, e lo stato è `OnAir` `playing` sulla nuova stazione.
    - `pause()`, poi `stop()` e attesa: lo stato è `isOff`, senza `stop` in più.
  - «play on an ended station reconnects it»: atterrare, emettere `idle`, poi `play()`. `played` vale `[s, s]`, lo stato è `playing` e `trips` resta invariato.
  - «play with nothing on air does nothing»: dallo stato iniziale `play()`. `played` vuoto, stato `isOff`.

- [ ] **Step 2: Eseguire i test**

Run: `flutter test test/features/radio/radio_controller_test.dart`
Expected: FAIL, perché `pauseTimeout` non esiste ancora.

- [ ] **Step 3: Implementare** `pauseTimeout` e le due regole del controller.

- [ ] **Step 4: Verificare**

Run: `flutter test test/features/radio/radio_controller_test.dart`, poi `bash tool/check.sh`.
Expected: verdi.

- [ ] **Step 5: Commit** `feat(radio): la pausa lunga chiude lo stream e play riconnette la stazione`

### Task 2: Notifica — scorribile in pausa, app tolta dalle recenti, play su stream chiuso

**Files:**
- Modify:
  - `lib/app/bootstrap.dart`: la configurazione esce in `AudioServiceConfig radioServiceConfig({required String channelName})`, nello stesso file e pubblica per il test, senza `androidNotificationOngoing: true`;
  - `lib/features/radio/data/radio_media_session.dart`: `enum RadioMediaCommand { next, previous, toggleFavorite, resume }`;
  - `lib/features/radio/data/radio_audio_handler.dart`;
  - `lib/features/radio/application/radio_notification.dart`.
- Test:
  - `test/features/radio/radio_audio_handler_test.dart`
  - `test/features/radio/radio_notification_test.dart`
  - `test/app/bootstrap_config_test.dart`

**Interfaces:**
- Consumes: `RadioController.play()` dal Task 1.
- Produces:
  - `RadioAudioHandler.onTaskRemoved()`: chiama `stop()` se `!player.playing && !_flying`;
  - `RadioAudioHandler.play()`: se `player.processingState == ProcessingState.idle` e non in volo, invia `RadioMediaCommand.resume` e non tocca il player. Gli altri casi restano come oggi;
  - il bridge mappa `resume` → `controller.play()`.

- [ ] **Step 1: Scrivere i test**
  - **config:** «the paused notification can be swiped away»:
    - `radioServiceConfig(channelName: 'x').androidNotificationOngoing` è `false`;
    - `androidStopForegroundOnPause` è `true`.
  - **handler:**
    - «removing the app while paused closes the service»: `player.playing = false`, `onTaskRemoved()`, `player.stops == 1`;
    - «removing the app while playing keeps it»: con `playing` vero, `stops == 0`;
    - «removing the app during a flight keeps it»: `showControls(flying: true)`, `stops == 0`;
    - «play on a closed stream asks the radio»: con `processingState` `idle`, `play()` invia `resume` e `player.plays == 0`;
    - «play on a paused stream resumes it»: con `processingState` `ready`, `player.plays == 1` e nessun comando.
  - **notifica (bridge):** «resume from the notification reconnects the ended station»: atterrare, emettere `idle` dal finto audio, poi `handler` invia `resume` (`await handler.play()` con il player del handler in `idle`). `audio.played` contiene due volte la stazione.

- [ ] **Step 2: Eseguire i test**

Run: `flutter test test/features/radio/ test/app/bootstrap_config_test.dart`
Expected: FAIL, perché `radioServiceConfig` e `resume` non esistono ancora.

- [ ] **Step 3: Implementare** le modifiche ai quattro file.

- [ ] **Step 4: Verificare**

Run: `bash tool/check.sh`
Expected: verde.

- [ ] **Step 5: Aggiornare `docs/status.md` e fare il commit**

Aggiungere in `docs/status.md` la sezione «Notifica in pausa — 15 novembre 2026», con le prove da fare sul telefono indicate nella spec.

Commit: `feat(radio): notifica scorribile in pausa e chiusa togliendo l'app in pausa`.
