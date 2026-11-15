# Ritocchi dell'interfaccia Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pausa e Salva come tasti a leva dentro la radio, cuore con contatore in alto, impostazioni nel foglio dei Preferiti, radio più stretta, «ORA LOCALE» sopra l'orario, pressione lunga per copiare il titolo della canzone.

**Architecture:** La cornice del foglio dei Preferiti diventa un widget comune in `lib/ui/widgets/travel_sheet.dart`, usato anche dalle impostazioni (la rotta `/settings` sparisce). `RadioCabinet` riceve i due tasti e la callback di copia; `RadioPage` smette di disegnare i bottoni sotto la radio. La versione di Android per la conferma della copia arriva da un nuovo metodo sul canale nativo esistente.

**Tech Stack:** Flutter 3.38.5, Riverpod, easy_localization, Kotlin (`MainActivity`).

**Spec:** `docs/superpowers/specs/2026-11-14-ritocchi-ui-design.md` · mockup https://claude.ai/artifact/96zvDHwYk1p5hMXG3Kn9jU

## Global Constraints

- Stile da `TravelRadioPalette`, misure in `RadioCabinetDesign` / `TravelRadioLayout` / `RadioFavoritesDesign`: nessun numero magico nei widget.
- Tema chiaro e scuro; disposizioni normale, compatta e orizzontale; testo fino a 200%.
- Nessuna nuova dipendenza Dart.
- Tasti premibili almeno 44 punti; ogni tasto con nome e stato per TalkBack.
- Testi nuovi in `assets/translations/it.json` e `en.json`, poi `bash tool/generate_l10n.sh`.
- `bash tool/check.sh` verde alla fine di ogni task.

## Review Focus

1. Schermo 320×640 con testo al 200%: i due tasti dentro la radio restano visibili e premibili, nessun overflow (task 3, test esistente aggiornato).
2. Orizzontale 640×320: i tasti stanno dentro la radio, accanto alla manopola (task 3).
3. Nessuna stazione o sintonia in corso: i tasti sono disabilitati e non fanno niente (task 3).
4. Titolo mancante (sotto il nome si vedono le etichette): la pressione lunga non copia nulla (task 5).
5. Android 13+: nessun messaggio dell'app dopo la copia; sotto 13 o canale assente: «Titolo copiato» (task 5).

---

### Task 1: Foglio comune e impostazioni nel foglio

**Files:**
- Create: `lib/ui/widgets/travel_sheet.dart`
- Create: `lib/app/presentation/app_settings_sheet.dart` (sostituisce `app_settings_page.dart`, da cancellare)
- Modify: `lib/features/favorites/presentation/favorites_sheet.dart`, `lib/app/routing/app_router.dart`, traduzioni
- Test: `test/app_test.dart`

**Interfaces:**
- Produces: `Future<void> showTravelSheet(BuildContext context, {required WidgetBuilder builder})` (la `showModalBottomSheet` di oggi dei Preferiti); `TravelSheet({required String title, required String subtitle, required List<Widget> children, Key? key})`: `DraggableScrollableSheet` con maniglia, titolo, sottotitolo, tasto chiudi (tooltip `close`) e `children` nella lista; `Future<void> showSettings(BuildContext context)`.
- Nuova chiave: `settingsSubtitle` = «Aspetto e lingua della radio.» / «Look and language of the radio.»

- [ ] **Step 1:** In `test/app_test.dart`, nel primo test, sostituisci `tester.pageBack()` con `await tester.tap(find.byTooltip('Close'))` e aggiungi dopo l'apertura `expect(find.text('Aspetto e lingua della radio.'), findsOneWidget)` e `expect(find.byType(DraggableScrollableSheet), findsOneWidget)`.
- [ ] **Step 2:** `flutter test test/app_test.dart` → FAIL (il sottotitolo non esiste).
- [ ] **Step 3:** Estrai la cornice da `FavoritesSheet` in `TravelSheet`; `FavoritesSheet` la usa con le sue righe. `AppSettingsSheet` usa `TravelSheet` con i titoli di sezione e gli `AppSettingsOption` di oggi. Il tasto impostazioni chiama `showSettings`; rimuovi `AppRoutes.settings` e la sua rotta.
- [ ] **Step 4:** `flutter test test/app_test.dart` → PASS.
- [ ] **Step 5:** commit `feat(ui): impostazioni nel foglio dei Preferiti`.

### Task 2: Cuore con contatore in alto

**Files:** Modify `lib/features/radio/presentation/radio_page.dart`; Test `test/app_test.dart`

- [ ] **Step 1:** Test `favorites button is a heart with the count in the primary colour`: con un preferito salvato, `find.byKey(ValueKey('favorites-open'))` contiene un `Badge` con testo `1` e `backgroundColor == colorScheme.primary`; `find.text('Preferiti · 1')` → findsNothing (resta solo come tooltip).
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Il bottone è sempre `AppIconButton` outlined (via il ramo `AppButton`), icona con `foregroundColor: colorScheme.primary`; `Badge.count` con `backgroundColor: primary`, `textColor: onPrimary`, nascosto a zero; tooltip invariato.
- [ ] **Step 4:** Run → PASS. **Step 5:** commit `feat(ui): solo il cuore per i Preferiti`.

### Task 3: Tasti a leva dentro la radio, radio più stretta

**Files:**
- Create: `lib/features/radio/presentation/radio_keys.dart`
- Modify: `radio_cabinet.dart`, `radio_page.dart`, `lib/ui/theme/travel_radio_design.dart`
- Test: `test/app_test.dart`, `test/features/radio/radio_journey_page_test.dart`

**Interfaces:**
- Produces: `RadioKey({required Key key, required IconData icon, required String label, required bool down, required VoidCallback? onPressed, Color? iconColor})`: tasto con `Tooltip(label)` e `Semantics(button, toggled: down, enabled)`; `RadioKeys({required RadioKey play, required RadioKey save})`: l'incavo con i due tasti. `RadioCabinet` riceve `Widget? keys`, messo al posto della riga viti-filo (normale), sotto i controlli (compatta), sotto i controlli nella colonna di destra (orizzontale).
- Chiavi: `ValueKey('radio-key-play')`, `ValueKey('radio-key-save')`. Etichette: `pause` quando suona, `resume` in pausa (giù); `save`, `saved` (giù, cuore pieno `TravelRadioPalette.accent`).
- Valori: `TravelRadioLayout.cabinetWidth` 320; `RouteMapDesign.height` 84; tasto alto 46 (compatto 44), incavo con raggio 12 e padding 6, abbassato = spostato di 3 punti con ombra interna.

- [ ] **Step 1:** Aggiorna i test: `find.text('Salva'|'Salvata'|'Pausa'|'Riprendi')` → `find.byTooltip(...)`; nel test 320×640 e nella prova 640×320 i tasti sono `hitTestable` e il loro rettangolo sta dentro quello di `RadioCabinet`; nuovo test `keys are disabled before the first station`: tap su `radio-key-save` senza stazione → nessun preferito, `Semantics` `isEnabled == false`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implementa `RadioKey`/`RadioKeys`, passa i tasti da `RadioPage` (stesse callback e condizioni di abilitazione dei bottoni di oggi), togli la riga dei bottoni sotto la radio e quelli della colonna orizzontale.
- [ ] **Step 4:** `flutter test` → PASS, compresi i test di overflow esistenti.
- [ ] **Step 5:** commit `feat(radio): Pausa e Salva come tasti dentro la radio`.

### Task 4: «ORA LOCALE» sopra l'orario

**Files:** Modify `lib/features/journey/presentation/journey_texts.dart` (`LocalTimeText`), `radio_cabinet.dart` (altezza riga di stato), traduzioni; Test `test/features/radio/radio_journey_page_test.dart`

- [ ] **Step 1:** Test: dopo l'atterraggio `find.text('ORA LOCALE')` → findsOneWidget e `find.byIcon(Icons.schedule)` → findsNothing (aggiorna anche l'attesa di `Icons.schedule` in `app_test.dart`). L'etichetta semantica `localTime` resta.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** `LocalTimeText` diventa una colonna allineata a destra: etichetta `localTimeLabel` («ora locale» / «local time», mostrata maiuscola, 9 punti, spaziatura 1.5, opacità .75) sopra l'orario. Aumenta `statusHeightFactor` quanto basta.
- [ ] **Step 4:** Run → PASS, overflow compresi. **Step 5:** commit `feat(journey): ora locale scritta sopra l'orario`.

### Task 5: Pressione lunga per copiare il titolo

**Files:**
- Create: `lib/features/radio/presentation/copy_track_title.dart`
- Modify: `radio_cabinet.dart` (`VoidCallback? onDetailLongPress` sul testo di dettaglio), `radio_page.dart`, `MainActivity.kt`, traduzioni
- Test: `test/features/radio/copy_track_title_test.dart`, `test/app_test.dart`

**Interfaces:**
- Produces: `Future<void> copyTrackTitle(BuildContext context, String title)`: `Clipboard.setData`, `HapticFeedback.lightImpact`, poi SnackBar `titleCopied` («Titolo copiato» / «Title copied») solo se `await systemConfirmsCopy()` è falso. `Future<bool> systemConfirmsCopy()`: vero se Android e `MethodChannel('frequenza/tuning_sound').invokeMethod<int>('sdkInt') >= 33`; falso su errore o canale assente.
- `MainActivity`: metodo `"sdkInt"` → `result.success(Build.VERSION.SDK_INT)`.

- [ ] **Step 1:** Test: con un titolo in onda, long press sul testo `Artista — Titolo` → `Clipboard` (mock di `SystemChannels.platform`) riceve `Artista — Titolo` e compare `Titolo copiato`; con `sdkInt` simulato a 33 il testo copiato c'è ma lo SnackBar no; prima del titolo (etichette mostrate) il long press non scrive negli appunti.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implementa; `RadioPage` passa `onDetailLongPress` solo quando il dettaglio mostrato è `player.trackTitle`.
- [ ] **Step 4:** Run → PASS; `flutter build apk --flavor dev --debug` compila il Kotlin.
- [ ] **Step 5:** commit `feat(radio): tieni premuto il titolo per copiarlo`.

### Task 6: Chiusura

- [ ] `bash tool/check.sh` verde; `docs/status.md`: sezione «Ritocchi interfaccia — 14 novembre 2026» con risultati e prossimo passo (collaudo su telefono, poi la ricerca per paese o nome); commit `docs: stato dei ritocchi dell'interfaccia`; push del branch.
