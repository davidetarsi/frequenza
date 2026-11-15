# Migrazione ad audio_service — piano

> **Per agenti:** SUB-SKILL RICHIESTA: superpowers:subagent-driven-development (consigliata) oppure superpowers:executing-plans, un task alla volta. I passi usano le checkbox (`- [ ]`).

**Obiettivo:** sostituire `just_audio_background` con un `AudioHandler` di `audio_service` scritto da noi, a parità di comportamento, così che nel passo 2 la notifica possa mostrare un segnaposto durante il volo.

**Architettura:**
- `RadioAudioHandler` (data) estende `BaseAudioHandler` sopra lo stesso `AudioPlayer` di `just_audio`. Traduce gli eventi del player in `PlaybackState` e riceve i comandi della notifica e delle cuffie.
- `JustAudioService` gli passa i metadati della stazione tramite la piccola porta `RadioMediaSession`, invece di metterli nel `tag` dell'`AudioSource`.
- `bootstrap.dart` inizializza `AudioService.init` e passa l'handler a Riverpod con un override.

**Stack:** Flutter, Riverpod generato, just_audio 0.9.x, audio_service 0.18.x (oggi già transitivo, versione 0.18.19 nel lock).

**Spec:** `docs/superpowers/specs/2026-11-12-rotta-sul-mondo-design.md`, sezione «Organizzazione del lavoro», passo 1.

**Branch:** `feat/audio-service`, creato da `design/rotta-sul-mondo`. La PR include anche il design se quello non è ancora stato unito.

## Vincoli globali

- Parità di comportamento:
  - stesso canale di notifica (`dev.davidetarsi.frequenza.channel.audio`) con nome localizzato da `LocaleKeys.audioChannelName`, come oggi;
  - `androidNotificationOngoing: true` e `androidStopForegroundOnPause: true`;
  - nella notifica, titolo = nome stazione, artista = Paese, immagine = favicon se presente.
- Nessuna modifica a `RadioAudioService`, `RadioController`, UI e manifest Android. `MainActivity` estende già `AudioServiceActivity`, e servizio e ricevitore sono già quelli di `audio_service`.
- `just_audio_background` va rimosso da `pubspec.yaml`. `audio_service` diventa dipendenza diretta (`^0.18.19`).
- `AudioPlayer.play()` di uno stream live si completa solo alla pausa o allo stop: non va mai atteso per concludere un comando. Vale lo stesso schema `unawaited(... .catchError)` già usato in `JustAudioService`.
- I test esistenti restano verdi senza modifiche: usano `FakeAudioService`.

## Focus della revisione

Ogni voce ha il suo test nel Task 1.

1. Play dalla notifica o dalle cuffie su uno stream live: il comando ritorna subito, senza aspettare la fine della riproduzione.
2. Pausa o play premuti in notifica con l'app in background: lo stato pubblicato all'esterno (`playbackState`) segue il player e il pulsante si inverte.
3. Tasto singolo delle cuffie (`click`): mette in pausa se suona e riprende se è in pausa.
4. Stazione senza favicon: `artUri` nullo, nessuna eccezione.
5. Errore nel flusso degli eventi del player (stream caduto): l'handler pubblica `AudioProcessingState.error` e non lascia eccezioni non gestite.

---

### Task 1: RadioAudioHandler e porta RadioMediaSession

**File:**
- Crea: `lib/features/radio/data/radio_media_session.dart`
- Crea: `lib/features/radio/data/radio_audio_handler.dart`
- Modifica: `pubspec.yaml`, aggiungendo `audio_service: ^0.18.19` accanto a `just_audio`. `just_audio_background` resta fino al Task 2.
- Test: `test/features/radio/radio_audio_handler_test.dart`

**Interfacce:**
- Produce:
  - `abstract interface class RadioMediaSession { void showStation(RadioStation station); }`
  - `class RadioAudioHandler extends BaseAudioHandler implements RadioMediaSession`, con costruttore `RadioAudioHandler(AudioPlayer player)`, getter `AudioPlayer get player` e metodo `Future<void> dispose()` che annulla la sottoscrizione agli eventi (non chiude il player, che appartiene a `JustAudioService`).

- [ ] **Passo 1: scrivere i test che falliscono**

Il player finto estende `Fake implements AudioPlayer`, come `LivePlayer` in `just_audio_service_test.dart`. Espone:
- `playbackEventStream` da uno `StreamController<PlaybackEvent>`;
- i campi impostabili `playing` e `processingState`;
- `play()` su un `Completer` mai completato;
- contatori per `pause()` e `stop()`.

Test:
- `publishes pause control and ready state while playing`: con `playing = true` e `processingState = ProcessingState.ready`, dopo un evento `playbackState.value.playing` è `true`, `processingState` è `AudioProcessingState.ready`, `controls.first` è `MediaControl.pause` e `controls` contiene `MediaControl.stop`.
- `publishes play control while paused`: con `playing = false` e `ready`, `controls.first` è `MediaControl.play`.
- `maps buffering and idle`: `ProcessingState.buffering` → `AudioProcessingState.buffering`; `ProcessingState.idle` → `AudioProcessingState.idle`.
- `play returns without waiting for live playback`: `await handler.play().timeout(const Duration(seconds: 1))` non lancia eccezioni.
- `pause and stop reach the player`: dopo `pause()` e `stop()` i contatori valgono 1.
- `click toggles playback`: con lo stato pubblicato `playing: true`, `click()` chiama `pause()`; con `playing: false`, chiama `play()`.
- `showStation publishes station metadata`: per una stazione con favicon `https://example.com/i.png`, `mediaItem.value` ha `id` = id stazione, `title` = nome, `artist` = Paese, `artUri` = `Uri.parse('https://example.com/i.png')`. Senza favicon, `artUri` è `null`.
- `player event errors become error state`: `controller.addError(StateError('x'))` porta a `playbackState.value.processingState == AudioProcessingState.error`, senza eccezioni non gestite.

- [ ] **Passo 2: verificare che falliscano**

Comando: `flutter test --no-pub test/features/radio/radio_audio_handler_test.dart`
Atteso: FAIL in compilazione, perché `RadioAudioHandler` non esiste.

- [ ] **Passo 3: implementare `RadioMediaSession` e `RadioAudioHandler`**

- Nel costruttore: sottoscrizione a `player.playbackEventStream`. Ogni evento → `playbackState.add(...)` con:
  - `controls: [playing ? MediaControl.pause : MediaControl.play, MediaControl.stop]`;
  - `androidCompactActionIndices: const [0]`;
  - `systemActions` vuoto, perché la diretta non si può scorrere;
  - `processingState` dalla mappa 1:1 di `ProcessingState`;
  - `playing`, `updatePosition` e `bufferedPosition` dal player.
- Gli errori del flusso aggiungono uno stato con `AudioProcessingState.error` e `playing: false`.
- `play()` usa `unawaited(player.play().catchError(...))`.
- `pause()` chiama `player.pause()`.
- `stop()` chiama `player.stop()`.
- `click()` resta quello di default di `BaseAudioHandler`, che alterna in base a `playbackState.value.playing`. Il test lo verifica.

- [ ] **Passo 4: verificare che passino**

Comando: `flutter test --no-pub test/features/radio/radio_audio_handler_test.dart`
Atteso: tutti PASS.

- [ ] **Passo 5: commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/radio/data/radio_media_session.dart lib/features/radio/data/radio_audio_handler.dart test/features/radio/radio_audio_handler_test.dart
git commit -m "Add an audio_service handler for the radio player"
```

### Task 2: collegare l'handler e rimuovere just_audio_background

**File:**
- Modifica: `lib/features/radio/data/just_audio_service.dart`, cioè il costruttore e `playStation`, dove oggi c'è `tag: MediaItem(...)`.
- Modifica: `lib/features/radio/application/radio_providers.dart`, più la rigenerazione di `radio_providers.g.dart`.
- Modifica: `lib/app/bootstrap.dart`.
- Modifica: `pubspec.yaml` e `pubspec.lock`, rimuovendo `just_audio_background`.
- Modifica: `docs/status.md`, con una sezione breve: fatto, verificato, collaudo aperto.
- Test: `test/features/radio/just_audio_service_test.dart`

**Interfacce:**
- Usa: `RadioMediaSession` e `RadioAudioHandler(AudioPlayer)` dal Task 1.
- Produce:
  - `JustAudioService({AudioPlayer? player, RadioMediaSession? mediaSession})`;
  - provider generato `@Riverpod(keepAlive: true) RadioAudioHandler? radioAudioHandler(Ref ref) => null;`, sovrascritto in `bootstrap`;
  - `radioAudioService` costruisce `JustAudioService(player: handler?.player, mediaSession: handler)`, dove `handler = ref.watch(radioAudioHandlerProvider)`.

- [ ] **Passo 1: scrivere il test che fallisce**

Nuovo test in `just_audio_service_test.dart`, `playStation shows the station on the media session`. Usa una `RecordingSession implements RadioMediaSession` che salva l'ultima stazione. Dopo `await service.playStation(station)`, la stazione salvata ha lo stesso `id`. I due test esistenti restano invariati.

- [ ] **Passo 2: verificare che fallisca**

Comando: `flutter test --no-pub test/features/radio/just_audio_service_test.dart`
Atteso: FAIL in compilazione, perché il parametro `mediaSession` non esiste.

- [ ] **Passo 3: implementare il collegamento**

- **`JustAudioService`:**
  - `AudioSource.uri(Uri.parse(station.streamUrl))` senza `tag`;
  - chiamata `_mediaSession?.showStation(station)` subito prima di `setAudioSource`, come fa oggi il `tag`;
  - rimuovere l'import di `just_audio_background`.
- **`bootstrap.dart`:**
  - creare un solo `AudioPlayer`;
  - `final handler = await AudioService.init(builder: () => RadioAudioHandler(player), config: AudioServiceConfig(androidNotificationChannelId: ..., androidNotificationChannelName: ..., androidNotificationOngoing: true, androidStopForegroundOnPause: true))`, con gli stessi valori e la stessa scelta del nome localizzato di oggi;
  - `ProviderScope(overrides: [radioAudioHandlerProvider.overrideWithValue(handler)], ...)`.
- Rimuovere `just_audio_background` da `pubspec.yaml`, poi `flutter pub get`.
- Rigenerare con `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Passo 4: verificare tutto**

Comando: `bash tool/check.sh --apk`
Atteso:
- formattazione invariata;
- `flutter analyze` con «No issues found»;
- `check_player_state` superato;
- suite con **29 test**, tutti PASS: i 20 esistenti, gli 8 del Task 1 e quello nuovo di questo task;
- APK release compilato.

Se la build APK fallisce per l'ambiente (blocco socket di Gradle, già visto in passato), annotarlo con l'errore testuale e verificare almeno `flutter build bundle --debug --no-pub`.

- [ ] **Passo 5: commit**

```bash
git add -A lib test pubspec.yaml pubspec.lock docs/status.md
git commit -m "Drive background playback through audio_service directly"
```

## Collaudo di Davide sul telefono

Fuori dai task: non si può automatizzare qui. Confrontare con l'APK di prima.

- [ ] Notifica: compaiono nome, Paese e logo; play/pausa e stop funzionano; il pulsante si aggiorna.
- [ ] Schermata di blocco: stessi dati e stessi comandi.
- [ ] Cuffie e Bluetooth: il tasto singolo mette in pausa e riprende. Staccando le cuffie va in pausa, come oggi tramite `audio_session`.
- [ ] Schermo spento per qualche minuto: l'audio continua.
- [ ] Pausa dalla notifica, poi ritorno nell'app: la UI mostra «In pausa» e «Riprendi» funziona.
- [ ] Sintonizzazione mentre suona: il fruscio silenzia la stazione precedente come prima.
