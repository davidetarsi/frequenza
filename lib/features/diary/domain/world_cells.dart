import 'dart:math' as math;

import '../../journey/data/world_atlas.g.dart';

/// One dot of the diary's map: a land cell, or the extra dot of a country
/// too small for one.
typedef CountryDot = ({
  String code,
  double lat,
  double lon,
  int row,
  double col,
});

List<CountryDot>? _dots;

/// Every dot of the map with its country, north to south, west to east;
/// the extra dots last.
List<CountryDot> countryDots() => _dots ??= [
  for (var row = 0; row < worldDotCountries.length; row++)
    for (var col = 0; col < worldDotRows[row].length; col++)
      if (worldDotCountries[row].substring(col * 2, col * 2 + 2) case final code
          when code != '..')
        (
          code: code,
          lat: worldDotNorth - worldDotStep / 2 - row * worldDotStep,
          lon: -180 + worldDotStep / 2 + col * worldDotStep,
          row: row,
          col: col.toDouble(),
        ),
  for (final MapEntry(key: code, value: (lat, lon)) in extraCountryDots.entries)
    if (((worldDotNorth - lat) / worldDotStep).floor() case final row)
      (
        code: code,
        // Where the map paints it: on its row, so a tap on it finds it.
        lat: worldDotNorth - worldDotStep / 2 - row * worldDotStep,
        lon: lon,
        row: row,
        col: (lon + 180) / worldDotStep - 0.5,
      ),
];

/// The country of the dot nearest to ([lat], [lon]) within [radiusCells]
/// cells, or null at sea.
String? countryNear(double lat, double lon, {double radiusCells = 1.5}) {
  final radius = radiusCells * worldDotStep;
  String? best;
  var bestDistance = double.infinity;
  for (final dot in countryDots()) {
    final dLat = dot.lat - lat, dLon = dot.lon - lon;
    final distance = math.sqrt(dLat * dLat + dLon * dLon);
    if (distance <= radius && distance < bestDistance) {
      best = dot.code;
      bestDistance = distance;
    }
  }
  return best;
}
