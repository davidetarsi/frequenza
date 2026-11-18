import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/diary/application/diary_providers.dart';
import 'package:frequenza/features/diary/domain/diary_flight.dart';
import 'package:frequenza/features/diary/presentation/diary_page.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/journey/data/world_atlas.g.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/recording_analytics.dart';
import '../favorites/favorites_test.dart' show MemoryFavorites;
import '../radio/radio_bar_test.dart' show BarRadio;
import '../radio/radio_controller_test.dart';
import '../songs/saved_songs_test.dart' show MemorySongs, kexp;
import 'listen_recorder_test.dart' show MemoryDiary;

RadioStation radio(String id, String code, {String? region}) => RadioStation(
  id: id,
  name: 'Radio $id',
  streamUrl: 'https://$id.example.com/live',
  country: code,
  countryCode: code,
  region: region,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  final paraiso = radio('paraiso', 'BR', region: 'Rio de Janeiro');
  final cultura = radio('cultura', 'BR');
  final cooperativa = radio('cooperativa', 'CL', region: 'Santiago');

  late BarRadio controller;
  late RecordingAnalytics analytics;
  late MemoryDiary diary;

  Future<void> openDiaryPage(WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final now = DateTime.now().toUtc();
    diary = MemoryDiary();
    await diary.startListen(
      paraiso,
      startedAt: now.subtract(const Duration(days: 2)),
      seconds: 6 * 3600,
    );
    await diary.startListen(
      cultura,
      startedAt: now.subtract(const Duration(days: 1)),
      seconds: 3600,
    );
    await diary.startListen(
      cooperativa,
      startedAt: now.subtract(const Duration(hours: 5)),
      seconds: 180,
    );
    analytics = RecordingAnalytics();
    controller = BarRadio(
      RadioSession.onAir(
        const Journey(landed: kexp, trips: 1),
        kexp,
        playback: OnAirPlayback.playing,
      ),
    );
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioControllerProvider.overrideWith(() => controller),
          radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
          songsRepositoryProvider.overrideWithValue(MemorySongs()),
          diaryRepositoryProvider.overrideWithValue(diary),
          analyticsProvider.overrideWithValue(analytics),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Apri il diario di viaggio'));
    await tester.pumpAndSettle();
    analytics.events.clear();
  }

  /// Taps the middle of the first dot of [code] on the map at 1×.
  Future<void> tapCountry(WidgetTester tester, String code) async {
    final map = tester.getRect(find.byKey(const ValueKey('diary-map')));
    final paint = tester.getSize(find.byKey(const ValueKey('diary-map-paint')));
    final cell = paint.width / worldDotRows.first.length;
    for (var row = 0; row < worldDotCountries.length; row++) {
      final at = worldDotCountries[row].indexOf(code);
      if (at.isEven && at >= 0) {
        final point = Offset((at ~/ 2 + 0.5) * cell, (row + 0.5) * cell);
        final controller = tester
            .widget<InteractiveViewer>(find.byType(InteractiveViewer))
            .transformationController!;
        controller.value = Matrix4.identity()
          ..translateByDouble(
            (map.width / 2 - point.dx).clamp(map.width - paint.width, 0),
            (map.height / 2 - point.dy).clamp(map.height - paint.height, 0),
            0,
            1,
          );
        await tester.pump();
        await tester.tapAt(
          map.topLeft + MatrixUtils.transformPoint(controller.value, point),
        );
        await tester.pumpAndSettle();
        return;
      }
    }
    fail('no dot for $code');
  }

  testWidgets('a stopped country: its stations, and a flight from them', (
    tester,
  ) async {
    await openDiaryPage(tester);
    await tester.ensureVisible(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brasile').last);
    await tester.pumpAndSettle();
    final sheet = find.byKey(const ValueKey('country-sheet'));
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('7 h · 2 radio')),
      findsOneWidget,
    );
    double top(String text) => tester
        .getTopLeft(find.descendant(of: sheet, matching: find.text(text)))
        .dy;
    expect(top('Radio paraiso'), lessThan(top('Radio cultura')));
    expect(
      find.descendant(of: sheet, matching: find.text('Rio de Janeiro · 6 h')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.textContaining('Ultimo ascolto'),
      ),
      findsOneWidget,
    );
    expect(analytics.events, [
      const AppEvent('diary_country_opened', {
        'country': 'BR',
        'kind': 'stopped',
      }),
    ]);

    await tester.tap(
      find.descendant(of: sheet, matching: find.text('Volaci')).first,
    );
    await tester.pumpAndSettle();
    expect(controller.calls, ['tuneTo:paraiso']);
    expect(find.byKey(const ValueKey('country-sheet')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('^Torna alla radio:')), findsOneWidget);
    expect(find.byType(DiaryPage), findsOneWidget);
    expect(find.text('In volo…'), findsOneWidget);
    expect(
      analytics.events.last,
      AppEvent.diaryFlight(DiaryFlightSource.countryStation),
    );
  });

  testWidgets('a country passed through says how long it takes to light', (
    tester,
  ) async {
    await openDiaryPage(tester);
    await tapCountry(tester, 'CL');
    final sheet = find.byKey(const ValueKey('country-sheet'));
    expect(
      find.descendant(
        of: sheet,
        matching: find.text(
          'Qui solo 3 min: un paese si accende dopo 5 min di ascolto.',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Radio cooperativa')),
      findsOneWidget,
    );
    expect(analytics.events.single.properties['kind'], 'passing');
  });

  testWidgets('a country never heard offers a flight there', (tester) async {
    await openDiaryPage(tester);
    await tapCountry(tester, 'MN');
    final sheet = find.byKey(const ValueKey('country-sheet'));
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('Non sei ancora passato di qui.'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: sheet, matching: find.text('Vola in Mongolia')),
    );
    await tester.pumpAndSettle();
    expect(controller.calls, ['tuneRandom:MN']);
    expect(
      analytics.events.last,
      AppEvent.diaryFlight(DiaryFlightSource.randomInCountry),
    );
  });

  testWidgets(
    'the country sheet hides the bar; back restores it before leaving',
    (tester) async {
      await openDiaryPage(tester);
      await tester.ensureVisible(find.text('Brasile').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Brasile').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('country-sheet')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('^Torna alla radio:')).hitTestable(),
        findsNothing,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('country-sheet')), findsNothing);
      expect(find.byType(DiaryPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DiaryPage), findsNothing);
    },
  );

  testWidgets('the most heard station flies from the top of the list', (
    tester,
  ) async {
    await openDiaryPage(tester);
    await tester.tap(find.textContaining('Radio paraiso · Brasile'));
    await tester.pumpAndSettle();
    expect(controller.calls, ['tuneTo:paraiso']);
    expect(
      analytics.events.single,
      AppEvent.diaryFlight(DiaryFlightSource.topStation),
    );
  });

  testWidgets('closing a country sheet restores the bar and its navigation', (
    tester,
  ) async {
    await openDiaryPage(tester);
    await tester.ensureVisible(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp('^Torna alla radio:')));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryPage), findsNothing);
  });

  testWidgets('the open sheet follows new listens', (tester) async {
    await openDiaryPage(tester);
    await tester.ensureVisible(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await diary.startListen(
      radio('nuova', 'BR'),
      startedAt: DateTime.now().toUtc(),
      seconds: 1800,
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('country-sheet')),
        matching: find.text('Radio nuova'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('every country sheet closes with the right-hand X', (
    tester,
  ) async {
    await openDiaryPage(tester);
    for (final code in ['BR', 'CL', 'EC']) {
      await tapCountry(tester, code);
      final sheet = find.byKey(const ValueKey('country-sheet'));
      final close = find.descendant(
        of: sheet,
        matching: find.byTooltip('Chiudi'),
      );
      expect(close, findsOneWidget);
      expect(
        tester.getCenter(close).dx,
        greaterThan(tester.getCenter(sheet).dx),
      );
      if (code == 'EC') {
        expect(
          find.descendant(
            of: sheet,
            matching: find.byIcon(Icons.arrow_forward),
          ),
          findsNothing,
        );
      }
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(sheet, findsNothing);
      expect(find.byType(DiaryPage), findsOneWidget);
    }
  });

  testWidgets('the close button is big enough to touch', (tester) async {
    await openDiaryPage(tester);
    await tester.ensureVisible(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brasile').last);
    await tester.pumpAndSettle();
    final handle = tester.getSize(find.byTooltip('Chiudi'));
    expect(handle.height, greaterThanOrEqualTo(44));
    expect(handle.width, greaterThanOrEqualTo(44));
  });

  testWidgets('a drag down closes the sheet even when its content scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openDiaryPage(tester);
    for (var index = 0; index < 8; index++) {
      await diary.startListen(
        radio('extra$index', 'BR'),
        startedAt: DateTime.now().toUtc(),
        seconds: 600,
      );
    }
    await tester.pumpAndSettle();
    await tapCountry(tester, 'BR');
    expect(find.byKey(const ValueKey('country-sheet')), findsOneWidget);
    final sheet = find.byKey(const ValueKey('country-sheet'));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: sheet, matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    await tester.flingFrom(tester.getCenter(sheet), const Offset(0, 300), 1500);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('country-sheet')), findsNothing);
  });
}
