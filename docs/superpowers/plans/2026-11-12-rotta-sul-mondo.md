# Rotta sul mondo — piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ogni sintonizzazione (manopola o Preferiti) diventa un volo senza spoiler sulla mappa del display, che atterra esattamente quando la stazione suona.

**Architecture:** il controller radio gestisce un unico flusso di volo per `tuneRandom` e `tuneTo`: tentativo con timeout, minimo di 1 s, attesa di `PlaybackStatus.playing` a stream muto, poi `land`, che toglie il muto e mostra la stazione nella notifica. Il viaggio (partenza, tratto, storico, contatore, fase) vive in `RadioPlayerState`. Geografia, distanze e ora locale sono Dart puro nella nuova feature `journey`, con tabelle generate da uno script versionato. La mappa è un `CustomPainter` che sostituisce l'equalizzatore nel layout regolare.

**Tech Stack:** Flutter 3.38.5, Riverpod generato 2.6, Freezed 2, just_audio, audio_service, easy_localization, intl. Nessuna nuova dipendenza Dart.

**Spec:** `docs/superpowers/specs/2026-11-12-rotta-sul-mondo-design.md`

## Global Constraints

- Usare Flutter 3.38.5 da `/srv/claude/workspaces/.tools/flutter-3.38.5/bin` (PATH davanti a quello di sistema). Con questa versione `pub get`, `build_runner` e `tool/generate_l10n.sh` si usano normalmente. Il lock non deve cambiare.
- Branch `feat/rotta-sul-mondo` sopra `feat/audio-service`. Niente push finché Davide non sblocca la chiave.
- Atterraggio: almeno 1 s **e** player in riproduzione. Audio della stazione mai udibile prima. Atterraggio di circa 0,6 s.
- Timeout di 12 s per tentativo, contato dall'avvio. Tune: al massimo 2 tentativi automatici dopo il primo. Preferito: nessun nuovo tentativo.
- Partenza: centro dell'Italia, poi l'ultima stazione atterrata con un luogo noto.
- Mai nome, Paese, coordinate o immagine della meta prima dell'atterraggio: né a schermo né nella notifica.
- Ora locale sempre mostrata se ricavabile. «≈» su distanza e ora quando sono approssimate. Distanza nascosta per lo stesso Paese con un estremo approssimato.
- Storico: ultime 5 rotte. Contatore «Viaggio n. X». Entrambi solo per la sessione.
- Riduzione del movimento (`AppMotion.enabled == false`): mappa ferma e arco già disegnato. Il fruscio resta.
- Nessun overflow a 320×640 e 640×320 con testo al 200%.

## Review Focus

1. Stream pronto prima di 1 s: deve restare muto fino a `land`. Test nel Task 3 (muto fino a `land`) e nel Task 4 (atterraggio non prima del minimo).
2. Un'interruzione «duck» che finisce durante il volo non deve riportare il volume a 1. Test nel Task 3.
3. Il risultato tardivo di un tentativo annullato non deve atterrare, togliere il muto né spostare la partenza. Test nel Task 4.
4. API lenta (8 s per mirror, fino a 24 s): il tentativo finisce comunque a 12 s. Test nel Task 4.
5. Dati sporchi: coordinate stringa, fuori intervallo o 0,0 nei preferiti e nell'API contano come assenti e il record resta valido. Una stazione senza coordinate e senza codice Paese atterra senza arco e senza errori nei testi. Test nei Task 1, 2 e 5.

Rischio noto, fuori dai test: Pausa o Stop dalla notifica durante il volo. La stazione è muta, quindi non si sente nulla, ma il volo finisce per timeout come «Segnale perso».

---

### Task 1: SDK del progetto, coordinate della stazione e preferiti

**Files:**
- Modify: `lib/features/radio/domain/radio_station.dart` (+ `.freezed.dart`, `.g.dart` rigenerati)
- Create: `lib/features/journey/domain/geo_point.dart`
- Modify: `lib/features/radio/data/radio_browser_repository.dart` (`_parseStation`)
- Modify: `lib/features/favorites/data/preferences_favorites_repository.dart`
- Test: `test/features/radio/radio_browser_repository_test.dart`, `test/features/favorites/favorites_test.dart`, `test/features/journey/geo_point_test.dart`

**Interfaces:**
- Produces: `RadioStation.latitude`/`longitude` (`double?`, JSON `lat`/`lon`); `class GeoPoint { const GeoPoint(this.latitude, this.longitude); static GeoPoint? tryFrom(Object? lat, Object? lon); double distanceKm(GeoPoint other); }`; `RadioStation.point → GeoPoint?`.

- [ ] **Step 1:** con il PATH su 3.38.5, eseguire `flutter pub get` e `dart run build_runner build --delete-conflicting-outputs`. Expected: `git status` pulito, oppure solo i `.g.dart` scritti a mano nel passo 1 che tornano alla forma generata. In quel caso: commit «Regenerate sources with the project SDK».
- [ ] **Step 2: test che falliscono.**
  - `geo_point_test`: `tryFrom('45.4', 9.2)` dà null, perché accetta solo `num`. `tryFrom(0, 0)` dà null. `tryFrom(91, 0)` e `tryFrom(0, 181)` danno null. `tryFrom(45.46, 9.19)` è valido. `GeoPoint(45.46, 9.19).distanceKm(GeoPoint(48.86, 2.35))` è 640 km circa (±5): haversine con R = 6371 km.
  - Repository: `geo_lat: 35.68, geo_long: 139.76` dà `point` non nullo. `geo_lat: null` o `geo_lat: 0, geo_long: 0` danno `point == null`.
  - Preferiti: un record v1 senza `lat`/`lon` si carica con `point == null`. Salvataggio e lettura conservano `lat`/`lon`. Un record con `lat: "x"` si carica con `point == null`.
- [ ] **Step 3:** eseguire i test. Expected: FAIL (`latitude` non esiste).
- [ ] **Step 4:** aggiungere i campi Freezed `double? latitude` (`@JsonKey(name: 'lat')`) e `double? longitude` (`@JsonKey(name: 'lon')`), il getter `point` (via `GeoPoint.tryFrom`) e rigenerare. Il repository legge `geo_lat`/`geo_long` e le salva solo se `GeoPoint.tryFrom` le accetta. I preferiti aggiungono `lat`/`lon` alle chiavi salvate e in lettura le passano solo se sono `num`.
- [ ] **Step 5:** `flutter test --no-pub test/features`. Expected: tutto verde.
- [ ] **Step 6:** commit «Read station coordinates and keep them in favorites».

### Task 2: atlante del mondo (dati generati, luoghi, distanze, ora locale)

**Files:**
- Create: `tool/world_atlas/generate.py`: genera l'atlante. Usa Natural Earth 110m land e 50m admin-0, scaricati in `build/world_atlas/` e non versionati, più `zone.tab` e `zoneinfo` del sistema.
- Create: `lib/features/journey/data/world_atlas.g.dart`: generato e versionato.
- Create: `lib/features/journey/domain/station_place.dart`, `lib/features/journey/domain/local_clock.dart`, `lib/features/journey/domain/travel_leg.dart`
- Test: `test/features/journey/station_place_test.dart`, `test/features/journey/local_clock_test.dart`

**Contenuto generato:**
- `const worldDotStep = 2.5`, `const worldDotRows = <String>[...]`: righe da 80° N a 60° S, colonne da −180° a 180°, `'1'` sulle celle con il centro in terra (point-in-polygon in Python puro).
- `const countryCentroids = <String, (double, double)>{...}`: `LABEL_Y`/`LABEL_X` da admin-0 50m, chiave `ISO_A2_EH`. Per i codici di `zone.tab` assenti si usa la prima città del Paese.
- `const timeZones = <(int stdMinutes, DstRule rule)>[...]` e `const countryZones = <String, List<(int zone, double lat, double lon)>>{...}`. Per Paese, una voce per ogni coppia (offset standard, regola) distinta, con la prima città di `zone.tab` per quella coppia. Prima voce = fuso principale, con override per `RU` Mosca, `BR` San Paolo, `AU` Sydney, `CA` Toronto, `MX` Città del Messico, `ID` Giacarta, `KZ` Almaty, `CD` Kinshasa.
- `enum DstRule { none, eu, northAmerica, australia, newZealand, chile }`. Lo script classifica ogni fuso confrontando `zoneinfo` giorno per giorno sul 2027 con ciascuna regola, tollerando 1 giorno. I fusi non classificabili usano `none` con l'offset più frequente nell'anno. Lo script li stampa: vanno nel ledger.

**Interfaces:**
- Produces:
  - `class StationPlace { GeoPoint point; bool approximate; String countryCode; }`
  - `StationPlace? placeOf(RadioStation s)`: coordinate proprie; altrimenti centro del Paese con `approximate: true`; altrimenti null.
  - `const StationPlace homePlace`: centro di `IT`, approssimato.
  - `class TravelLeg { StationPlace from; StationPlace? to; }` con `({int km, bool approximate})? get distance`: null se `to` è null, oppure se è lo stesso Paese con un estremo approssimato.
  - `({String hhmm, bool approximate})? localTimeOf(RadioStation s, DateTime nowUtc)`

- [ ] **Step 1:** scrivere e lanciare lo script. Expected: il file `.g.dart` è generato, `dart format` è pulito e il riepilogo mostra righe, Paesi e fusi non classificati.
- [ ] **Step 2: test che falliscono.**
  - `placeOf` usa le coordinate proprie con `approximate: false`. Senza coordinate e con `FR` restituisce il centroide approssimato. Con `countryCode: ''` e senza coordinate restituisce null.
  - Distanza: Milano → Parigi (proprie) dà 640 km circa, non approssimata. `homePlace` → stazione `IT` approssimata dà null. `homePlace` → `JP` approssimata è approssimata.
  - `localTimeOf`:
    - `IT` alle `2027-07-01T10:00Z` dà `12:00`; a gennaio dà `11:00`.
    - `US` con coordinate di Los Angeles alle `2027-07-01T20:00Z` dà `13:00`, non approssimata. `US` senza coordinate dà `16:00`, approssimata.
    - `AU` Sydney a gennaio è UTC+11.
    - Codice sconosciuto `XX` dà null.
  - Atlante: almeno una cella di terra in `worldDotRows` alla riga di 45° N nella colonna di 9° E, e nessuna a 0°, −30° (Atlantico).
- [ ] **Step 3:** eseguire i test. Expected: FAIL.
- [ ] **Step 4:** implementare `station_place.dart`, `travel_leg.dart` e `local_clock.dart`. Le date delle regole DST si calcolano in UTC: EU ultima domenica di marzo e di ottobre alle 01:00 UTC. Nord America seconda domenica di marzo e prima di novembre alle 02:00 ora locale. Australia prima domenica di ottobre e di aprile. Nuova Zelanda ultima domenica di settembre e prima di aprile. Cile prima domenica di settembre e di aprile alle 04:00 UTC. Nessuna dipendenza `timezone`: le tabelle stanno nell'atlante.
- [ ] **Step 5:** `flutter test --no-pub test/features/journey`. Expected: verde.
- [ ] **Step 6:** commit «Add the generated world atlas with places, distances and local time».

### Task 3: volo muto e rivelazione nella sessione multimediale

**Files:**
- Modify: `lib/features/radio/domain/radio_audio_service.dart`, `lib/features/radio/data/just_audio_service.dart`, `lib/features/radio/data/radio_media_session.dart`, `lib/features/radio/data/radio_audio_handler.dart`, `lib/app/bootstrap.dart`
- Test: `test/features/radio/just_audio_service_test.dart`, `test/features/radio/radio_audio_handler_test.dart`, i fake in `test/features/radio/radio_controller_test.dart`

**Interfaces:**
- Produces:
  - `RadioAudioService.playStation(station)`: avvia la stazione a volume 0 e mostra il segnaposto.
  - `RadioAudioService.land(RadioStation station) → Future<void>`: volume pieno, oppure 0.2 se è in corso un duck, e stazione nella sessione.
  - `RadioMediaSession.showFlight()`.
  - `RadioAudioHandler(player, {required String flightTitle, required String flightSubtitle})`.

- [ ] **Step 1: test che falliscono.**
  - `playStation` chiama `setVolume(0)` prima di `play` e `showFlight`, non `showStation`.
  - `land` chiama `setVolume(1)` e `showStation(station)`.
  - Un duck finito durante il volo lascia il volume a 0. Interruzioni simulate con un'`AudioSession` iniettabile, oppure esponendo `handleInterruption(AudioInterruptionEvent)` come `@visibleForTesting`: la scelta è del builder.
  - `showFlight` pubblica un `MediaItem` con `title: flightTitle`, `artist: flightSubtitle` e senza `artUri`.
- [ ] **Step 2:** eseguire i test. Expected: FAIL.
- [ ] **Step 3:** implementare con un flag `_muted`. Il duck, alla fine, ripristina `_muted ? 0 : 1`. `bootstrap` passa `flightTitle: config.appName` e `flightSubtitle` dalla nuova chiave `notificationFlying` («In volo…» / «In flight…»), risolta come il nome del canale. Aggiungere la chiave ai cataloghi e rigenerare con `tool/generate_l10n.sh`.
- [ ] **Step 4:** `flutter test --no-pub test/features/radio`. Expected: verde. I fake del controller implementano `land`.
- [ ] **Step 5:** commit «Keep the station silent and unnamed until landing».

### Task 4: flusso di volo unico nel controller

**Files:**
- Modify: `lib/features/radio/domain/radio_player_state.dart` (+ `.freezed.dart`), `lib/features/radio/application/radio_controller.dart`, `lib/features/radio/application/radio_providers.dart` (+ `.g.dart`)
- Test: `test/features/radio/radio_controller_test.dart`

**Interfaces:**
- Consumes: `placeOf`, `homePlace`, `TravelLeg` (Task 2); `land` (Task 3).
- Produces:
  - `enum FlightPhase { grounded, flying, signalLost }`
  - Nuovi campi di `RadioPlayerState`: `@Default(FlightPhase.grounded) FlightPhase flight`, `@Default(homePlace) StationPlace departure`, `TravelLeg? leg`, `@Default([]) List<TravelLeg> history` (al massimo 5, dalla più vecchia), `@Default(0) int trips`, `DateTime? flightStartedAt`.
  - `class FlightTiming { minimum = 1 s; attemptTimeout = 12 s; autoRetries = 2; signalLostPause = 900 ms }` dal provider generato `flightTimingProvider`.

Regole:
- In volo `status == tuning` e `station == null`: niente spoiler nello stato.
- Il fruscio parte all'inizio del primo tentativo e si ferma solo all'atterraggio, al fallimento finale o con `stop`. Tra un tentativo e l'altro non si ferma.
- Ogni tentativo:
  1. sceglie la stazione: API per Tune, quella data per il preferito;
  2. chiama `playStation`;
  3. aspetta `playing`, con `currentStatus` o lo stream; `error` fa fallire subito;
  4. aspetta anche il minimo;
  5. il tutto ha come limite `attemptTimeout`, dall'avvio del tentativo.
- Ogni await controlla il token.
- Atterraggio: `stopTuningSound`, poi `land`. Lo stato passa a `playing`, la stazione è impostata, `leg = TravelLeg(from: departure, to: placeOf(station))`, `departure = to ?? departure`, lo storico prende la nuova rotta (ultime 5), `trips + 1` e `flight = grounded`.
- Fallimento di un tentativo:
  - `audio.stop()`, poi `flight = signalLost` per `signalLostPause`.
  - Tune con tentativi rimasti: nuovo tentativo, con `flight = flying`.
  - Altrimenti: `stopTuningSound`, `status = error`, `flight` resta `signalLost` e `departure` non cambia.
- `stop()` durante il volo: annulla il token, ferma fruscio e player, `status = idle`, `flight = grounded`.

- [ ] **Step 1: test che falliscono.** `FlightTiming` nei test: minimum 50 ms, timeout 300 ms, pausa 10 ms. Il fake audio ha `playStation` che non emette `playing` finché il test non chiama `emitStatus`.
  - `lands only after the minimum even if playing arrives at once`: lo stato è ancora `tuning` a 20 ms e `playing` dopo 60 ms. `land` è chiamato una volta.
  - `waits for playback beyond the minimum`: a 100 ms senza `playing` è ancora `tuning`, con il fruscio attivo e `station == null`. Dopo `emitStatus(playing)` atterra.
  - `tuning sound stays on while the stream loads`: il fruscio è attivo dopo che `playStation` è stato chiamato.
  - `tune retries twice after timeouts then errors`: 3 chiamate a `getRandomStation`, `status == error`, `flight == signalLost`, fruscio spento, `land` mai chiamato, `departure == homePlace`.
  - `favorite does not retry`: `tuneTo` con timeout dà una sola `playStation` e `error`.
  - `stalled API ends the attempt at the timeout`: il repository non risponde mai, quindi con `autoRetries: 0` lo stato è `error` entro 400 ms.
  - `a newer tune cancels the flight`: il primo tentativo atterra in ritardo dopo un secondo `tuneTo`. Lo stato contiene la seconda stazione, `trips == 1` e `land` è chiamato una sola volta con la seconda.
  - `landing records the leg and moves the departure`: due atterraggi, con le coordinate di Tokyo e poi con il solo codice `FR`. Risultato: `history.length == 2`, `trips == 2`, `leg.from.point` alle coordinate di Tokyo e `departure` approssimata in Francia. Dopo 6 atterraggi `history.length == 5`.
  - `stop during flight grounds the radio`: `idle`, `grounded` e fruscio spento.
  - Adattare i test esistenti al nuovo timing: restano validi nel significato.
- [ ] **Step 2:** eseguire i test. Expected: FAIL.
- [ ] **Step 3:** implementare, rigenerare con `build_runner`, poi `flutter test --no-pub test/features/radio`. Expected: verde.
- [ ] **Step 4:** commit «Fly every tune until the station really plays».

### Task 5: mappa, testi del display, contatore e localizzazione

**Files:**
- Create: `lib/features/journey/presentation/route_map.dart` (`RouteMap` + painter)
- Modify: `lib/features/radio/presentation/radio_cabinet.dart`, `lib/features/radio/presentation/radio_page.dart`, `lib/ui/theme/travel_radio_design.dart` (`RouteMapDesign`), `assets/translations/{it,en}.json`, `lib/l10n/*.g.dart` rigenerati
- Test: `test/features/journey/route_map_test.dart`, `test/app_test.dart` o il test della home esistente per i layout

**Interfaces:**
- Consumes: lo stato del Task 4, `worldDotRows`, `TravelLeg.distance`, `localTimeOf`.
- Produces:
  - `RouteMap({required FlightPhase flight, required bool playing, required StationPlace departure, TravelLeg? leg, required List<TravelLeg> history, required int trips})`
  - nuovi parametri di `RadioCabinet`: `map` (`Widget?`), `localTime` (`String?`), `tripLabel` (`String?`).

Comportamento:
- **Volo:** impulsi radar concentrici dalla partenza, senza direzione.
- **Atterraggio:** quando `trips` aumenta, l'arco si traccia in 600 ms con `Curves.easeOutCubic`. L'arco è una quadratica nel piano equirettangolare, con il punto di controllo alzato verso nord di `0.25 ×` la lunghezza, quindi non attraversa mai il bordo. Il nome entra con `ImageFiltered` blur 6 → 0 sincronizzato.
- **In onda:** l'arrivo pulsa piano.
- **In pausa:** niente pulsazione.
- **Segnale perso:** solo il punto di partenza, nessuna scia.
- **Spenta (`trips == 0` e a terra):** solo i puntini.
- **Storico:** tratti tratteggiati con opacità 0.25.
- **Riduzione del movimento:** nessun controller in `repeat`, arco completo subito, nessun blur.
- La mappa è sempre dentro `ExcludeSemantics`.
- **Layout regolare:** la mappa sostituisce l'equalizzatore, con altezza `RouteMapDesign.height`. Il builder la sceglie per far stare 320×640 e 640×320 al 200%. **Compatto e orizzontale:** restano le barre.

Testi (chiavi nuove IT/EN):
- `flyingTo` «In volo verso» / «Flying to», seguito da puntini animati, statici con la riduzione del movimento.
- `nextStopPending` «Prossima fermata: …» / «Next stop: …», sopra la radio durante il volo.
- `signalLost` «Segnale perso» / «Signal lost».
- `departingFrom` «Da {}» / «From {}» nella riga del Paese durante il volo, con il Paese della partenza oppure «Italia»/«Italy».
- `distanceKm` «{} km», con il numero formattato da `NumberFormat.decimalPattern(locale)` e preceduto da «≈ » se approssimato.
- `localTime` «{} ora locale» / «{} local time», preceduto da «≈ » se approssimato.
- `tripNumber` «Viaggio n. {}» / «Trip no. {}», accanto a «F / RADIO» se `trips > 0`.
- `notificationFlying` (dal Task 3).
- Rimuovere `exploring` e `findingPlace`.
- Riga del Paese in onda: «Paese · ≈ 1.420 km», senza distanza quando `distance` è null.

- [ ] **Step 1: test che falliscono.**
  - `RouteMap` con `disableAnimations: true` in volo: dopo `pump` non ci sono frame pianificati (`tester.binding.hasScheduledFrame == false`).
  - Display in volo: compare «In volo verso» e non il nome né il Paese della stazione. Il fake fa partire il volo con una stazione nota.
  - Display in onda: compare «France · ≈ 640 km», o il valore corrispondente, e un testo che finisce con «ora locale».
  - Stazione senza coordinate e senza codice: in onda compaiono il nome e nessun errore, con `RouteMap` senza arco.
  - Layout: 320×640 e 640×320 con `TextScaler.linear(2)`, in volo e in onda: nessuna eccezione di overflow.
- [ ] **Step 2:** eseguire i test. Expected: FAIL.
- [ ] **Step 3:** implementare, rigenerare la l10n e formattare.
- [ ] **Step 4:** eseguire `bash tool/check.sh` (senza `--apk`) con 3.38.5. Expected: analisi pulita e suite verde.
- [ ] **Step 5:** commit «Draw the route map and travel details on the display».

### Chiusura

- `docs/status.md`: una sezione breve con risultati verificati, limiti noti (iOS senza fruscio, il rischio noto qui sopra, fusi non classificati) e prossimo passo: push di entrambi i branch, collaudo su telefono, poi aggiornamento di Flutter.
- Il collaudo di Davide su telefono, insieme alla checklist del passo 1:
  - volo da manopola e da Preferiti;
  - nessun audio prima dell'atterraggio;
  - notifica «In volo…» poi la stazione;
  - segnale perso in modalità aereo;
  - riduzione del movimento attiva.
