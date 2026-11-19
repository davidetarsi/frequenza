import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/presentation/route_map.dart';
import 'package:frequenza/features/radio/presentation/radio_cabinet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_test.dart' show expectKeysInsideRadio;
import 'copy_track_title_test.dart' show onAir;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({'app.welcomeRevision': 2});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> resize(
    WidgetTester tester,
    double height, {
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the radio shrinks progressively and keeps its map below the old breakpoint',
    (tester) async {
      await onAir(tester);
      addTearDown(tester.view.resetPadding);
      final mapState = tester.state(find.byType(RouteMap));
      final heights = <double>[];
      for (final height in [900.0, 820.0, 780.0, 740.0, 720.0]) {
        await resize(tester, height);
        expect(tester.takeException(), isNull, reason: 'height $height');
        expect(find.byType(RouteMap), findsOneWidget, reason: 'height $height');
        expect(tester.state(find.byType(RouteMap)), same(mapState));
        final radio = tester.getRect(find.byType(RadioCabinet));
        heights.add(radio.height);
        expect(
          tester.getRect(find.text('WEB RADIO · SENZA CONFINI')).top -
              radio.bottom,
          greaterThanOrEqualTo(23.9),
          reason: 'the footer must clear the painted shadow',
        );
        expect(
          tester.getRect(find.text('frequenza')).left,
          closeTo(radio.left, .5),
        );
        expect(
          find.text('WEB RADIO · SENZA CONFINI').hitTestable(),
          findsOneWidget,
        );
        expectKeysInsideRadio(tester);
      }
      for (var i = 1; i < heights.length; i++) {
        expect(heights[i], lessThanOrEqualTo(heights[i - 1]));
      }
      expect(heights.toSet().length, greaterThanOrEqualTo(3));
      expect(find.byType(Scrollable), findsNothing);
    },
  );

  testWidgets(
    'only an insufficient viewport removes the map, then restores it when space returns',
    (tester) async {
      await onAir(tester);
      addTearDown(tester.view.resetPadding);
      await resize(tester, 560, width: 360);
      expect(find.byType(RouteMap), findsNothing);
      expect(find.byTooltip('Pausa').hitTestable(), findsOneWidget);
      expectKeysInsideRadio(tester);
      expect(tester.takeException(), isNull);
      await resize(tester, 800, width: 360);
      expect(find.byType(RouteMap), findsOneWidget);
      expect(find.byTooltip('Pausa').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('landscape keeps the map whenever the horizontal radio fits', (
    tester,
  ) async {
    await onAir(tester);
    addTearDown(tester.view.resetPadding);
    await resize(tester, 420, width: 800);
    expect(find.byType(RouteMap), findsOneWidget);
    expect(find.byTooltip('Pausa').hitTestable(), findsOneWidget);
    expectKeysInsideRadio(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fitting preserves the system text scale and accessible keys', (
    tester,
  ) async {
    await onAir(tester);
    addTearDown(tester.view.resetPadding);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await resize(tester, 860);
    expect(find.byType(RouteMap), findsOneWidget);
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.byType(RadioCabinet)),
      ).scale(16),
      closeTo(20.8, .01),
    );
    expectKeysInsideRadio(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('very short screens with large text can scroll to the controls', (
    tester,
  ) async {
    await onAir(tester);
    addTearDown(tester.view.resetPadding);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await resize(tester, 480, width: 320);
    expect(find.byType(RouteMap), findsNothing);
    expect(find.byType(Scrollable), findsOneWidget);
    final play = find.byKey(const ValueKey('radio-key-play'));
    await tester.dragUntilVisible(
      play,
      find.byType(Scrollable),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    expect(play.hitTestable(), findsOneWidget);
    expectKeysInsideRadio(tester);
    await tester.tap(play);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Riprendi').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
