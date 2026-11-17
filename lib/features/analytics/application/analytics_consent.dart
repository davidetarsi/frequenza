import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/state/latest_save.dart';

part 'analytics_consent.g.dart';

/// Whether the statistics may be sent now: not while a choice is being
/// saved, and not when saving it failed, since the person may just have
/// turned them off.
bool analyticsOn(AsyncValue<bool> consent) =>
    !consent.isLoading && !consent.hasError && (consent.valueOrNull ?? false);

/// Whether the anonymous statistics are on: on unless turned off in the
/// settings, off when the preferences cannot be read.
@Riverpod(keepAlive: true)
class AnalyticsConsent extends _$AnalyticsConsent {
  static const _key = 'app.analyticsOn';
  final _save = LatestSave();

  @override
  Future<bool> build() async {
    _save.start(ref);
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_key) ?? true;
    } catch (_) {
      return false;
    }
  }

  /// False when the choice could not be saved.
  Future<bool> select(bool on) async {
    if (state.isLoading) return true;
    // After a failed save the old value is not the one in force: save again.
    if (!state.hasError && state.valueOrNull == on) return true;
    final result = await _save.run(
      shown: state,
      emit: (value) => state = value,
      action: () async {
        final preferences = await SharedPreferences.getInstance();
        if (!await preferences.setBool(_key, on)) {
          throw StateError('Statistics choice could not be saved');
        }
        return on;
      },
    );
    return !result.hasError;
  }
}
