import 'package:frequenza/features/analytics/domain/analytics.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';

/// Keeps every event instead of sending it.
class RecordingAnalytics implements Analytics {
  final events = <AppEvent>[];
  final session = <String, Object>{};

  List<String> get names => [for (final event in events) event.name];

  @override
  void track(AppEvent event) => events.add(event);

  @override
  void describeSession(Map<String, Object> properties) =>
      session.addAll(properties);
}
