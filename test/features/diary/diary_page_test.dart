import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/diary/application/diary_providers.dart';
import 'package:frequenza/features/diary/domain/diary_period.dart';
import 'package:frequenza/features/diary/domain/listen.dart';
import 'package:frequenza/features/diary/domain/world_cells.dart';
import 'package:frequenza/features/diary/presentation/diary_map.dart';
import 'package:frequenza/features/diary/presentation/diary_page.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/radio/presentation/radio_page.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/recording_analytics.dart';
import '../favorites/favorites_test.dart' show MemoryFavorites;
import '../radio/journey_test.dart' show station;
import '../radio/radio_bar_test.dart' show BarRadio;
import '../radio/radio_controller_test.dart';
import '../songs/saved_songs_test.dart' show MemorySongs, kexp;
import 'listen_recorder_test.dart' show MemoryDiary;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  final brazil = station(1, code: 'BR');
  final germany = station(2, code: 'DE');
  final chile = station(3, code: 'CL');

  Future<(MemoryDiary, RecordingAnalytics, MemorySongs)> openRadio(
    WidgetTester tester, {
    bool empty = false,
    String? title,
    MemoryDiary? log,
    bool reducedMotion = true,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: reducedMotion);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final now = DateTime.now().toUtc();
    final diary = log ?? MemoryDiary();
    if (!empty) {
      await diary.startListen(
        brazil,
        startedAt: now.subtract(const Duration(days: 2)),
        seconds: 9 * 3600,
      );
      await diary.startListen(
        germany,
        startedAt: now.subtract(const Duration(days: 20)),
        seconds: 5 * 3600,
      );
      await diary.startListen(
        chile,
        startedAt: now.subtract(const Duration(days: 1)),
        seconds: 180,
      );
    }
    final analytics = RecordingAnalytics();
    final songs = MemorySongs();
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioControllerProvider.overrideWith(
            () => BarRadio(
              RadioSession.onAir(
                const Journey(landed: kexp, trips: 1),
                kexp,
                playback: OnAirPlayback.playing,
                trackTitle: title,
              ),
            ),
          ),
          radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
          songsRepositoryProvider.overrideWithValue(songs),
          diaryRepositoryProvider.overrideWithValue(diary),
          analyticsProvider.overrideWithValue(analytics),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    return (diary, analytics, songs);
  }

  Future<void> openDiaryPage(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Apri il diario di viaggio'));
    await tester.pumpAndSettle();
  }

  bool onlyRadio(WidgetTester tester) =>
      find.byType(DiaryPage).evaluate().isEmpty &&
      !Navigator.of(tester.element(find.byType(RadioPage))).canPop();

  testWidgets('the diary opens from the radio and counts the stops', (
    tester,
  ) async {
    final (_, analytics, _) = await openRadio(tester);
    await openDiaryPage(tester);
    expect(find.byType(DiaryPage), findsOneWidget);
    expect(find.text('2 paesi · 14 h'), findsOneWidget);
    expect(find.textContaining('Station 1 · Brasile · 9 h'), findsOneWidget);
    double top(String text) => tester.getTopLeft(find.text(text).last).dy;
    expect(top('Brasile'), lessThan(top('Germania')));
    expect(
      find.bySemanticsLabel('2 paesi; il più ascoltato: Brasile'),
      findsOneWidget,
    );
    expect(analytics.events, [const AppEvent.diaryOpened()]);
  });

  testWidgets('a shorter period counts again, and is counted', (tester) async {
    final (_, analytics, _) = await openRadio(tester);
    await openDiaryPage(tester);
    await tester.tap(find.text('7 giorni'));
    await tester.pumpAndSettle();
    expect(find.text('1 paese · 9 h'), findsOneWidget);
    expect(analytics.events.last, AppEvent.diaryPeriodChosen(DiaryPeriod.week));
  });

  testWidgets('an empty diary says how it fills', (tester) async {
    await openRadio(tester, empty: true);
    await openDiaryPage(tester);
    expect(
      find.text(
        'Il diario si riempie mentre ascolti: un paese si accende dopo 5 minuti.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('back, or the bar, closes the diary over the radio', (
    tester,
  ) async {
    await openRadio(tester);
    for (var i = 0; i < 3; i++) {
      await openDiaryPage(tester);
      await tester.tap(find.byTooltip('Torna alla radio'));
      await tester.pumpAndSettle();
      expect(onlyRadio(tester), isTrue);
      await openDiaryPage(tester);
      await tester.tap(find.bySemanticsLabel(RegExp('^Torna alla radio:')));
      await tester.pumpAndSettle();
      expect(onlyRadio(tester), isTrue);
    }
  });

  testWidgets('a tap on the song saves it and does not open the diary', (
    tester,
  ) async {
    final (_, _, songs) = await openRadio(tester, title: 'Ana Moura - Desfado');
    await tester.tap(find.text('Ana Moura — Desfado'));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryPage), findsNothing);
    expect(songs.items.single.title, 'Desfado');
  });

  testWidgets('large text on a small phone: no overflow, the list scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openRadio(tester);
    await tester.tap(find.bySemanticsLabel('Apri il diario di viaggio'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final map = tester.getSize(find.byKey(const ValueKey('diary-map')));
    expect(map.height, greaterThanOrEqualTo(180));
    expect(find.byKey(const ValueKey('diary-list')), findsOneWidget);
  });

  testWidgets('on a tall phone the label sits in the map corner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openRadio(tester);
    await tester.tap(find.text('DIARIO ›'));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryPage), findsOneWidget);
  });

  testWidgets("a country the atlas does not name shows Radio Browser's name", (
    tester,
  ) async {
    final (diary, _, _) = await openRadio(tester, empty: true);
    await diary.startListen(
      const RadioStation(
        id: 'gib',
        name: 'GBC Radio',
        streamUrl: 'https://gib.example.com/live',
        country: 'Gibraltar',
        countryCode: 'GI',
      ),
      startedAt: DateTime.now().toUtc(),
      seconds: 3600,
    );
    await openDiaryPage(tester);
    expect(find.text('GI'), findsNothing);
    expect(find.text('Gibraltar'), findsOneWidget);
  });

  testWidgets('with no stop the map does not name a most heard country', (
    tester,
  ) async {
    final (diary, _, _) = await openRadio(tester, empty: true);
    await diary.startListen(
      chile,
      startedAt: DateTime.now().toUtc(),
      seconds: 180,
    );
    await openDiaryPage(tester);
    expect(
      find.bySemanticsLabel('Mappa spenta: ancora nessun paese'),
      findsOneWidget,
    );
  });

  testWidgets('a phone held sideways: no overflow, the list within reach', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openRadio(tester);
    await openDiaryPage(tester);
    expect(tester.takeException(), isNull);
    final list = tester.getSize(find.byKey(const ValueKey('diary-list')));
    expect(list.height, greaterThanOrEqualTo(64));
  });

  testWidgets('a notice from the bar sits above the bar', (tester) async {
    await openRadio(tester, title: 'Ana Moura - Desfado');
    await openDiaryPage(tester);
    await tester.tap(find.byTooltip('Salva canzone'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final notice = tester.getRect(find.byType(SnackBar));
    final bar = tester.getRect(
      find.bySemanticsLabel(RegExp('^Torna alla radio:')),
    );
    expect(notice.bottom, lessThanOrEqualTo(bar.top));
  });

  testWidgets('the map invites a tap until a country is picked', (
    tester,
  ) async {
    await openRadio(tester);
    await openDiaryPage(tester);
    expect(find.text('Tocca un paese'), findsOneWidget);
    await tester.tap(find.text('Brasile').last);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DiaryPage), findsOneWidget);
    expect(find.text('Tocca un paese'), findsNothing);
  });

  testWidgets('a new period keeps the last diary while it loads', (
    tester,
  ) async {
    final log = HeldDiary();
    await openRadio(tester, log: log);
    await openDiaryPage(tester);
    log.hold = true;
    await tester.tap(find.text('7 giorni'));
    await tester.pumpAndSettle();
    expect(find.text('2 paesi · 14 h'), findsOneWidget);
    expect(find.textContaining('Il diario si riempie'), findsNothing);
  });

  testWidgets('a diary that cannot be read says so', (tester) async {
    await openRadio(tester, log: HeldDiary()..broken = true);
    await openDiaryPage(tester);
    expect(
      find.text('Non è stato possibile leggere il diario.'),
      findsOneWidget,
    );
    expect(find.textContaining('Il diario si riempie'), findsNothing);
  });

  testWidgets('with reduced motion the bar does not slide in', (tester) async {
    await openRadio(tester);
    await tester.tap(find.bySemanticsLabel('Apri il diario di viaggio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final bar = find.bySemanticsLabel(RegExp('^Torna alla radio:'));
    final early = tester.getRect(bar);
    await tester.pumpAndSettle();
    expect(tester.getRect(bar).top, early.top);
  });

  testWidgets('a listen in French Guiana lights it, not France', (
    tester,
  ) async {
    final (diary, _, _) = await openRadio(tester, empty: true);
    await diary.startListen(
      const RadioStation(
        id: 'gf',
        name: 'Guyane la 1ère',
        streamUrl: 'https://gf.example.com/live',
        country: 'French Guiana',
        countryCode: 'GF',
      ),
      startedAt: DateTime.now().toUtc(),
      seconds: 3600,
    );
    await openDiaryPage(tester);
    expect(find.text('Guyana francese'), findsOneWidget);
    expect(find.text('Francia'), findsNothing);
    final map = find.byKey(const ValueKey('diary-map-paint'));
    final looks =
        (tester.widget<CustomPaint>(map).painter! as DiaryMapPainter).looks;
    expect(looks.keys, ['GF']);
    expect(countryDots().where((d) => d.code == 'GF'), isNotEmpty);
  });
}

/// A diary that can hold back a period, or fail to be read.
class HeldDiary extends MemoryDiary {
  var hold = false;
  var broken = false;

  @override
  Stream<List<Listen>> watchListensSince(DateTime? since) {
    if (broken) return Stream.error(StateError('Disk unreadable'));
    if (hold) return StreamController<List<Listen>>().stream;
    return super.watchListensSince(since);
  }
}
