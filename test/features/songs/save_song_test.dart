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
import 'saved_songs_test.dart' show MemorySongs, HeldSongs;

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
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byTooltip('Togli'), findsOneWidget);
    expect(bookmark, findsNothing);
    expect(bookmarked, findsOneWidget);
  });

  testWidgets('tapping the title saves it too', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ana Moura — Desfado'));
    await tester.pumpAndSettle();

    expect(savedSongs(tester).single.title, 'Desfado');
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a saved song is not saved twice', (tester) async {
    androidVersion(tester, 32);
    final (audio, _) = await onAir(tester);
    audio.trackTitles.add('Ana Moura - Desfado');
    await tester.pumpAndSettle();
    await tester.tap(bookmark);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ana Moura — Desfado'));
    await tester.pumpAndSettle();

    expect(savedSongs(tester), hasLength(1));
  });

  for (final accessible in [false, true]) {
    testWidgets(
      'the saved bookmark removes the song without confirmation, accessible navigation $accessible',
      (tester) async {
        androidVersion(tester, 32);
        final (audio, _) = await onAir(tester);
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(
              disableAnimations: true,
              accessibleNavigation: accessible,
            );
        audio.trackTitles.add('Ana Moura - Desfado');
        await tester.pumpAndSettle();
        await tester.tap(bookmark);
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
        await tester.pump(const Duration(seconds: 10));
        await tester.tap(bookmarked);
        await tester.pumpAndSettle();
        expect(savedSongs(tester), isEmpty);
        expect(bookmark, findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byTooltip('Salva canzone'), findsOneWidget);
      },
    );
  }

  for (final initiallySaved in [false, true]) {
    testWidgets(
      'failed toggle preserves membership and supports retry, initially saved $initiallySaved',
      (tester) async {
        androidVersion(tester, 32);
        final repository = MemorySongs();
        final (audio, _) = await onAir(tester, songsRepository: repository);
        audio.trackTitles.add('Ana Moura - Desfado');
        await tester.pumpAndSettle();
        if (initiallySaved) {
          await tester.tap(bookmark);
          await tester.pumpAndSettle();
        }
        repository.failSave = true;
        final button = initiallySaved ? bookmarked : bookmark;
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(button.hitTestable(), findsOneWidget);
        expect(repository.items.length, initiallySaved ? 1 : 0);
        expect(
          find.text('Non è stato possibile aggiornare le canzoni. Riprova.'),
          findsOneWidget,
        );
        repository.failSave = false;
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(repository.items.length, initiallySaved ? 0 : 1);
      },
    );
  }

  testWidgets(
    'a pending write disables the bookmark and keeps the captured song through a title change',
    (tester) async {
      androidVersion(tester, 32);
      final repository = HeldSongs();
      final (audio, _) = await onAir(tester, songsRepository: repository);
      audio.trackTitles.add('First song');
      await tester.pumpAndSettle();
      await tester.tap(bookmark);
      await tester.pump();
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(of: bookmark, matching: find.byType(IconButton)),
            )
            .onPressed,
        isNull,
      );
      audio.trackTitles.add('Second song');
      await tester.pumpAndSettle();
      repository.release.complete();
      await tester.pumpAndSettle();
      expect(repository.items.single.title, 'First song');
      expect(bookmark.hitTestable(), findsOneWidget);
      await tester.tap(bookmark);
      await tester.pumpAndSettle();
      await tester.tap(bookmarked);
      await tester.pumpAndSettle();
      expect(repository.items.single.title, 'First song');
    },
  );

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
