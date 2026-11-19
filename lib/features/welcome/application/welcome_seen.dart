import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/preferences/application/app_preferences_provider.dart';
import '../../../app/state/latest_save.dart';

import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';

part 'welcome_seen.g.dart';

/// Whether this revision of the guide has been seen, including after an update.
@Riverpod(keepAlive: true)
class WelcomeSeen extends _$WelcomeSeen {
  final _save = LatestSave();

  // Increment only when a changed guide should be shown again, not per release.
  static const currentRevision = 2;

  /// Unreadable preferences count as seen: bootstrap waits for this value,
  /// and the radio must open whatever happens.
  @override
  Future<bool> build() async {
    _save.start(ref);
    final repository = ref.watch(appPreferencesRepositoryProvider);
    try {
      return await repository.loadWelcomeRevision() >= currentRevision;
    } catch (_) {
      return true;
    }
  }

  /// Used for launch analytics: seeing a revised guide is not a first install.
  Future<bool> hasSeenAnyGuide() async {
    final repository = ref.read(appPreferencesRepositoryProvider);
    try {
      return await repository.hasSeenAnyGuide();
    } catch (_) {
      return true;
    }
  }

  /// Seen at once: a failed save only means the welcome comes back on the
  /// next launch, never that the radio stays out of reach.
  Future<void> markSeen() async {
    final repository = ref.read(appPreferencesRepositoryProvider);
    ref.read(analyticsProvider).track(AppEvent.welcomeCompleted());
    // The in-memory flag stays true even on error: leaving the guide must
    // remain possible. AsyncValue still exposes a failed persistence attempt.
    await _save.run(
      shown: const AsyncData(true),
      emit: (value) => state = value,
      action: () async {
        await repository.saveWelcomeRevision(currentRevision);
        return true;
      },
    );
  }
}
