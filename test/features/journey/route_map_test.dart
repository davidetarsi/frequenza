import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/geo_point.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/journey/domain/travel_leg.dart';
import 'package:frequenza/features/journey/presentation/route_map.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';

const paris = StationPlace(
  point: GeoPoint(48.86, 2.35),
  approximate: false,
  countryCode: 'FR',
);

Widget host(RouteMap map, {bool reduceMotion = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: Center(child: SizedBox(width: 270, height: 96, child: map)),
);

void main() {
  testWidgets('reduced motion keeps the flight still', (tester) async {
    await tester.pumpWidget(
      host(
        const RouteMap(
          flight: FlightPhase.flying,
          playing: false,
          departure: homePlace,
          history: [],
          trips: 0,
        ),
        reduceMotion: true,
      ),
    );
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
  });

  testWidgets('the flight animates and stops once paused', (tester) async {
    const leg = TravelLeg(from: homePlace, to: paris);
    await tester.pumpWidget(
      host(
        const RouteMap(
          flight: FlightPhase.flying,
          playing: false,
          departure: homePlace,
          history: [],
          trips: 0,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(
      host(
        const RouteMap(
          flight: FlightPhase.grounded,
          playing: false,
          departure: paris,
          leg: leg,
          history: [leg],
          trips: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a landing without a place draws no arc and does not fail', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RouteMap(
          flight: FlightPhase.grounded,
          playing: true,
          departure: homePlace,
          leg: TravelLeg(from: homePlace, to: null),
          history: [],
          trips: 1,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
