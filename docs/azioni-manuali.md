# Azioni manuali di Davide

Cose che solo Davide può fare: account, chiavi, impostazioni di GitHub e del Play Store. Le spunte si aggiornano man mano. Stato al 13 novembre 2026.

## Ora

- [ ] Unire le PR verso `develop`, in quest'ordine:
  1. https://github.com/davidetarsi/frequenza/compare/develop...feat/audio-service?expand=1
  2. https://github.com/davidetarsi/frequenza/compare/feat/audio-service...feat/rotta-sul-mondo?expand=1 (dopo il merge della prima, controllare che la base sia diventata `develop`)
  3. https://github.com/davidetarsi/frequenza/compare/develop...feat/pipeline?expand=1 (le pipeline; contiene già la Rotta, quindi dopo la 2 mostra solo le sue modifiche)
- [x] Scegliere il logo: la manopola (proposta 1 in https://claude.ai/artifact/KknrUgBnLJ1mKAjGCeG7th). Stessa icona per dev e prod; la dev cambia solo il nome, «Frequenza Dev».

## Pipeline e Play Store

Account sviluppatore personale: prima della produzione servono 14 giorni di test chiuso con almeno 12 tester.

### A. Decisione da prendere subito

- [x] **Package name:** `it.davidetarsi.frequenza`, deciso il 12 novembre 2026. La versione dev sarà `it.davidetarsi.frequenza.dev`. Dopo il primo caricamento sul Play Store non si può più cambiare.

### B. Sul tuo computer: chiavi di firma

- [ ] **Chiave di upload**, per la prod. Conservala con un backup: se la perdi va chiesto un reset a Google.
  ```sh
  keytool -genkeypair -v -keystore frequenza-upload.jks -alias upload \
    -keyalg RSA -keysize 2048 -validity 10000
  base64 -i frequenza-upload.jks | pbcopy      # macOS; su Linux: base64 -w0 frequenza-upload.jks
  ```
- [ ] **Chiave dev stabile.** Serve perché ogni APK dev si installi sopra la precedente.
  ```sh
  keytool -genkeypair -v -keystore frequenza-dev.p12 -storetype PKCS12 \
    -alias androiddebugkey -storepass android -keypass android \
    -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
  base64 -i frequenza-dev.p12 | pbcopy
  ```

### C. Play Console (https://play.google.com/console)

- [ ] **Crea app.** Nome «Frequenza», app, gratuita.
- [ ] **Configura l'app** dalla lista nella dashboard. Senza login e senza dati raccolti è veloce:
  - accesso all'app: «tutte le funzionalità disponibili senza restrizioni»;
  - annunci: no;
  - classificazione dei contenuti: questionario;
  - pubblico di destinazione;
  - sicurezza dei dati: nessun dato raccolto né condiviso;
  - norme sulla privacy: un URL con una pagina semplice, che Claude può preparare.
- [ ] **Scheda dello Store.** Testi e icona 512×512 sono già nel repo (`fastlane/metadata/android`) e si inviano con Actions, «Scheda Google Play». Mancano grafica 1024×500 e almeno 2 screenshot: Claude può prepararli.
- [ ] **Test chiuso.**
  - Apri Test, poi Test chiuso. Crea il canale (o usa «Alpha») e aggiungi i tester come elenco email o Google Group.
  - Il conto dei 14 giorni parte quando i tester hanno accettato l'invito e installato l'app: conviene averne più di 12.
- [ ] **Primo AAB caricato a mano.** Google accetta caricamenti automatici solo dopo il primo.
  - Scarica l'AAB dagli artifact della run «Android Release Candidate» (tab Actions, in fondo alla pagina della run; resta 30 giorni) e caricalo tu nel test chiuso. La release su GitHub ha solo tag e note, nessun file: il repo è pubblico.
  - Così si attiva anche la firma delle app di Google Play, l'opzione predefinita.
  - Solo quando quella prima versione del test chiuso è stata approvata da Google, accendi i caricamenti automatici: variabile `PLAY_UPLOAD` = `on` (punto E). Prima, Google rifiuterebbe i caricamenti perché l'app è ancora una bozza.

### D. Google Cloud: account di servizio per i caricamenti automatici

- [ ] Vai su https://console.cloud.google.com e crea un progetto, per esempio «frequenza-ci». Va bene anche quello di PackLog.
- [ ] In API e servizi, abilita **Google Play Android Developer API**.
- [ ] In IAM, poi Account di servizio, creane uno. Poi Chiavi, Aggiungi chiave, JSON, e scarica il file.
- [ ] Nella Play Console, apri Utenti e autorizzazioni, poi Invita nuovi utenti.
  - Inserisci l'email dell'account di servizio.
  - Dagli accesso all'app Frequenza con il permesso di rilasciare nei canali di test e in produzione.

### E. GitHub (repo frequenza)

- [ ] **Segreti:** Settings, poi Secrets and variables, poi Actions, poi New repository secret.

  | Segreto | Valore |
  |---|---|
  | `KEYSTORE_BASE64` | il base64 di `frequenza-upload.jks` |
  | `KEYSTORE_PASSWORD` | la password della chiave di upload |
  | `KEY_PASSWORD` | la password della chiave di upload |
  | `KEY_ALIAS` | `upload` |
  | `DEBUG_KEYSTORE_BASE64` | il base64 di `frequenza-dev.p12` |
  | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | il contenuto intero del file JSON |
  | `PAT_TOKEN` | token fine-grained di GitHub, solo sul repo frequenza, permesso Contents read/write. Serve all'aggiornamento automatico della versione |
  | `TELEGRAM_BOT_TOKEN` | lo stesso valore del repo PackLog: è il bot che manda l'APK dev in chat |
  | `TELEGRAM_CHAT_ID` | lo stesso valore del repo PackLog |

  I segreti non passano da un repo all'altro: vanno copiati. Senza i due segreti Telegram l'APK dev resta solo nella tab Actions (7 giorni).

  La chiave dev deve usare alias `androiddebugkey` e password `android`, come nel comando del punto B: la pipeline dev la apre con questi valori.

- [ ] **Variabili:** stessa pagina, scheda Variables, poi New repository variable.

  | Variabile | Valore |
  |---|---|
  | `PLAY_UPLOAD` | `on`, ma solo dopo il primo AAB caricato a mano e approvato (punto C). Finché manca, il rilascio si ferma verde dopo la release GitHub |
  | `PLAY_TRACK` | facoltativa: il nome del canale del test chiuso. Se manca vale `alpha`, il test chiuso predefinito |

- [ ] **Etichette:** Issues, poi Labels. Crea `version:major`, `version:minor` e `version:patch`.
- [ ] **Regole dei branch:** Settings, poi Rules, poi Rulesets. Crea una regola per `main` e una per `develop` con:
  - Require a pull request before merging;
  - Require status checks to pass: «Lint & Unit Tests», più «Android Version Selection» solo su `main`;
  - Block force pushes;
  - Restrict deletions.

  I nomi dei controlli compaiono nell'elenco dopo la prima esecuzione delle pipeline: si possono aggiungere dopo.

  Nella regola di `develop` aggiungi anche **Bypass list → Repository admin** (modalità «Always allow»). L'aggiornamento automatico della versione scrive con il tuo `PAT_TOKEN` direttamente su `develop`, il branch della PR di rilascio: senza l'eccezione la regola «Require a pull request» lo rifiuta e il controllo «Android Version Selection» resta rosso. In alternativa, la versione si aggiorna a mano con una piccola PR.

### F. Primo rilascio verso `main`

Fatto da Claude il 13 novembre 2026, sul branch `feat/pipeline`: versioni dev e prod (un solo `main.dart`), firma da `key.properties`, icona manopola, pipeline adattate da PackLog. Comandi locali: `flutter run` (parte la dev), `flutter build appbundle --flavor prod`.

- [ ] **Versione del primo rilascio, una volta sola.** Su `main` la versione è ancora `0.1.0` e l'aggiornamento automatico arriva su `main` solo con questo stesso rilascio. Prima di aprire la PR `develop → main`, una piccola PR verso `develop` porta `pubspec.yaml` a `version: 0.2.0+1` (Claude può prepararla). Poi la PR `develop → main` con l'etichetta `version:minor`. Dal secondo rilascio in poi basta l'etichetta.
- [ ] **Novità della versione:** prima di ogni rilascio, aggiorna `distribution/whatsnew/whatsnew-it-IT` e `whatsnew-en-US` (massimo 500 caratteri).
- [ ] **Passaggio in produzione**, dopo i 14 giorni con 12 tester: Actions, «Promuovi in produzione», Run workflow, con il numero di build (il numero dopo il `+`, per esempio `1` per `0.2.0+1`) e la percentuale di utenti.

Quando A, B ed E sono fatti, basta dire «fatto»: Claude non può controllare gli account.

## Collaudo su telefono (dopo la prima APK dev)

- [ ] Checklist del passo 1 (in fondo a `docs/superpowers/plans/2026-11-12-audio-service.md`):
  - notifica e schermata di blocco;
  - cuffie e Bluetooth;
  - schermo spento;
  - pausa dalla notifica e poi dall'app;
  - cambio stazione durante l'ascolto.
- [ ] Rotta sul mondo:
  - volo da manopola e da Preferiti;
  - nessun audio prima dell'atterraggio;
  - notifica «In volo…» e poi la stazione;
  - modalità aereo per vedere «Segnale perso»;
  - riduzione del movimento attiva.

## Dopo

- [ ] Aggiornamento di Flutter, come lavoro separato.
- [ ] Pipeline come modulo opzionale dello starter.
