# Frequenza — stato verificato al 10 novembre 2026

Fase attiva: 2, prova tecnica implementata e corretta; validazione Android aperta.
Piano attivo: phase-2-follow-up.md. Roadmap: ../../flutter_starter/docs/project/roadmap.md.

## Lavoro di questa ripresa

- Riutilizzati i repository esistenti; nessuna ricostruzione del template.
- Riprodotto con Dart puro un errore nello stato: un nuovo tentativo conservava il messaggio precedente. Corretto con clearError esplicito e regressione riproducibile.
- Avvio live separato dalla durata dello stream: just_audio.play() termina alla pausa/stop/fine, perciò non viene atteso per concludere l'avvio. Errori del future gestiti nello stato.
- Subscription audio annullate alla chiusura; eventi tardivi ignorati dopo disposal.
- Aggiunti test per recupero errore e comportamento del future live, senza dichiararli eseguiti.
- Una revisione indipendente limitata al diff non ha trovato nuovi problemi. Disposal delle subscription non ha un test dedicato: limite noto della copertura.

## Evidenza attuale

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
