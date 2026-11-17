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

/// This launch, as 32 random hex characters. Never stored.
@Riverpod(keepAlive: true)
String analyticsSessionId(Ref ref) {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// Where the events go: nowhere without the keys, or with the statistics
/// off or not yet read.
@Riverpod(keepAlive: true)
Analytics analytics(Ref ref) {
  final keys = ref.watch(analyticsKeysProvider);
  final on = analyticsOn(ref.watch(analyticsConsentProvider));
  if (!on || !analyticsKeysComplete(keys)) return const NoAnalytics();
  return TgramAnalytics(
    apiKey: keys.apiKey,
    serverUrl: keys.serverUrl,
    sessionId: ref.watch(analyticsSessionIdProvider),
    client: ref.watch(analyticsHttpClientProvider),
  );
}
