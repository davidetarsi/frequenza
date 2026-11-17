import 'app_event.dart';

/// Where the app's anonymous events go. Never throws: the radio does not
/// wait for it and does not notice when it fails.
abstract interface class Analytics {
  void track(AppEvent event);
}

/// Statistics off: nothing is sent, nothing is kept.
final class NoAnalytics implements Analytics {
  const NoAnalytics();

  @override
  void track(AppEvent event) {}
}
