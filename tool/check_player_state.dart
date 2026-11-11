// Pure Dart regression check, runnable even without the Flutter test runner.
import 'dart:io';

import 'package:frequenza/features/radio/domain/radio_player_state.dart';

void main() {
  const failed = RadioPlayerState(
    status: PlaybackStatus.error,
    errorMessage: 'Previous failure',
  );
  final retrying = failed.copyWith(
    status: PlaybackStatus.tuning,
    errorMessage: null,
  );
  if (retrying.errorMessage != null) {
    throw StateError('A new tune must clear the previous failure.');
  }
  final preserved = failed.copyWith(status: PlaybackStatus.paused);
  if (preserved.errorMessage != 'Previous failure') {
    throw StateError('An unrelated update must preserve the failure.');
  }
  stdout.writeln('Player state regression checks passed (2).');
}
