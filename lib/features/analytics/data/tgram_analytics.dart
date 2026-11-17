import 'package:http/http.dart' as http;
import 'package:tgram_analytics/tgram_analytics.dart';

import '../domain/analytics.dart';
import '../domain/app_event.dart';

/// Sends the events to a tgram-analytics server. The client is set up on
/// the first event, once per process; every call is guarded.
final class TgramAnalytics implements Analytics {
  TgramAnalytics({
    required this.apiKey,
    required this.serverUrl,
    required this.sessionId,
    this.client,
  });

  final String apiKey;
  final String serverUrl;

  /// Random for every launch and kept only in memory.
  final String sessionId;
  final http.Client? client;

  void _ready() {
    if (!TGA.isInitialized) TGA.init(apiKey, serverUrl, client: client);
  }

  @override
  void track(AppEvent event) {
    try {
      _ready();
      TGA.track(event.name, sessionId, properties: event.properties);
    } catch (_) {
      // Statistics never reach the radio.
    }
  }

  @override
  void describeSession(Map<String, Object> properties) {
    try {
      _ready();
      TGA.identify(sessionId, properties);
    } catch (_) {
      // Statistics never reach the radio.
    }
  }
}
