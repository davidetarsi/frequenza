# Analisi d'uso con tgram-analytics — design breve

Data: 17 novembre 2026. Stato: **approvato** da Davide il 17/11. Branch `docs/analisi`, da `develop`.

Legenda:
- **[D]** decisione di Davide;
- **[C]** scelta di Claude.

## Intento

Davide vuole sapere cosa ascoltano i suoi utenti, pochi, forse dieci, e dove l'app si inceppa, per migliorarla. C'è anche uno scopo didattico: imparare a scegliere gli eventi e a ragionare sui dati **[D]**. Si fa prima del diario, così il diario nasce già misurato **[D]**.

**Anti-obiettivi:**
- l'app non deve chiedere niente prima della prima radio;
- nessun identificativo che resti sul telefono tra un avvio e l'altro;
- un errore delle analisi non deve mai toccare la radio.

## Approcci

1. **Scelto: tgram-analytics** **[D]**. Davide lo usa già in PackLog e riceve i report sul suo bot Telegram. Ha il pacchetto Flutter `tgram_analytics` (MIT), server in UE, nessun IP salvato.
2. **Scartato: PostHog.** È più potente, ma più pesante, raccoglie molto di base e richiede una dashboard in più.
3. **Scartato: Firebase Analytics.** Usa un identificativo del dispositivo e manda i dati a Google; servirebbe il consenso.
4. **Sentry per i crash: dopo**, in un passo suo **[C]**. tgram conta gli eventi, ma non raccoglie le tracce dei crash.

## Server

- **Server di Davide su Coolify**, all'indirizzo `https://analytics.davidetarsi.com`, così i progetti sono illimitati **[D]**. Se non è pronto in tempo, si usa il servizio gestito (`https://api.tgram-analytics.com`).
- **Indirizzo e chiave del progetto** arrivano con `--dart-define` (`TGA_SERVER_URL`, `TGA_API_KEY`), dai segreti di GitHub. Cambiare server non tocca il codice **[C]**.
- **Solo la build di produzione manda eventi** **[C]**. La dev e i test non hanno la chiave, e senza chiave le analisi sono spente. Per provarle, una build locale con le due variabili e `test: true`.
- **Conservazione:** 90 giorni, impostati sul progetto dal bot. Sul server proprio il predefinito è «per sempre» **[C]**.

## Consenso e Impostazioni

- **Accese di base, con un interruttore per spegnerle** **[C]**:
  - la sessione è un codice casuale creato a ogni avvio e tenuto solo in memoria;
  - non si salva nessun identificativo;
  - i dati non dicono chi sei.

  Chiedere il consenso nel benvenuto violerebbe la prima regola di `docs/principi.md`. È la lettura di Claude, non una consulenza legale.
- **Nelle Impostazioni, una sezione «Privacy»:**
  - l'interruttore «Statistiche anonime», con la riga «Aiutano a capire cosa non funziona. Nessun dato su di te.»;
  - il link all'informativa.
- **Spento significa spento:** nessuna chiamata al pacchetto, neanche in coda, e nessun evento d'addio. La scelta resta sul telefono, nelle preferenze.

## Gli eventi

Nomi in inglese, `oggetto_azione`, al passato. Le proprietà hanno valori chiusi o pubblici. Non si manda mai niente scritto dall'utente **[C]**.

**Proprietà della sessione**, una volta all'avvio:
- `app_version`;
- `locale`, `it` o `en`;
- `theme`: `system`, `light` o `dark`;
- `android_sdk`.

| Evento | Proprietà | Per capire |
|---|---|---|
| `app_opened` | `first_open` | quante persone tornano |
| `welcome_completed` | — | se il benvenuto ferma qualcuno |
| `flight_started` | `kind` (`forward` / `back` / `reconnect`) | quanto si gira la manopola, quanto si torna indietro |
| `flight_landed` | `kind`, `country`, `station`, `codec`, `attempts` | dove si atterra; quali formati arrivano |
| `flight_failed` | `kind`, `attempts` | quanto spesso un volo fallisce del tutto |
| `playback_broken` | `country`, `station`, `codec` | quali stazioni si rompono dopo l'atterraggio |
| `favorite_added` / `favorite_removed` | `country`, `station` | cosa piace davvero |
| `song_saved` / `song_removed` | `country`, `station` | se il segnalibro si usa |
| `song_search_opened` | `service` (`spotify` / `youtube` / `amazon_music` / `web`) | quali servizi servono davvero |
| `song_copied` / `station_retuned` | — | se le altre voci del menu si usano |

- **`station`** è il nome pubblico della stazione da Radio Browser; `country` è il codice ISO **[C]**.
- **`codec`**, già nella stazione, serve anche per le stazioni mute e per i formati che si rompono **[C]**.
- **Il tempo di ascolto** (`listen_ended`, con la durata a fasce) **arriva con il diario.** Lo calcola già la macchina a stati del registro (`Listening`, parte 1), e non lo si scrive due volte **[C]**. Il piano del diario aggiunge una riga per mandarlo.
- **Avvisi sul bot:** si configurano dal bot, non nel codice. Consiglio `flight_failed` e `playback_broken`, più il `/digest` settimanale **[C]**.

## Come si costruisce

- **Una feature `lib/features/analytics/`**, con i livelli dello starter (contratto e eventi nel domain, tgram nel data, provider e osservatore nell'application):
  - un'interfaccia `Analytics` con `track(name, properties)`;
  - due versioni: `TgramAnalytics` e `NoAnalytics`;
  - un provider che sceglie in base a chiave e interruttore.

  Le funzioni con i nomi degli eventi stanno in un solo file, come `CoreAnalyticsService` in PackLog **[C]**.
- **La radio non conosce le analisi** **[C]**. Un osservatore avviato in `bootstrap` guarda i passaggi della `RadioSession`:
  - da `Flying` a `OnAir`: `flight_landed`;
  - da `Flying` a `Failed`: `flight_failed`;
  - da `OnAir` a `broken`: `playback_broken`.

  Preferiti e canzoni chiamano l'evento dopo un salvataggio riuscito.
- **Dove nascono gli eventi** **[C]**:
  - **Radio** (`flight_*`, `playback_broken`): un osservatore, `radioAnalyticsProvider`, avviato in `bootstrap` accanto a `radioNotificationProvider`. Confronta la sessione prima e dopo ogni passaggio, con una funzione pura (prima, dopo) → eventi, testata come `next()`. Manopola, notifica, cuffie e «Riaccendi» passano tutti dalla stessa macchina a stati, quindi nessun volo si perde e nessuno si conta due volte. Il codice della radio resta com'è.
  - **Salvataggi** (`favorite_*`, `song_saved`, `song_removed`): nei controller `Favorites.toggle` e `SavedSongs.save` / `remove`, dopo che il salvataggio è riuscito. Lo stesso gesto arriva da più punti (segnalibro e tocco sul titolo; trascinamento e menu), e un doppione rifiutato non conta.
  - **Voci del menu** (`song_search_opened`, `song_copied`, `station_retuned`): in `SongsTab._choose`. Non passano da un controller, e solo lì si sa da dove è partito il gesto.
  - **Avvio** (`app_opened`, proprietà della sessione): in `bootstrap`, dopo aver letto le preferenze. **`welcome_completed`** in `WelcomeSeen.markSeen`.
- **Errori:** ogni chiamata è protetta. Senza rete, gli eventi in coda si perdono, senza riprovare all'infinito **[C]**.
- **Test:**
  - con le analisi spente non parte nessuna chiamata;
  - ogni passaggio della radio produce l'evento giusto, e uno solo;
  - nessuna proprietà contiene testo dell'utente.

## Testi da cambiare

- **Informativa** (`docs/privacy.html`, IT/EN):
  - un paragrafo su cosa si manda, a chi, dove, per quanto e come si spegne;
  - le canzoni salvate tra le cose che restano sul telefono.
- **README:** «No account, no ads, no algorithm. Anonymous usage statistics, which you can turn off.»
- **Scheda dello Store** (IT/EN): cambia la riga «nessun dato raccolto».
- **Sicurezza dei dati nella Play Console**, un'azione manuale di Davide:
  - «Attività nell'app → interazioni» e «Informazioni e prestazioni dell'app → diagnostica»;
  - raccolti, non condivisi, cifrati in transito, facoltativi.
- **`docs/principi.md`:** la scelta «nessun dato» diventa «statistiche anonime, che si spengono». Il 16/11 il diario aveva deciso «niente analytics»: questa decisione la sostituisce **[D]**.

## Lasciato a chi costruisce

- Se aggiungere alla stazione il campo `hls` di Radio Browser, per distinguere i flussi HLS (non serve per partire).
