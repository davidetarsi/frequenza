// Explicit screenshot generator, not part of the application's test suite.
// Run: flutter test tool/preview/capture_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/diary/application/diary_providers.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/songs/application/saved_songs.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../test/features/analytics/recording_analytics.dart';
import '../../test/features/diary/listen_recorder_test.dart' show MemoryDiary;
import '../../test/features/favorites/favorites_test.dart' show MemoryFavorites;
import '../../test/features/radio/radio_bar_test.dart' show BarRadio;
import '../../test/features/radio/radio_controller_test.dart';
import '../../test/features/songs/saved_songs_test.dart' show MemorySongs;

const fip = RadioStation(
  id: 'preview-fip',
  name: 'FIP',
  country: 'France',
  countryCode: 'FR',
  latitude: 48.8566,
  longitude: 2.3522,
  streamUrl: 'https://example.invalid/fip',
);
const examples = [
  fip,
  RadioStation(
    id: 'preview-jp',
    name: 'Jazz Sakura',
    country: 'Japan',
    countryCode: 'JP',
    streamUrl: 'https://example.invalid/jp',
  ),
  RadioStation(
    id: 'preview-br',
    name: 'Rádio Cultura',
    country: 'Brazil',
    countryCode: 'BR',
    streamUrl: 'https://example.invalid/br',
  ),
  RadioStation(
    id: 'preview-it',
    name: 'Rai Radio 3',
    country: 'Italy',
    countryCode: 'IT',
    streamUrl: 'https://example.invalid/it',
  ),
  RadioStation(
    id: 'preview-us',
    name: 'KEXP',
    country: 'United States',
    countryCode: 'US',
    streamUrl: 'https://example.invalid/us',
  ),
  RadioStation(
    id: 'preview-de',
    name: 'Deutschlandfunk',
    country: 'Germany',
    countryCode: 'DE',
    streamUrl: 'https://example.invalid/de',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('render the current radio and diary with demo data', (
    tester,
  ) async {
    // Load the same platform fonts used by Android instead of test Ahem glyphs.
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    final fonts = FontLoader('Roboto');
    for (final weight in ['Regular']) {
      fonts.addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
            ).readAsBytesSync(),
          ),
        ),
      );
    }
    await fonts.load();
    final mono = FontLoader('monospace')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$flutterRoot/bin/cache/dart-sdk/bin/resources/devtools/assets/fonts/Roboto_Mono/RobotoMono-Regular.ttf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await mono.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    for (final lang in ['it', 'en']) {
      SharedPreferencesStorePlatform.instance =
          InMemorySharedPreferencesStore.withData({
            'app.themeMode': 'dark',
            'app.welcomeRevision': 2,
          });
      await EasyLocalization.ensureInitialized();
      final diary = MemoryDiary();
      final now = DateTime.now().toUtc();
      const minutes = [48, 34, 27, 19, 12, 8];
      for (var i = 0; i < examples.length; i++) {
        await diary.startListen(
          examples[i],
          startedAt: now.subtract(Duration(days: i + 1)),
          seconds: minutes[i] * 60,
        );
      }
      final audio = FakeAudioService();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: ProviderScope(
            overrides: [
              radioControllerProvider.overrideWith(
                () => BarRadio(
                  RadioSession.onAir(
                    const Journey()
                        .arrive(fip, FlightKind.forward)
                        .copyWith(trips: 12),
                    fip,
                    playback: OnAirPlayback.playing,
                    trackTitle: 'Stevie Wonder - Superstition',
                  ),
                ),
              ),
              radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
              radioAudioServiceProvider.overrideWithValue(audio),
              favoritesRepositoryProvider.overrideWithValue(
                MemoryFavorites()..items = [fip, examples[1], examples[4]],
              ),
              songsRepositoryProvider.overrideWithValue(MemorySongs()),
              diaryRepositoryProvider.overrideWithValue(diary),
              analyticsProvider.overrideWithValue(RecordingAnalytics()),
            ],
            child: StarterApp(locale: Locale(lang)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        expect(tester.takeException(), isNull);
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await render.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/img/$name-$lang.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      debugPrint('Capturing radio $lang');
      await capture('radio');
      debugPrint('Opening diary $lang');
      await tester.tap(
        find.byTooltip(
          lang == 'it' ? 'Apri il diario di viaggio' : 'Open the travel diary',
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('diary-list')),
        const Offset(0, -60),
      );
      await tester.pumpAndSettle();
      debugPrint('Capturing diary $lang');
      await capture('diario');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await audio.dispose();
    }
  });
}
