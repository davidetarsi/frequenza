import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';

part 'welcome_seen.g.dart';

/// Whether this revision of the guide has been seen, including after an update.
@Riverpod(keepAlive: true)
class WelcomeSeen extends _$WelcomeSeen {
  static const _key = 'app.welcomeSeen';
  static const revisionKey = 'app.welcomeRevision';

  // Increment only when a changed guide should be shown again, not per release.
  static const currentRevision = 2;

  /// Unreadable preferences count as seen: bootstrap waits for this value,
  /// and the radio must open whatever happens.
  @override
  Future<bool> build() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return (preferences.getInt(revisionKey) ?? 0) >= currentRevision;
    } catch (_) {
      return true;
    }
  }

  /// Used for launch analytics: seeing a revised guide is not a first install.
  Future<bool> hasSeenAnyGuide() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return (preferences.getBool(_key) ?? false) ||
          (preferences.getInt(revisionKey) ?? 0) > 0;
    } catch (_) {
      return true;
    }
  }

  /// Seen at once: a failed save only means the welcome comes back on the
  /// next launch, never that the radio stays out of reach.
  Future<void> markSeen() async {
    state = const AsyncData(true);
    ref.read(analyticsProvider).track(const AppEvent.welcomeCompleted());
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(revisionKey, currentRevision);
      await preferences.setBool(_key, true);
    } catch (_) {}
  }
}
