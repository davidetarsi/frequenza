import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import '../../radio/application/radio_controller.dart';
import '../domain/listen_tracker.dart';
import 'diary_providers.dart';

part 'listen_recorder.g.dart';

/// A monotonic clock for durations, and the system clock in UTC, read
/// once per listen for its start.
typedef DiaryClock = ({
  Duration Function() elapsed,
  DateTime Function() utcNow,
});

@Riverpod(keepAlive: true)
DiaryClock diaryClock(Ref ref) {
  final stopwatch = Stopwatch()..start();
  return (
    elapsed: () => stopwatch.elapsed,
    utcNow: () => DateTime.now().toUtc(),
  );
}

/// How often the total of the listen on air is written.
const diaryWriteEvery = Duration(seconds: 30);

/// Watches the radio from outside and writes the log: every 30 seconds,
/// when the app goes to the background, and when a listen ends. The
/// writes go one at a time, in order; a failed write never reaches the
/// radio.
@Riverpod(keepAlive: true)
void listenRecorder(Ref ref) {
  final clock = ref.watch(diaryClockProvider);
  final tracker = ListenTracker();
  var queue = Future<void>.value();
  int? listenId;

  Future<void> write(ListenWrite change, Duration at) async {
    final diary = ref.read(diaryRepositoryProvider);
    switch (change) {
      case StartListen(:final station, :final since, :final seconds):
        listenId = null;
        listenId = await diary.startListen(
          station,
          startedAt: clock.utcNow().subtract(at - since),
          seconds: seconds,
        );
      case UpdateListen(:final seconds):
        if (listenId case final id?) await diary.setSeconds(id, seconds);
      case FinishListen(:final station, :final seconds):
        ref
            .read(analyticsProvider)
            .track(AppEvent.listenEnded(station, seconds: seconds));
        final id = listenId;
        listenId = null;
        if (id != null) await diary.setSeconds(id, seconds);
    }
  }

  void apply(List<ListenWrite> changes, Duration at) {
    for (final change in changes) {
      queue = queue.then((_) => write(change, at)).catchError((Object _) {
        // The diary loses this write; the radio goes on.
      });
    }
  }

  void tick() {
    final now = clock.elapsed();
    apply(tracker.tick(now), now);
  }

  ref.listen(radioControllerProvider, (_, session) {
    final now = clock.elapsed();
    apply(tracker.observe(session, now), now);
  }, fireImmediately: true);
  final timer = Timer.periodic(diaryWriteEvery, (_) => tick());
  final lifecycle = AppLifecycleListener(onPause: tick);
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
}
