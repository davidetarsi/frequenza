import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/application/analytics_consent.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/data/tgram_analytics.dart';
import 'package:frequenza/features/analytics/domain/analytics.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:tgram_analytics/tgram_analytics.dart';

import '../welcome/welcome_seen_test.dart' show BrokenStore;

/// Preferences that read, but cannot write.
class ReadOnlyStore extends SharedPreferencesStorePlatform {
  @override
  Future<Map<String, Object>> getAll() async => {};

  @override
  Future<bool> clear() async => false;

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

const complete = (apiKey: 'proj_test', serverUrl: 'https://analytics.test');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(TGA.reset);

  var requests = <http.Request>[];
  http.Client server({bool fails = false}) {
    requests = [];
    return MockClient((request) async {
      requests.add(request);
      if (fails) throw const SocketException('No route to host');
      return http.Response('{}', 202);
    });
  }

  ProviderContainer container({
    AnalyticsKeys keys = complete,
    http.Client? client,
  }) {
    final container = ProviderContainer(
      overrides: [
        analyticsKeysProvider.overrideWithValue(keys),
        analyticsHttpClientProvider.overrideWithValue(client ?? server()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<Analytics> loaded(ProviderContainer container) async {
    await container.read(analyticsConsentProvider.future);
    return container.read(analyticsProvider);
  }

  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('no key, no analytics', () async {
    for (final keys in [
      (apiKey: '', serverUrl: 'https://analytics.test'),
      (apiKey: 'abc', serverUrl: 'https://analytics.test'),
      (apiKey: 'proj_test', serverUrl: 'http://analytics.test'),
      (apiKey: 'proj_test', serverUrl: ''),
    ]) {
      expect(await loaded(container(keys: keys)), isA<NoAnalytics>());
    }
  });

  test('default is on', () async {
    final c = container();
    expect(await c.read(analyticsConsentProvider.future), isTrue);
    expect(c.read(analyticsProvider), isA<TgramAnalytics>());
  });

  test('consent off, no analytics; on again, analytics', () async {
    SharedPreferences.setMockInitialValues({'app.analyticsOn': false});
    final c = container();
    expect(await loaded(c), isA<NoAnalytics>());
    expect(
      await c.read(analyticsConsentProvider.notifier).select(true),
      isTrue,
    );
    expect(c.read(analyticsProvider), isA<TgramAnalytics>());
  });

  test('switched off mid-session stops events', () async {
    final c = container(client: server());
    (await loaded(c)).track(AppEvent.songCopied());
    await settle();
    expect(requests, hasLength(1));
    expect(requests.single.body, contains('song_copied'));

    await c.read(analyticsConsentProvider.notifier).select(false);
    c.read(analyticsProvider).track(AppEvent.songCopied());
    await settle();
    expect(requests, hasLength(1));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app.analyticsOn'), isFalse);
  });

  test('unreadable preferences mean off', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = BrokenStore();
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    final c = container();
    expect(await c.read(analyticsConsentProvider.future), isFalse);
    expect(c.read(analyticsProvider), isA<NoAnalytics>());
  });

  test('a failing server never throws', () async {
    final c = container(client: server(fails: true));
    final analytics = await loaded(c);
    analytics.describeSession({'locale': 'it'});
    analytics.track(AppEvent.welcomeCompleted());
    await settle();
    expect(requests, isNotEmpty);
  });

  test('the session id is 32 hex chars and stable', () {
    final a = container(), b = container();
    final id = a.read(analyticsSessionIdProvider);
    expect(id, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(a.read(analyticsSessionIdProvider), id);
    expect(b.read(analyticsSessionIdProvider), isNot(id));
  });

  test('keys come complete only with proj_ and https', () {
    expect(analyticsKeysComplete(complete), isTrue);
    expect(
      analyticsKeysComplete((apiKey: 'proj_', serverUrl: 'https://x')),
      isFalse,
    );
  });

  test('an off that cannot be saved still stops events', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = ReadOnlyStore();
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    final c = container(client: server());
    expect(await loaded(c), isA<TgramAnalytics>());

    final saved = c.read(analyticsConsentProvider.notifier).select(false);
    expect(c.read(analyticsProvider), isA<NoAnalytics>());
    expect(await saved, isFalse);

    c.read(analyticsProvider).track(AppEvent.songCopied());
    await settle();
    expect(requests, isEmpty);
    expect(c.read(analyticsProvider), isA<NoAnalytics>());
    expect(analyticsOn(c.read(analyticsConsentProvider)), isFalse);
  });
}
