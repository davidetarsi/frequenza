import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/domain/radio_station.dart';
import '../domain/listening.dart';
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
  // The controller only runs the effects; [nextListening] decides.
  var listening = const Listening.idle();
  var queue = Future<void>.value();
  int? listenId;
  // A start that could not be written: the next total tries again.
  ({RadioStation station, DateTime startedAt})? unsaved;

  Future<void> save(int seconds) async {
    final diary = ref.read(diaryRepositoryProvider);
    if (listenId case final id?) return diary.setSeconds(id, seconds);
    if (unsaved case (:final station, :final startedAt)) {
      listenId = await diary.startListen(
        station,
        startedAt: startedAt,
        seconds: seconds,
      );
      unsaved = null;
    }
  }

  Future<void> write(ListenWrite change, DateTime utcAt, Duration at) async {
    switch (change) {
      case StartListen(:final station, :final since, :final seconds):
        listenId = null;
        unsaved = (station: station, startedAt: utcAt.subtract(at - since));
        await save(seconds);
      case UpdateListen(:final seconds):
        await save(seconds);
      case FinishListen(:final station, :final seconds):
        try {
          await save(seconds);
        } finally {
          // Counted only once it is in the diary.
          if (listenId != null) {
            ref
                .read(analyticsProvider)
                .track(AppEvent.listenEnded(station, seconds: seconds));
          }
          listenId = null;
          unsaved = null;
        }
    }
  }

  void apply(List<ListenWrite> changes, Duration at) {
    // The system time is read now, not when a slow write gets its turn.
    final utcAt = clock.utcNow();
    for (final change in changes) {
      queue = queue.then((_) => write(change, utcAt, at)).catchError((
        Object error,
      ) {
        // The diary loses this write; the radio goes on.
        if (kDebugMode) debugPrint('Diary write failed: $error');
      });
    }
  }

  void step(ListenEvent event) {
    final result = nextListening(listening, event);
    listening = result.state;
    apply(result.writes, event.at);
  }

  void tick() => step(ClockTicked(at: clock.elapsed()));

  ref.listen(
    radioControllerProvider,
    (_, session) => step(RadioChanged(session, at: clock.elapsed())),
    fireImmediately: true,
  );
  final timer = Timer.periodic(diaryWriteEvery, (_) => tick());
  final lifecycle = AppLifecycleListener(onPause: tick);
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
}
