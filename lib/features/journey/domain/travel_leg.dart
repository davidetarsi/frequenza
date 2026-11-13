import 'station_place.dart';

/// One flight. [to] is null when the station could not be placed.
class TravelLeg {
  const TravelLeg({required this.from, required this.to});

  final StationPlace from;
  final StationPlace? to;

  /// Length of the leg, hidden when a country centre would make a
  /// same-country distance meaningless.
  ({int km, bool approximate})? get distance {
    final to = this.to;
    if (to == null) return null;
    final approximate = from.approximate || to.approximate;
    if (approximate && from.countryCode == to.countryCode) return null;
    return (
      km: from.point.distanceKm(to.point).round(),
      approximate: approximate,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TravelLeg && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}
