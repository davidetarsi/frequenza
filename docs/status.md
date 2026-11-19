# Frequenza — stato verificato al 20 novembre 2026

Il punto di ripresa di ogni sessione: si legge questo, poi solo il piano attivo. Le regole per le idee nuove sono in [principi.md](principi.md).

## Dove siamo

- `main`: versione 0.4.1+6, dopo il merge della PR #46. Questo indica lo stato del repository; la pubblicazione sul Play Store resta gestita da Davide.
- `develop`: include anche radio adattiva, snackbar e sintonizzazione in background, dopo il merge della PR #49 (`3aa62c7`).
- Branch di lavoro: `fix/scadenza-snackbar`, da `origin/develop` dopo la PR #49. PR verso `develop` richiesta da Davide; merge e collaudo sul telefono gestiti da Davide.
- Audit del 19 novembre: completati i blocchi su persistenza/stati, sicurezza/privacy, confini architetturali e localizzazione. Completato anche il blocco UI condivisa/token; resta il punto di manutenzione P3 nativo descritto sotto. Il rapporto è nell'area di lavoro `../audit/2026-11-19/rapporto.md` (non versionata nel repository).

## Piano attivo

Scadenza snackbar completata — segnalazione del 20 novembre.

- Davide segnala che l'avviso resta aperto dopo i 4 secondi. Nel componente comune era rimasta l'eccezione `persist: true` quando MediaQuery.accessibleNavigation era attivo; il flag del telefono non è stato rilevato direttamente, ma il comportamento è stato riprodotto nei test per salvataggio e rimozione.
- Rimossa l'eccezione: `persist: false` esplicito in appSnackBar, durata sempre dal token condiviso di 4 secondi. Il componente non legge più MediaQuery e non richiede BuildContext; i due consumatori sono aggiornati. Nessuna modifica alle azioni Annulla o ai dati salvati.
- Due regressioni falliscono prima della correzione e passano dopo. Verificato Annulla prima della scadenza con flag sia attivo sia disattivo. **42 test della feature canzoni superati**, analisi statica pulita, formattazione/diff verificati. Nessuna build nativa aggiuntiva per questa modifica Dart/UI; collaudo sul telefono da ripetere.

## Radio adattiva completata — 19 novembre 2026

Radio adattiva completata, autorizzata da Davide.

- Sostituire il passaggio rigido a 740/900 punti con adattamento progressivo basato sulle dimensioni reali del contenuto, mantenendo la mappa fino all'ingombro minimo leggibile. `AdaptiveFit` misura un solo sottoalbero e sceglie la densità più grande che entra, senza trasformare testo o aree di tocco.
- RadioCabinet usa metriche interpolate nei token tra configurazione regolare e minima con mappa; larghezza e intestazione si riducono insieme. Mappa da 84 a 56 punti, pulsanti sempre almeno 44 punti e text scaler di sistema conservato. Niente misure/font locali.
- Solo se la radio minima con mappa non entra, usare la variante compatta esistente. Solo per viewport estremi in cui non entra neanche quella, consentire scorrimento della pagina conservando la posizione.
- Adattamento applicato anche alla variante orizzontale: la mappa viene mantenuta quando il contenuto entra. Margine dedicato tra ombra della scocca e testo in fondo alla pagina. Identità della mappa conservata durante le riduzioni progressive; posizione di scorrimento conservata nei casi estremi.
- Verifiche completate con Flutter 3.38.5: **530 test Flutter superati**, analisi statica pulita, formattazione/diff coerenti e APK dev debug arm64 compilato. Cinque regressioni responsive coprono riduzione continua con mappa a 740/720 punti, fallback e ripristino della mappa, orizzontale, scala del testo e controlli ancora utilizzabili dopo uno scorrimento/aggiornamento.
- Controllo visivo tramite renderer Flutter con font Roboto/MaterialIcons su viewport 390×900, 390×740 e 390×560, con barre di sistema simulate. Nessun telefono collegato; collaudo reale ancora da fare. Correzioni snackbar/notifica precedenti conservate nello stesso branch; nessun cambiamento a versione o regole CI/PR.

## Snackbar e sintonizzazione dalla notifica — 19 novembre 2026

Snackbar temporanee e sintonizzazione dalla notifica: correzioni completate.

- Snackbar con Annulla: la versione Flutter in uso rende persistenti per default gli avvisi con un'azione. Componente `appSnackBar` condiviso per salvataggio e rimozione della canzone, durata nel token AppMessageDesign a 4 secondi e persistenza solo con navigazione accessibile attiva, per mantenere utilizzabile Annulla.
- Il cambio radio dalla notifica usa già lo stesso RadioController della manopola: avvio della connessione in parallelo, volume a zero fino al minimo di 1 secondo e dissolvenza all'arrivo. Nessuna modifica ai tempi o al controller.
- Causa del fruscio assente: MainActivity vietava start fuori dal primo piano e fermava l'effetto in onStop. Il canale piattaforma e il MediaPlayer ora appartengono a FrequenzaPlatformPlugin, registrato una volta sul motore condiviso di audio_service, con applicationContext e rilascio al distacco del motore. Nessun riferimento all'Activity nel player o nel canale, nessun nuovo servizio o permesso Android.
- 29 test mirati superati: scadenza del salvataggio/rimozione senza gesto, Annulla/accessibilità, notifica Avanti/Indietro con lifecycle paused e audio effettivamente muto a 999 ms, udibile dopo 1000 ms. APK dev debug arm64 compilato, analisi pulita e suite completa con **525 test Flutter superati**. Formattazione e diff verificati.
- Nessun dispositivo collegato: fruscio con schermo spento e Activity ricreata da collaudare su telefono. Non sono stati cambiati firma, versione, dati o regole CI/PR.

## Correzione mondo → paese completata — 19 novembre 2026

Correzione animazione mondo → paese completata, segnalata da Davide.

- Riprodotto con regressioni: la scala si riduceva geometricamente ma il centro avanzava linearmente, lasciando il paese fuori dall'inquadratura durante l'avvicinamento. Il confine iniziava a disegnarsi prima della fine dello zoom; un arrivo rapido nello stesso paese ereditava inoltre il contorno precedente.
- CountryShape: centraggio accoppiato alla variazione della scala su entrambi gli assi, estremi esatti e scorrimento lineare quando la scala resta uguale. Il paese rimane in vista durante l'avvicinamento. RouteMap conserva la vista corrente nelle interruzioni e azzera il tratto disegnato a ogni nuova sintonizzazione, anche nello stesso paese.
- Token centrali: durata totale di arrivo invariata a 1800 ms; prima metà per centraggio/zoom, seconda per il disegno lineare del confine a vista ferma. Colori, tratto e opacità originali conservati. Riconnessione e movimento ridotto continuano a evitare il riavvio dell'animazione o a mostrare subito l'esito, rispettivamente.
- Quattro nuove regressioni: permanenza nell'inquadratura per paesi lontani/piccoli, scorrimento senza zoom, disegno successivo al centraggio e arrivo rapido nello stesso paese. Suite completa Flutter: **521 test superati**. Dopo il controllo dei frame renderizzati e il ripristino dell'opacità originale del tratto, ripetuti tutti i **38 test della mappa/geografia**, superati, e analisi statica pulita. Formattazione/diff verificati. Nessuna nuova regola CI/PR, variazione della versione o build nativa in questa fase.
- Da verificare su telefono la fluidità percepita e la leggibilità del tracciamento; controllo visivo dei frame eseguito tramite renderer Flutter, senza dispositivo fisico. Resta il punto P3 di manutenzione nativa già documentato sotto.

## Sesta fase dell'audit completata — 19 novembre 2026

Sesta fase dell'audit: componenti condivisi e token UI completati.

- Valori grafici del diario, selettore dei periodi, scheda paese, bookmark, player e intestazione nei token di `lib/ui/theme`. Anche i coefficienti di disegno e le curve mondo/paese sono ora nei token, con gli stessi valori. Sorgenti delle schermate verificati senza font numerici, pesi, colori esadecimali, opacità fisse o spaziature numeriche locali; restano calcoli geometrici e valori dinamici del tema. Seed di AppConfig dalla palette condivisa.
- `TravelSheetDesign` dedicato al foglio comune: geometria, ombre, maniglia, tipografia e chiusura condivise da tutte le istanze. `RadioFavoritesDesign` contiene gli stili specifici dei preferiti.
- `AppMessage.error` e `AppMessage.emptyPanel` riusati in preferiti e canzoni; errori con la stessa composizione e azione Riprova allineata all'inizio. `AppButton.emphasized` sostituisce la CTA locale della scheda paese, con gli stessi colori e altezza. `CodeBadge` riutilizzato anche per le targhette dei preferiti, conservando misure, bordi, colori e il globo per il codice assente.
- Colori, misure e tipografia approvati conservati; tempi e curve delle animazioni trasferiti senza modificarli. Nessuna correzione dei problemi dell'animazione mondo/paese in questa fase. Nessun nuovo controllo CI/PR.
- `tool/check.sh` completo con Flutter 3.38.5: generazione/schema coerenti, formattazione e analisi pulite, 6 test Node, 57 test Python e **517 test Flutter superati**. Inclusi due nuovi test di integrazione: errore di lettura → Riprova → stato vuoto e chiusura del foglio per preferiti e canzoni con testo al doppio della dimensione. Collaudo visivo su telefono ancora da fare; APK non ricompilato in questa fase, che modifica solo Dart/UI.
- Prossimo lavoro: le anomalie nelle animazioni segnalate da Davide, da precisare prima di modificarne il comportamento. Resta il punto P3 di manutenzione nativa già documentato sotto.

## Quinta fase dell'audit completata — 19 novembre 2026

Localizzazione completata, autorizzata da Davide.

- Lingua salvata tramite il repository delle preferenze e AsyncValue, mantenendo la chiave `locale` esistente. Priorità alla scelta salvata, poi alla lingua del dispositivo, con inglese per le lingue non supportate. Scritture serializzate e messaggio IT/EN in caso di errore; la lingua mostrata cambia solo dopo il salvataggio riuscito.
- Una sorgente della lingua effettivamente visualizzata aggiorna il gestore della notifica, i controlli e i metadati analytics, senza riavviare la radio. Il codice della sessione analytics resta invariato quando cambia la lingua; consenso e dati raccolti invariati.
- Canale Android rinominato tramite API pubblica, conservando ID e impostazioni dell'utente. La libreria di traduzione rende i testi; la persistenza resta nel repository. Il primo frame attende la lingua corretta anche con la cache della libreria valorizzata da una versione precedente.
- Lookup geografico IT/EN condiviso fra diario, home, player, preferiti, canzoni e notifica. Nomi propri di stazioni e brani conservati; i dati del catalogo non vengono riscritti. Composizioni e accessibilità nel dizionario con parametri; numeri formattati per lingua. Informativa aperta alla sezione IT/EN scelta nell'app.
- Verificati 78 test mirati, inclusi migrazione delle preferenze, cambi rapidi, errore/riprova, cambio lingua durante l'ascolto senza nuova sintonizzazione e continuità della sessione analytics. Poi `tool/check.sh` completo con Flutter 3.38.5: generazione/schema coerenti, formattazione e analisi pulite, 6 test Node, 57 test Python e **515 test Flutter superati**. Controllate tutte le 157 chiavi IT/EN e la corrispondenza dei parametri. APK dev debug arm64 compilato. Da collaudare su telefono il cambio lingua della notifica e del nome del canale Android, incluse le impostazioni personalizzate dell'utente.
- Prossimo blocco: UI condivisa e token. Nessuna modifica alle animazioni o nuove regole automatiche in CI/PR.

## Quarta fase dell'audit completata — 19 novembre 2026

Separazione dei livelli completata; localizzazione e UI condivisa restano blocchi separati, come consentito da Davide.

- Atlante e contorni statici in `journey/domain/atlas`, senza I/O né dipendenze da implementazioni. Generatore aggiornato ai nuovi percorsi; dati geografici verificati identici a HEAD (solo l'import di DstRule cambia). Nessun cambiamento all'animazione mondo/paese.
- `RadioMediaSession` nel dominio; application usa il contratto. Bootstrap collega un solo player al motore e alla notifica e ne registra lo smaltimento, senza esporre il concreto RadioAudioHandler tramite provider pubblici di application.
- `AppPlatform` Dart puro, implementazione nel data e provider Riverpod: versioni, SDK, app installate, cache della notifica, clipboard/haptic e apertura esterna. Widget senza accessi diretti al canale; metadati opzionali con timeout e valori neutri. Provider delle app musicali spostato da data ad application.
- `TrackTitle`, `AppEvent`, gli eventi `RadioEvent`, `DisplayText` e `RadioDisplay` con Freezed, conservando i dati e i comportamenti. Eliminata `WelcomeDemo`, senza riferimenti attivi.
- Rete: validazione HTTPS condivisa tra catalogo, preferiti e snapshot del diario; limiti a URL/metadati e titoli ICY. Risposte JSON limitate a 1 MiB anche senza Content-Length; timeout con cancellazione e annullamento delle richieste alla chiusura. Client creato dal repository chiuso dal provider; un client iniettato resta di proprietà del chiamante. Redirect del catalogo disattivati: si usa il mirror successivo senza scendere a HTTP. User-Agent con versione installata, senza il vecchio valore fisso 0.1.0; vincolo http aggiornato a ^1.6.0 per l'API AbortableRequest già presente nel lockfile, senza cambio di versione risolta.
- Apertura link con messaggio di errore comune a impostazioni e canzoni, inclusi false/exception. Regole UI e testi esistenti riutilizzati.
- Verificati 340 test mirati, generazione/schema e formattazione, 6 test Node e 57 test Python. Dopo la correzione del record URL canonico: analisi statica pulita e suite Flutter completa ripetuta, **504 test superati**; APK dev debug arm64 ricompilato con Flutter 3.38.5. Controllo manuale degli import: zero dipendenze improprie nel dominio e zero accessi diretti ai plugin nei widget. Nessun dispositivo collegato per il collaudo reale.
- Punto P3 ancora aperto: RadioForeground usa il metodo privato `exitForegroundState` di audio_service 0.18.19 (versione del lockfile), protetto dalla regola ProGuard già caricata dal plugin Flutter. Non esiste un equivalente pubblico che lasci invariati foreground durante la pausa e rilascio del wake lock. Chiesta a Davide una scelta tra mantenere il workaround o modificare il plugin; nessuna risposta/deroga registrata. Chiarito che AGENTS impone l'isolamento, non vieta esplicitamente la reflection: non è una deroga automatica né un'autorizzazione a creare un fork. Implementazione nativa conservata.
- Prossimo blocco: localizzazione (lingua salvata/notifiche/analytics, paesi e testi parametrizzati), poi UI condivisa. Nessuna nuova regola automatica in CI/PR.

## Terza fase dell'audit completata — 19 novembre 2026

Terza fase dell'audit: firma release, backup e informative, autorizzata da Davide il 19 novembre.

- Firma: ogni flavor definisce la propria configurazione. `prodRelease` usa sempre quella esplicita di release; la build verifica file e campi necessari prima di produrre gli artefatti. Dev conserva il ripiego debug se manca `key.properties`; debug non richiede chiavi prod. Workflow e requisiti PR invariati.
- Backup Android mantenuto attivo, con elenco esplicito dei soli archivi utente per Android fino a 11, cloud e trasferimento dispositivo da Android 12. Preferenze in `FlutterSharedPreferences.xml`; diario Drift in `root/app_flutter/frequenza.sqlite`, con WAL/journal per il recupero SQLite, senza file temporanei SHM. Percorso verificato nelle dipendenze installate drift_flutter/path_provider e nel motore Flutter 3.38.5.
- Informativa IT/EN in `docs/privacy.html`: backup del sistema, metadati precompilati nella URL Google Forms già all'apertura e testo delle ricerche passato ai servizi esterni solo su azione dell'utente. Descrizione Radio Browser corretta per includere i parametri della richiesta; terminologia aggiornata anche nei testi locali della scheda Play Store.
- Dizionario IT/EN: «Statistiche d'uso», con indicazione di eventi e dati tecnici; rimossa la promessa assoluta «Nessun dato su di te». Fornitore tgram-analytics gestito e comportamento del consenso conservati.
- Fase completata: 44 test mirati, poi `tool/check.sh` con Flutter 3.38.5: generazione/schema coerenti, formattazione e analisi pulite, 6 test Node, **57 test Python e 486 test Flutter** superati. APK dev debug arm64 compilato; manifest, risorse backup e firma debug verificati anche nell’APK. Gradle verificato con configurazione prod assente/incompleta, keystore mancante e una chiave temporanea valida; verificati grafo APK/AAB e configurazioni dev/debug. Chiave temporanea rimossa, nessun artefatto prod generato.
- Nessun dispositivo Android collegato: ripristino reale del backup da collaudare su telefono. Informativa modificata nel repository locale, senza pubblicazione o merge.
- Prossimo blocco: confini architetturali. Restano aperti anche validazione URL, limiti delle risposte/metadati, ciclo di vita HTTP e le altre voci dell'audit. Nessun nuovo vincolo CI/PR.

## Seconda fase dell'audit completata — 19 novembre 2026

Seconda fase dell'audit: onboarding e preferenze, autorizzata da Davide il 19 novembre.

- Dominio: `WelcomeSession` e `WelcomeEvent` Freezed, con stati radio/preferiti/diario/chiusura/completato e funzione pura `nextWelcome`; tabella delle transizioni accanto al codice.
- Application: `WelcomeController` Riverpod esegue gli effetti (avvio radio e registrazione del completamento), ignora tap/Indietro ripetuti durante la chiusura e scarta completamenti dopo la propria distruzione. La UI mantiene misure, animazioni e navigazione.
- Preferenze: contratto Dart puro `AppPreferencesRepository`, implementazione SharedPreferences e provider iniettato comuni a tema, consenso analytics e tour. Chiavi esistenti e revisione del tour **2** conservate. Nessun accesso diretto a SharedPreferences nei tre controller.
- Persistenza attraverso AsyncValue: errori di scrittura visibili allo stato; consenso disattivato anche se il salvataggio fallisce, radio raggiungibile anche se il completamento del tour non può essere scritto. Nessuna modifica alle scelte di prodotto su consenso o ripresentazione del tour.
- Stili già approvati del tour spostati in `WelcomeTourDesign`: tipografia, geometria, padding, colori e tratti delle frecce centralizzati, senza restyle.
- Fase completata: 78 test mirati superati, poi `tool/check.sh` completo con Flutter 3.38.5: generazione/schema coerenti, formattazione e analisi pulite, 6 test Node, 56 test Python e **486 test Flutter** superati. Build APK e collaudo su telefono non eseguiti in questa fase.
- Prossimo blocco concordato: sicurezza e privacy (firma release, backup, informative e copy analytics). Restano poi confini architetturali, localizzazione e UI condivisa. Nessun nuovo vincolo CI/PR.

## Prima fase dell'audit completata — 19 novembre 2026

- Regole in `AGENTS.md`, applicate al lavoro dell'assistente. Deroghe solo con approvazione esplicita di Davide, registrate in `docs/deroghe.md`. Nessun nuovo vincolo in CI, PR o branch protection, per sua richiesta.
- Salvataggi canzoni serializzati: ogni operazione legge il risultato della precedente; duplicati, rimozioni e ripristini usano la stessa coda. Un ricaricamento aspetta la scrittura già in corso senza applicare risultati obsoleti.
- Esito del salvataggio tipizzato con Freezed. La home comunica il fallimento con una stringa IT/EN, anziché trattarlo come un duplicato.
- Diario: un cambio di periodo fallito mostra l'errore e «Riprova», senza mostrare i totali del periodo precedente. Durante il caricamento si conserva la continuità visiva già prevista.
- Verifiche completate con Flutter 3.38.5 e lo script esistente `tool/check.sh`: generazione e schema coerenti, formattazione e analisi pulite, 6 test Node, 56 test Python e 469 test Flutter superati. Non sono stati aggiunti controlli automatici. Build APK e collaudo su telefono non eseguiti in questa fase.

## Rifiniture radio e diario — 18 novembre 2026

- Branch `fix/gerarchia-radio-diario`, da `develop`. Barra superiore allineata alla scocca con Preferiti, Diario e Impostazioni. Preferiti senza cerchio e badge, conteggio nel tooltip. Diario aperto dalla mappa ripiegata (`map_outlined`, scelta da Davide), pausa più larga del cuore.
- Freccia del diario allineata al margine dei contenuti. Invito «Tocca un paese» rimosso definitivamente. Spazio prima di «Volaci» nella stazione più ascoltata e nelle righe paese.
- Scheda paese nel verde chiaro `screenInk`, testo `screen`, targhetta coordinata nei due temi.
- Mappa aggiornata per riempire il viewport mantenendo le proporzioni. In verticale si esplora lateralmente il mondo, inizialmente centrato. L'intera superficie riceve pinch e trascinamento. Zoom 1–6, tasti animati con `AppMotion.standard`, interrompibili dal gesto e immediati con riduzione movimento. Il ritorno a 1 e il cambio di dimensioni ricentrano la vista.
- Verifiche mappa: 34 test di mappa/pagina/schede passati, poi 11 test mappa inclusi pinch progressivo, trascinamento dalla metà inferiore, selezione nel viewport alto, interruzione e riduzione movimento. Analisi del componente pulita. Fluidità reale da collaudare su telefono.
- Verificati 118 test mirati di diario, home e viaggio. Bundle debug compilato. Analisi con tre avvisi preesistenti `containsSemantics` nei test, nessun errore.
- Prossimo passo: collaudo visivo su telefono, nei due temi e con testo grande. Prima verifica con Flutter 3.47.4, poi controllo completo con Flutter 3.38.5 come la CI.

## Diario con player sospeso — 18 novembre 2026

- Richiesta di Davide: mappa e statistiche scorrono insieme sotto il player. Intestazione e filtri restano fissi.
- `Scaffold.extendBody` e un'unica `CustomScrollView`; player sovrapposto con margini laterali/inferiori, sfumatura e sfocatura limitata alla fascia inferiore. Padding finale ricavato dall'altezza effettiva della barra, anche con testo grande.
- Aprendo un paese il player scompare da vista, tocchi e accessibilità. La scheda usa la parte bassa della pagina. Chiudendola o avviando un volo ricompare la barra. L'ascolto segue lo stato radio esistente.
- Durante un pinch o un trascinamento della mappa ingrandita, lo scorrimento della pagina cede il gesto alla mappa. A scala iniziale il trascinamento verticale scorre la pagina.
- Verificati scorrimento con player fermo, ultima riga raggiungibile, navigazione dopo chiusura della scheda, layout piccoli/orizzontali e testo grande. Screenshot locali del diario e della scheda aggiornati con dati di esempio.
- Player aggiornato al verde chiaro `screenInk`, testo e icone `screen`, play/pausa verde scuro con icona chiara. Cuore salvato nel colore accent. Sfocatura laterale/inferiore leggera (sigma 4), tinta al 22% per lasciare visibili i dati sottostanti. Test mirati e analisi verificati, screenshot aggiornati.
- Revisione screenshot: corretto il contrasto della stazione più ascoltata in tema chiaro impostando esplicitamente il colore del testo sulla superficie scura. Regressione aggiunta al test pagina, 18 test superati.
- Resta il collaudo visivo e dei gesti su telefono.

## Allineamento sfocatura e chiusura dei fogli — 18 novembre 2026

- Branch `fix/chiusura-fogli-e-sfocatura`, da `develop` dopo il merge della PR #40.
- Margine superiore del player spostato fuori dal filtro. La sfocatura parte dal bordo superiore della barra e si muove con essa durante la transizione.
- Intestazione condivisa `TravelSheetHeader` in `lib/ui/widgets/travel_sheet.dart`: maniglia, titolo e X a destra con area di tocco da 48 punti. Usata da Preferiti, Impostazioni e schede paese. La chiusura del paese passa al callback del diario.
- Rimossa la freccia dalla CTA «Vola in …».
- Verificati 44 test mirati con Flutter 3.38.5, inclusi allineamento del filtro, chiusura dei tre tipi di scheda paese, testo grande e layout orizzontale. Aperto il riscontro visivo su telefono.

## Bottom sheet unico — 18 novembre 2026

- Preferiti, Impostazioni e paese usano `TravelSheet`: superficie, raggi, padding, titolo, maniglia, X, lista e chiusura sono definiti nel componente comune. `CountrySheet` prepara soltanto i contenuti del paese.
- `TravelSheetPresentation` seleziona l'apertura ridimensionabile nella route modale oppure il foglio integrato nel diario, che adatta l'altezza ai contenuti entro il limite disponibile. Il callback del paese chiude la scheda nel diario.
- La chiusura trascinando verso il basso del foglio integrato è gestita da `TravelSheet`. Per le route modali il componente conserva `DraggableScrollableSheet` e il messenger dei messaggi con Annulla. Le liste integrate hanno uno scorrimento indipendente dalla pagina.
- Token di superficie e spaziature condivisi anche per il paese; intestazione resa privata al componente. Eliminati contenitore, intestazione e gestione del trascinamento duplicati nella feature diario.
- Verificati 52 test mirati con Flutter 3.38.5, inclusi i tre tipi di paese, Preferiti, Impostazioni, canzoni e messaggi. Screenshot Flutter del paese aggiornati con la superficie standard. Riscontro visivo su telefono aperto.

## Offuscamento graduale del diario — 18 novembre 2026

- Branch `fix/sfocatura-graduale`, da `develop` dopo il merge della PR #41.
- Sostituito il filtro uniforme con `BottomFade`: sfumatura continua di opacità verso il verde della pagina, trasparente al bordo superiore del player e più coprente verso il fondo. Player e comandi rimangono nitidi.
- La fascia è creata solo quando lo stato radio prevede il player. Con radio spenta il diario non riserva né disegna una fascia filtrata. Con scheda paese aperta il player e la sfumatura sono nascosti insieme.
- Verificati 31 test con Flutter 3.38.5, inclusa la verifica pixel su fondo ad alto contrasto della continuità della sfumatura. Regressioni per diario senza player, allineamento al bordo superiore e navigazione. Analisi senza segnalazioni. Riscontro visivo su telefono aperto.

## Intestazione, filtri e apertura del diario — 18 novembre 2026

- Riepilogo paesi/tempo sulla stessa riga del titolo e allineato al margine destro dei contenuti, come richiesto da Davide. Larghezza limitata per gestire schermi stretti e testo ingrandito. Il totale usa minuti localizzati, includendo il tempo nei paesi di passaggio, e conserva l'indicazione sotto il minuto.
- Apertura da 420 a 520 ms con `easeInOutCubic`; chiusura a 340 ms con `easeInCubic`.
- Interpretati i pulsanti da ingrandire come i filtri periodo del diario mostrati nello screenshot: padding da 12/8 a 14/10 punti, spazio fra pulsanti da 6 a 8 punti. Token in `DiaryDesign`.
- Davide ha chiarito che i pulsanti da ingrandire sono quelli della home. Applicati simboli da 26 punti (prima 24), area di tocco 48×48 e gap 4 punti (prima 0), tramite tema locale della riga. In orizzontale titolo e azioni su righe distinte. Filtri del diario conservati per la revisione visiva richiesta.
- Per «Prossima fermata», proposta di riga dedicata sopra la radio se «Ovunque» diventa un selettore. Scelta del selettore da confermare con Davide.
- Verificati 41 test di diario, schede paese e home con Flutter 3.38.5. Analisi senza segnalazioni. Screenshot aggiornati. Corretto nel test helper il limite di clamp per un errore di arrotondamento floating-point del viewport.
- Ultima verifica dell’intestazione: 30 test di diario e schede paese superati, analisi pulita. Controllati stessa riga del titolo e margine destro. Screenshot aggiornati con icone home a 26 punti e riepilogo sulla riga del titolo.
- Riscontro visivo su telefono aperto per la nuova apertura e la tappabilità dei pulsanti.

## Prossimi passi, in ordine

1. **Cartolina del luogo:** sagoma e cartolina sulla radio, con l'animazione da definire con Davide; poi la collezione nel diario e le foto. Design in `superpowers/specs/2026-11-16-cartolina-design.md`.
2. **Scelta dei paesi:** il motore c'è, mancano interfaccia e gruppi. Il design va ancora fatto.

## Problemi aperti

- **Confini tra `radio` e `journey`:** i due domain si importano a vicenda, e `radio/domain/journey.dart` vive nella feature radio. Da chiarire prima di usare Frequenza come esempio dello starter.
- **`radio_cabinet.dart`** è lungo 908 righe: da dividere al prossimo intervento sulla radio.
- **Roadmap generale:** sta nello starter, non ancora pubblicato. Il collegamento si aggiunge quando lo starter è su GitHub.

---

# Storico
### Integrazione UI approvata — verifica più recente

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

### Rifinitura design — radio e pannello preferiti

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

### Scocca e display — 11 novembre 2026

- Scocca centrata a 360 px logici, limitata dai vincoli disponibili nelle finestre più strette. Le spaziature esterne variano entro limiti. Display con spazio riservato per stazione, dettaglio, indicatore a barre e stato.
- Manopola e griglia allineate e di diametro 112 px logici. Rimossa la didascalia della manopola in IT/EN.
- L'indicatore a barre è decorativo e compare in ascolto. Il titolo arriva da ICY se lo stream lo fornisce e viene azzerato a ogni nuova sintonizzazione.
- Verificati stabilità a 390 e 620 px e durante la sintonizzazione, accesso ai preferiti a 320×640 con testo al 200%, parità dei diametri, titolo simulato e azzeramento. Suite 19/19, analyzer pulito e bundle debug compilato.
- Prossimo passo: riscontro visivo su Android e verifica dei metadati su stream reali quando riprende il collaudo audio.

### Home senza scorrimento — 11 novembre 2026

- La home usa un layout non scorrevole. Scocca e comandi compatti nelle finestre basse, display e manopola affiancati in orizzontale. Rimossi i testi promozionali esterni alla radio.
- Verificati sintonizzazione, pausa, salvataggio e apertura preferiti in viewport simulati. Il caso a 320×640 e 640×320 include testo al 200% e margini di sistema simulati. Suite 19/19, analisi pulita e bundle debug compilato.
- Prossimo passo: feedback visivo su Android e collaudo dei metadati su stream reali.

### Didascalie ripristinate — 11 novembre 2026

- Ripristinati «Prossima fermata: ovunque» sopra la radio e il footer «WEB RADIO · SENZA CONFINI», con le traduzioni esistenti.
- Scocca verticale a 344 px logici, manopola e speaker ridotti allo stesso diametro. Nel layout compatto le barre condividono la riga di stato.
- Home senza scorrimento verificata in verticale e orizzontale con testo al 200%. Suite 19/19, analisi pulita e bundle debug compilato.

### Movimento e fruscio di sintonizzazione — 11 novembre 2026

- Le barre del display si muovono solo in play, si fermano in pausa e rispettano la riduzione del movimento. Il disegno è decorativo.
- La ricerca casuale dura almeno un secondo. Su Android, un fruscio sintetico locale riprodotto tramite SoundPool accompagna la ricerca e termina prima di caricare la diretta. SoundPool si ferma anche quando l'attività va in background. La scelta dai preferiti resta immediata.
- Verificati 19 test, analisi pulita e APK debug ARM64. Sull'emulatore, AudioFlinger ha registrato l'aggiunta e la rimozione della traccia del fruscio a circa 1,3 s di distanza, prima dell'avvio della traccia della diretta. La sessione di collaudo è stata messa in pausa.
- Prossimo passo: riscontro d'ascolto del fruscio su telefono e collaudo della riproduzione in background su dispositivo reale.

### Adozione dello starter — 11 novembre 2026

- Radio e Preferiti usano modelli e stati Freezed e provider Riverpod generati. Il contratto del player è nel dominio, con composizione in application.
- Home, pannello preferiti e schermata diagnostica usano componenti e token condivisi dallo starter. Tema base identico e palette radio passata dal prodotto.
- Preferiti v1 verificati con un record preesistente, inclusi i campi facoltativi e i tag malformati. Rigenerazione, formattazione, analisi, suite 20/20 e APK debug ARM64 verificati.
- La prova di riuso da zero con una seconda app neutra resta aperta nella fase 7.

### Preferiti asincroni — 12 novembre 2026

- Il provider generato espone AsyncValue. La lista confermata resta visibile durante la scrittura e dopo un errore. Il caricamento fallito resta recuperabile dal pannello.
- Code generation, analisi, bundle debug e 20 test verificati. Il prossimo intervento sulla base condivisa è nella roadmap dello starter, sezione Evoluzione dello starter secondo le convenzioni PackLog.

### Base condivisa adottata — 12 novembre 2026

- GoRouter collega home e Impostazioni. Easy Localization genera loader e chiavi dai cataloghi IT/EN. Le Impostazioni condivise espongono lingua e tema Sistema, Chiaro o Scuro con preferenze persistenti.
- Palette e token della home, scocca, equalizzatore, pannello Preferiti e diagnostica sono centralizzati nel tema di prodotto. I widget comuni seguono la base dello starter.
- Verificati generazione, formattazione, analisi, 20 test e APK debug ARM64. Sull'emulatore verificato il percorso home → Impostazioni → home. I test simulano il riavvio per lingua e tema nello starter e il cambio in Frequenza.
- Restano la prova della seconda app neutra e i moduli opzionali della roadmap, incluso Tgram Analytics per gli eventi prodotto.

### Notifica tramite audio_service — 12 novembre 2026

Passo 1 del design `superpowers/specs/2026-11-12-rotta-sul-mondo-design.md`; piano `superpowers/plans/2026-11-12-audio-service.md`.

- Rimosso `just_audio_background`. `RadioAudioHandler` (audio_service diretto) pubblica stato e comandi della notifica dallo stesso `AudioPlayer`; `JustAudioService` passa nome, Paese e logo della stazione tramite `RadioMediaSession`. Canale, opzioni di notifica e contratto del controller invariati.
- Verificati sulla VPS: formattazione, analisi senza segnalazioni, controlli dello stato del player, suite 31/31, bundle debug. Una revisione indipendente del branch ha portato a due correzioni: notifica ferma quando lo stream finisce e lock riportato sulle versioni del progetto. APK release non verificato: la build sulla VPS è stata fermata per memoria insufficiente.
- La VPS ha Flutter 3.47.4: `pub get` riscrive il lock e `build_runner` si blocca sull'analyzer. Il lock è stato modificato a mano e il provider `radioAudioHandler` scritto a mano nel `.g.dart`: rieseguire `bash tool/check.sh --apk` con Flutter 3.38.5 e versionare eventuali differenze.
- Prossimo passo: collaudo su telefono (checklist in fondo al piano), poi passo 2, la Rotta sul mondo.

### Rotta sul mondo — 12 novembre 2026

Passo 2 del design `superpowers/specs/2026-11-12-rotta-sul-mondo-design.md`; piano `superpowers/plans/2026-11-12-rotta-sul-mondo.md`. Branch `feat/rotta-sul-mondo` sopra `feat/audio-service`, non ancora pubblicato.

- Manopola e Preferiti seguono lo stesso volo. Il volo dura almeno 1 s, con il fruscio e la stazione a volume zero. L'atterraggio avviene solo con la riproduzione avviata e solo allora la notifica mostra la stazione. Dopo 12 s senza riproduzione compare «Segnale perso»: la manopola fa fino a 2 nuovi tentativi, il preferito nessuno. Una pausa di sistema durante il volo (cuffie, chiamata) annulla il volo.
- Display: mappa a puntini (Natural Earth) al posto delle barre nel layout normale, con scia radar, arco, storico di 5 rotte e «Viaggio n. X». Mostra anche distanza del tratto e ora locale con icona. Nel layout compatto l'ora prende il posto delle barre.
- L'atlante (`lib/features/journey/domain/atlas/world_atlas.g.dart`) si rigenera con `bash tool/world_atlas/generate.sh`, che usa la tzdata del sistema. L'Egitto e Lord Howe usano l'ora solare. Il Cile può sbagliare l'ora legale di una settimana in alcuni anni.
- Flutter 3.38.5 del progetto è installato sulla VPS in `/srv/claude/workspaces/.tools/flutter-3.38.5`. Verificati `tool/check.sh` (lock invariato), analisi pulita e suite 69/69, più una revisione indipendente del branch con quattro correzioni. APK non compilato sulla VPS.
- Limiti noti: su iOS il volo è muto. Pausa dalla notifica durante il volo: la stazione resta muta, il volo scade in «Segnale perso» e la manopola può riprovare.
- Prossimo passo: push dei due branch e PR, collaudo su telefono (checklist del passo 1, volo da manopola e Preferiti, niente audio prima dell'atterraggio, notifica «In volo…», modalità aereo, riduzione del movimento), poi aggiornamento di Flutter.

### Pipeline di rilascio — 13 novembre 2026

Design `superpowers/specs/2026-11-12-pipeline-design.md`; piano `superpowers/plans/2026-11-13-pipeline.md`. Branch `feat/pipeline`, che contiene anche la Rotta sul mondo (merge): da unire in `develop` dopo le PR della notifica e della Rotta.

- Due versioni installabili insieme: «Frequenza» (`it.davidetarsi.frequenza`) e «Frequenza Dev» (`.dev`), un solo `main.dart`. `default-flavor: dev` nel pubspec: `flutter run` e `tool/check.sh --apk` costruiscono la dev senza `--flavor`; per la prod `flutter build appbundle --flavor prod`.
- Firma da `android/key.properties` (ignorato da git); senza il file le release si firmano con la chiave di debug.
- Icona manopola generata da `python3 tool/icon/generate.py` (adattiva, monocromatica, PNG per densità, 512 per lo Store).
- Workflow: `ci.yml` (check.sh + `git diff --exit-code`; versione dalle etichette verso `main`), `bump_version.yml`, `build_dev.yml` (APK su Telegram), `release_prod.yml` (prerelease senza file, AAB negli artifact, Play solo con `PLAY_UPLOAD=on`, canale `PLAY_TRACK` o `alpha`), `promote_prod.yml` (a mano), `store_listing.yml`. Logica delle versioni in `.github/scripts/version.cjs`.
- `tool/check.sh` lancia anche i test Node delle versioni e i test Python (icona, workflow, scheda). Senza PyYAML in locale i test dei workflow si saltano; in CI sono obbligatori.
- Verificati sulla VPS: check.sh verde (69 test Flutter, 6 Node, test Python), APK dev e prod debug, APK dev release firmata con la chiave di debug (`aapt2`: id e nome giusti), script dei due workflow delle versioni simulati con GitHub finto. Le pipeline vere si verificano solo su GitHub: annotare qui l'esito della prima esecuzione di ognuna.
- Prossimo passo: azioni manuali in `docs/azioni-manuali.md` (segreti, variabili, etichette, regole), merge in `develop`, prima APK dev su Telegram e collaudo su telefono.

### Ritocchi interfaccia — 14 novembre 2026

Design `superpowers/specs/2026-11-14-ritocchi-ui-design.md`, piano `superpowers/plans/2026-11-14-ritocchi-ui.md`, branch `feat/ritocchi-ui`.

- Pausa e Salva sono tasti a leva dentro la radio, solo icone; restano abbassati in pausa o con la stazione salvata. Radio larga 320, mappa alta 84.
- In alto solo il cuore, con il numero dei preferiti nel colore primario.
- Impostazioni nello stesso foglio dei Preferiti (`TravelSheet`); la pagina `/settings` non c'è più.
- «ORA LOCALE» sopra l'orario nella disposizione normale; in quella compatta resta l'icona dell'orologio.
- Pressione lunga sul titolo della canzone: copia, vibrazione, «Titolo copiato» solo sotto Android 13 (metodo `sdkInt` sul canale nativo).
- Verificato: `tool/check.sh` verde (76 test Flutter), build dev debug.
- Aperto: collaudo sul telefono (aspetto dei tasti nei due temi, vibrazione, conferma di copia su Android 13+).
- Prossimo passo dopo il collaudo: ricerca per paese o per nome della stazione (Radio Browser ha già i filtri necessari).

### Notifica — 14 novembre 2026

Design `superpowers/specs/2026-11-14-notifica-design.md`, piano `superpowers/plans/2026-11-14-notifica.md`, branch `feat/notifica`.

- Tasti: indietro (a pila vuota riconnette la stazione), play/pausa, avanti, cuore; niente stop; in volo solo play/pausa. Sotto Android 13 il cuore non compare (limite accettato).
- Indietro: pila delle ultime 10 stazioni lasciate, solo sessione; il ritorno è un volo e conta come viaggio.
- Cuore della notifica e preferiti dell'app sempre allineati (provider `radioNotification`).
- Icona piccola: manopola bianca `ic_stat_frequenza`; immagine grande: logo della stazione o, se manca, il logo di Frequenza copiato nella cache.
- Verificato: `tool/check.sh` verde, build dev debug con icone e logo nell'APK.
- Da provare sul telefono: aspetto su Android 13+ e sotto, tasti da schermata di blocco, cuore e indietro dopo vari voli, logo di ripiego su una stazione senza logo.

### Larghezze in proporzione allo schermo — 14 novembre 2026

- Titolo e icone in alto usano tutta la larghezza, meno un margine del 3% dello schermo (12–24 punti).
- La radio è l'88% della larghezza dello schermo (280–420 punti, mai oltre lo spazio disponibile), arrotondata a punti interi: 343 su un telefono da 390, 281 su uno da 320.
- Tutti i valori in `TravelRadioLayout`; i pezzi interni della radio restano a misura fissa (la radio tutta in proporzione è rimandata).

### Allineamento alle convenzioni dello starter — 15 novembre 2026

- Controllo contro le convenzioni ereditate da PackLog. Allineati: code generation, Riverpod annotato, Easy Localization, tema chiaro e scuro, UI in `lib/ui`, feature first, pipeline GitHub. Supabase e Drift non servono.
- Corretti tre scostamenti:
  - `GeoPoint`, `StationPlace` e `TravelLeg` ora sono Freezed;
  - tolte dal codice tre stringhe in italiano (errore dello stream, «Sconosciuto», «Mondo»). Il paese mancante ora resta vuoto e l'interfaccia mostra «Paese sconosciuto» tradotto;
  - colore trasparente scritto a mano sostituito con `Colors.transparent`.
- Rimosso `RadioPlayerState.errorMessage`, che non veniva mai mostrato. Rimosso anche `tool/check_player_state.dart`: il suo caso è coperto dai test del controller.
- I preferiti salvati prima con paese «Mondo» lo conservano: è un dato già scritto in memoria.
- Da fare quando lo starter sarà su GitHub: confronto completo file per file.

### Etichetta della manopola su una riga — 15 novembre 2026

- La scritta sotto la manopola non va mai a capo. Se non ci sta, scorre verso sinistra (`MarqueeText` in `lib/ui/widgets`): pausa di 1,2 secondi con l'inizio in vista, poi 3 giri e si ferma sull'inizio. Con le animazioni disattivate è tagliata con «…». TalkBack la legge una volta sola.
- Il calcolo è dinamico: si misura il testo con la scala del carattere e lo si confronta con lo spazio disponibile. Nessuna larghezza fissata a mano; velocità, spazio tra le copie, pausa e giri sono token in `AppMotion`.
- Impostazioni senza sottotitolo: in `TravelSheet` il sottotitolo ora è facoltativo.

### Lingue con la sigla — 15 novembre 2026

- Nelle impostazioni ogni lingua ha la sua targhetta «IT» / «EN» al posto del globo, nello stile delle sigle dei Preferiti (`CodeBadge` in `lib/ui/widgets`, misure in `CodeBadgeDesign`). Prende il colore dell'icona, quindi anche quello della selezione.
- Ogni lingua è scritta nel suo nome in entrambe le lingue dell'app: «Italiano», «English».
- Scelta al posto delle bandiere: una lingua non è un paese, e le bandiere emoji cambiano da telefono a telefono.

### Radio bloccata in «Connessione alla radio» — 15 novembre 2026

Segnalato da Davide: con l'app in background la musica si ferma dopo pochi secondi, la notifica gira a vuoto e, riaperta l'app, manopola e tasti sono spenti.

- Lo stream smette di arrivare (buffering) e niente lo interrompeva: ora, se una stazione atterrata resta in buffering per 10 secondi (`FlightTiming.stallTimeout`), la radio si riconnette da sola con il volo di riconnessione, fino a 3 tentativi; se fallisce mostra l'errore con «Riprova».
- Durante il buffering di una stazione accesa manopola, pausa e cuore restano attivi: solo il volo li spegne.
- Una pausa mentre lo stream si riempie vale come pausa (`JustAudioService`), così la riconnessione non riaccende una radio messa in pausa.
- Ancora da capire: perché lo stream si ferma in background. Ipotesi: Android limita la rete all'app quando il servizio in primo piano cade. Serve un logcat dal telefono per confermarla.

### Macchine a stati esplicite — 15 novembre 2026

Piano `superpowers/plans/2026-11-15-macchine-a-stati.md`, branch `refactor/macchine-a-stati`.

- La radio è una `RadioSession` sealed (spenta, in volo, in onda, fallita) con `Journey` sempre presente. Le transizioni stanno in `next()` (`features/radio/domain/radio_session.dart`) con la loro tabella; il controller esegue solo gli effetti.
- La schermata legge `RadioDisplay.of(session)`: un solo `switch` esaustivo per titolo, paese, stato, manopola e tasti.
- «In volo» ha una sola fonte: la notifica lo sa solo da `showControls`, il motore audio segnala le pause di sistema (`systemPauses`) e decide la radio.
- Preferiti e tema salvano con `LatestSave` (`lib/app/state`).
- Cancellata la pagina di prova non raggiungibile, con il suo test e 24 chiavi di traduzione.
- Regola sealed/`AsyncValue` in `AGENTS.md`. Da portare nello starter: la regola, `LatestSave`, `CodeBadge`, `MarqueeText` e un esempio di feature con stato sealed.
- Verificato: `tool/check.sh` verde, 160 test. Da provare sul telefono: voli, indietro, pausa con le cuffie, notifica durante una nuova sintonia.

### Notifica in pausa — 15 novembre 2026

Design `superpowers/specs/2026-11-15-notifica-in-pausa-design.md`, piano `superpowers/plans/2026-11-15-notifica-in-pausa.md`, branch `feat/notifica-in-pausa`, sopra `refactor/macchine-a-stati`.

- Mentre suona o vola la notifica resta fissa. In pausa all'inizio si poteva scorrere via; dal fix del servizio in primo piano (sotto) resta fissa anche in pausa.
- Dopo 10 minuti di pausa (`FlightTiming.pauseTimeout`) lo stream si chiude e con lui la notifica; l'app mostra ancora la stazione, «Pronta a partire».
- App tolta dalle recenti: in pausa chiude servizio e notifica; mentre suona o vola continua (`RadioAudioHandler.onTaskRemoved`).
- Play su uno stream chiuso (app, cuffie, Bluetooth) rifà il volo di riconnessione verso la stessa stazione (`RadioMediaCommand.resume` → `RadioController.play`).
- Da provare sul telefono: scorrere via la notifica in pausa; togliere l'app dalle recenti mentre suona e in pausa; pausa lunga (per provarla, abbassare `pauseTimeout`); play dalle cuffie dopo la chiusura.
- Limite noto: dopo aver tolto l'app dalle recenti in pausa, il servizio e il motore Dart si chiudono; un play dalle cuffie riapre l'app da spenta, senza riconnettere. Da verificare anche che non chiuda l'app per errore (Android 12+ e avvio del servizio da un tasto multimediale).

### Suono di sintonizzazione — 15 novembre 2026

Design `superpowers/specs/2026-11-15-suono-sintonia-design.md`, piano `superpowers/plans/2026-11-15-suono-sintonia.md`, branch `feat/suono-sintonia`, sopra `feat/notifica-in-pausa`.

- Nuovo fruscio «C2» scelto da Davide: morbido e ovattato, timbro che scivola dal cupo al chiaro, stazioni che affiorano; 7,4 s in loop senza stacco. Generato da `tool/tuning_sound/generate.py` (seme fisso, test in `tool/test_tuning_sound.py`); il WAV passa da 44 KB a 650 KB.
- Android: `MediaPlayer` al posto di `SoundPool`; ogni volo parte da un punto a caso; volume `TUNING_VOLUME = 0.42f`; all'atterraggio sfuma in 400 ms; uscendo dall'app si ferma subito.
- La stazione sale di volume in 400 ms (8 passi) mentre il fruscio sfuma; una nuova sintonia interrompe la salita.
- Verificato: `tool/check.sh --apk` verde. Da provare sul telefono: volo lungo con il passaggio di fine loop; dissolvenza all'atterraggio; due voli di fila non identici; voli ravvicinati (il fruscio deve ripartire, non spegnersi).

### Vite in alto e voce «Informazioni» — 15 novembre 2026

Branch `feat/informazioni-e-vite`, sopra `feat/suono-sintonia`.

- La vite in alto a destra restava sul bordo solo prima del primo viaggio: la scritta «Viaggio n.» ora è allineata a destra nella sua metà, e la vite resta ferma accanto al numero (test con testo piccolo, come sul telefono).
- Impostazioni: nuova sezione «Informazioni» («About») con la voce «Visualizza progetto su GitHub» («View project on GitHub») e l'icona ↗; apre `https://github.com/davidetarsi/frequenza` (repository pubblico) con `url_launcher`, nuova dipendenza ufficiale di Flutter. Se il link non si apre compare «Impossibile aprire il link». L'indirizzo sta in `AppLinks` (`lib/app/links/external_links.dart`).
- Verificato: `tool/check.sh --apk` verde, 182 test. Da provare sul telefono: il link apre il browser o l'app di GitHub; la vite non si sposta dopo il primo viaggio.

### Servizio in primo piano anche in pausa — 15 novembre 2026

- **Il bug:** la radio in background si fermava dopo pochi secondi, con la notifica in caricamento. Il logcat di Davide mostra la radio in riproduzione senza servizio in primo piano: Android silenzia l'audio (`AudioHardening`) e congela il processo; quando l'app prova a tornare in primo piano dal background, `startForegroundService()` viene vietato.
- **La causa:** con `androidStopForegroundOnPause: true`, audio_service toglie il servizio dal primo piano a ogni pausa (anche di sistema: cuffie, chiamate, audio di un'altra app) e lo riprende solo quando la riproduzione riparte. Se riparte dal background, per esempio dal tasto delle cuffie, Android lo vieta.
- **Il fix:** `androidStopForegroundOnPause: false`, scelto da Davide. Il servizio resta in primo piano anche in pausa, quindi la notifica in pausa non si scorre via. Si chiude da sola dopo 10 minuti di pausa, oppure togliendo l'app dalle recenti.
- **La chiusura:** audio_service chiude il servizio sul passaggio a `idle`, ma non lo toglie dal primo piano, e la notifica di un servizio in primo piano non si cancella. Per questo, quando la radio si ferma davvero (stop, fine dello stream, errore), `RadioAudioHandler` chiede ad Android, prima di mostrare il nuovo stato, di togliere il servizio dal primo piano: metodo `leaveForeground` di `MainActivity`, che chiama `RadioForeground` (nel package del plugin) e la routine del plugin `exitForegroundState`, tenuta da R8 in `android/app/proguard-rules.pro`. Così si rilascia anche il wake lock. Rilievo della revisione indipendente.
- **Da provare sul telefono:** «Spegni» con l'app aperta, la notifica deve sparire; pausa, poi altra app, poi play dal tasto delle cuffie Bluetooth; la radio in background per qualche minuto mentre si usano altre app; la pausa lunga (si chiude dopo 10 minuti); togliere l'app dalle recenti in pausa.

### Pagina di benvenuto — 15 novembre 2026

- **Quando:** solo alla prima apertura (`WelcomeSeen`, chiave `app.welcomeSeen`); `bootstrap` la legge prima del primo frame e il router rimanda `/` a `/welcome`.
- **Cosa mostra:**
  - in alto le targhette EN · IT, che cambiano subito la lingua di tutta l'app;
  - al centro la radio vera (`RadioCabinet`) guidata da un copione di 6 secondi in loop: spenta, la manopola gira e la radio vola, poi atterra su «Radio Paraíso» (Brasile) con la rotta sulla mappa. È muta; con la riduzione del movimento resta ferma sulla stazione atterrata;
  - sopra la radio titolo e frase; con poco spazio e testo grande scorrono, così la radio resta visibile;
  - niente pulsante: intorno alla manopola un alone pulsa piano, e sotto c'è «Tocca la manopola per accendere». Toccando la radio, la pagina diventa vista, parte il primo volo e la radio si allarga fino a quella vera (`RadioCabinetHero`, uno shuttle che scala la radio di arrivo dentro un `Material` trasparente). Per i lettori di schermo la radio è il pulsante «Accendi la radio».
- **Lingua preselezionata:** quella con cui l'app si apre già, cioè l'italiano su un telefono italiano e l'inglese altrove. Scelta di Claude, nel design.
- **Da provare sul telefono:** prima apertura (per rivederla: cancellare i dati dell'app); il passaggio dalla radio piccola a quella vera, con il fruscio del primo volo; cambio di lingua dal benvenuto, che deve restare anche nella radio e alle aperture successive; tema chiaro e scuro; schermo piccolo; riduzione del movimento.

### Modulo per idee e segnalazioni — 15 novembre 2026

- **Dove:** Impostazioni, poi Informazioni, poi «Segnala un problema o un'idea», sotto «Visualizza progetto su GitHub».
- **Il link:** apre il modulo Google di Davide (`AppLinks.feedback`) con due campi già scritti: «Telefono» (`entry.331406160`, per esempio «Google Pixel 8 · Android 16», metodo nativo `deviceInfo`) e «Versione dell'app» (`entry.1664657182`).
- **La versione:** la legge `MainActivity` (metodo `appVersion`, `versionName+versionCode`) tramite `appVersionProvider`. Se non riesce, il campo resta vuoto.
- **Se il link non si apre:** compare «Impossibile aprire il link», come per GitHub.
- **Da provare sul telefono:** la voce apre il modulo con telefono e versione già compilati.


## Onboarding nella home — 18 novembre 2026

- Branch `feat/onboarding-guidato`, da `develop` dopo il rilascio 0.4.0+5. La guida usa `RadioPage` e `RadioCabinet` reali. Suggerimenti nel display con freccia e componente evidenziato, nell'ordine manopola, preferiti, diario. Nessun pulsante Avanti o Salta visibile.
- Primo titolo approvato «Accendi la radio». Corpo esatto da `welcomeBody`: «Ogni giro è una radio in diretta da qualche parte nel mondo. Quelle che ami le tieni con il cuore.»
- Fascia EN/IT disponibile nei tre step. Primo passo attivato solo dalla manopola, che avvia davvero il primo viaggio. Negli altri due basta un tocco sulla pagina. Le azioni della radio restano protette durante la guida. Indietro Android chiude la guida.
- Completamento salvato all'uscita, senza far interrompere l'ascolto. Dissolvenza della guida e della fascia, poi transizione esistente alla home con Hero della radio. Con movimento ridotto la dissolvenza e il volo Hero sono disabilitati.
- Copy scorrevole nel display su schermi piccoli, in orizzontale e con testo ingrandito. Azioni semantiche per proseguire con lettore di schermo. Traduzioni IT/EN rigenerate.
- Screenshot nativi controllati nei tre step. Rigenerazione, schema database, formato, analisi statica e controlli Node/Python superati con Flutter 3.38.5. Suite Flutter finale: 444 test superati, inclusi cambio lingua durante la guida, avvio viaggio, completamento persistente, Indietro Android, testo grande, orizzontale, movimento ridotto e azioni del lettore di schermo. Resta il collaudo su telefono di lettura, tocco e passaggio finale alla home.

### Guida dopo l'aggiornamento

- La revisione della guida è ora salvata in `app.welcomeRevision` (attuale: 2), separata dalla versione dell'app. Chi ha visto solo il vecchio onboarding vede la nuova guida una volta. Nuove installazioni mostrano direttamente la nuova guida, senza passare da quella precedente. Dopo completamento o chiusura con Indietro, i successivi avvii e aggiornamenti ordinari aprono la home.
- Il vecchio flag resta per compatibilità e per distinguere i nuovi utenti nelle statistiche: rivedere la guida dopo l'aggiornamento non conta come prima installazione. Per riproporla in futuro bisogna incrementare esplicitamente la revisione.
- Verificate tutte le stringhe IT/EN della guida e rigenerato il provider. Analisi statica pulita, 24 test mirati superati (installazione nuova, vecchio onboarding, revisione corrente/futura, riavvio, migrazione nella pagina, analytics e bootstrap).

## Informativa e logging — 19 novembre 2026

- Branch `fix/informativa-logging`, da `develop` dopo il merge della PR #44. Aggiornata la bozza di `docs/privacy.html` in italiano e inglese, confrontandola con eventi, dettagli della sessione, preferenza analytics e client tgram-analytics 0.2.0.
- Logging esplicito nell'introduzione e nella sezione dedicata; finalità, attivazione predefinita, eventi e dati esclusi. Distinti archivi locali ed eventi inviati, codice temporaneo e identificativi persistenti, disattivazione delle statistiche e connessioni per la radio. Rimossi assoluti non adatti al trattamento descritto, come «nessun dato personale» e «l'app non manda più nulla».
- Data aggiornata al 19 novembre 2026. HTML controllato per struttura, sezioni IT/EN e navigazione fra le lingue. Pubblicazione autorizzata da Davide tramite GitHub Pages, alimentato dal branch `develop`.
- Correzione di Davide: Frequenza usa il piano gratuito del servizio gestito tgram-analytics, non un server dello sviluppatore. Questa indicazione sostituisce l'ipotesi di hosting proprio presente nei vecchi piani. Corretti informativa IT/EN e istruzioni operative: endpoint del fornitore `https://api.tgram-analytics.com`, collegamenti a privacy e DPA, report tramite Telegram, infrastruttura UE e conservazione predefinita di 90 giorni attribuita al fornitore, senza dichiararla verificata sul singolo progetto. IP/User-Agent originali non conservati e hash giornaliero descritti secondo la documentazione ufficiale verificata il 19/11/2026 (https://tgram-analytics.com/privacy.html e https://tgram-analytics.com/dpa.html).

## Animazione mondo → paese → mondo — 19 novembre 2026

- Branch `feat/animazione-paese`, da `develop`. Prima versione da valutare visivamente con Davide, ripartendo dalla conversazione del 16/11: la direzione paese/cartolina era stata discussa, ma il movimento del vecchio mockup non era approvato. In questa fase si lavora solo sulla mappa della home.
- `RouteMap` torna al mondo al cambio stazione (800 ms) e all'arrivo avvicina il paese tracciandone il contorno (1800 ms, con sovrapposizione alla rotta esistente). Curve senza rimbalzo. I confini restano visibili durante l'ascolto e la pausa. Le riconnessioni mantengono l'inquadratura; un cambio interrotto riparte dalla vista corrente. Nessun ritardo aggiunto all'audio, nessuna modifica al motore della radio.
- Sagome offline da Natural Earth 1:50m, con la stessa divisione dei territori già usata nell'atlante. Nuovo generatore `tool/world_atlas/outlines.py`, richiamato da `generate.sh`; coordinate semplificate e codificate a delta, circa 274 KB complessivi. Decodifica e tracciati memorizzati al primo utilizzo. Gestiti paesi piccoli, linea del cambio data e dati mancanti (restano mondo e rotta). Nessuna richiesta di rete aggiuntiva.
- Movimento ridotto: inquadratura finale immediata, senza zoom né disegno animato. Prove native di Brasile e Giappone catturate per l'anteprima; sagome offline verificate anche per Singapore, Fiji, Russia e Guyana francese. Controllo completo `bash tool/check.sh` superato con 462 test Flutter, analisi statica pulita e controlli Node/Python verdi. Dopo una rifinitura per il ritorno dal background su una stazione senza posizione, ripetuti analisi e 34 test mirati dell’atlante/mappa, tutti verdi. Anteprima GIF nativa di 10,6 secondi disponibile nel workspace, fuori dal repository.
- Prossimo passo: giudizio di Davide sul movimento e collaudo della fluidità su telefono. Cartolina, foto e collezione restano nella fase successiva. Davide ha approvato l’anteprima e richiesto il merge in `develop`.
