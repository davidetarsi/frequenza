import 'package:freezed_annotation/freezed_annotation.dart';

import '../../radio/domain/radio_station.dart';
import '../data/world_atlas.g.dart';
import 'geo_point.dart';

part 'station_place.freezed.dart';

/// Where a station is on the map. [approximate] marks a country centre used
/// in place of the station's own coordinates.
@freezed
class StationPlace with _$StationPlace {
  const factory StationPlace({
    required GeoPoint point,
    required bool approximate,
    required String countryCode,
  }) = _StationPlace;
}

/// The first departure: the centre of Italy (`countryCentroids['IT']`).
const homePlace = StationPlace(
  point: GeoPoint(44.73, 11.08),
  approximate: true,
  countryCode: 'IT',
);

StationPlace? placeOf(RadioStation station) {
  final code = station.countryCode;
  if (station.point case final point?) {
    return StationPlace(point: point, approximate: false, countryCode: code);
  }
  final centre = countryCentroids[code];
  if (centre == null) return null;
  return StationPlace(
    point: GeoPoint(centre.$1, centre.$2),
    approximate: true,
    countryCode: code,
  );
}
