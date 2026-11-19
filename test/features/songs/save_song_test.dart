import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/presentation/radio_page.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:frequenza/features/songs/domain/saved_song.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../favorites/favorites_test.dart' show station;
import '../radio/copy_track_title_test.dart';

List<SavedSong> savedSongs(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(RadioPage)),
).read(savedSongsProvider).requireValue;

final bookmark = find.byIcon(Icons.bookmark_add_outlined);
final bookmarked = find.byIcon(Icons.bookmark_added);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('the bookmark saves the song on air', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();

    await tester.tap(bookmark);
    await tester.pumpAndSettle();

    final song = savedSongs(tester).single;
    expect(song.artist, 'Ana Moura');
    expect(song.title, 'Desfado');
    expect(song.station.id, station.id);
    expect(find.text('Canzone salvata'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Annulla'), findsOneWidget);
    expect(bookmark, findsNothing);
    expect(bookmarked, findsOneWidget);
  });

  testWidgets(
    'saving feedback expires after four seconds without removing the song',
    (tester) async {
      androidVersion(tester, 32);
      final (audio, _) = await onAir(tester);
      audio.trackTitles.add('Ana Moura - Desfado');
      await tester.pumpAndSettle();
      await tester.tap(bookmark);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Canzone salvata'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Canzone salvata'), findsNothing);
      expect(savedSongs(tester).single.title, 'Desfado');
      expect(bookmarked, findsOneWidget);
    },
  );

  testWidgets('accessible navigation keeps undo available beyond the timeout', (
    tester,
  ) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          accessibleNavigation: true,
        );
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();
    await tester.tap(bookmark);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Canzone salvata'), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Annulla'));
    await tester.pumpAndSettle();
    expect(savedSongs(tester), isEmpty);
  });

  testWidgets('tapping the title saves it too', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ana Moura — Desfado'));
    await tester.pumpAndSettle();

    expect(savedSongs(tester).single.title, 'Desfado');
    expect(find.text('Canzone salvata'), findsOneWidget);
  });

  testWidgets('a saved song is not saved twice', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();
    await tester.tap(bookmark);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ana Moura — Desfado'));
    await tester.tap(bookmarked);
    await tester.pumpAndSettle();

    expect(savedSongs(tester), hasLength(1));
  });

  testWidgets('undo removes it', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();
    await tester.tap(bookmark);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SnackBarAction, 'Annulla'));
    await tester.pumpAndSettle();

    expect(savedSongs(tester), isEmpty);
    expect(bookmark, findsOneWidget);
  });

  testWidgets('a long press still copies, and does not save', (tester) async {
    androidVersion(tester, 32);
    final (audio, copied) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Ana Moura — Desfado'));
    await tester.pumpAndSettle();

    expect(copied, ['Ana Moura — Desfado']);
    expect(savedSongs(tester), isEmpty);
  });

  testWidgets('no title, no bookmark', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    expect(bookmark, findsNothing);
    audio.trackTitles.add('Advertisement');
    await tester.pumpAndSettle();
    expect(bookmark, findsNothing);
  });

  testWidgets('saves the title shown when tapped', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();

    await tester.tap(bookmark);
    audio.trackTitles.add('Mariza - Ó Gente da Minha Terra');
    await tester.pumpAndSettle();

    expect(savedSongs(tester).single.title, 'Desfado');
  });
}
