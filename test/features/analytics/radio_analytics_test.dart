import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/application/radio_analytics.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/flight_timing.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_notification.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';

import '../favorites/favorites_test.dart' show MemoryFavorites;
import '../radio/radio_audio_handler_test.dart' show EventPlayer;
import '../radio/radio_controller_test.dart';
import '../radio/radio_notification_test.dart' show numbered;
import 'recording_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RadioAudioHandler handler;
  late FakeRadioRepository repository;
  late FakeAudioService audio;
  late RecordingAnalytics analytics;
  late ProviderContainer container;

  setUp(() async {
    handler = RadioAudioHandler(
      EventPlayer(),
      flightTitle: 'Frequenza',
      flightSubtitle: 'In volo…',
      saveLabel: 'Salva',
      removeLabel: 'Togli',
    );
    repository = FakeRadioRepository();
    audio = FakeAudioService();
    analytics = RecordingAnalytics();
    container = ProviderContainer(
      overrides: [
        radioAudioHandlerProvider.overrideWithValue(handler),
        radioRepositoryProvider.overrideWithValue(repository),
        radioAudioServiceProvider.overrideWithValue(audio),
        favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
        analyticsProvider.overrideWithValue(analytics),
        flightTimingProvider.overrideWithValue(
          const FlightTiming(
            minimum: Duration(milliseconds: 20),
            attemptTimeout: Duration(milliseconds: 300),
            signalLostPause: Duration(milliseconds: 10),
          ),
        ),
      ],
    );
    container.read(radioNotificationProvider);
    container.read(radioAnalyticsProvider);
    await container.read(favoritesProvider.future);
  });
  tearDown(() async {
    container.dispose();
    await handler.dispose();
    await audio.dispose();
  });

  test('a random flight that lands records started and landed once', () async {
    repository.stationToReturn = numbered(1);
    await container.read(radioControllerProvider.notifier).tuneRandom();
    expect(analytics.names, ['flight_started', 'flight_landed']);
    expect(analytics.events.last.properties['station'], 'Radio 1');
  });

  test('a flight from the notification counts once', () async {
    repository.stationToReturn = numbered(1);
    await handler.skipToNext();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(analytics.names, ['flight_started', 'flight_landed']);
  });
}
