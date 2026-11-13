import '../../radio/domain/radio_station.dart';
import '../data/world_atlas.g.dart';
import 'dst_rule.dart';
import 'geo_point.dart';

/// The station's wall-clock time as `HH:mm`. [approximate] is true when a
/// multi-zone country gives no coordinates to pick the zone.
({String hhmm, bool approximate})? localTimeOf(
  RadioStation station,
  DateTime nowUtc,
) {
  final cities = countryZones[station.countryCode];
  if (cities == null || cities.isEmpty) return null;
  var (zone, _, _) = cities.first;
  final point = station.point;
  final approximate = cities.length > 1 && point == null;
  if (cities.length > 1 && point != null) {
    var nearest = double.infinity;
    for (final (index, lat, lon) in cities) {
      final distance = point.distanceKm(GeoPoint(lat, lon));
      if (distance < nearest) (nearest, zone) = (distance, index);
    }
  }
  final (standard, rule) = timeZones[zone];
  final utc = nowUtc.toUtc();
  final offset = standard + (_inDaylightSaving(rule, standard, utc) ? 60 : 0);
  final local = utc.add(Duration(minutes: offset));
  String two(int value) => value.toString().padLeft(2, '0');
  return (
    hhmm: '${two(local.hour)}:${two(local.minute)}',
    approximate: approximate,
  );
}

/// Mirrors `rule_offset` in tool/world_atlas/generate.py.
bool _inDaylightSaving(DstRule rule, int standardMinutes, DateTime t) {
  final y = t.year;
  const hour = Duration(hours: 1);
  final local = Duration(minutes: standardMinutes);
  bool between(DateTime start, DateTime end) =>
      !t.isBefore(start) && t.isBefore(end);
  return switch (rule) {
    DstRule.none => false,
    DstRule.eu => between(
      _lastSunday(y, 3).add(hour),
      _lastSunday(y, 10).add(hour),
    ),
    DstRule.northAmerica => between(
      _nthSunday(y, 3, 2).add(hour * 2 - local),
      _nthSunday(y, 11, 1).add(hour - local),
    ),
    DstRule.australia => !between(
      _nthSunday(y, 4, 1).add(hour * 2 - local),
      _nthSunday(y, 10, 1).add(hour * 2 - local),
    ),
    DstRule.newZealand => !between(
      _nthSunday(y, 4, 1).add(hour * 2 - local),
      _lastSunday(y, 9).add(hour * 2 - local),
    ),
    DstRule.chile => !between(
      _nthSunday(y, 4, 1).add(hour * 3),
      _nthSunday(y, 9, 1).add(hour * 4),
    ),
  };
}

DateTime _nthSunday(int year, int month, int n) {
  final first = DateTime.utc(year, month);
  return first.add(Duration(days: (7 - first.weekday) % 7 + 7 * (n - 1)));
}

DateTime _lastSunday(int year, int month) {
  final last = DateTime.utc(year, month + 1, 0);
  return last.subtract(Duration(days: last.weekday % 7));
}
