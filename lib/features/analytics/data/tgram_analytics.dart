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
    this.details = const {},
    this.client,
  });

  final String apiKey;
  final String serverUrl;

  /// Random, kept only in memory: a new one every time the statistics
  /// start, so an off period separates what came before and after.
  final String sessionId;

  /// The launch details, sent with every event of [sessionId].
  final Map<String, Object> details;
  final http.Client? client;
  var _described = false;

  void _ready() {
    if (!TGA.isInitialized) TGA.init(apiKey, serverUrl, client: client);
    if (!_described && details.isNotEmpty) {
      TGA.identify(sessionId, details);
      _described = true;
    }
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

  /// Drops the details kept for [sessionId].
  void close() {
    try {
      TGA.forget(sessionId);
    } catch (_) {
      // Statistics never reach the radio.
    }
  }
}
