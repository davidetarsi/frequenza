import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../radio/domain/station_record.dart';
import '../../radio/domain/radio_station.dart';
import '../domain/favorites_repository.dart';

class PreferencesFavoritesRepository implements FavoritesRepository {
  static const _key = 'frequenza.favorites.v1';

  @override
  Future<List<RadioStation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Invalid favorites');
    final result = <String, RadioStation>{};
    for (final entry in decoded) {
      if (stationFromRecord(entry) case final station?) {
        result[station.id] = station;
      }
    }
    return result.values.toList(growable: false);
  }

  @override
  Future<void> save(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(stations.map(stationRecord).toList());
    if (!await prefs.setString(_key, encoded)) {
      throw StateError('Favorites not saved');
    }
  }
}
