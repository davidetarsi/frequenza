import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../radio/application/radio_controller.dart';
import '../domain/welcome_session.dart';
import 'welcome_seen.dart';

part 'welcome_controller.g.dart';

/// Owns the guide's effects; the domain transition decides every state change.
/// Auto-disposal ties this session to the guide, not to the lifetime of the app.
@riverpod
class WelcomeController extends _$WelcomeController {
  Object? _generation;

  @override
  WelcomeSession build() {
    final generation = Object();
    _generation = generation;
    ref.onDispose(() {
      if (_generation == generation) _generation = null;
    });
    return const WelcomeSession.radio();
  }

  void advance() => _apply(const WelcomeEvent.advance());
  void dismiss() => _apply(const WelcomeEvent.dismiss());

  void _apply(WelcomeEvent event) {
    final before = state;
    final after = nextWelcome(before, event);
    if (identical(before, after)) return;
    state = after;
    if (before is WelcomeRadio && after is WelcomeFavorites) {
      unawaited(ref.read(radioControllerProvider.notifier).tuneRandom());
    }
    if (after is WelcomeClosing) unawaited(_recordCompletion(after));
  }

  Future<void> _recordCompletion(WelcomeClosing closing) async {
    final generation = _generation;
    await ref.read(welcomeSeenProvider.notifier).markSeen();
    if (generation == null || _generation != generation) return;
    if (state == closing) _apply(const WelcomeEvent.completionRecorded());
  }
}
