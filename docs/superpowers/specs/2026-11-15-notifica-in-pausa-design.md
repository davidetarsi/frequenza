# Notifica in pausa — design breve

Data: 15 novembre 2026. Stato: **approvato da Davide**. Branch `feat/notifica-in-pausa`, costruito sopra `refactor/macchine-a-stati`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude, approvata con il design.

## Intento

La notifica deve seguire lo stato della radio in modo coerente. Mentre suona resta fissa; in pausa si può togliere; non deve mai restare un player «zombie» che non si chiude **[D]**.

Oggi la notifica in pausa non si toglie per due motivi:
- in `bootstrap.dart` c'è `androidNotificationOngoing: true`, che rende la notifica fissa anche in pausa;
- quando l'app viene tolta dalle recenti la libreria non fa nulla.

## Comportamento

| Situazione | Notifica | App riaperta |
|---|---|---|
| Suona, o è in volo | fissa (servizio in primo piano) | come oggi |
| In pausa | si può scorrere via **[D]** | stazione visibile, in pausa |
| Notifica scorsa via in pausa | si chiude, servizio fermo | stazione visibile, «Pronta a partire» |
| 10 minuti di pausa senza toccare niente | si chiude da sola **[D]** | come sopra |
| App tolta dalle recenti mentre suona | resta, la musica continua **[D]** | — |
| App tolta dalle recenti in pausa | si chiude, servizio fermo **[D]** | — |
| Play su una stazione ferma (app, cuffie, Bluetooth) | ricompare | rifà il volo di riconnessione **[C]** |

## Approcci

1. **Scelto: libreria attuale più poche regole nostre** **[C]**:
   - `audio_service` già rende scorribile la notifica in pausa e chiama `stop()` quando la si scorre via;
   - aggiungiamo `onTaskRemoved`, il timer di pausa e la regola per play.
2. **Scartato: riscrivere il servizio nativo con Media3.** Ha gli stessi risultati, ma è un lavoro sproporzionato e porta via la libreria che oggi gestisce notifica e sessione.

## Come **[C]**

- **`bootstrap.dart`:** si toglie `androidNotificationOngoing: true` e resta `androidStopForegroundOnPause: true`. Mentre suona, Android tiene la notifica fissa perché il servizio è in primo piano.
- **`RadioAudioHandler.onTaskRemoved()`:** se non suona e non è in volo, `stop()`.
- **`RadioAudioHandler.play()` con stream chiuso** (`ProcessingState.idle`): non riprende il player. Invia invece il comando `RadioMediaCommand.resume`, e il bridge chiama `RadioController.play()`. La regola su cosa vuol dire «play» resta solo nel controller.
- **`RadioController.play()`:**
  - in onda con `ended`: volo di riconnessione verso la stazione, con `FlightKind.reconnect` e `autoRetries` tentativi;
  - in onda negli altri casi: come oggi.
- **Timer di pausa nel controller:**
  - quando la sessione diventa `OnAir` in `paused`, parte `FlightTiming.pauseTimeout`, 10 minuti;
  - se alla scadenza la sessione è ancora in pausa sulla stessa stazione, chiama `audio.stop()`. Lo stream chiuso porta la sessione in `ended` e la libreria chiude servizio e notifica;
  - ogni altro cambio di stato annulla il timer, come per lo stallo.

## Fuori

- il player fissato nelle Impostazioni rapide di Android, che è un'opzione di sistema del telefono;
- l'analisi del comportamento di Spotify.

## Da verificare sul telefono

- scorrere via la notifica in pausa;
- togliere l'app dalle recenti, sia mentre suona sia in pausa;
- pausa lunga: in prova si può abbassare il timer;
- play dalle cuffie dopo la chiusura.
