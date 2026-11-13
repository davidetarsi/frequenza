import '../../radio/domain/radio_station.dart';
import '../data/world_atlas.g.dart';
import 'geo_point.dart';

/// Where a station is on the map. [approximate] marks a country centre used
/// in place of the station's own coordinates.
class StationPlace {
  const StationPlace({
    required this.point,
    required this.approximate,
    required this.countryCode,
  });

  final GeoPoint point;
  final bool approximate;
  final String countryCode;

  @override
  bool operator ==(Object other) =>
      other is StationPlace &&
      other.point == point &&
      other.approximate == approximate &&
      other.countryCode == countryCode;

  @override
  int get hashCode => Object.hash(point, approximate, countryCode);
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
