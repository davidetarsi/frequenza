# Azioni manuali di Davide

Cose che solo Davide può fare: account, chiavi, impostazioni di GitHub e del Play Store. Le spunte si aggiornano man mano. Stato al 13 novembre 2026.

Account sviluppatore personale: prima della produzione servono 14 giorni di test chiuso con almeno 12 tester.

Comandi per il Mac. Le chiavi stanno fuori dal repo, in `~/chiavi/frequenza`.

**Chi fa cosa.** Claude scrive codice, testi e grafiche e li manda come branch. Non entra negli account: GitHub (impostazioni), Play Console e Google Cloud passano da Davide. Per GitHub e Google Cloud ci sono due script, `tool/setup/github.sh` e `tool/setup/google_cloud.sh`, che fanno i clic al posto suo.

Decisioni già prese:
- package `it.davidetarsi.frequenza`, la dev `.dev`: non si può più cambiare dopo il primo caricamento;
- logo: la manopola, uguale per dev e prod.

## 1. Chiavi di firma, sul Mac

- [ ] Prepara la cartella. Se `keytool` non si trova, usa il Java di Android Studio:
  ```sh
  mkdir -p ~/chiavi/frequenza && cd ~/chiavi/frequenza
  export PATH="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin:$PATH"
  ```
- [ ] **Chiave di upload**, firma le versioni per il Play Store.
  ```sh
  keytool -genkeypair -v -keystore frequenza-upload.jks -alias upload \
    -keyalg RSA -keysize 2048 -validity 10000
  ```
  - Una sola password, salvata nel gestore di password: vale sia per l'archivio sia per la chiave.
  - Come dati basta il nome; alla fine rispondi `sì`.
  - **Backup** del file e della password: se si perdono, va chiesto un reset a Google.
- [ ] **Chiave dev**, perché ogni APK dev si installi sopra la precedente. Alias e password `android` sono voluti: la pipeline dev li usa così.
  ```sh
  keytool -genkeypair -v -keystore frequenza-dev.p12 -storetype PKCS12 \
    -alias androiddebugkey -storepass android -keypass android \
    -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
  ```

## 2. GitHub, prima di unire le PR

Senza `DEBUG_KEYSTORE_BASE64` la pipeline dev fallisce: questo punto viene prima del merge.

- [ ] **Raccogli i tre valori** che lo script chiede.
  - **`PAT_TOKEN`**: foto profilo, poi Settings, poi Developer settings, poi Personal access tokens, poi Fine-grained tokens, poi Generate new token.
    - Nome: `frequenza-bump`.
    - Repository access: Only select repositories, poi `frequenza`.
    - Permissions: Contents «Read and write», Pull requests «Read-only».
    - Si vede una volta sola: copialo subito.
  - **Token del bot Telegram**: è lo stesso di PackLog. GitHub non mostra i segreti salvati, quindi va ripreso da @BotFather: `/mybots`, poi il bot, poi API Token.
  - **Chat ID**: se non l'hai segnato, scrivi un messaggio al bot (o nel gruppo) e poi lancia questo comando. Se è un gruppo il numero è negativo: tieni anche il meno.
    ```sh
    curl -s "https://api.telegram.org/bot<IL_TOKEN>/getUpdates" | grep -o '"chat":{"id":-\?[0-9]*'
    ```
- [ ] **Lancia lo script** dalla cartella del repo. Fa tutto in un colpo:
  - gli 8 segreti (le chiavi le legge da `~/chiavi/frequenza`);
  - le etichette `version:major`, `version:minor` e `version:patch`;
  - le regole di `main` e `develop`: PR obbligatoria, controlli verdi obbligatori, niente force push né cancellazioni, e su `develop` l'eccezione «Repository admin» per il bump della versione.

  Si può rilanciare: chiede prima di sovrascrivere un segreto.
  ```sh
  brew install gh && gh auth login        # una volta sola
  bash tool/setup/github.sh
  ```

  <details><summary>A mano, senza script</summary>

  - **Segreti.** Settings, poi Secrets and variables, poi Actions, poi New repository secret.
    - `KEYSTORE_BASE64`: si copia con `base64 -i ~/chiavi/frequenza/frequenza-upload.jks | pbcopy`.
    - `KEYSTORE_PASSWORD` e `KEY_PASSWORD`: la password della chiave di upload.
    - `KEY_ALIAS`: `upload`.
    - `DEBUG_KEYSTORE_BASE64`: si copia con `base64 -i ~/chiavi/frequenza/frequenza-dev.p12 | pbcopy`.
    - `PAT_TOKEN`, `TELEGRAM_BOT_TOKEN` e `TELEGRAM_CHAT_ID`.
  - **Etichette.** Issues, poi Labels, poi New label: `version:major`, `version:minor` e `version:patch`.
  - **Regole.** Settings, poi Rules, poi Rulesets, poi New branch ruleset, una per `main` e una per `develop`.
    - Enforcement Active; target `main` o `develop`.
    - Spunta Restrict deletions, Block force pushes e Require a pull request (0 approvazioni).
    - In Require status checks: «Lint & Unit Tests», più «Android Version Selection» solo su `main`. I nomi compaiono nell'elenco dopo la prima esecuzione.
    - Su `develop`: Bypass list, poi Repository admin, «Always allow».
  </details>

## 3. Unire le PR e ricevere la prima APK dev

- [ ] Unisci in `develop`, in quest'ordine:
  1. le pipeline: https://github.com/davidetarsi/frequenza/compare/develop...feat/pipeline?expand=1. Contiene già la Rotta sul mondo: la PR di `feat/rotta-sul-mondo` non serve più.
  2. questa guida e gli script: https://github.com/davidetarsi/frequenza/compare/develop...docs/guida-configurazione?expand=1
  3. grafica e privacy: https://github.com/davidetarsi/frequenza/compare/develop...feat/materiali-play-store?expand=1
  4. la versione del primo rilascio: https://github.com/davidetarsi/frequenza/compare/develop...release/0.2.0?expand=1

  Il branch `docs/azioni-manuali` è superato da `docs/guida-configurazione`: si può ignorare.
- [ ] Nella tab Actions parte «Build DEV». In circa 10 minuti l'APK arriva su Telegram. Installala; se Android lo chiede, permetti l'installazione da Telegram.
- [ ] **Collaudo sul telefono:**
  - checklist del passo 1 (in fondo a `docs/superpowers/plans/2026-11-12-audio-service.md`):
    - notifica e schermata di blocco;
    - cuffie e Bluetooth;
    - schermo spento;
    - pausa dalla notifica e poi dall'app;
    - cambio stazione durante l'ascolto;
  - Rotta sul mondo:
    - volo dalla manopola e dai Preferiti;
    - nessun audio prima dell'atterraggio;
    - notifica «In volo…» e poi la stazione;
    - modalità aereo per vedere «Segnale perso»;
    - riduzione del movimento attiva.

  I problemi si raccontano a Claude.

## 4. Play Console (in parallelo al punto 3)

Su https://play.google.com/console.

- [ ] **Crea app:**
  - nome «Frequenza»;
  - lingua Italiano;
  - App, Gratuita;
  - accetta le dichiarazioni.
- [ ] **Norme sulla privacy online.** Settings del repo, poi Pages: «Deploy from a branch», branch `develop`, cartella `/docs`. L'indirizzo è https://davidetarsi.github.io/frequenza/privacy.html. La pagina è `docs/privacy.html`: l'email di contatto è quella di Davide.
- [ ] **Configura l'app**, dalla lista «Configura la tua app» nella dashboard:

  | Modulo | Risposta |
  |---|---|
  | Norme sulla privacy | l'URL qui sopra |
  | Accesso alle app | tutte le funzionalità disponibili senza restrizioni |
  | Annunci | no |
  | Classificazione dei contenuti | questionario: «Tutti gli altri tipi di app», no a violenza, sesso, gioco d'azzardo e simili |
  | Pubblico di destinazione | solo 18+: così non valgono le regole per i bambini |
  | Sicurezza dei dati | nessun dato raccolto né condiviso |
  | App governative, finanziarie, sanitarie, di notizie | no |
  | Impostazioni dello Store | categoria Musica e audio, email di contatto |

- [ ] **Scheda dello Store**, la prima volta a mano: i caricamenti automatici funzionano solo dopo il punto 6.
  - Titolo e descrizioni: da `fastlane/metadata/android/it-IT/` (ed `en-US/` per l'inglese).
  - Icona: `images/icon.png`.
  - Grafica 1024×500: `images/featureGraphic.png`.
  - Screenshot, almeno 2: dal telefono con la dev (accensione + volume giù), cioè manopola, Preferiti e Rotta. Claude può sistemarli.
- [ ] **Test chiuso.** Test e rilascio, poi Test, poi Test chiuso, poi «Alpha» (o Crea canale).
  - Paesi/regioni: almeno l'Italia.
  - Tester: elenco email con gli account Gmail degli amici, **15 o più**.
  - Il link di partecipazione arriva dopo il primo rilascio.

## 5. Primo rilascio

- [ ] La versione `0.2.0+1` è nella PR `release/0.2.0` (punto 3). Serve una volta sola: su `main` c'è ancora `0.1.0` e il bump automatico arriva lì solo con questo rilascio.
- [ ] **Novità della versione.** Prima di ogni rilascio, controlla `distribution/whatsnew/whatsnew-it-IT` e `whatsnew-en-US` (massimo 500 caratteri).
- [ ] **PR di rilascio:** https://github.com/davidetarsi/frequenza/compare/main...develop?expand=1
  - Etichetta `version:minor`; controlli verdi.
  - Unisci con **«Create a merge commit»**, non con «Squash»: altrimenti `develop` e `main` divergono e al rilascio dopo ci sono conflitti.
- [ ] **AAB.** Actions, poi la run «Android Release Candidate», poi Artifacts in fondo alla pagina: lo zip contiene `Frequenza-prod-v0.2.0+1.aab`. Resta 30 giorni. La release su GitHub ha solo tag e note, nessun file: il repo è pubblico.
- [ ] **Primo caricamento a mano.** Play Console, poi Test chiuso, poi Crea nuova release.
  - Accetta la firma delle app di Google Play.
  - Carica l'AAB, incolla le novità, poi Avanti e Salva.
  - Panoramica pubblicazione, poi Invia modifiche per la revisione.
- [ ] Quando Google approva (da qualche ora a qualche giorno), manda ai tester il link di partecipazione: lo trovi nella pagina del test chiuso.

## 6. Caricamenti automatici, dopo l'approvazione

- [ ] **Account di servizio.** Si può riusare quello di PackLog: basta una chiave nuova e l'invito su Frequenza. Altrimenti lo crea lo script:
  ```sh
  brew install --cask google-cloud-sdk && gcloud auth login   # una volta sola
  bash tool/setup/google_cloud.sh
  ```
  Lo script crea il progetto `frequenza-ci-davidetarsi`, abilita la Google Play Android Developer API, crea l'account `frequenza-ci` e salva la chiave in `~/chiavi/frequenza/frequenza-ci.json`. Se l'id del progetto è preso: `PROJECT=altro-id bash tool/setup/google_cloud.sh`.

  <details><summary>A mano, senza script</summary>

  1. https://console.cloud.google.com: Nuovo progetto.
  2. API e servizi, poi Libreria, poi «Google Play Android Developer API», poi Abilita.
  3. IAM e amministrazione, poi Account di servizio, poi Crea: nessun ruolo.
  4. Chiavi, poi Aggiungi chiave, poi JSON.
  </details>
- [ ] **Invito nella Play Console** (solo a mano). Utenti e autorizzazioni, poi Invita nuovi utenti.
  - Email dell'account (finisce con `.iam.gserviceaccount.com`).
  - In Autorizzazioni app aggiungi Frequenza, con:
    - Rilascia app nei canali di test;
    - Rilascia in produzione…;
    - Gestisci la presenza nello Store;
    - Visualizza informazioni sull'app.
- [ ] **Accendi i caricamenti:** imposta il segreto `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` e la variabile `PLAY_UPLOAD=on`.
  ```sh
  bash tool/setup/github.sh play ~/chiavi/frequenza/frequenza-ci.json
  ```
  Da qui ogni merge su `main` finisce da solo nel test chiuso. La scheda si aggiorna da Actions, «Scheda Google Play», Run workflow con «pubblica» acceso.

  `PLAY_TRACK` è facoltativa: è il nome del canale del test chiuso, predefinito `alpha`.

## 7. Produzione

- [ ] Servono 14 giorni di fila con almeno 12 tester che hanno accettato l'invito e tengono l'app installata.
- [ ] Nella dashboard della Play Console: **Richiedi accesso alla produzione**, un breve questionario sul test. Google risponde in circa una settimana.
- [ ] Dopo l'approvazione: Actions, poi «Promuovi in produzione», poi Run workflow.
  - `version_code`: il numero dopo il `+` (`1` per `0.2.0+1`).
  - `rollout`: `100`, o meno per partire piano.

## Dopo

- [ ] Aggiornamento di Flutter, come lavoro separato.
- [ ] Pipeline come modulo opzionale dello starter.
