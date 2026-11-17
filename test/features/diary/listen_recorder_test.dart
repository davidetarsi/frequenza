import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/diary/application/diary_providers.dart';
import 'package:frequenza/features/diary/application/listen_recorder.dart';
import 'package:frequenza/features/diary/domain/diary_repository.dart';
import 'package:frequenza/features/diary/domain/listen.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

import '../analytics/recording_analytics.dart';
import '../radio/journey_test.dart' show station;

/// The log in memory, keeping every write in order.
class MemoryDiary implements DiaryRepository {
  final rows = <int, Listen>{};
  final saved = <String, RadioStation>{};
  final writes = <String>[];
  var failWrites = false;

  /// When set, every write waits for it: a slow disk.
  Completer<void>? gate;

  @override
  Future<int> startListen(
    RadioStation station, {
    required DateTime startedAt,
    required int seconds,
  }) async {
    await gate?.future;
    if (failWrites) throw StateError('Disk full');
    final id = rows.length + 1;
    saved[station.id] = station;
    rows[id] = Listen(
      id: id,
      stationId: station.id,
      countryCode: station.countryCode,
      startedAt: startedAt,
      seconds: seconds,
    );
    writes.add('start ${station.id} $seconds');
    return id;
  }

  @override
  Future<void> setSeconds(int listenId, int seconds) async {
    await gate?.future;
    if (failWrites) throw StateError('Disk full');
    rows[listenId] = rows[listenId]!.copyWith(seconds: seconds);
    writes.add('set $listenId $seconds');
  }

  @override
  Future<List<Listen>> listens() async => rows.values.toList();

  @override
  Future<List<RadioStation>> stations() async => saved.values.toList();

  @override
  Stream<List<Listen>> watchListensSince(DateTime? since) => Stream.value([
    for (final listen in rows.values)
      if (since == null || !listen.startedAt.isBefore(since)) listen,
  ]);
}

/// A radio whose state the test sets by hand.
class ManualRadio extends RadioController {
  @override
  RadioSession build() => const RadioSession.off(Journey());

  void show(RadioSession session) => state = session;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final paris = station(1);
  final playing = RadioSession.onAir(
    Journey(landed: paris, trips: 1),
    paris,
    playback: OnAirPlayback.playing,
  );
  final paused = RadioSession.onAir(
    Journey(landed: paris, trips: 1),
    paris,
    playback: OnAirPlayback.paused,
  );
  final noon = DateTime.utc(2026, 11, 17, 12);

  late MemoryDiary diary;
  late RecordingAnalytics analytics;

  ProviderContainer open(FakeAsync async) {
    diary = MemoryDiary();
    analytics = RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        radioControllerProvider.overrideWith(ManualRadio.new),
        diaryRepositoryProvider.overrideWithValue(diary),
        analyticsProvider.overrideWithValue(analytics),
        diaryClockProvider.overrideWithValue((
          elapsed: () => async.elapsed,
          utcNow: () => noon.add(async.elapsed),
        )),
      ],
    );
    container.read(listenRecorderProvider);
    return container;
  }

  ManualRadio radio(ProviderContainer c) =>
      c.read(radioControllerProvider.notifier) as ManualRadio;

  test('a station played for a minute is saved with 60 seconds', () {
    fakeAsync((async) {
      final c = open(async);
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 60));
      expect(diary.writes, ['start s1 30', 'set 1 60']);
      expect(diary.rows[1]!.startedAt, noon);
      expect(analytics.events, isEmpty);
      c.dispose();
    });
  });

  test('pausing finishes the listen and counts it once', () {
    fakeAsync((async) {
      final c = open(async);
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 45));
      radio(c).show(paused);
      async.flushMicrotasks();
      expect(diary.writes, ['start s1 30', 'set 1 45']);
      expect(analytics.events, [AppEvent.listenEnded(paris, seconds: 45)]);
      async.elapse(const Duration(minutes: 5));
      expect(diary.writes, hasLength(2));
      c.dispose();
    });
  });

  test('a short listen gets its real start time', () {
    fakeAsync((async) {
      final c = open(async);
      async.elapse(const Duration(seconds: 100));
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 12));
      radio(c).show(paused);
      async.flushMicrotasks();
      expect(diary.writes, ['start s1 12', 'set 1 12']);
      expect(diary.rows[1]!.startedAt, noon.add(const Duration(seconds: 100)));
      c.dispose();
    });
  });

  test('going to the background writes the total', () {
    fakeAsync((async) {
      final c = open(async);
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 40));
      final binding = TestWidgetsFlutterBinding.instance;
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        binding.handleAppLifecycleStateChanged(state);
      }
      async.flushMicrotasks();
      expect(diary.writes, ['start s1 30', 'set 1 40']);
      c.dispose();
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        binding.handleAppLifecycleStateChanged(state);
      }
    });
  });

  test('under five seconds no listen_ended', () {
    fakeAsync((async) {
      final c = open(async);
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 3));
      radio(c).show(paused);
      async.flushMicrotasks();
      expect(diary.writes, isEmpty);
      expect(analytics.events, isEmpty);
      c.dispose();
    });
  });

  test('a log that cannot be written never reaches the radio', () {
    fakeAsync((async) {
      final c = open(async);
      diary.failWrites = true;
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 60));
      radio(c).show(paused);
      async.flushMicrotasks();
      expect(diary.writes, isEmpty);
      expect(c.read(radioControllerProvider), paused);
      expect(analytics.events, isEmpty, reason: 'an unsaved listen');
      c.dispose();
    });
  });

  test('a start that failed is saved at the next write', () {
    fakeAsync((async) {
      final c = open(async);
      diary.failWrites = true;
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 30));
      diary.failWrites = false;
      async.elapse(const Duration(seconds: 30));
      expect(diary.writes, ['start s1 60']);
      expect(diary.rows[1]!.startedAt, noon);
      radio(c).show(paused);
      async.flushMicrotasks();
      expect(analytics.events, [AppEvent.listenEnded(paris, seconds: 60)]);
      c.dispose();
    });
  });

  test('a slow disk does not move the start time', () {
    fakeAsync((async) {
      final c = open(async);
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 30));
      diary.gate = Completer<void>();
      radio(c).show(paused);
      radio(c).show(playing);
      async.elapse(const Duration(seconds: 40));
      diary.gate!.complete();
      async.flushMicrotasks();
      expect(diary.writes, ['start s1 30', 'set 1 30', 'start s1 30']);
      expect(diary.rows[2]!.startedAt, noon.add(const Duration(seconds: 30)));
      c.dispose();
    });
  });
}
