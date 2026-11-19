import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:frequenza/features/journey/domain/geo_point.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/journey/domain/travel_leg.dart';
import 'package:frequenza/features/journey/presentation/route_map.dart';
import 'package:frequenza/features/journey/presentation/country_shape.dart';
import 'package:frequenza/features/radio/presentation/radio_display.dart';

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
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();
  RouteMapPainter frame(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(find.byKey(const ValueKey('route-map')))
              .painter!
          as RouteMapPainter;
  RouteMap map({
    FlightPhase phase = FlightPhase.grounded,
    int trips = 1,
    StationPlace? to = paris,
    bool reconnecting = false,
  }) => RouteMap(
    flight: phase,
    playing: false,
    departure: to ?? homePlace,
    leg: TravelLeg(from: homePlace, to: to),
    history: const [],
    trips: trips,
    reconnecting: reconnecting,
  );

  testWidgets(
    'arrival zooms progressively; the next flight returns to the world',
    (tester) async {
      await tester.pumpWidget(
        host(map(phase: FlightPhase.flying, trips: 0, to: null)),
      );
      expect(frame(tester).country, isNull);
      await tester.pumpWidget(host(map()));
      expect(frame(tester).viewport.width, closeTo(360, 1e-8));
      expect(frame(tester).outline, 0);
      await tester.pump(const Duration(milliseconds: 900));
      expect(
        frame(tester).viewport.width,
        inExclusiveRange(CountryShape.of('FR')!.viewport.width, 360),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(frame(tester).outline, 1);
      final arrived = frame(tester).viewport;
      await tester.pumpWidget(host(map(phase: FlightPhase.flying)));
      expect(frame(tester).viewport.width, closeTo(arrived.width, 1e-8));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        frame(tester).viewport.width,
        inExclusiveRange(arrived.width, 360),
      );
      await tester.pump(const Duration(milliseconds: 450));
      expect(frame(tester).viewport.width, closeTo(360, 1e-8));
      expect(frame(tester).outline, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'interrupted zooms continue from the current view without a jump',
    (tester) async {
      await tester.pumpWidget(
        host(map(phase: FlightPhase.flying, trips: 0, to: null)),
      );
      await tester.pumpWidget(host(map()));
      await tester.pump(const Duration(milliseconds: 700));
      final before = frame(tester).viewport;
      await tester.pumpWidget(host(map(phase: FlightPhase.flying)));
      expect(frame(tester).viewport.width, closeTo(before.width, 1e-8));
      expect(frame(tester).viewport.center.dx, closeTo(before.center.dx, 1e-8));
      await tester.pump(const Duration(milliseconds: 100));
      final leaving = frame(tester).viewport;
      const brazil = StationPlace(
        point: GeoPoint(-15.8, -47.9),
        approximate: false,
        countryCode: 'BR',
      );
      await tester.pumpWidget(host(map(to: brazil, trips: 2)));
      expect(frame(tester).viewport.width, closeTo(leaving.width, 1e-8));
      await tester.pumpAndSettle();
      expect(
        frame(tester).viewport.width,
        closeTo(CountryShape.of('BR')!.viewport.width, 1e-8),
      );
    },
  );

  testWidgets(
    'a reconnect preserves country focus and does not replay the arrival',
    (tester) async {
      await tester.pumpWidget(host(map()));
      final before = frame(tester).viewport;
      await tester.pumpWidget(
        host(map(phase: FlightPhase.flying, reconnecting: true)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(frame(tester).viewport, before);
      await tester.pumpWidget(host(map()));
      await tester.pumpAndSettle();
      expect(frame(tester).viewport, before);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets(
    'reduced motion shows the final country immediately, then the world',
    (tester) async {
      await tester.pumpWidget(
        host(map(phase: FlightPhase.flying, trips: 0), reduceMotion: true),
      );
      await tester.pumpWidget(host(map(), reduceMotion: true));
      expect(frame(tester).outline, 1);
      expect(
        frame(tester).viewport.width,
        closeTo(CountryShape.of('FR')!.viewport.width, 1e-8),
      );
      await tester.pumpWidget(
        host(map(phase: FlightPhase.flying), reduceMotion: true),
      );
      expect(frame(tester).outline, 0);
      expect(frame(tester).viewport.width, closeTo(360, 1e-8));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('a country without geometry keeps the world and route visible', (
    tester,
  ) async {
    const unknown = StationPlace(
      point: GeoPoint(0, 0),
      approximate: true,
      countryCode: 'ZZ',
    );
    await tester.pumpWidget(host(map(to: unknown)));
    expect(frame(tester).country, isNull);
    expect(frame(tester).outline, 0);
    expect(frame(tester).viewport.width, closeTo(360, 1e-8));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'resuming after an unplaced landing clears the previous country',
    (tester) async {
      await tester.pumpWidget(host(map(), reduceMotion: true));
      expect(frame(tester).outline, 1);
      // In background a whole flight can happen without a visible frame.
      await tester.pumpWidget(
        host(map(to: null, trips: 2), reduceMotion: true),
      );
      expect(frame(tester).viewport.width, closeTo(360, 1e-8));
      expect(frame(tester).outline, 0);
      expect(tester.takeException(), isNull);
    },
  );

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

  testWidgets(
    'rebuilding the map leaves nothing behind',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      // The welcome demo rebuilds the map on every frame.
      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(
          host(
            RouteMap(
              flight: FlightPhase.grounded,
              playing: false,
              departure: homePlace,
              leg: const TravelLeg(from: homePlace, to: paris),
              history: const [],
              trips: 1 + i % 2,
            ),
          ),
        );
      }
      await tester.pumpAndSettle();
    },
  );
}
