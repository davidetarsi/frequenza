import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
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
  bool failLoad = false;
  @override
  Future<List<RadioStation>> load() async {
    if (failLoad) throw StateError('Unavailable');
    return List.of(items);
  }

  @override
  Future<void> save(List<RadioStation> stations) async {
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
  test(
    'toggle removes by identity and failure preserves saved stations',
    () async {
      final repository = MemoryFavorites();
      final controller = FavoritesController(repository);
      addTearDown(controller.dispose);
      await controller.ready;
      await controller.toggle(station);
      expect(controller.state.stations.single.id, 'id');
      repository.failSave = true;
      await controller.toggle(station);
      expect(controller.state.stations.single.id, 'id');
      expect(controller.state.hasError, isTrue);
      repository.failSave = false;
      await controller.toggle(station);
      expect(controller.state.stations, isEmpty);
      expect(controller.state.hasError, isFalse);
    },
  );
}
