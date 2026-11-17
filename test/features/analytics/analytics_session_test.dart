import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/links/app_version.dart';
import 'package:frequenza/features/analytics/application/analytics_consent.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/application/analytics_session.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../radio/radio_controller_test.dart';
import '../radio/radio_notification_test.dart' show numbered;
import 'recording_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the launch is described and counted before any flight', () async {
    SharedPreferences.setMockInitialValues({'app.themeMode': 'dark'});
    final analytics = RecordingAnalytics();
    final repository = FakeRadioRepository()..stationToReturn = numbered(1);
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        appVersionProvider.overrideWith((ref) async => '0.4.0+5'),
        radioRepositoryProvider.overrideWithValue(repository),
        radioAudioServiceProvider.overrideWithValue(audio),
      ],
    );
    addTearDown(container.dispose);

    await startAnalytics(container, firstOpen: true, locale: 'it');

    expect(container.read(analyticsConsentProvider).hasValue, isTrue);
    expect(container.read(analyticsSessionDetailsProvider), {
      'app_version': '0.4.0+5',
      'locale': 'it',
      'theme': 'dark',
      'android_sdk': 0,
    });
    expect(analytics.events, [AppEvent.appOpened(firstOpen: true)]);

    await container.read(radioControllerProvider.notifier).tuneRandom();
    expect(analytics.names, ['app_opened', 'flight_started', 'flight_landed']);
  });
}
