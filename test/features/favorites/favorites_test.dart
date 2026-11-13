import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/favorites/data/preferences_favorites_repository.dart';
import 'package:frequenza/features/favorites/domain/favorites_repository.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:shared_preferences/shared_preferences.dart';

const station = RadioStation(
  id: 'id',
  name: 'Radio',
  streamUrl: 'https://example.com/live',
  country: 'Italia',
  countryCode: 'IT',
);

class MemoryFavorites implements FavoritesRepository {
  List<RadioStation> items = [];
  bool failSave = false;
  Completer<void>? pendingSave;
  bool failLoad = false;
  @override
  Future<List<RadioStation>> load() async {
    if (failLoad) throw StateError('Unavailable');
    return List.of(items);
  }

  @override
  Future<void> save(List<RadioStation> stations) async {
    await pendingSave?.future;
    if (failSave) throw StateError('Storage unavailable');
    items = List.of(stations);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('saved stations survive reopening the preferences adapter', () async {
    SharedPreferences.setMockInitialValues({});
    final first = PreferencesFavoritesRepository();
    await first.save([station]);
    final loaded = await PreferencesFavoritesRepository().load();
    expect(loaded.single.id, 'id');
    expect(loaded.single.streamUrl, 'https://example.com/live');
  });
  test('reads v1 favorites and preserves the persisted keys', () async {
    SharedPreferences.setMockInitialValues({
      'frequenza.favorites.v1':
          '[{"id":"id","name":"Radio","url":"https://example.com/live","code":"IT","tags":["rock",42]}]',
    });
    final repository = PreferencesFavoritesRepository();
    final saved = await repository.load();
    expect(saved.single.countryCode, 'IT');
    expect(saved.single.tags, ['rock']);
    await repository.save(saved);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('frequenza.favorites.v1'),
      '[{"id":"id","name":"Radio","url":"https://example.com/live","country":"","code":"IT","tags":["rock"]}]',
    );
  });

  test('favorites keep valid coordinates and ignore malformed ones', () async {
    SharedPreferences.setMockInitialValues({
      'frequenza.favorites.v1':
          '[{"id":"bad","name":"Bad","url":"https://example.com/bad","code":"FR","lat":"x","lon":2.3}]',
    });
    final repository = PreferencesFavoritesRepository();
    expect((await repository.load()).single.point, isNull);

    await repository.save([station.copyWith(latitude: 45.46, longitude: 9.19)]);
    final loaded = (await repository.load()).single;
    expect(loaded.point?.latitude, 45.46);
    expect(loaded.point?.longitude, 9.19);
  });

  test(
    'toggle removes by identity and failure preserves saved stations',
    () async {
      final repository = MemoryFavorites();
      final container = ProviderContainer(
        overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(favoritesProvider.notifier);
      expect(container.read(favoritesProvider).isLoading, isTrue);
      await container.read(favoritesProvider.future);
      await controller.toggle(station);
      expect(
        container.read(favoritesProvider).valueOrNull?.stations.single.id,
        'id',
      );
      repository.failSave = true;
      final pendingSave = repository.pendingSave = Completer<void>();
      final removal = controller.toggle(station);
      final saving = container.read(favoritesProvider);
      expect(saving.isLoading, isTrue);
      expect(saving.valueOrNull?.stations.single.id, 'id');
      pendingSave.complete();
      await removal;
      expect(
        container.read(favoritesProvider).valueOrNull?.stations.single.id,
        'id',
      );
      expect(container.read(favoritesProvider).hasError, isTrue);
      repository.failSave = false;
      await controller.toggle(station);
      expect(container.read(favoritesProvider).valueOrNull?.stations, isEmpty);
      expect(container.read(favoritesProvider).hasError, isFalse);
    },
  );
}
