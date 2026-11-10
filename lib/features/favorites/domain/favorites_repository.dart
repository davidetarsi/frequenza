import '../../radio/domain/radio_station.dart';

abstract interface class FavoritesRepository {
  Future<List<RadioStation>> load();
  Future<void> save(List<RadioStation> stations);
}
