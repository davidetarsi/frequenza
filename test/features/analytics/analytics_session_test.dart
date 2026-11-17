import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/links/app_version.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/application/analytics_session.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'recording_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the launch describes itself, then opens', () async {
    SharedPreferences.setMockInitialValues({'app.themeMode': 'dark'});
    final analytics = RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        appVersionProvider.overrideWith((ref) async => '0.4.0+5'),
      ],
    );
    addTearDown(container.dispose);

    await describeAnalyticsSession(container, firstOpen: true, locale: 'it');

    expect(analytics.session, {
      'app_version': '0.4.0+5',
      'locale': 'it',
      'theme': 'dark',
      'android_sdk': 0,
    });
    expect(analytics.events, [AppEvent.appOpened(firstOpen: true)]);
  });
}
