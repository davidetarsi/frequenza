import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/domain/track_title.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../favorites/favorites_test.dart' show MemoryFavorites;
import '../songs/saved_songs_test.dart' show MemorySongs, kexp;
import '../welcome/welcome_seen_test.dart' show BrokenStore;
import 'recording_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingAnalytics analytics;
  late MemoryFavorites favorites;
  late MemorySongs songs;

  ProviderContainer open() {
    analytics = RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        favoritesRepositoryProvider.overrideWithValue(favorites),
        songsRepositoryProvider.overrideWithValue(songs),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    favorites = MemoryFavorites();
    songs = MemorySongs();
  });

  final desfado = TrackTitle.parse('Ana Moura - Desfado')!;

  test('toggle records added, then removed', () async {
    final c = open();
    await c.read(favoritesProvider.future);
    await c.read(favoritesProvider.notifier).toggle(kexp);
    await c.read(favoritesProvider.notifier).toggle(kexp);
    expect(analytics.events, [
      AppEvent.favoriteAdded(kexp),
      AppEvent.favoriteRemoved(kexp),
    ]);
  });

  test('a failed favorite save records nothing', () async {
    favorites.failSave = true;
    final c = open();
    await c.read(favoritesProvider.future);
    await c.read(favoritesProvider.notifier).toggle(kexp);
    expect(analytics.events, isEmpty);
  });

  test('a saved song records song_saved once', () async {
    final c = open();
    await c.read(savedSongsProvider.future);
    final notifier = c.read(savedSongsProvider.notifier);
    await notifier.save(desfado, kexp);
    await notifier.save(desfado, kexp);
    expect(analytics.events, [AppEvent.songSaved(kexp)]);
  });

  test('a failed song save records nothing', () async {
    songs.failSave = true;
    final c = open();
    await c.read(savedSongsProvider.future);
    await c.read(savedSongsProvider.notifier).save(desfado, kexp);
    expect(analytics.events, isEmpty);
  });

  test('removing records song_removed; undo records nothing more', () async {
    final c = open();
    await c.read(savedSongsProvider.future);
    final notifier = c.read(savedSongsProvider.notifier);
    await notifier.save(desfado, kexp);
    final song = c.read(savedSongsProvider).requireValue.single;
    await notifier.remove(song);
    await notifier.restore(song, 0);
    expect(analytics.names, ['song_saved', 'song_removed']);
    expect(analytics.events.last, AppEvent.songRemoved(kexp));
  });

  test('the welcome counts once it is seen, saved or not', () async {
    var c = open();
    await c.read(welcomeSeenProvider.future);
    await c.read(welcomeSeenProvider.notifier).markSeen();
    expect(analytics.events, [const AppEvent.welcomeCompleted()]);

    final previous = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = BrokenStore();
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    c = open();
    await c.read(welcomeSeenProvider.future);
    await c.read(welcomeSeenProvider.notifier).markSeen();
    expect(analytics.events, [const AppEvent.welcomeCompleted()]);
  });
}
