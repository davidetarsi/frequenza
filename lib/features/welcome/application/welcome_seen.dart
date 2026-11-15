import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'welcome_seen.g.dart';

/// Whether the welcome page has been seen: it shows only on the first launch.
@Riverpod(keepAlive: true)
class WelcomeSeen extends _$WelcomeSeen {
  static const _key = 'app.welcomeSeen';

  @override
  Future<bool> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_key) ?? false;
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
