import 'dart:async';
import 'dart:convert';

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
  bool failSave = false;

  @override
  Future<List<SavedSong>> load() async => List.of(items);

  @override
  Future<void> save(List<SavedSong> songs) async {
    if (failSave) throw StateError('Storage unavailable');
    items = List.of(songs);
  }
}

class HeldSongs extends MemorySongs {
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  Future<void> save(List<SavedSong> songs) async {
    if (!started.isCompleted) {
      started.complete();
      await release.future;
    }
    await super.save(songs);
  }
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

  test('concurrent saves retain both songs', () async {
    final repository = MemorySongs();
    final c = container(repository);
    await c.read(savedSongsProvider.future);
    final controller = c.read(savedSongsProvider.notifier);
    await Future.wait([
      controller.save(track('First song'), kexp),
      controller.save(track('Second song'), kexp),
    ]);
    expect(repository.items.map((s) => s.title), ['First song', 'Second song']);
  });

  test('concurrent duplicate saves retain one song', () async {
    final repository = MemorySongs();
    final c = container(repository);
    await c.read(savedSongsProvider.future);
    final controller = c.read(savedSongsProvider.notifier);
    final results = await Future.wait([
      controller.save(track('Same song'), kexp),
      controller.save(track('Same song'), kexp),
    ]);
    expect(results, [true, false]);
    expect(repository.items, hasLength(1));
  });

  test('a queued save does not undo a preceding removal', () async {
    final repository = MemorySongs();
    final c = container(repository);
    await c.read(savedSongsProvider.future);
    final controller = c.read(savedSongsProvider.notifier);
    await controller.save(track('Old song'), kexp);
    final old = repository.items.single;
    await Future.wait([
      controller.remove(old),
      controller.save(track('New song'), kexp),
    ]);
    expect(repository.items.map((s) => s.title), ['New song']);
  });

  test(
    'reloading during a write waits for persistence before the next save',
    () async {
      final repository = HeldSongs();
      final c = container(repository);
      await c.read(savedSongsProvider.future);
      final pending = c
          .read(savedSongsProvider.notifier)
          .save(track('First'), kexp);
      await repository.started.future;
      c.invalidate(savedSongsProvider);
      final reloaded = c.read(savedSongsProvider.future);
      repository.release.complete();
      await pending;
      expect((await reloaded).map((s) => s.title), ['First']);
      await c.read(savedSongsProvider.notifier).save(track('Second'), kexp);
      expect(repository.items.map((s) => s.title), ['First', 'Second']);
    },
  );

  test('a failed write does not block subsequent saves', () async {
    final repository = MemorySongs()..failSave = true;
    final c = container(repository);
    await c.read(savedSongsProvider.future);
    final controller = c.read(savedSongsProvider.notifier);
    expect(await controller.save(track('Failed'), kexp), isFalse);
    repository.failSave = false;
    expect(await controller.save(track('Recovered'), kexp), isTrue);
    expect(repository.items.map((s) => s.title), ['Recovered']);
  });

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

  test('songs are stored with the keys of the first version', () async {
    // Phones already keep songs in this shape: the keys never change.
    SharedPreferences.setMockInitialValues({});
    await PreferencesSongsRepository().save([
      SavedSong(
        artist: 'Ana Moura',
        title: 'Desfado',
        station: kexp,
        savedAt: DateTime.utc(2026, 11, 16, 21, 30),
      ),
      SavedSong(
        title: 'Only a title',
        station: fip,
        savedAt: DateTime.utc(2026, 11, 17, 8),
      ),
    ]);

    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('frequenza.songs.v1')!), [
      {
        'artist': 'Ana Moura',
        'title': 'Desfado',
        'at': '2026-11-16T21:30:00.000Z',
        'station': {
          'id': 'kexp',
          'name': 'KEXP',
          'url': 'https://kexp.example.com/live',
          'country': 'The United States Of America',
          'code': 'US',
          'tags': <String>[],
          'region': 'Washington',
          'lat': 47.6,
          'lon': -122.3,
        },
      },
      {
        'title': 'Only a title',
        'at': '2026-11-17T08:00:00.000Z',
        'station': {
          'id': 'fip',
          'name': 'FIP',
          'url': 'https://fip.example.com/live',
          'country': 'France',
          'code': 'FR',
          'tags': <String>[],
        },
      },
    ]);
  });

  test('a song saved at local time is stored in UTC', () async {
    SharedPreferences.setMockInitialValues({});
    final local = DateTime(2026, 11, 16, 21, 30);
    await PreferencesSongsRepository().save([
      SavedSong(title: 'Desfado', station: fip, savedAt: local),
    ]);

    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('frequenza.songs.v1')!) as List;
    expect(stored.single['at'], local.toUtc().toIso8601String());
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
        {"title":"   ","at":"2026-11-16T20:00:00.000Z",
         "station":{"id":"fip","name":"FIP","url":"https://fip.example.com/live"}},
        {"title":"Bad date","at":"not a date",
         "station":{"id":"fip","name":"FIP","url":"https://fip.example.com/live"}},
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
  test('saved song titles cannot bypass metadata bounds on reload', () {
    final snapshot = SavedSong(
      title: 'Valid',
      station: kexp,
      savedAt: DateTime.utc(2026),
    ).toJson();
    expect(
      () => SavedSong.fromJson({...snapshot, 'title': 'x' * 4097}),
      throwsFormatException,
    );
    expect(
      () => SavedSong.fromJson({...snapshot, 'title': '  '}),
      throwsFormatException,
    );
  });
}
