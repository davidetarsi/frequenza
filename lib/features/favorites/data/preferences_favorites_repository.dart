import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
      if (entry is! Map<String, dynamic>) continue;
      final id = entry['id'], name = entry['name'], url = entry['url'];
      if (id is! String ||
          id.isEmpty ||
          name is! String ||
          name.isEmpty ||
          url is! String) {
        continue;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) continue;
      result[id] = RadioStation(
        id: id,
        name: name,
        streamUrl: url,
        country: entry['country'] is String ? entry['country'] as String : '',
        countryCode: entry['code'] is String ? entry['code'] as String : '',
        tags: (entry['tags'] is List ? entry['tags'] as List : [])
            .whereType<String>()
            .toList(),
      );
    }
    return result.values.toList(growable: false);
  }

  @override
  Future<void> save(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      stations
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'url': s.streamUrl,
              'country': s.country,
              'code': s.countryCode,
              'tags': s.tags,
            },
          )
          .toList(),
    );
    if (!await prefs.setString(_key, encoded)) {
      throw StateError('Favorites not saved');
    }
  }
}
