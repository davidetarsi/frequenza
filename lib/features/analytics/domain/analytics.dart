import 'app_event.dart';

/// Where the app's anonymous events go. Never throws: the radio does not
/// wait for it and does not notice when it fails.
abstract interface class Analytics {
  void track(AppEvent event);

  /// Properties of this launch, sent with every later event.
  void describeSession(Map<String, Object> properties);
}

/// Statistics off: nothing is sent, nothing is kept.
final class NoAnalytics implements Analytics {
  const NoAnalytics();

  @override
  void track(AppEvent event) {}

  @override
  void describeSession(Map<String, Object> properties) {}
}
