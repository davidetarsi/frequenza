import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/journey/domain/travel_leg.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

RadioStation station(int n, {String code = 'FR', double? lat, double? lon}) =>
    RadioStation(
      id: 's$n',
      name: 'Station $n',
      streamUrl: 'https://example.com/$n',
      country: 'Somewhere',
      countryCode: code,
      latitude: lat,
      longitude: lon,
    );

void main() {
  final paris = station(1, lat: 48.86, lon: 2.35);
  final berlin = station(2, code: 'DE', lat: 52.52, lon: 13.4);

  test('leaving stacks the station on air, at most 10', () {
    var journey = const Journey();
    for (var n = 0; n < 12; n++) {
      journey = journey.copyWith(landed: station(n)).leave();
    }
    expect(journey.landed, isNull);
    expect(journey.previous.map((s) => s.id), [
      for (var n = 2; n < 12; n++) 's$n',
    ]);
    expect(Journey.backStackLength, 10);
  });

  test('leaving towards the station on air keeps it', () {
    final journey = Journey(landed: paris);
    expect(journey.leave(target: paris), journey);
  });

  test('arriving records the leg, moves the departure and counts the trip', () {
    final journey = const Journey().arrive(paris, FlightKind.forward);
    final to = placeOf(paris);
    expect(journey.leg, TravelLeg(from: homePlace, to: to));
    expect(journey.departure, to);
    expect(journey.history, [journey.leg]);
    expect(journey.trips, 1);
    expect(journey.landed, paris);
  });

  test('a place-less arrival keeps departure and history', () {
    final nowhere = station(9, code: '');
    final journey = const Journey().arrive(nowhere, FlightKind.forward);
    expect(journey.leg, const TravelLeg(from: homePlace, to: null));
    expect(journey.departure, homePlace);
    expect(journey.history, isEmpty);
    expect(journey.trips, 1);
  });

  test('arriving back pops the stack', () {
    final journey = Journey(
      previous: [paris, berlin],
    ).arrive(berlin, FlightKind.back);
    expect(journey.previous, [paris]);
    expect(journey.trips, 1);
    expect(journey.landed, berlin);
  });

  test('a reconnect arrival only remembers the station', () {
    final before = Journey(trips: 3, previous: [berlin]);
    expect(
      before.arrive(paris, FlightKind.reconnect),
      before.copyWith(landed: paris),
    );
  });

  test('history keeps the last 5 legs', () {
    var journey = const Journey();
    for (var n = 0; n < 7; n++) {
      journey = journey.arrive(
        station(n, lat: 40.0 + n, lon: 10.0),
        FlightKind.forward,
      );
    }
    expect(journey.history, hasLength(Journey.historyLength));
    expect(journey.history.last, journey.leg);
    expect(journey.trips, 7);
  });

  test('switching off clears the leg', () {
    final journey = const Journey().arrive(paris, FlightKind.forward);
    final off = journey.switchOff();
    expect(off.leg, isNull);
    expect(off.copyWith(leg: journey.leg), journey);
  });
}
