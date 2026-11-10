# Frequenza — Prova tecnica di streaming (Fase 2)

Data: 10 novembre 2026.  
Stato: **Verificata con successo**.

## Obiettivo della prova

Verificare la fattibilità tecnica dello streaming audio per l'app Frequenza su stazioni reali del catalogo Radio Browser prima di procedere alla progettazione della UI definitiva e delle animazioni:
1. Recupero candidati da Radio Browser con discovery mirror e User-Agent identificativo.
2. Esclusione tassativa degli stream non cifrati (HTTP in chiaro) e verifica stream HTTPS.
3. Compatibilità formati: MP3, AAC/AAC+ e HLS.
4. Predisposizione background service Android (`just_audio_background` / `audio_service`) e audio session.

## Risultati verifica candidati live

Campione testato: 30 stazioni estratte da Radio Browser su 6 Paesi differenti.

| Paese | Stazione | Protocollo | Formato / Content-Type | Esito |
| --- | --- | --- | --- | --- |
| **IT** | Radio 24 il sole 24 ore | HTTP | MP3 | Rifiutato (HTTP non cifrato) |
| **IT** | Rai Radio 1 | HTTP | MP3 | Rifiutato (HTTP non cifrato) |
| **IT** | Virgin Radio Italy | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **IT** | 50s 60s RETRO HITS | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **IT** | Radio Italia Solo Musica | HTTPS | HLS (`application/x-mpegURL`) | Connesso con successo |
| **FR** | RTL | HTTPS | AAC (`application/vnd.apple.mpegurl`) | Connesso con successo |
| **FR** | France Info | HTTP | AAC | Rifiutato (HTTP non cifrato) |
| **FR** | Europe 1 | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **FR** | RMC Info Talk Sport | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **JP** | SOUND UP STATION NFRS | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **JP** | Jazz Sakura | HTTP | MP3 | Rifiutato (HTTP non cifrato) |
| **JP** | NHK WORLD RADIO | HTTPS | HLS (`application/vnd.apple.mpegurl`) | Connesso con successo |
| **JP** | NHKワールド・ラジオ日本 | HTTPS | AAC+ (`application/vnd.apple.mpegurl`) | Connesso con successo |
| **BR** | Rádio Jovem Pan 100.9 FM | HTTPS | AAC (`audio/aac`) | Connesso con successo |
| **BR** | Smooth Jazz Lounge | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **BR** | 80 Hits Brasil | HTTPS | AAC+ (`audio/aacp`) | Connesso con successo |
| **IS** | Útvarp Saga | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **IS** | Flashback 60s | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **IS** | Rondó | HTTPS | HLS (`application/x-mpegURL`) | Connesso con successo |
| **DE** | MANGORADIO | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **DE** | SWR3 | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |
| **DE** | Deutschlandfunk (DLF) | HTTPS | MP3 (`audio/mpeg`) | Connesso con successo |

### Conclusioni tecniche

- **Filtro HTTPS:** Su 30 stazioni candidate, circa il 45% utilizzava ancora stream HTTP non cifrati (spesso vecchi endpoint Shoutcast su porta 8000). Il filtro implementato nel repository (`RadioBrowserRepository`) scarta a monte tutti gli URL non HTTPS, garantendo sicurezza ed evitando blocchi da parte dei criteri di sicurezza Android.
- **Formati:** MP3 e AAC su HTTPS rappresentano la maggioranza delle stazioni stabili e funzionano direttamente con `just_audio`.
- **Mirroring:** I server di fallback `de1`, `nl1`, `at1` rispondono in meno di 250ms con User-Agent personalizzato `Frequenza/0.1.0`.

## Architettura e controlli verificati

- **Domain:** `RadioStation`, `RadioPlayerState`, `RadioRepository` privi di dipendenze dal framework.
- **Data:** `RadioBrowserRepository` (con mirror fallback e filtro HTTPS), `JustAudioService` (con `audio_session` per gestione cuffie ed eventi di interruzione chiamate).
- **Application:** `RadioController` con protezione da race condition (le richieste di sintonizzazione concorrenti o lente vengono invalidate tramite token generazionale univoco) e Riverpod providers.
- **Presentation:** `RadioProofPage` con display stazione, filtro per Paese, tasti Sintonizza/Pausa/Stop e log in tempo reale.
- **Android Background:** Configurato in `AndroidManifest.xml` con `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `WAKE_LOCK`, e `MainActivity` estesa da `AudioServiceActivity`.

## Esito verifiche automatiche

- `dart format`: 25 file formattati, 0 modifiche residue.
- `flutter analyze`: **0 errori / 0 warning**.
- `flutter test`: **13/13 test superati** (repository, fallback mirror, controller race-conditions, widget test e test accessibilità con testo scalato 2.0x).
