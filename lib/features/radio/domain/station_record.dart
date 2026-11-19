import 'package:freezed_annotation/freezed_annotation.dart';

import '../../journey/domain/geo_point.dart';
import 'radio_station.dart';
import '../../../app/network/domain/https_uri.dart';
import 'station_input.dart';

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
  final uri = httpsUri(url);
  if (StationInput.text(id, StationInput.id) == null ||
      StationInput.text(name, StationInput.name) == null ||
      uri == null) {
    return null;
  }
  final point = GeoPoint.tryFrom(record['lat'], record['lon']);
  final region = record['region'];
  return RadioStation.fromJson({
    'id': id,
    'name': name,
    'url': uri.toString(),
    'country': StationInput.text(record['country'], StationInput.country) ?? '',
    'code': StationInput.text(record['code'], StationInput.countryCode) ?? '',
    'region': StationInput.text(region, StationInput.region),
    'tags': (record['tags'] is List ? record['tags'] as List : [])
        .whereType<String>()
        .where((tag) => StationInput.text(tag, StationInput.tag) != null)
        .take(StationInput.tagsCount)
        .toList(),
    'lat': point?.latitude,
    'lon': point?.longitude,
  });
}

/// The full snapshot used by the diary, checked through the same station
/// boundary as favourites. Optional display metadata never bypasses its bounds.
RadioStation? stationFromSnapshot(Object? snapshot) {
  if (snapshot is! Map<String, dynamic>) return null;
  try {
    final station = RadioStation.fromJson(snapshot);
    final base = stationFromRecord(stationRecord(station));
    if (base == null) return null;
    return base.copyWith(
      faviconUrl: httpsUri(station.faviconUrl)?.toString(),
      codec: StationInput.text(station.codec, StationInput.codec),
      bitrate: (station.bitrate ?? 0) > 0 ? station.bitrate : null,
    );
  } catch (_) {
    return null;
  }
}

/// A station inside another stored record: it throws when the station
/// cannot be tuned in again, so the record holding it is skipped.
class StationRecordConverter
    implements JsonConverter<RadioStation, Map<String, Object?>> {
  const StationRecordConverter();

  @override
  RadioStation fromJson(Map<String, Object?> json) =>
      stationFromRecord(json) ??
      (throw const FormatException('Station cannot be tuned in again'));

  @override
  Map<String, Object?> toJson(RadioStation station) => stationRecord(station);
}
