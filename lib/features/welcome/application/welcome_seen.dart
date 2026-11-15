import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'welcome_seen.g.dart';

/// Whether the welcome page has been seen: it shows only on the first launch.
@Riverpod(keepAlive: true)
class WelcomeSeen extends _$WelcomeSeen {
  static const _key = 'app.welcomeSeen';

  /// Unreadable preferences count as seen: bootstrap waits for this value,
  /// and the radio must open whatever happens.
  @override
  Future<bool> build() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_key) ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Seen at once: a failed save only means the welcome comes back on the
  /// next launch, never that the radio stays out of reach.
  Future<void> markSeen() async {
    state = const AsyncData(true);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_key, true);
    } catch (_) {}
  }
}
