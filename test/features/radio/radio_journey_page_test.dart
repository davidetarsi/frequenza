import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/journey/domain/travel_leg.dart';
import 'package:frequenza/features/journey/presentation/route_map.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../favorites/favorites_test.dart';
import 'radio_controller_test.dart';

const fip = RadioStation(
  id: 'fip',
  name: 'FIP Paris',
  streamUrl: 'https://example.com/fip',
  country: 'France',
  countryCode: 'FR',
  latitude: 48.86,
  longitude: 2.35,
);

const nowhere = RadioStation(
  id: 'nowhere',
  name: 'Radio Nowhere',
  streamUrl: 'https://example.com/nowhere',
  country: 'Mondo',
  countryCode: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<FakeAudioService> open(
    WidgetTester tester,
    RadioStation station, {
    Size size = const Size(390, 900),
    double textScale = 1,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final audio = FakeAudioService()..autoPlay = false;
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioRepositoryProvider.overrideWithValue(
            FakeRadioRepository()..stationToReturn = station,
          ),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    return audio;
  }

  Future<void> land(WidgetTester tester, FakeAudioService audio) async {
    audio.emitStatus(PlaybackStatus.playing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('the flight hides the destination, the landing reveals it', (
    tester,
  ) async {
    final audio = await open(tester, fip);
    expect(find.byType(RouteMap), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tune-knob')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('In volo verso'), findsOneWidget);
    expect(find.text('Prossima fermata: …'), findsOneWidget);
    expect(find.textContaining('FIP'), findsNothing);
    expect(find.textContaining('FRANCE'), findsNothing);

    await land(tester, audio);
    final km = NumberFormat.decimalPattern(
      'it',
    ).format(TravelLeg(from: homePlace, to: placeOf(fip)).distance!.km);
    expect(find.text('FIP Paris'), findsOneWidget);
    expect(find.text('FRANCE · ≈ $km KM'), findsOneWidget);
    expect(find.textContaining('ora locale'), findsOneWidget);
    expect(find.text('Viaggio n. 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a station without a place still lands with its texts', (
    tester,
  ) async {
    final audio = await open(tester, nowhere);
    await tester.tap(find.byKey(const ValueKey('tune-knob')));
    await tester.pump();
    await land(tester, audio);
    expect(find.text('Radio Nowhere'), findsOneWidget);
    expect(find.text('MONDO'), findsOneWidget);
    expect(find.textContaining('ora locale'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (size, scale) in [
    (const Size(320, 640), 2.0),
    (const Size(640, 320), 2.0),
    (const Size(360, 740), 1.0),
    (const Size(390, 900), 2.0),
  ]) {
    testWidgets('no overflow at $size with text x$scale in flight and on air', (
      tester,
    ) async {
      final audio = await open(tester, fip, size: size, textScale: scale);
      await tester.tap(find.byKey(const ValueKey('tune-knob')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      await land(tester, audio);
      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsNothing);
    });
  }
}
