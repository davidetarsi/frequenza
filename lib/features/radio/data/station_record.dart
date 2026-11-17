import '../../journey/domain/geo_point.dart';
import '../domain/radio_station.dart';

/// A station as the phone keeps it: short keys, and only what is needed to
/// tune in again.
Map<String, Object?> stationRecord(RadioStation station) {
  final json = station.toJson();
  return {
    for (final key in ['id', 'name', 'url', 'country', 'code', 'tags'])
      key: json[key],
    'region': ?station.region,
    // Records without coordinates keep the original v1 shape.
    if (station.point case final point?) ...{
      'lat': point.latitude,
      'lon': point.longitude,
    },
  };
}

/// The station in [record], or null when it cannot be tuned in again: no
/// id, no name, or a stream that is not HTTPS.
RadioStation? stationFromRecord(Object? record) {
  if (record is! Map<String, dynamic>) return null;
  final id = record['id'], name = record['name'], url = record['url'];
  if (id is! String ||
      id.isEmpty ||
      name is! String ||
      name.isEmpty ||
      url is! String) {
    return null;
  }
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  final point = GeoPoint.tryFrom(record['lat'], record['lon']);
  final region = record['region'];
  return RadioStation.fromJson({
    'id': id,
    'name': name,
    'url': url,
    'country': record['country'] is String ? record['country'] : '',
    'code': record['code'] is String ? record['code'] : '',
    'region': region is String && region.isNotEmpty ? region : null,
    'tags': (record['tags'] is List ? record['tags'] as List : [])
        .whereType<String>()
        .toList(),
    'lat': point?.latitude,
    'lon': point?.longitude,
  });
}
