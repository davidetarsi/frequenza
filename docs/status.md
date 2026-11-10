# Frequenza — stato verificato al 10 novembre 2026

Fase attiva: 3, UI radio da viaggio integrata; validazione Android reale ancora aperta.
Piano attivo: superpowers/plans/2026-11-10-travel-radio-ui.md. Roadmap: ../../flutter_starter/docs/project/roadmap.md.

## Storico — correzioni della prova tecnica

- Riutilizzati i repository esistenti; nessuna ricostruzione del template.
- Riprodotto con Dart puro un errore nello stato: un nuovo tentativo conservava il messaggio precedente. Corretto con clearError esplicito e regressione riproducibile.
- Avvio live separato dalla durata dello stream: just_audio.play() termina alla pausa/stop/fine, perciò non viene atteso per concludere l'avvio. Errori del future gestiti nello stato.
- Subscription audio annullate alla chiusura; eventi tardivi ignorati dopo disposal.
- Aggiunti test per recupero errore e comportamento del future live, senza dichiararli eseguiti.
- Una revisione indipendente limitata al diff non ha trovato nuovi problemi. Disposal delle subscription non ha un test dedicato: limite noto della copertura.

## Evidenza della precedente ripresa

| Controllo | Esito |
| --- | --- |
| Regressione Dart prima della correzione | Fallita: A new tune must clear the previous failure |
| dart tool/check_player_state.dart | Superati 2 controlli dopo la correzione |
| Formattazione lib/test/tool | Eseguita; controllo finale senza modifiche |
| flutter analyze --no-pub | No issues found |
| flutter build bundle --debug --no-pub | Exit code 0; bundle Dart/asset compilato |
| flutter test --no-pub --reporter expanded | Runner bloccato prima dei test: socket 127.0.0.1 vietato (Operation not permitted) |
| APK, installazione e background su telefono | Non certificati in questa ripresa |

I precedenti report dichiarano 13 test e connessioni live; mancano qui log grezzi e una prova Android registrata, perciò non sono una certificazione attuale. L'APK del template aveva già incontrato il blocco socket di Gradle; nessun tentativo ripetuto senza cambiamenti all'ambiente.

## Prossimo passo

In un terminale normale, con Flutter 3.38.5 e SDK Android configurato, eseguire dalla directory frequenza:

```sh
bash tool/check.sh --apk
flutter run
```

Prima di chiudere la fase 2: provare almeno dieci candidati su tre Paesi con il player Android, documentare esiti e device; verificare schermo spento, cuffie/interruzioni, notifica e redirect/segmenti HTTP. Solo dopo i controlli dinamici si possono certificare regressioni audio e stato live.

Rimangono da completare discovery dinamica dei mirror, retry/cancellazione robusti nel player, cache, preferiti e ripresa della diretta; i primi due vanno verificati nella prova tecnica, gli altri nell'integrazione prevista. Il filtro dell'URL iniziale non prova che tutti i redirect/segmenti siano HTTPS.

La fase 3 parte da un mockup da mostrare a Davide: radio da viaggio, display della stazione/Paese, Sintonizza, pausa e preferiti. Nessuna UI definitiva o animazione avanzata approvata ancora.

## Integrazione UI approvata — verifica più recente

- Davide ha approvato il mockup radio da viaggio corretto e l'integrazione. Animazioni avanzate esplicitamente rinviate.
- Home sostituita con RadioPage/RadioCabinet: manopola come sola azione primaria, display di stazione/Paese/stato, Pausa/Riprendi, Salva/Salvata e pulsante Preferiti con conteggio.
- Preferiti persistenti via SharedPreferences, identificati per station ID. Pannello dal basso con vuoto/caricamento/errore, rimozione e sintonizzazione. Fallimento di scrittura preserva l'elenco precedente.
- Riutilizzati player/controller e componenti Material; RadioProofPage resta nel codice per la diagnostica. Localizzazione IT/EN completa per la nuova UI.
- Nuova dipendenza concreta: shared_preferences; intl esplicitato e vincolato alla famiglia compatibile con Flutter localization.
- Il runtime di test Flutter ora parte: suite completa **18/18 passata**. Coperti avvio senza autoplay, manopola, salvataggio, riapertura archivio, scrittura fallita, ascolto dai preferiti e display 320px/testo 200%.
- `flutter analyze --no-pub`: No issues found. `flutter build bundle --debug --no-pub`: exit 0. Formattazione verificata.
- Tentata build APK release con Java configurato e cache dedicate: avvio daemon Gradle rifiutato (`java.net.SocketException: Operation not permitted`). Nessun APK consegnato o prova su telefono dichiarata.
- Unica revisione indipendente: nessun difetto importante. Copertura UI di rimozione dal pannello e load-error/retry non dedicata: nota minore rinviata; toggle e scrittura fallita coperti dal controller.

Prossimo passo: eseguire `bash tool/check.sh --apk` in ambiente Android abilitato e provare la UI/player su telefono. Poi rifinire le animazioni (manopola, ricerca, display), rispettando riduzione movimento e stato reale del player. La precedente nota «nessuna UI definitiva approvata» è superata da questa approvazione; le verifiche tecniche Android aperte restano valide.
