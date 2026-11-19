import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:frequenza/features/songs/domain/saved_song.dart';
import 'package:frequenza/l10n/locale_keys.g.dart';
import 'package:frequenza/ui/widgets/travel_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/favorites/favorites_test.dart' show MemoryFavorites;
import '../features/radio/radio_controller_test.dart';
import '../features/songs/saved_songs_test.dart' show MemorySongs;

class UnavailableSongs extends MemorySongs {
  bool failLoad = true;

  @override
  Future<List<SavedSong>> load() async {
    if (failLoad) throw StateError('Storage unavailable');
    return super.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final songsTab in [false, true]) {
    testWidgets(
      '${songsTab ? 'songs' : 'stations'} recover from a read error through the shared retry, then show the empty panel',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        tester.view.physicalSize = const Size(390, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({'app.welcomeRevision': 2});
        await EasyLocalization.ensureInitialized();
        final favorites = MemoryFavorites()..failLoad = !songsTab;
        final songs = UnavailableSongs();
        final audio = FakeAudioService();
        addTearDown(audio.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
              radioAudioServiceProvider.overrideWithValue(audio),
              favoritesRepositoryProvider.overrideWithValue(favorites),
              songsRepositoryProvider.overrideWithValue(songs),
            ],
            child: const StarterApp(locale: Locale('it')),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('favorites-open')));
        await tester.pumpAndSettle();
        if (songsTab) {
          await tester.tap(find.text(LocaleKeys.tabSongs.tr()));
          await tester.pumpAndSettle();
        }
        final error = songsTab
            ? LocaleKeys.songsError
            : LocaleKeys.favoritesError;
        final empty = songsTab
            ? LocaleKeys.songsEmpty
            : LocaleKeys.favoritesEmpty;
        final errorInSheet = find.descendant(
          of: find.byType(TravelSheet),
          matching: find.text(error.tr()),
        );
        expect(errorInSheet, findsOneWidget);
        final retry = find.text(LocaleKeys.retry.tr());
        await tester.dragUntilVisible(
          retry,
          find.byType(Scrollable).last,
          const Offset(0, -150),
        );
        await tester.pumpAndSettle();
        favorites.failLoad = false;
        songs.failLoad = false;
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(errorInSheet, findsNothing);
        expect(retry, findsNothing);
        expect(find.text(empty.tr()), findsOneWidget);
        expect(tester.takeException(), isNull);
        // The shared sheet remains usable after the recovery, at large text.
        final close = find.byTooltip(LocaleKeys.close.tr());
        await tester.dragUntilVisible(
          close,
          find.byType(Scrollable).last,
          const Offset(0, 150),
        );
        await tester.pumpAndSettle();
        await tester.tap(close);
        await tester.pumpAndSettle();
        expect(find.text(empty.tr()), findsNothing);
      },
    );
  }
}
