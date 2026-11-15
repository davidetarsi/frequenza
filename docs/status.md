# Frequenza — stato verificato al 14 novembre 2026

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

## Rifinitura design — radio e pannello preferiti

Richiesta: fermare la ricerca audio e migliorare la resa visiva. Piano: superpowers/plans/2026-11-10-design-polish.md.

- Radio: scocca sfumata con cornice/profondità, maniglia aperta, display incassato, griglia stratificata e manopola metallica con indice e tacche decorative. Nessun nuovo comando o animazione continua.
- Preferiti: route Material conservata per accessibilità/gesti, superficie custom coordinata con palette della radio, schede con Paese, evidenza della stazione in ascolto, rimozione e chiusura. Non più il foglio Material predefinito.
- Palette condivisa di prodotto in ui/theme/travel_radio_palette.dart, usata anche dallo sfondo dell'app. Il template generico resta neutro.
- Controllate visivamente catture Flutter a 390×844 della home e del pannello, con font reali. Catture temporanee usate per QA, non nuove immagini di prodotto.
- Suite: 19/19 passata; aggiunta regressione rimozione dal pannello e caricamento fallito/retry. Corretto overflow del marchio sulla radio con testo al 200%. Analyzer senza segnalazioni; bundle ricompilato.
- Aggiornato l'emulatore già attivo tramite flutter attach + hot reload: 11 librerie ricaricate, senza riavviare l'app. Sessione di attach poi scollegata.

### Stato del template

Uso corretto di separazione per feature, contratti Dart, adapter persistenti e test con override. Nessuna dipendenza radio/audio aggiunta al template. Il design del prodotto vive solo in Frequenza.

Scostamenti preesistenti ancora aperti: provider manuali/StateNotifier invece della code generation usata dall'esempio; data/just_audio_service importa la porta audio da application, da spostare in domain quando si interviene sull'architettura. Non è stata fatta una migrazione degli strumenti durante il restyling. Lo stile del pannello è specifico della radio: non estrarlo nel template prima di un secondo uso concreto.

Prossimo passo: feedback sul design nell'emulatore, poi lavoro mirato sulle animazioni già rinviate. Ricerca sul silenzio audio sospesa esplicitamente su richiesta di Davide; nessuna causa o risoluzione definitiva dichiarata.

## Scocca e display — 11 novembre 2026

- Scocca centrata a 360 px logici, limitata dai vincoli disponibili nelle finestre più strette. Le spaziature esterne variano entro limiti. Display con spazio riservato per stazione, dettaglio, indicatore a barre e stato.
- Manopola e griglia allineate e di diametro 112 px logici. Rimossa la didascalia della manopola in IT/EN.
- L'indicatore a barre è decorativo e compare in ascolto. Il titolo arriva da ICY se lo stream lo fornisce e viene azzerato a ogni nuova sintonizzazione.
- Verificati stabilità a 390 e 620 px e durante la sintonizzazione, accesso ai preferiti a 320×640 con testo al 200%, parità dei diametri, titolo simulato e azzeramento. Suite 19/19, analyzer pulito e bundle debug compilato.
- Prossimo passo: riscontro visivo su Android e verifica dei metadati su stream reali quando riprende il collaudo audio.

## Home senza scorrimento — 11 novembre 2026

- La home usa un layout non scorrevole. Scocca e comandi compatti nelle finestre basse, display e manopola affiancati in orizzontale. Rimossi i testi promozionali esterni alla radio.
- Verificati sintonizzazione, pausa, salvataggio e apertura preferiti in viewport simulati. Il caso a 320×640 e 640×320 include testo al 200% e margini di sistema simulati. Suite 19/19, analisi pulita e bundle debug compilato.
- Prossimo passo: feedback visivo su Android e collaudo dei metadati su stream reali.

## Didascalie ripristinate — 11 novembre 2026

- Ripristinati «Prossima fermata: ovunque» sopra la radio e il footer «WEB RADIO · SENZA CONFINI», con le traduzioni esistenti.
- Scocca verticale a 344 px logici, manopola e speaker ridotti allo stesso diametro. Nel layout compatto le barre condividono la riga di stato.
- Home senza scorrimento verificata in verticale e orizzontale con testo al 200%. Suite 19/19, analisi pulita e bundle debug compilato.

## Movimento e fruscio di sintonizzazione — 11 novembre 2026

- Le barre del display si muovono solo in play, si fermano in pausa e rispettano la riduzione del movimento. Il disegno è decorativo.
- La ricerca casuale dura almeno un secondo. Su Android, un fruscio sintetico locale riprodotto tramite SoundPool accompagna la ricerca e termina prima di caricare la diretta. SoundPool si ferma anche quando l'attività va in background. La scelta dai preferiti resta immediata.
- Verificati 19 test, analisi pulita e APK debug ARM64. Sull'emulatore, AudioFlinger ha registrato l'aggiunta e la rimozione della traccia del fruscio a circa 1,3 s di distanza, prima dell'avvio della traccia della diretta. La sessione di collaudo è stata messa in pausa.
- Prossimo passo: riscontro d'ascolto del fruscio su telefono e collaudo della riproduzione in background su dispositivo reale.

## Adozione dello starter — 11 novembre 2026

- Radio e Preferiti usano modelli e stati Freezed e provider Riverpod generati. Il contratto del player è nel dominio, con composizione in application.
- Home, pannello preferiti e schermata diagnostica usano componenti e token condivisi dallo starter. Tema base identico e palette radio passata dal prodotto.
- Preferiti v1 verificati con un record preesistente, inclusi i campi facoltativi e i tag malformati. Rigenerazione, formattazione, analisi, suite 20/20 e APK debug ARM64 verificati.
- La prova di riuso da zero con una seconda app neutra resta aperta nella fase 7.

## Preferiti asincroni — 12 novembre 2026

- Il provider generato espone AsyncValue. La lista confermata resta visibile durante la scrittura e dopo un errore. Il caricamento fallito resta recuperabile dal pannello.
- Code generation, analisi, bundle debug e 20 test verificati. Il prossimo intervento sulla base condivisa è nella roadmap dello starter, sezione Evoluzione dello starter secondo le convenzioni PackLog.

## Base condivisa adottata — 12 novembre 2026

- GoRouter collega home e Impostazioni. Easy Localization genera loader e chiavi dai cataloghi IT/EN. Le Impostazioni condivise espongono lingua e tema Sistema, Chiaro o Scuro con preferenze persistenti.
- Palette e token della home, scocca, equalizzatore, pannello Preferiti e diagnostica sono centralizzati nel tema di prodotto. I widget comuni seguono la base dello starter.
- Verificati generazione, formattazione, analisi, 20 test e APK debug ARM64. Sull'emulatore verificato il percorso home → Impostazioni → home. I test simulano il riavvio per lingua e tema nello starter e il cambio in Frequenza.
- Restano la prova della seconda app neutra e i moduli opzionali della roadmap, incluso Tgram Analytics per gli eventi prodotto.

## Notifica tramite audio_service — 12 novembre 2026

Passo 1 del design `superpowers/specs/2026-11-12-rotta-sul-mondo-design.md`; piano `superpowers/plans/2026-11-12-audio-service.md`.

- Rimosso `just_audio_background`. `RadioAudioHandler` (audio_service diretto) pubblica stato e comandi della notifica dallo stesso `AudioPlayer`; `JustAudioService` passa nome, Paese e logo della stazione tramite `RadioMediaSession`. Canale, opzioni di notifica e contratto del controller invariati.
- Verificati sulla VPS: formattazione, analisi senza segnalazioni, controlli dello stato del player, suite 31/31, bundle debug. Una revisione indipendente del branch ha portato a due correzioni: notifica ferma quando lo stream finisce e lock riportato sulle versioni del progetto. APK release non verificato: la build sulla VPS è stata fermata per memoria insufficiente.
- La VPS ha Flutter 3.47.4: `pub get` riscrive il lock e `build_runner` si blocca sull'analyzer. Il lock è stato modificato a mano e il provider `radioAudioHandler` scritto a mano nel `.g.dart`: rieseguire `bash tool/check.sh --apk` con Flutter 3.38.5 e versionare eventuali differenze.
- Prossimo passo: collaudo su telefono (checklist in fondo al piano), poi passo 2, la Rotta sul mondo.

## Rotta sul mondo — 12 novembre 2026

Passo 2 del design `superpowers/specs/2026-11-12-rotta-sul-mondo-design.md`; piano `superpowers/plans/2026-11-12-rotta-sul-mondo.md`. Branch `feat/rotta-sul-mondo` sopra `feat/audio-service`, non ancora pubblicato.

- Manopola e Preferiti seguono lo stesso volo. Il volo dura almeno 1 s, con il fruscio e la stazione a volume zero. L'atterraggio avviene solo con la riproduzione avviata e solo allora la notifica mostra la stazione. Dopo 12 s senza riproduzione compare «Segnale perso»: la manopola fa fino a 2 nuovi tentativi, il preferito nessuno. Una pausa di sistema durante il volo (cuffie, chiamata) annulla il volo.
- Display: mappa a puntini (Natural Earth) al posto delle barre nel layout normale, con scia radar, arco, storico di 5 rotte e «Viaggio n. X». Mostra anche distanza del tratto e ora locale con icona. Nel layout compatto l'ora prende il posto delle barre.
- L'atlante (`lib/features/journey/data/world_atlas.g.dart`) si rigenera con `bash tool/world_atlas/generate.sh`, che usa la tzdata del sistema. L'Egitto e Lord Howe usano l'ora solare. Il Cile può sbagliare l'ora legale di una settimana in alcuni anni.
- Flutter 3.38.5 del progetto è installato sulla VPS in `/srv/claude/workspaces/.tools/flutter-3.38.5`. Verificati `tool/check.sh` (lock invariato), analisi pulita e suite 69/69, più una revisione indipendente del branch con quattro correzioni. APK non compilato sulla VPS.
- Limiti noti: su iOS il volo è muto. Pausa dalla notifica durante il volo: la stazione resta muta, il volo scade in «Segnale perso» e la manopola può riprovare.
- Prossimo passo: push dei due branch e PR, collaudo su telefono (checklist del passo 1, volo da manopola e Preferiti, niente audio prima dell'atterraggio, notifica «In volo…», modalità aereo, riduzione del movimento), poi aggiornamento di Flutter.

## Pipeline di rilascio — 13 novembre 2026

Design `superpowers/specs/2026-11-12-pipeline-design.md`; piano `superpowers/plans/2026-11-13-pipeline.md`. Branch `feat/pipeline`, che contiene anche la Rotta sul mondo (merge): da unire in `develop` dopo le PR della notifica e della Rotta.

- Due versioni installabili insieme: «Frequenza» (`it.davidetarsi.frequenza`) e «Frequenza Dev» (`.dev`), un solo `main.dart`. `default-flavor: dev` nel pubspec: `flutter run` e `tool/check.sh --apk` costruiscono la dev senza `--flavor`; per la prod `flutter build appbundle --flavor prod`.
- Firma da `android/key.properties` (ignorato da git); senza il file le release si firmano con la chiave di debug.
- Icona manopola generata da `python3 tool/icon/generate.py` (adattiva, monocromatica, PNG per densità, 512 per lo Store).
- Workflow: `ci.yml` (check.sh + `git diff --exit-code`; versione dalle etichette verso `main`), `bump_version.yml`, `build_dev.yml` (APK su Telegram), `release_prod.yml` (prerelease senza file, AAB negli artifact, Play solo con `PLAY_UPLOAD=on`, canale `PLAY_TRACK` o `alpha`), `promote_prod.yml` (a mano), `store_listing.yml`. Logica delle versioni in `.github/scripts/version.cjs`.
- `tool/check.sh` lancia anche i test Node delle versioni e i test Python (icona, workflow, scheda). Senza PyYAML in locale i test dei workflow si saltano; in CI sono obbligatori.
- Verificati sulla VPS: check.sh verde (69 test Flutter, 6 Node, test Python), APK dev e prod debug, APK dev release firmata con la chiave di debug (`aapt2`: id e nome giusti), script dei due workflow delle versioni simulati con GitHub finto. Le pipeline vere si verificano solo su GitHub: annotare qui l'esito della prima esecuzione di ognuna.
- Prossimo passo: azioni manuali in `docs/azioni-manuali.md` (segreti, variabili, etichette, regole), merge in `develop`, prima APK dev su Telegram e collaudo su telefono.

## Ritocchi interfaccia — 14 novembre 2026

Design `superpowers/specs/2026-11-14-ritocchi-ui-design.md`, piano `superpowers/plans/2026-11-14-ritocchi-ui.md`, branch `feat/ritocchi-ui`.

- Pausa e Salva sono tasti a leva dentro la radio, solo icone; restano abbassati in pausa o con la stazione salvata. Radio larga 320, mappa alta 84.
- In alto solo il cuore, con il numero dei preferiti nel colore primario.
- Impostazioni nello stesso foglio dei Preferiti (`TravelSheet`); la pagina `/settings` non c'è più.
- «ORA LOCALE» sopra l'orario nella disposizione normale; in quella compatta resta l'icona dell'orologio.
- Pressione lunga sul titolo della canzone: copia, vibrazione, «Titolo copiato» solo sotto Android 13 (metodo `sdkInt` sul canale nativo).
- Verificato: `tool/check.sh` verde (76 test Flutter), build dev debug.
- Aperto: collaudo sul telefono (aspetto dei tasti nei due temi, vibrazione, conferma di copia su Android 13+).
- Prossimo passo dopo il collaudo: ricerca per paese o per nome della stazione (Radio Browser ha già i filtri necessari).

## Notifica — 14 novembre 2026

Design `superpowers/specs/2026-11-14-notifica-design.md`, piano `superpowers/plans/2026-11-14-notifica.md`, branch `feat/notifica`.

- Tasti: indietro (a pila vuota riconnette la stazione), play/pausa, avanti, cuore; niente stop; in volo solo play/pausa. Sotto Android 13 il cuore non compare (limite accettato).
- Indietro: pila delle ultime 10 stazioni lasciate, solo sessione; il ritorno è un volo e conta come viaggio.
- Cuore della notifica e preferiti dell'app sempre allineati (provider `radioNotification`).
- Icona piccola: manopola bianca `ic_stat_frequenza`; immagine grande: logo della stazione o, se manca, il logo di Frequenza copiato nella cache.
- Verificato: `tool/check.sh` verde, build dev debug con icone e logo nell'APK.
- Da provare sul telefono: aspetto su Android 13+ e sotto, tasti da schermata di blocco, cuore e indietro dopo vari voli, logo di ripiego su una stazione senza logo.

## Larghezze in proporzione allo schermo — 14 novembre 2026

- Titolo e icone in alto usano tutta la larghezza, meno un margine del 3% dello schermo (12–24 punti).
- La radio è l'88% della larghezza dello schermo (280–420 punti, mai oltre lo spazio disponibile), arrotondata a punti interi: 343 su un telefono da 390, 281 su uno da 320.
- Tutti i valori in `TravelRadioLayout`; i pezzi interni della radio restano a misura fissa (la radio tutta in proporzione è rimandata).

## Allineamento alle convenzioni dello starter — 15 novembre 2026

- Controllo contro le convenzioni ereditate da PackLog. Allineati: code generation, Riverpod annotato, Easy Localization, tema chiaro e scuro, UI in `lib/ui`, feature first, pipeline GitHub. Supabase e Drift non servono.
- Corretti tre scostamenti:
  - `GeoPoint`, `StationPlace` e `TravelLeg` ora sono Freezed;
  - tolte dal codice tre stringhe in italiano (errore dello stream, «Sconosciuto», «Mondo»). Il paese mancante ora resta vuoto e l'interfaccia mostra «Paese sconosciuto» tradotto;
  - colore trasparente scritto a mano sostituito con `Colors.transparent`.
- Rimosso `RadioPlayerState.errorMessage`, che non veniva mai mostrato. Rimosso anche `tool/check_player_state.dart`: il suo caso è coperto dai test del controller.
- I preferiti salvati prima con paese «Mondo» lo conservano: è un dato già scritto in memoria.
- Da fare quando lo starter sarà su GitHub: confronto completo file per file.

## Etichetta della manopola su una riga — 15 novembre 2026

- La scritta sotto la manopola non va mai a capo. Se non ci sta, scorre verso sinistra (`MarqueeText` in `lib/ui/widgets`): pausa di 1,2 secondi con l'inizio in vista, poi 3 giri e si ferma sull'inizio. Con le animazioni disattivate è tagliata con «…». TalkBack la legge una volta sola.
- Il calcolo è dinamico: si misura il testo con la scala del carattere e lo si confronta con lo spazio disponibile. Nessuna larghezza fissata a mano; velocità, spazio tra le copie, pausa e giri sono token in `AppMotion`.
- Impostazioni senza sottotitolo: in `TravelSheet` il sottotitolo ora è facoltativo.

## Lingue con la sigla — 15 novembre 2026

- Nelle impostazioni ogni lingua ha la sua targhetta «IT» / «EN» al posto del globo, nello stile delle sigle dei Preferiti (`CodeBadge` in `lib/ui/widgets`, misure in `CodeBadgeDesign`). Prende il colore dell'icona, quindi anche quello della selezione.
- Ogni lingua è scritta nel suo nome in entrambe le lingue dell'app: «Italiano», «English».
- Scelta al posto delle bandiere: una lingua non è un paese, e le bandiere emoji cambiano da telefono a telefono.

## Radio bloccata in «Connessione alla radio» — 15 novembre 2026

Segnalato da Davide: con l'app in background la musica si ferma dopo pochi secondi, la notifica gira a vuoto e, riaperta l'app, manopola e tasti sono spenti.

- Lo stream smette di arrivare (buffering) e niente lo interrompeva: ora, se una stazione atterrata resta in buffering per 10 secondi (`FlightTiming.stallTimeout`), la radio si riconnette da sola con il volo di riconnessione, fino a 3 tentativi; se fallisce mostra l'errore con «Riprova».
- Durante il buffering di una stazione accesa manopola, pausa e cuore restano attivi: solo il volo li spegne.
- Una pausa mentre lo stream si riempie vale come pausa (`JustAudioService`), così la riconnessione non riaccende una radio messa in pausa.
- Ancora da capire: perché lo stream si ferma in background. Ipotesi: Android limita la rete all'app quando il servizio in primo piano cade. Serve un logcat dal telefono per confermarla.

## Macchine a stati esplicite — 15 novembre 2026

Piano `superpowers/plans/2026-11-15-macchine-a-stati.md`, branch `refactor/macchine-a-stati`.

- La radio è una `RadioSession` sealed (spenta, in volo, in onda, fallita) con `Journey` sempre presente. Le transizioni stanno in `next()` (`features/radio/domain/radio_session.dart`) con la loro tabella; il controller esegue solo gli effetti.
- La schermata legge `RadioDisplay.of(session)`: un solo `switch` esaustivo per titolo, paese, stato, manopola e tasti.
- «In volo» ha una sola fonte: la notifica lo sa solo da `showControls`, il motore audio segnala le pause di sistema (`systemPauses`) e decide la radio.
- Preferiti e tema salvano con `LatestSave` (`lib/app/state`).
- Cancellata la pagina di prova non raggiungibile, con il suo test e 24 chiavi di traduzione.
- Regola sealed/`AsyncValue` in `AGENTS.md`. Da portare nello starter: la regola, `LatestSave`, `CodeBadge`, `MarqueeText` e un esempio di feature con stato sealed.
- Verificato: `tool/check.sh` verde, 160 test. Da provare sul telefono: voli, indietro, pausa con le cuffie, notifica durante una nuova sintonia.

## Notifica in pausa — 15 novembre 2026

Design `superpowers/specs/2026-11-15-notifica-in-pausa-design.md`, piano `superpowers/plans/2026-11-15-notifica-in-pausa.md`, branch `feat/notifica-in-pausa`, sopra `refactor/macchine-a-stati`.

- Mentre suona o vola la notifica resta fissa. In pausa all'inizio si poteva scorrere via; dal fix del servizio in primo piano (sotto) resta fissa anche in pausa.
- Dopo 10 minuti di pausa (`FlightTiming.pauseTimeout`) lo stream si chiude e con lui la notifica; l'app mostra ancora la stazione, «Pronta a partire».
- App tolta dalle recenti: in pausa chiude servizio e notifica; mentre suona o vola continua (`RadioAudioHandler.onTaskRemoved`).
- Play su uno stream chiuso (app, cuffie, Bluetooth) rifà il volo di riconnessione verso la stessa stazione (`RadioMediaCommand.resume` → `RadioController.play`).
- Da provare sul telefono: scorrere via la notifica in pausa; togliere l'app dalle recenti mentre suona e in pausa; pausa lunga (per provarla, abbassare `pauseTimeout`); play dalle cuffie dopo la chiusura.
- Limite noto: dopo aver tolto l'app dalle recenti in pausa, il servizio e il motore Dart si chiudono; un play dalle cuffie riapre l'app da spenta, senza riconnettere. Da verificare anche che non chiuda l'app per errore (Android 12+ e avvio del servizio da un tasto multimediale).

## Suono di sintonizzazione — 15 novembre 2026

Design `superpowers/specs/2026-11-15-suono-sintonia-design.md`, piano `superpowers/plans/2026-11-15-suono-sintonia.md`, branch `feat/suono-sintonia`, sopra `feat/notifica-in-pausa`.

- Nuovo fruscio «C2» scelto da Davide: morbido e ovattato, timbro che scivola dal cupo al chiaro, stazioni che affiorano; 7,4 s in loop senza stacco. Generato da `tool/tuning_sound/generate.py` (seme fisso, test in `tool/test_tuning_sound.py`); il WAV passa da 44 KB a 650 KB.
- Android: `MediaPlayer` al posto di `SoundPool`; ogni volo parte da un punto a caso; volume `TUNING_VOLUME = 0.42f`; all'atterraggio sfuma in 400 ms; uscendo dall'app si ferma subito.
- La stazione sale di volume in 400 ms (8 passi) mentre il fruscio sfuma; una nuova sintonia interrompe la salita.
- Verificato: `tool/check.sh --apk` verde. Da provare sul telefono: volo lungo con il passaggio di fine loop; dissolvenza all'atterraggio; due voli di fila non identici; voli ravvicinati (il fruscio deve ripartire, non spegnersi).

## Vite in alto e voce «Informazioni» — 15 novembre 2026

Branch `feat/informazioni-e-vite`, sopra `feat/suono-sintonia`.

- La vite in alto a destra restava sul bordo solo prima del primo viaggio: la scritta «Viaggio n.» ora è allineata a destra nella sua metà, e la vite resta ferma accanto al numero (test con testo piccolo, come sul telefono).
- Impostazioni: nuova sezione «Informazioni» («About») con la voce «Visualizza progetto su GitHub» («View project on GitHub») e l'icona ↗; apre `https://github.com/davidetarsi/frequenza` (repository pubblico) con `url_launcher`, nuova dipendenza ufficiale di Flutter. Se il link non si apre compare «Impossibile aprire il link». L'indirizzo sta in `AppLinks` (`lib/app/links/external_links.dart`).
- Verificato: `tool/check.sh --apk` verde, 182 test. Da provare sul telefono: il link apre il browser o l'app di GitHub; la vite non si sposta dopo il primo viaggio.

## Servizio in primo piano anche in pausa — 15 novembre 2026

- **Il bug:** la radio in background si fermava dopo pochi secondi, con la notifica in caricamento. Il logcat di Davide mostra la radio in riproduzione senza servizio in primo piano: Android silenzia l'audio (`AudioHardening`) e congela il processo; quando l'app prova a tornare in primo piano dal background, `startForegroundService()` viene vietato.
- **La causa:** con `androidStopForegroundOnPause: true`, audio_service toglie il servizio dal primo piano a ogni pausa (anche di sistema: cuffie, chiamate, audio di un'altra app) e lo riprende solo quando la riproduzione riparte. Se riparte dal background, per esempio dal tasto delle cuffie, Android lo vieta.
- **Il fix:** `androidStopForegroundOnPause: false`, scelto da Davide. Il servizio resta in primo piano anche in pausa, quindi la notifica in pausa non si scorre via. Si chiude da sola dopo 10 minuti di pausa, oppure togliendo l'app dalle recenti.
- **La chiusura:** audio_service chiude il servizio sul passaggio a `idle`, ma non lo toglie dal primo piano, e la notifica di un servizio in primo piano non si cancella. Per questo, quando la radio si ferma davvero (stop, fine dello stream, errore), `RadioAudioHandler` chiede ad Android, prima di mostrare il nuovo stato, di togliere il servizio dal primo piano: metodo `leaveForeground` di `MainActivity`, che chiama `RadioForeground` (nel package del plugin) e la routine del plugin `exitForegroundState`, tenuta da R8 in `android/app/proguard-rules.pro`. Così si rilascia anche il wake lock. Rilievo della revisione indipendente.
- **Da provare sul telefono:** «Spegni» con l'app aperta, la notifica deve sparire; pausa, poi altra app, poi play dal tasto delle cuffie Bluetooth; la radio in background per qualche minuto mentre si usano altre app; la pausa lunga (si chiude dopo 10 minuti); togliere l'app dalle recenti in pausa.

