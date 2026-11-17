# Canzoni salvate (primo passo della cartolina) — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** il titolo in onda arriva pulito; il segnalibro accanto al titolo lo salva; le canzoni salvate si ritrovano nella scheda «Canzoni» dei preferiti, da cui si cercano nelle app, si copiano, si riaccende la radio e si tolgono con «Annulla».

**Architecture:**
- **Pulizia del titolo:** una funzione pura nel dominio radio, `TrackTitle.parse`.
- **Nuova feature `songs`:**
  - dominio: `SavedSong`;
  - repository su SharedPreferences, come i preferiti; passerà a Drift con il diario;
  - controller Riverpod;
  - costruttore puro dei link di ricerca, più un metodo nativo per sapere quali app sono installate.
- **Interfaccia:** il segnalibro sta nello schermo della radio; i preferiti diventano un foglio con due schede.

**Tech Stack:** Flutter, Riverpod (generator), freezed, easy_localization, shared_preferences, url_launcher, Kotlin (MainActivity).

**Spec:** `docs/superpowers/specs/2026-11-16-cartolina-design.md` (passo 2 dell'ordine dei lavori, più la pulizia del titolo del passo 1).

## Global Constraints

- **Le parole** (it/en):
  - le stazioni sono «preferite»;
  - le canzoni sono «salvate», mai «preferite»;
  - le due schede si chiamano «Radio» e «Canzoni».
- **Le icone:**
  - per salvare, `Icons.bookmark_add_outlined`, che diventa `Icons.bookmark_added` quando la canzone è salvata;
  - il cuore resta solo sulla stazione.
- **Il salvataggio:**
  - si salva toccando il segnalibro oppure il titolo;
  - la pressione lunga sul titolo copia, come oggi;
  - una canzone già salvata non si duplica.
- **L'avviso:** è una snackbar in basso, con l'azione «Annulla». Non ci sono mai richieste di conferma.
- **Il menu della canzone:** si apre dai tre puntini verticali (`Icons.more_vert`). Le voci sono, in questo ordine:
  - un «Cerca su <servizio>» per ogni app installata;
  - «Cerca sul web»;
  - «Copia»;
  - «Riaccendi <stazione>»;
  - «Togli», per ultima, in colore di errore.
- **Per togliere una canzone:** trascinarla a sinistra (`Dismissible`, `endToStart`) oppure la voce «Togli» del menu. Tutte e due mostrano «Annulla».
- **I link di ricerca**, con `<q>` = `Uri.encodeComponent(query)`:
  - Spotify: `spotify:search:<q>`;
  - YouTube: `https://www.youtube.com/results?search_query=<q>`;
  - Apple Music: `https://music.apple.com/search?term=<q>`;
  - web: `https://www.google.com/search?q=<q>`.
- **I pacchetti da dichiarare** in `<queries>`: `com.spotify.music`, `com.google.android.youtube`, `com.apple.android.music`.
- **Archiviazione:**
  - chiave SharedPreferences `frequenza.songs.v1`;
  - tutto resta sul telefono;
  - letture tolleranti come `PreferencesFavoritesRepository`, che salta le voci non valide.
- **Verifica a fine task:** `bash tool/check.sh`, con Flutter in `/srv/claude/workspaces/.tools/flutter-3.38.5/bin`. Dopo i cambi a freezed o riverpod va rigenerato con `dart run build_runner build -d`; dopo i cambi alle traduzioni con `tool/generate_l10n.sh`.

## Review Focus

1. **Lo stesso titolo con maiuscole o spazi diversi:** non crea un doppione (Task 3).
2. **Annulla dopo due rimozioni di fila:** rimette la canzone giusta, nella sua posizione (Task 3).
3. **Dati salvati rovinati o di una versione diversa:** si caricano quelli validi, senza crash (Task 3).
4. **Canale nativo assente** (test, altre piattaforme): nessuna app risulta installata, nel menu resta «Cerca sul web» e non c'è nessuna eccezione (Task 4).
5. **Il titolo cambia mentre tocchi:** si salva il titolo mostrato al momento del tocco, non quello arrivato subito dopo (Task 5).

---

### Task 1: `TrackTitle`, il titolo pulito

**Files:**
- Create: `lib/features/radio/domain/track_title.dart`
- Modify: `lib/features/radio/presentation/radio_display.dart` (il campo `song` usa il titolo pulito)
- Test: `test/features/radio/track_title_test.dart`, `test/features/radio/radio_display_test.dart`

**Interfaces:**
- Produces: `final class TrackTitle { final String? artist; final String title; String get display; String get query; static TrackTitle? parse(String raw, {String? stationName}); }`
  - `display` vale `'$artist — $title'`, oppure `title` quando manca l'artista.
  - `query` vale `'$artist $title'`, oppure `title`.

- [ ] **Step 1: test** in `track_title_test.dart`:
  - «splits artist and title on a spaced dash»: `parse('Ana Moura - Desfado')` → artist `Ana Moura`, title `Desfado`. Stesso risultato con ` – ` e ` — `. Si divide solo al primo trattino: `parse('A - B - C')` → artist `A`, title `B - C`.
  - «drops the on-air prefixes»: `parse('Now On Air: Fábio Jr. - Pai')!.artist == 'Fábio Jr.'`; idem per `Now Playing:`, `On Air:`, `NP:`, senza distinguere le maiuscole.
  - «keeps a title without artist»: `parse('Desfado')` → artist `null`, display `Desfado`.
  - «rejects what is not a song»: `null` per:
    - `''` e `'  '`;
    - `'002'` e `'- -'`, cioè solo cifre e punteggiatura;
    - `'Live365 - Live365 - Advertisement'`;
    - qualunque testo che contenga, senza distinguere le maiuscole, `advert`, `commercial break` o `pubblicità`;
    - il nome della stazione: `parse('KEXP 90.3 FM', stationName: 'KEXP 90.3 FM')`.
  - «trims and collapses spaces»: `parse('  Ana   Moura  -  Desfado ')!.display == 'Ana Moura — Desfado'`.
- [ ] **Step 2:** eseguirli. Expected: FAIL (file mancante).
- [ ] **Step 3:** implementare `TrackTitle`.
- [ ] **Step 4: test in `radio_display_test.dart`:** «the song on air is shown clean». Una sessione `OnAir` con `trackTitle: 'Now On Air: Ana Moura - Desfado'` dà `display.song == 'Ana Moura — Desfado'`; con `trackTitle: 'Advertisement'` dà `display.song == null`. Poi va fatto passare, aggiungendo a `RadioDisplay` anche `final TrackTitle? track` per i task successivi.
- [ ] **Step 5:** `bash tool/check.sh`. Expected: verde. Commit `feat(radio): titolo della canzone pulito, artista e titolo separati`.

### Task 2: ricerca nelle app

**Files:**
- Create: `lib/features/songs/domain/song_search.dart`, `lib/features/songs/data/installed_apps.dart`
- Modify: `android/app/src/main/kotlin/it/davidetarsi/frequenza/MainActivity.kt` (metodo `installedApps`), `android/app/src/main/AndroidManifest.xml` (tre `<package>` in `<queries>`)
- Test: `test/features/songs/song_search_test.dart`

**Interfaces:**
- Produces:
  - `enum SearchService { spotify, youtube, appleMusic, web }`, con `String? get package`, nullo per `web`;
  - `List<(SearchService, Uri)> SongSearch.links(String query, Set<String> installedPackages)`;
  - `Future<Set<String>> installedPackages(Iterable<String> packages)`, che usa `nativeChannel.invokeMethod<List>('installedApps', packages.toList())`;
  - `final installedPackagesProvider = FutureProvider<Set<String>>` (keepAlive), sui tre pacchetti.

- [ ] **Step 1: test:**
  - «builds the four links with the query encoded»: per la query `Ana Moura Desfado` e tutti i pacchetti installati, le URI sono esattamente quelle dei Global Constraints, con `Ana%20Moura%20Desfado`;
  - «shows only installed apps, the web always»: con solo `com.google.android.youtube` installato, la lista è `[youtube, web]`;
  - «no channel means no apps»: `installedPackages` su un canale senza handler restituisce `{}` senza eccezioni (`TestDefaultBinaryMessengerBinding`).
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare.
  - **Lato Kotlin:** per ogni pacchetto si considera installato se `packageManager.getLaunchIntentForPackage(name) != null`.
  - **Lato Dart:** su `PlatformException`, `MissingPluginException` o dopo un timeout di 1 s si restituisce `{}`.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde. Commit `feat(songs): link di ricerca per Spotify, YouTube, Apple Music e web`.

### Task 3: `SavedSong`, archivio e controller

**Files:**
- Modify: `lib/features/radio/domain/radio_station.dart` (`String? region`, `@JsonKey(name: 'region')`), `lib/features/radio/data/radio_browser_repository.dart` (`region` da `json['state']`, ripulito degli spazi, nullo se vuoto)
- Create: `lib/features/songs/domain/saved_song.dart`, `lib/features/songs/data/preferences_songs_repository.dart`, `lib/features/songs/application/saved_songs.dart`
- Test: `test/features/songs/saved_songs_test.dart`, più un caso in `radio_browser_repository_test.dart`

**Interfaces:**
- Consumes: `TrackTitle` (Task 1).
- Produces:
  - `SavedSong`, freezed con JSON, con i campi `String? artist, String title, RadioStation station, DateTime savedAt`.
    - `String get key`: `'${station.id}|${normalized(artist)}|${normalized(title)}'`, dove `normalized` vuol dire minuscole e spazi compattati.
    - `String get display` e `String get query`, come in `TrackTitle`.
    - La regione è `station.region` e il paese `station.country`/`countryCode`.
  - `abstract interface class SongsRepository { Future<List<SavedSong>> load(); Future<void> save(List<SavedSong> songs); }`, con `songsRepositoryProvider`.
  - `@Riverpod(keepAlive: true) class SavedSongs extends _$SavedSongs`:
    - `Future<List<SavedSong>> build()`, in ordine di salvataggio;
    - `Future<bool> save(TrackTitle track, RadioStation station)`, che restituisce `false` se c'era già;
    - `bool contains(TrackTitle track, RadioStation station)`;
    - `Future<void> remove(SavedSong song)`;
    - `Future<void> restore(SavedSong song, int index)`.
  - Il controller serializza i salvataggi con `LatestSave`, come `Favorites`.

- [ ] **Step 1: test:**
  - «parses the region from Radio Browser's state»: `'state': ' California '` → `region == 'California'`; `''` → `null`;
  - «saving twice the same song keeps one»: `save` di `Desfado` e poi di ` desfado ` sulla stessa stazione → una sola voce, e il secondo `save` restituisce `false`;
  - «the same song on another station is another entry»;
  - «saved songs survive reopening the repository», con la stazione intera (url, paese, regione) e `savedAt`;
  - «a broken entry is skipped, the others load»: un JSON con una voce senza `title`, una con url non https e una valida → si carica solo la valida;
  - «restore puts the song back where it was»: con tre canzoni A, B, C, si tolgono B e poi C, poi si fa `restore(B, 1)` → l'elenco è `[A, B]`.
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare, poi `dart run build_runner build -d`.
  - L'archivio usa le stesse chiavi corte e le stesse verifiche della stazione nei preferiti, più `region`.
  - Le date vanno salvate in ISO 8601 UTC.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde. Commit `feat(songs): canzoni salvate sul telefono, senza doppioni, con Annulla`.

### Task 4: il segnalibro sulla radio

**Files:**
- Modify: `lib/features/radio/presentation/radio_cabinet.dart` (parametri `onDetailTap` e `detailAction: Widget?`, accanto al titolo nella riga del dettaglio), `lib/features/radio/presentation/radio_page.dart`, `assets/translations/it.json`, `assets/translations/en.json`
- Test: `test/app_test.dart` o `test/features/songs/save_song_test.dart` (widget)

**Interfaces:**
- Consumes: `RadioDisplay.track` (Task 1), `SavedSongs.save/contains/remove` (Task 3).
- Testi nuovi:
  - `saveSong`: «Salva canzone» / «Save song»;
  - `songSaved`: «Canzone salvata» / «Song saved»;
  - `undo`: «Annulla» / «Undo».
  - **Ruling:** l'avviso non nomina ancora la cartolina, perché in questo passo non esiste. Diventerà «Salvata sulla cartolina di …» con le cartoline.

- [ ] **Step 1: test:**
  - «the bookmark saves the song on air»: c'è una stazione in onda con un titolo; il tocco su `Icons.bookmark_add_outlined` aggiunge una canzone e mostra la snackbar «Canzone salvata» con «Annulla»; l'icona diventa `Icons.bookmark_added`;
  - «tapping the title saves it too»;
  - «undo removes it»;
  - «a long press still copies», cioè non cambia niente rispetto a oggi;
  - «no title, no bookmark»: con soli i tag mostrati, il segnalibro non c'è;
  - «saves the title shown when tapped»: si tocca e subito dopo arriva un nuovo titolo; la canzone salvata è la prima.
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare.
  - L'icona ha come tooltip e etichetta semantica `saveSong`.
  - Il colore è quello dell'inchiostro dello schermo, ed è dentro lo schermo.
  - Un tocco sul segnalibro di una canzone già salvata non fa niente.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde. Commit `feat(songs): il segnalibro accanto al titolo salva la canzone`.

### Task 5: la scheda «Canzoni»

**Files:**
- Modify: `lib/features/favorites/presentation/favorites_sheet.dart` (due schede, stato locale della scheda scelta, apertura su «Radio»)
- Create: `lib/features/songs/presentation/songs_tab.dart`
- Modify: traduzioni it/en
- Test: `test/features/songs/songs_tab_test.dart`

**Interfaces:**
- Consumes: `SavedSongs` (Task 3), `SongSearch.links`, `installedPackagesProvider` (Task 2), `RadioController.tuneTo(RadioStation)`, `copyTrackTitle`.
- Testi nuovi:
  - `tabStations`: «Radio» / «Radio»;
  - `tabSongs`: «Canzoni» / «Songs»;
  - `songsSubtitle`: «Canzoni trovate in viaggio.» / «Songs found on the road.»;
  - `songsEmpty`: «Ancora nessuna canzone. Tocca il segnalibro accanto al titolo quando ne senti una che ti piace.» / «No songs yet. Tap the bookmark next to the title when you hear one you like.»;
  - `searchOn`: «Cerca su {}» / «Search on {}»;
  - `searchWeb`: «Cerca sul web» / «Search the web»;
  - `copy`: «Copia» / «Copy»;
  - `tuneAgain`: «Riaccendi {}» / «Tune in to {}»;
  - `removeSong`: «Togli» / «Remove»;
  - `songRemoved`: «Canzone tolta» / «Song removed».
  - I nomi dei servizi non si traducono: Spotify, YouTube, Apple Music.

- [ ] **Step 1: test:**
  - «the sheet opens on Radio and switches to Songs»;
  - «songs are grouped by country, newest first». I gruppi seguono la canzone più recente; un codice paese vuoto va in un gruppo «Paese sconosciuto» (chiave esistente `unknownCountry`). Ogni riga mostra il titolo, poi «artista · stazione · giorno», con la regione dopo la stazione quando c'è;
  - «the menu lists installed apps, then web, copy, tune, remove»: con solo YouTube installato, le voci sono, in quest'ordine, `Cerca su YouTube`, `Cerca sul web`, `Copia`, `Riaccendi KEXP`, `Togli`;
  - «a search opens the link outside the app»: si verifica con un `launchUrl` finto iniettato via provider (`songLauncherProvider`, `Future<bool> Function(Uri)`), che riceve la URI di YouTube;
  - «swiping left removes with undo», poi «Annulla» la rimette al suo posto;
  - «remove from the menu shows the same undo»;
  - «tune again closes the sheet and flies to the station».
- [ ] **Step 2:** eseguirli. Expected: FAIL.
- [ ] **Step 3:** implementare.
  - Le schede sono `SegmentedButton` o `TabBar`, nello stile del foglio.
  - Lo sfondo del `Dismissible` mostra l'icona `Icons.delete_outline` e «Togli».
  - **Ruling:** la cancellazione «a penna» e le altre animazioni restano fuori. Davide vuole definirle a parte; per ora valgono l'animazione standard del `Dismissible` e quella della snackbar.
- [ ] **Step 4:** `bash tool/check.sh`. Expected: verde. Commit `feat(songs): scheda Canzoni nei preferiti, con ricerca, copia, riaccendi e togli`.

### Task 6: prova sul telefono e note

**Files:**
- Modify: `distribution/whatsnew/whatsnew-it-IT`, `distribution/whatsnew/whatsnew-en-US`, aggiornati solo se Davide decide di pubblicare questo passo; altrimenti nessun file.

- [ ] **Step 1:** dopo il merge su develop, Davide installa la build di sviluppo e prova:
  - «Cerca su Spotify», che deve aprire l'app con la ricerca scritta;
  - «Cerca su Apple Music», che deve arrivare sulla ricerca o almeno nell'app;
  - «Cerca su YouTube».
  
  Se il link di Spotify non apre la ricerca, si passa a `https://open.spotify.com/search/<q>`: è una riga in `song_search.dart`, con il test aggiornato.
- [ ] **Step 2:** aggiornare `frequenza-da-fare-davide` (memoria) con le prove sul telefono.
