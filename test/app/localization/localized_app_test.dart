import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/app/localization/application/app_language_provider.dart';
import 'package:frequenza/app/localization/domain/app_language.dart';
import 'package:frequenza/app/platform/application/app_platform_provider.dart';
import 'package:frequenza/app/preferences/application/app_preferences_provider.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_media_localization.dart';
import 'package:frequenza/features/radio/domain/radio_media_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/app_platform_test.dart' show FakePlatform;
import '../../features/radio/radio_controller_test.dart';
import '../../features/favorites/favorites_test.dart' show MemoryFavorites;
import '../../features/songs/saved_songs_test.dart' show fip;
import '../../support/memory_app_preferences.dart';

class LanguagePlatform extends FakePlatform {
  LanguagePlatform(this.device);
  final String device;
  final channels = <(String, String)>[];
  @override
  String get deviceLanguageCode => device;
  @override
  Future<void> updateNotificationChannel(String id, String name) async =>
      channels.add((id, name));
}

class LocalSession implements RadioMediaSession {
  RadioMediaLocalization? labels;
  @override
  void updateLocalization(RadioMediaLocalization labels) =>
      this.labels = labels;
  @override
  Stream<RadioMediaCommand> get commands => const Stream.empty();
  @override
  void showStation(RadioStation station) {}
  @override
  void showFlight() {}
  @override
  void showControls({required bool flying, required bool saved}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LanguagePlatform platform;
  late LocalSession session;
  late FakeAudioService audio;
  late FakeRadioRepository radio;

  Future<ProviderContainer> open(
    WidgetTester tester, {
    Map<String, Object> values = const {},
    String device = 'en',
    MemoryAppPreferences? repository,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'app.welcomeRevision': 2,
      ...values,
    });
    await EasyLocalization.ensureInitialized();
    platform = LanguagePlatform(device);
    session = LocalSession();
    audio = FakeAudioService();
    radio = FakeRadioRepository()..stationToReturn = fip;
    addTearDown(audio.dispose);
    final container = ProviderContainer(
      overrides: [
        appPlatformProvider.overrideWithValue(platform),
        if (repository != null)
          appPreferencesRepositoryProvider.overrideWithValue(repository),
        radioMediaSessionProvider.overrideWithValue(session),
        radioAudioServiceProvider.overrideWithValue(audio),
        radioRepositoryProvider.overrideWithValue(radio),
        favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
        flightTimingProvider.overrideWithValue(fastFlights),
      ],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(welcomeSeenProvider.future));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const StarterApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> english(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('English'),
      find.byType(Scrollable).last,
      const Offset(0, -140),
    );
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
  }

  testWidgets('a saved Italian locale overrides device English on startup', (
    tester,
  ) async {
    final container = await open(tester, values: {'locale': 'it'});
    expect(find.text('Dove andiamo?'), findsOneWidget);
    expect(find.text('Where shall we go?'), findsNothing);
    expect(container.read(activeAppLanguageProvider), AppLanguage.it);
    expect(session.labels!.language, AppLanguage.it);
  });

  testWidgets(
    'switching language updates the live station without restarting audio',
    (tester) async {
      final container = await open(tester, values: {'locale': 'it'});
      await tester.tap(find.byKey(const ValueKey('tune-knob')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('FRANCIA'), findsOneWidget);
      final plays = audio.played.length;
      await english(tester);
      expect(find.text('FRANCE'), findsOneWidget);
      expect(container.read(activeAppLanguageProvider), AppLanguage.en);
      expect(session.labels!.language, AppLanguage.en);
      expect(platform.channels.last.$2, session.labels!.channelName);
      expect(container.read(radioControllerProvider), isA<OnAir>());
      expect(audio.played.length, plays);
      expect(radio.randomCalls, 1);
      expect((await SharedPreferences.getInstance()).getString('locale'), 'en');
      await container.read(radioControllerProvider.notifier).stop();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'a failed language write keeps UI and notification consistent and can be retried',
    (tester) async {
      final repository = MemoryAppPreferences()
        ..revision = 2
        ..language = AppLanguage.it;
      final container = await open(tester, repository: repository);
      repository.failWrites = true;
      await english(tester);
      expect(
        find.text('Impossibile salvare la lingua. Riprova.'),
        findsOneWidget,
      );
      expect(container.read(activeAppLanguageProvider), AppLanguage.it);
      expect(session.labels!.language, AppLanguage.it);
      repository.failWrites = false;
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(container.read(activeAppLanguageProvider), AppLanguage.en);
      expect(repository.language, AppLanguage.en);
    },
  );
}
