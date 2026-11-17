import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/radio/domain/track_title.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:frequenza/features/songs/data/preferences_songs_repository.dart';
import 'package:frequenza/features/songs/domain/saved_song.dart';
import 'package:frequenza/features/songs/domain/songs_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kexp = RadioStation(
  id: 'kexp',
  name: 'KEXP',
  streamUrl: 'https://kexp.example.com/live',
  country: 'The United States Of America',
  countryCode: 'US',
  region: 'Washington',
  latitude: 47.6,
  longitude: -122.3,
);

const fip = RadioStation(
  id: 'fip',
  name: 'FIP',
  streamUrl: 'https://fip.example.com/live',
  country: 'France',
  countryCode: 'FR',
);

class MemorySongs implements SongsRepository {
  List<SavedSong> items = [];

  @override
  Future<List<SavedSong>> load() async => List.of(items);

  @override
  Future<void> save(List<SavedSong> songs) async => items = List.of(songs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer container(MemorySongs songs) {
    final container = ProviderContainer(
      overrides: [songsRepositoryProvider.overrideWithValue(songs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  TrackTitle track(String raw) => TrackTitle.parse(raw)!;

  test('saving twice the same song keeps one', () async {
    final songs = MemorySongs();
    final c = container(songs);
    final notifier = c.read(savedSongsProvider.notifier);
    await c.read(savedSongsProvider.future);

    expect(await notifier.save(track('Ana Moura - Desfado'), kexp), isTrue);
    expect(await notifier.save(track('ana  moura - DESFADO '), kexp), isFalse);

    expect(songs.items, hasLength(1));
    expect(notifier.contains(track('Ana Moura - desfado'), kexp), isTrue);
  });

  test('the same song on another station is another entry', () async {
    final songs = MemorySongs();
    final c = container(songs);
    final notifier = c.read(savedSongsProvider.notifier);
    await c.read(savedSongsProvider.future);

    await notifier.save(track('Desfado'), kexp);
    expect(await notifier.save(track('Desfado'), fip), isTrue);

    expect(songs.items, hasLength(2));
    expect(notifier.contains(track('Desfado'), fip), isTrue);
  });

  test('saved songs survive reopening the repository', () async {
    SharedPreferences.setMockInitialValues({});
    final savedAt = DateTime.utc(2026, 11, 16, 21, 30);
    await PreferencesSongsRepository().save([
      SavedSong(
        artist: 'Ana Moura',
        title: 'Desfado',
        station: kexp,
        savedAt: savedAt,
      ),
    ]);

    final song = (await PreferencesSongsRepository().load()).single;

    expect(song.artist, 'Ana Moura');
    expect(song.title, 'Desfado');
    expect(song.savedAt, savedAt);
    expect(song.station.id, 'kexp');
    expect(song.station.name, 'KEXP');
    expect(song.station.streamUrl, 'https://kexp.example.com/live');
    expect(song.station.country, 'The United States Of America');
    expect(song.station.countryCode, 'US');
    expect(song.station.region, 'Washington');
    expect(song.station.point?.latitude, 47.6);
  });

  test('a broken entry is skipped, the others load', () async {
    SharedPreferences.setMockInitialValues({
      'frequenza.songs.v1': '''[
        {"artist":"A","at":"2026-11-16T20:00:00.000Z",
         "station":{"id":"fip","name":"FIP","url":"https://fip.example.com/live"}},
        {"title":"Http","at":"2026-11-16T20:00:00.000Z",
         "station":{"id":"x","name":"X","url":"http://x.example.com/live"}},
        {"title":"No date",
         "station":{"id":"fip","name":"FIP","url":"https://fip.example.com/live"}},
        42,
        {"title":"Good","artist":7,"at":"2026-11-16T20:00:00.000Z",
         "station":{"id":"fip","name":"FIP","url":"https://fip.example.com/live"}}
      ]''',
    });

    final songs = await PreferencesSongsRepository().load();

    expect(songs.single.title, 'Good');
    expect(songs.single.artist, isNull);
    expect(songs.single.station.countryCode, '');
  });

  test('data from another shape fails the load, never wipes it', () async {
    // Like the favorites: an unreadable list is an error to show, not an
    // empty list that the next save would write over.
    SharedPreferences.setMockInitialValues({'frequenza.songs.v1': '{"v":2}'});
    await expectLater(
      PreferencesSongsRepository().load(),
      throwsFormatException,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('frequenza.songs.v1'), '{"v":2}');
  });

  test('restore puts the song back where it was', () async {
    final songs = MemorySongs();
    final c = container(songs);
    final notifier = c.read(savedSongsProvider.notifier);
    await c.read(savedSongsProvider.future);
    for (final title in ['A', 'B', 'C']) {
      await notifier.save(track(title), kexp);
    }
    final [a, b, cSong] = c.read(savedSongsProvider).requireValue;

    await notifier.remove(b);
    await notifier.remove(cSong);
    await notifier.restore(b, 1);

    expect(c.read(savedSongsProvider).requireValue, [a, b]);
    expect(songs.items, [a, b]);
  });

  test('restore past the end puts the song last', () async {
    final songs = MemorySongs();
    final c = container(songs);
    final notifier = c.read(savedSongsProvider.notifier);
    await c.read(savedSongsProvider.future);
    await notifier.save(track('A'), kexp);
    await notifier.save(track('B'), kexp);
    final [a, b] = c.read(savedSongsProvider).requireValue;

    await notifier.remove(a);
    await notifier.remove(b);
    await notifier.restore(b, 1);

    expect(c.read(savedSongsProvider).requireValue, [b]);
  });
}
