# Pipeline di rilascio — design

Data: 12 novembre 2026, aggiornato il 13. Stato: bozza, da approvare da Davide.

Legenda: **[D]** = deciso da Davide; **[C]** = scelta proposta da Claude, da confermare leggendo. Il resto è vincolo derivato dal codice o da PackLog.

## Intento

Frequenza arriva sul Play Store per una decina di amici. Prima passa dal test chiuso, poi va in produzione. Lo scopo dichiarato è anche imparare il processo di pubblicazione sul Play Store **[D]**. Per questo si riprende il sistema di PackLog: PR, branch `develop` e `main`, APK dev a ogni merge, rilascio firmato da `main`. Lo si adatta a un'app senza backend e senza login. La prima versione che Davide installa è la dev **[D]**.

## Obiettivi

- Due versioni Android installabili insieme sullo stesso telefono **[D]**:
  - **Frequenza**, `it.davidetarsi.frequenza` **[D]**;
  - **Frequenza Dev**, `it.davidetarsi.frequenza.dev`.
- Stessa icona per le due, la manopola (proposta 1 della tavola https://claude.ai/artifact/KknrUgBnLJ1mKAjGCeG7th) **[D]**. Cambia solo il nome sotto l'icona **[D]**.
- PR verso `develop` e verso `main` controllate in automatico. Il merge su `develop` produce l'APK dev. Il merge su `main` produce la versione firmata e la carica nel **test chiuso** del Play Store **[D]**.
- Passaggio dal test chiuso alla **produzione** avviato a mano da Davide, quando decide **[C]**.
- Numero di versione aggiornato dalle etichette della PR verso `main`, come in PackLog.
- Scheda dello Store versionata nel repo, inviata da una pipeline come in PackLog.

## Non obiettivi

- iOS e App Store.
- Servizi esterni per ambiente (backend, analytics, crash reporting): Frequenza non ne ha. Non si aggiungono.
- Pubblicazione automatica in produzione.
- Distribuzione dell'APK dev con altri servizi (Firebase App Distribution, link pubblici): basta il bot Telegram.
- La versione prod su Telegram: arriva agli amici solo dal Play Store **[C]**.
- Pagina delle norme sulla privacy e grafiche dello Store (screenshot, immagine 1024×500): si preparano a parte, sono voci della lista `docs/azioni-manuali.md`.
- Modulo opzionale nello starter: viene dopo, quando su Frequenza funziona **[D]**.

## Anti-obiettivi

Questi casi rendono il lavoro sbagliato anche se le pipeline «girano».

- Una chiave, una password o il JSON dell'account di servizio nel repo o nei log.
- Una versione per il Play Store firmata con la chiave di debug.
- La dev che si installa al posto della versione del Play Store, o viceversa.
- Un rilascio che finisce in produzione senza un gesto esplicito di Davide.
- La stessa versione caricata due volte con contenuti diversi, oppure un tag spostato su un altro commit.
- Pipeline rosse per un motivo diverso da un problema vero del codice. Per esempio il rilascio che fallisce finché il primo AAB non è stato caricato a mano.

## Comportamento

### Le due versioni dell'app

- Due flavor Android, `dev` e `prod`, nella dimensione `app_environment` come PackLog. La dev aggiunge `.dev` all'id e si chiama «Frequenza Dev».
- **Un solo `main.dart`** **[C]**. In PackLog `main_dev.dart` e `main_prod.dart` passano a `bootstrap` un ambiente diverso, che sceglie servizi e chiavi diversi. Frequenza non ha niente da scegliere: la differenza vive solo nella configurazione Android (id, nome). Il codice Dart resta uno ed è identico nelle due versioni.
- Comandi:
  - `flutter run --flavor dev`;
  - `flutter build apk --flavor dev`;
  - `flutter build appbundle --flavor prod`.
- Nuovo id anche nel resto del progetto **[C]**: `namespace` Gradle, pacchetto Kotlin di `MainActivity`, id del canale della notifica e User-Agent verso Radio Browser. Nessuno ha ancora installato l'app, quindi non c'è niente da migrare.
- Icona:
  - adattiva (sfondo verde scuro, manopola in primo piano nell'area sicura);
  - monocromatica, per le icone a tema di Android 13+;
  - versioni per tutte le densità;
  - 512×512 per il Play Store.

  Le due versioni usano le stesse risorse.

### Firma

- `android/key.properties`, ignorato da git, letto da Gradle come in PackLog. Se esiste, le build release usano la chiave indicata, altrimenti la chiave di debug locale. Così `flutter run --release` funziona sul computer di Davide senza chiavi.
- **Dev:** chiave dev stabile, dal segreto `DEBUG_KEYSTORE_BASE64`, così ogni APK dev si installa sopra la precedente.
- **Prod:** chiave di upload, dai segreti `KEYSTORE_*`. Il Play Store la sostituisce con la sua (firma delle app di Google Play).

### Pipeline (GitHub Actions)

Flutter fissato a 3.38.5, come nel progetto. Nomi e struttura ripresi da PackLog dove non c'è motivo di cambiarli.

1. **Controlli sulle PR** (`ci.yml`), su PR verso `develop` e `main`:
   - lancia `bash tool/check.sh`: dipendenze, l10n, codice generato, formattazione, analisi, controllo dello stato del player, test;
   - poi verifica che i file generati e versionati non risultino cambiati (`git diff --exit-code`) **[C]**;
   - solo per le PR verso `main`, verifica che ci sia esattamente un'etichetta `version:major|minor|patch` e che `pubspec.yaml` sia stato aggiornato di conseguenza (job «Android Version Selection», come PackLog).
2. **Versione automatica** (`bump_version.yml`): identico a PackLog. Quando una PR verso `main` riceve l'etichetta, aggiorna `version:` nel branch della PR. Usa `PAT_TOKEN`, perché i commit fatti con il token predefinito non riavviano i controlli.
3. **APK dev** (`build_dev.yml`), a ogni push su `develop` (escluse le modifiche solo a `docs/`, `test/` e file `.md`) e a mano:
   - APK arm64 del flavor dev;
   - versione `X.Y.Z-dev.<numero della run>` e numero di build = numero della run;
   - si scarica dalla tab Actions, conservato 7 giorni;
   - viene mandato in chat dallo **stesso bot Telegram di PackLog** **[D]**, con lo step di PackLog: segreti `TELEGRAM_BOT_TOKEN` e `TELEGRAM_CHAT_ID`, didascalia con versione, ultimo commit e link alla run, solo link oltre i 50 MB. Senza i due segreti lo step si salta e l'APK resta solo nella tab Actions.
4. **Rilascio** (`release_prod.yml`), a ogni push su `main`:
   - verifica la versione e il tag `vX.Y.Z`: si ferma se il tag esiste su un altro commit;
   - costruisce AAB e APK prod firmati;
   - crea il tag e una prerelease GitHub **senza file allegati**, con solo le note **[D]**: il repo è pubblico e i file firmati non devono essere scaricabili da una pagina pubblica;
   - AAB e APK prod restano come artifact della run, conservati 30 giorni **[D]**. (Su un repo pubblico gli artifact li scarica chi ha un account GitHub: Davide lo sa e va bene così.)
   - carica l'AAB nel **test chiuso**: il canale è la variabile del repository `PLAY_TRACK`, predefinita `alpha` (il test chiuso predefinito della Play Console) **[C]** con le novità prese da `distribution/whatsnew/`.
   - **Il caricamento sul Play Store parte solo se la variabile del repository `PLAY_UPLOAD` vale `on`** **[C]**. Google accetta caricamenti automatici solo dopo il primo AAB caricato a mano. Fino ad allora la pipeline si ferma, verde, dopo la prerelease GitHub. Davide scarica l'AAB per il primo caricamento dagli artifact della run.
5. **Promozione in produzione** (`promote_prod.yml`), solo a mano **[C]**:
   - dalla tab Actions, Davide sceglie la versione;
   - la pipeline la sposta dal test chiuso alla produzione con fastlane `supply`;
   - la percentuale di distribuzione è opzionale, predefinita 100%.
   - Finché l'account non ha superato i 14 giorni con 12 tester, Google rifiuta la promozione e la pipeline fallisce con il messaggio di Google: è atteso.
6. **Scheda dello Store** (`store_listing.yml`), come PackLog:
   - testi in `fastlane/metadata/android/it-IT` e `en-US`;
   - prova a vuoto sulle PR che li toccano;
   - invio vero solo a mano.
   - In questo lavoro entrano i testi (titolo, descrizione breve e lunga) e l'icona 512. Screenshot e grafica arrivano dopo.

### Versioni

- `pubspec.yaml` passa a `version: 0.1.0+1`, perché le pipeline richiedono la forma `MAJOR.MINOR.PATCH+BUILD`.
- **Il primo rilascio è un caso speciale** **[C]**:
  - su `main` la versione è ancora `0.1.0`, senza `+BUILD`, e `bump_version.yml` arriva su `main` solo con quella stessa PR;
  - il controllo «Android Version Selection» accetta una versione di base senza `+BUILD` e la tratta come `+0`;
  - per la prima PR `develop → main` (etichetta `version:minor`) la versione attesa è quindi `0.2.0+1`, e va scritta a mano su `develop` con una piccola PR prima di aprire il rilascio;
  - dal secondo rilascio in poi il bump è automatico, come in PackLog.

### Regole dei branch

Le imposta Davide su GitHub (lista in `docs/azioni-manuali.md`, punto E):
- PR obbligatoria su `develop` e `main`;
- controlli verdi obbligatori;
- niente force push né cancellazione.

Le PR di funzionalità vanno verso `develop`. Le PR `develop → main` sono i rilasci.

## Vincoli

- **Punto di partenza** **[C]**: il lavoro parte dopo le due PR aperte (notifica e Rotta sul mondo), perché la rinomina tocca `bootstrap.dart`, `radio_browser_repository.dart` e `pubspec.yaml`, che quelle PR cambiano. Se non sono ancora unite, `feat/pipeline` parte da `feat/rotta-sul-mondo` e la sua PR viene spostata su `develop` dopo il loro merge. Così anche la prima APK dev contiene tutto.

- Nessun segreto nel repo. `key.properties`, `*.jks`, `*.p12` e i JSON vanno in `.gitignore` prima di tutto.
- Nessuna nuova dipendenza Dart.
- Azioni GitHub esterne fissate a una versione: `r0adkll/upload-google-play` e `actions/github-script` allo SHA usato in PackLog, fastlane con la versione fissata in PackLog.
- `tool/check.sh` resta il comando unico dei controlli, in locale e in CI.
- Le pipeline non si possono provare sulla VPS. La verifica vera avviene su GitHub dopo il merge in `develop`: ogni pipeline va controllata alla prima esecuzione e annotata in `docs/status.md`.
- Sulla VPS si possono verificare:
  - build locali dei due flavor (`flutter build apk --flavor dev|prod --debug`), se la memoria basta;
  - analisi e test;
  - sintassi dei workflow (`actionlint`, se disponibile senza installare niente fuori dal workspace).

## Lasciato al builder

- Come generare le icone dalle forme della tavola (SVG → PNG per densità), purché il risultato sia versionato e rigenerabile con uno script in `tool/`.
- I testi iniziali della scheda dello Store, in italiano e inglese, nel tono dell'app.
- Il nome dei job oltre a quelli che le regole dei branch useranno («Lint & Unit Tests», «Android Version Selection», da tenere uguali a PackLog).
- L'ordine dei commit.
