import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/tgram_analytics.dart';
import '../domain/analytics.dart';
import 'analytics_consent.dart';

part 'analytics_providers.g.dart';

/// The project key and the server, given when the app is built. Only the
/// production build has them.
typedef AnalyticsKeys = ({String apiKey, String serverUrl});

bool analyticsKeysComplete(AnalyticsKeys keys) =>
    keys.apiKey.startsWith('proj_') &&
    keys.apiKey.length > 'proj_'.length &&
    keys.serverUrl.startsWith('https://');

@Riverpod(keepAlive: true)
AnalyticsKeys analyticsKeys(Ref ref) => (
  apiKey: const String.fromEnvironment('TGA_API_KEY'),
  serverUrl: const String.fromEnvironment('TGA_SERVER_URL'),
);

/// The HTTP client for the events; the package's own when null.
@Riverpod(keepAlive: true)
http.Client? analyticsHttpClient(Ref ref) => null;

/// A launch code: 32 random hex characters, never stored.
String newAnalyticsSessionId() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// The launch details (version, language, theme, Android), sent with
/// every event; empty until the launch has been described.
@Riverpod(keepAlive: true)
class AnalyticsSessionDetails extends _$AnalyticsSessionDetails {
  @override
  Map<String, Object> build() => const {};

  void describe(Map<String, Object> details) =>
      state = Map.unmodifiable(details);
}

/// Where the events go: nowhere without the keys, or with the statistics
/// off or not yet read. Every time they start, a new launch code.
@Riverpod(keepAlive: true)
Analytics analytics(Ref ref) {
  final keys = ref.watch(analyticsKeysProvider);
  final on = analyticsOn(ref.watch(analyticsConsentProvider));
  if (!on || !analyticsKeysComplete(keys)) return const NoAnalytics();
  final analytics = TgramAnalytics(
    apiKey: keys.apiKey,
    serverUrl: keys.serverUrl,
    sessionId: newAnalyticsSessionId(),
    details: ref.watch(analyticsSessionDetailsProvider),
    client: ref.watch(analyticsHttpClientProvider),
  );
  ref.onDispose(analytics.close);
  return analytics;
}
