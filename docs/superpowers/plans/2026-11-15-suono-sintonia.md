# Suono di sintonizzazione — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:**
- il fruscio del volo diventa il suono C2, generato da uno script nel repo;
- parte da un punto a caso;
- sfuma all'atterraggio, mentre la stazione sale in dissolvenza.

**Architecture:**
- Lo script Python genera il WAV versionato.
- Su Android il fruscio passa da `SoundPool` a `MediaPlayer`, che può partire da un punto qualsiasi e sfumare in uscita.
- Il motore audio Dart fa salire il volume della stazione a passi.

**Tech Stack:** Python 3 standard, Kotlin (Android), Flutter / just_audio.

**Spec:** `docs/superpowers/specs/2026-11-15-suono-sintonia-design.md`

## Global Constraints

- Il suono usa i parametri di C2: banda del fruscio 150–2200 Hz, livello 1.0, 3 stazioni, nessun fischio, fading 0.35, voce 0.6, musica 0.35, seme 3, timbro da 900 a 4200 Hz con 0.6 variazioni al secondo, mono a 44,1 kHz e 16 bit.
- Le due dissolvenze, uscita del fruscio e ingresso della stazione, durano **400 ms**.
- Il volume del fruscio è `0.42f`, in una costante.
- **Verifica di fine task:** `bash tool/check.sh`. Per il Task 3 si aggiunge `--apk`, che compila anche il Kotlin.

## Review Focus

1. **Nuova sintonia durante la salita della stazione:** la stazione nuova resta muta (Task 2).
2. **Fruscio richiesto di nuovo mentre sta sfumando** (voli ravvicinati): riparte invece di spegnersi (Task 3, verificato sul telefono).
3. **Uscendo dall'app durante il volo** il fruscio si ferma subito, come oggi (Task 3).
4. **Ducking durante la salita:** il volume finale rispetta la riduzione (Task 2).
5. **Il loop del WAV non ha salti** alla giuntura (Task 1).

---

### Task 1: Generatore del suono e WAV

**Files:**
- Create: `tool/tuning_sound/generate.py`, cioè lo script di prova ridotto a C2, con `main(out_path)`
- Modify: `android/app/src/main/res/raw/tuning_static.wav`, rigenerato
- Test: `tool/test_tuning_sound.py`

- [ ] **Step 1: Scrivere il test**

«generates a soft loop»: genera il suono in un file temporaneo e controlla:
- un canale, 44100 Hz, 2 byte per campione;
- durata tra 7,2 e 7,6 s;
- picco ≤ 0,62 del massimo;
- differenza tra l'ultimo e il primo campione ≤ 0,1 del massimo;
- due generazioni producono byte identici.

- [ ] **Step 2: Eseguire il test**

Run: `python3 -m unittest tool/test_tuning_sound.py`
Expected: FAIL, perché il modulo non esiste.

- [ ] **Step 3: Scrivere lo script e generare il WAV**

Run: `python3 tool/tuning_sound/generate.py android/app/src/main/res/raw/tuning_static.wav`

- [ ] **Step 4: Verificare**

Run: il test, poi `bash tool/check.sh`.
Expected: verdi.

- [ ] **Step 5: Commit** `feat(radio): nuovo fruscio di sintonizzazione, morbido e generato dallo script`

### Task 2: La stazione entra in dissolvenza

**Files:**
- Modify: `lib/features/radio/data/just_audio_service.dart`
- Test: `test/features/radio/just_audio_service_test.dart`

**Interfaces:**
- `JustAudioService.landingFade = Duration(milliseconds: 400)` e `landingSteps = 8`.
- `land()` non aspetta la fine della salita: rivela subito la stazione e fa salire il volume in background.
- `playStation()` interrompe una salita in corso.

- [ ] **Step 1: Scrivere i test**
  - «land restores the volume and reveals the station»: dopo `land` la stazione è subito mostrata; dopo 500 ms `calls.last == 'volume 1.0'`.
  - «the station fades in»: i volumi dopo `land` sono strettamente crescenti, il primo è minore di 0,5 e l'ultimo è 1,0.
  - «a new flight during the fade keeps the next station silent»: `land`, dopo 100 ms `playStation`, poi attesa di 500 ms. Ultimo volume `0.0`.
  - «a duck during the fade ends ducked»: `land`, poi un `duck` che inizia. Dopo 500 ms l'ultimo volume è `0.2`.

- [ ] **Step 2: Eseguire i test**

Run: `flutter test test/features/radio/just_audio_service_test.dart`
Expected: FAIL su «fades in» e «new flight during the fade».

- [ ] **Step 3: Implementare la salita**

Un passo ogni `landingFade / landingSteps`. Il volume è `_volume * k / landingSteps`. Un token annulla la salita.

- [ ] **Step 4: Verificare**

Run: `bash tool/check.sh`
Expected: verde.

- [ ] **Step 5: Commit** `feat(radio): la stazione entra in dissolvenza all'atterraggio`

### Task 3: Fruscio nativo con partenza a caso e sfumatura

**Files:**
- Modify: `android/app/src/main/kotlin/it/davidetarsi/frequenza/MainActivity.kt`
- Modify: `docs/status.md`, sezione «Suono di sintonizzazione — 15 novembre 2026»

**Come funziona:**
- **Avvio:** un `MediaPlayer`, creato con `R.raw.tuning_static` e gli stessi attributi audio di oggi, in `setLooping(true)`.
  - `start` lo fa partire da `seekTo(random(duration))` al volume `TUNING_VOLUME`.
  - Se il fruscio sta sfumando, la sfumatura si annulla e riparte.
- **`stop`:** sfuma in 400 ms, con passi da 40 ms via `Handler(Looper.getMainLooper())`, poi `pause()`.
- **`onStop` dell'activity:** pausa immediata, senza sfumatura.
- **`cleanUpFlutterEngine`:** `release()`.
- **Restano uguali:** i metodi del canale e il fatto che il fruscio suoni solo con l'app in primo piano.

- [ ] **Step 1: Implementare**

Run: `bash tool/check.sh --apk`
Expected: verde, con la APK dev costruita.

- [ ] **Step 2: Aggiornare `docs/status.md` e fare il commit**

In `docs/status.md` vanno le prove sul telefono indicate nella spec.

Commit: `feat(radio): il fruscio parte da un punto a caso e sfuma all'atterraggio`.
