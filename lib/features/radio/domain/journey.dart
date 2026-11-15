import 'package:freezed_annotation/freezed_annotation.dart';

import '../../journey/domain/station_place.dart';
import '../../journey/domain/travel_leg.dart';
import 'radio_station.dart';

part 'journey.freezed.dart';

/// Forward flights stack the station left; back ones pop it; a reconnect
/// replays the station on air without moving the journey.
enum FlightKind { forward, back, reconnect }

/// The trip so far: it outlives every state of the radio.
@freezed
class Journey with _$Journey {
  const Journey._();

  const factory Journey({
    /// Where the next flight leaves from: the last placed landing.
    @Default(homePlace) StationPlace departure,

    /// The leg that brought the radio to the station on air.
    TravelLeg? leg,

    /// The last placed legs of this session, oldest first.
    @Default(<TravelLeg>[]) List<TravelLeg> history,
    @Default(0) int trips,

    /// Stations left behind by forward flights, oldest first: where the
    /// notification's back key returns.
    @Default(<RadioStation>[]) List<RadioStation> previous,

    /// The last station that landed, kept while a back or reconnect flight
    /// hides it.
    RadioStation? landed,
  }) = _Journey;

  static const historyLength = 5;
  static const backStackLength = 10;

  bool get canGoBack => previous.isNotEmpty;

  /// A forward flight leaves the station on air behind, unless it flies
  /// back to that same station.
  Journey leave({RadioStation? target}) {
    final left = landed;
    if (left == null || left.id == target?.id) return this;
    final stack = [...previous, left];
    return copyWith(
      previous: stack.length > backStackLength
          ? stack.sublist(stack.length - backStackLength)
          : stack,
      landed: null,
    );
  }

  Journey arrive(RadioStation station, FlightKind kind) {
    if (kind == FlightKind.reconnect) return copyWith(landed: station);
    final to = placeOf(station);
    final leg = TravelLeg(from: departure, to: to);
    final legs = [...history, if (to != null) leg];
    return copyWith(
      leg: leg,
      departure: to ?? departure,
      history: legs.length > historyLength
          ? legs.sublist(legs.length - historyLength)
          : legs,
      trips: trips + 1,
      previous: kind == FlightKind.back && previous.isNotEmpty
          ? previous.sublist(0, previous.length - 1)
          : previous,
      landed: station,
    );
  }

  /// Switched off, the map forgets the last leg.
  Journey switchOff() => copyWith(leg: null);
}
