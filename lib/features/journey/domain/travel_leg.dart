import 'package:freezed_annotation/freezed_annotation.dart';

import 'station_place.dart';

part 'travel_leg.freezed.dart';

/// One flight. [to] is null when the station could not be placed.
@freezed
class TravelLeg with _$TravelLeg {
  const TravelLeg._();

  const factory TravelLeg({
    required StationPlace from,
    required StationPlace? to,
  }) = _TravelLeg;

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
}
