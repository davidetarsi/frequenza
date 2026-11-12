# Azioni manuali di Davide

Cose che solo Davide può fare: account, chiavi, impostazioni di GitHub e del Play Store. Le spunte si aggiornano man mano. Stato al 12 novembre 2026.

## Ora

- [ ] Unire le PR verso `develop`, in quest'ordine:
  1. https://github.com/davidetarsi/frequenza/compare/develop...feat/audio-service?expand=1
  2. https://github.com/davidetarsi/frequenza/compare/feat/audio-service...feat/rotta-sul-mondo?expand=1 (dopo il merge della prima, controllare che la base sia diventata `develop`)
- [ ] Scegliere il logo (dev e prod).

## Pipeline e Play Store

Account sviluppatore personale: prima della produzione servono 14 giorni di test chiuso con almeno 12 tester.

### A. Decisione da prendere subito

- [ ] **Package name.** Oggi è `dev.davidetarsi.frequenza`. Dopo il primo caricamento sul Play Store non si può più cambiare. PackLog usa `com.davidetarsi.packlog`: per lo stesso schema servirebbe `com.davidetarsi.frequenza`. Va deciso prima che si scrivano le pipeline.

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
- [ ] **Scheda dello Store.** Descrizione breve e lunga, icona 512×512, grafica 1024×500 e almeno 2 screenshot. Claude può prepararli.
- [ ] **Test chiuso.**
  - Apri Test, poi Test chiuso. Crea il canale (o usa «Alpha») e aggiungi i tester come elenco email o Google Group.
  - Il conto dei 14 giorni parte quando i tester hanno accettato l'invito e installato l'app: conviene averne più di 12.
- [ ] **Primo AAB caricato a mano.** Google accetta caricamenti automatici solo dopo il primo.
  - Scarica l'AAB costruito dalla pipeline (tab Actions) e caricalo tu nel test chiuso.
  - Così si attiva anche la firma delle app di Google Play, l'opzione predefinita.

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

- [ ] **Etichette:** Issues, poi Labels. Crea `version:major`, `version:minor` e `version:patch`.
- [ ] **Regole dei branch:** Settings, poi Rules, poi Rulesets. Crea una regola per `main` e una per `develop` con:
  - Require a pull request before merging;
  - Require status checks to pass: «Lint & Unit Tests», più «Android Version Selection» solo su `main`;
  - Block force pushes;
  - Restrict deletions.

  I nomi dei controlli compaiono nell'elenco dopo la prima esecuzione delle pipeline: si possono aggiungere dopo.

### F. Parte di Claude

Dopo il passo A, sul branch `feat/pipeline` verso `develop`, con prima un breve documento di progetto da approvare:
- le versioni dev e prod dell'app (Frequenza Dev con id `.dev`);
- la firma da `key.properties`;
- `main_dev` e `main_prod`;
- le pipeline adattate da PackLog: rilascio nel test chiuso invece che nell'interno, e passaggio a produzione da avviare a mano.

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
