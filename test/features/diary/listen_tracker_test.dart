import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/domain/listen_tracker.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';

import '../radio/journey_test.dart' show station;

void main() {
  final paris = station(1);
  final berlin = station(2, code: 'DE');
  RadioSession onAir(OnAirPlayback playback, [int n = 1]) => RadioSession.onAir(
    Journey(landed: n == 1 ? paris : berlin, trips: 1),
    n == 1 ? paris : berlin,
    playback: playback,
  );
  final playing = onAir(OnAirPlayback.playing);
  const flying = RadioSession.flying(Journey(), kind: FlightKind.forward);
  Duration s(int seconds) => Duration(seconds: seconds);

  late ListenTracker tracker;
  setUp(() => tracker = ListenTracker());

  test('a minute on air starts at the first tick, then updates', () {
    expect(tracker.observe(playing, s(0)), isEmpty);
    expect(tracker.tick(s(30)), [StartListen(paris, since: s(0), seconds: 30)]);
    expect(tracker.tick(s(60)), [const UpdateListen(60)]);
  });

  test('a station change without pause closes one and opens another', () {
    tracker.observe(playing, s(0));
    tracker.tick(s(30));
    expect(tracker.observe(flying, s(40)), [FinishListen(paris, seconds: 40)]);
    expect(tracker.observe(onAir(OnAirPlayback.playing, 2), s(45)), isEmpty);
    expect(tracker.tick(s(75)), [
      StartListen(berlin, since: s(45), seconds: 30),
    ]);
  });

  test('pause and resume make two listens, the pause not counted', () {
    tracker.observe(playing, s(0));
    tracker.tick(s(30));
    expect(tracker.observe(onAir(OnAirPlayback.paused), s(50)), [
      FinishListen(paris, seconds: 50),
    ]);
    expect(tracker.observe(playing, s(500)), isEmpty);
    expect(tracker.tick(s(530)), [
      StartListen(paris, since: s(500), seconds: 30),
    ]);
  });

  test('a listen that ends before any tick is saved whole', () {
    tracker.observe(playing, s(0));
    expect(tracker.observe(flying, s(12)), [
      StartListen(paris, since: s(0), seconds: 12),
      FinishListen(paris, seconds: 12),
    ]);
  });

  test('under five seconds nothing is written', () {
    tracker.observe(playing, s(0));
    expect(tracker.tick(s(4)), isEmpty);
    expect(tracker.observe(flying, s(4)), isEmpty);
  });

  test('a flight is not a listen', () {
    expect(tracker.observe(flying, s(0)), isEmpty);
    expect(tracker.tick(s(60)), isEmpty);
  });

  test('a broken stream ends the listen', () {
    tracker.observe(playing, s(0));
    tracker.tick(s(30));
    expect(tracker.observe(onAir(OnAirPlayback.broken), s(35)), [
      FinishListen(paris, seconds: 35),
    ]);
    expect(tracker.tick(s(90)), isEmpty);
  });

  test('ticks without change write nothing', () {
    tracker.observe(playing, s(0));
    tracker.tick(s(30));
    expect(tracker.tick(s(30)), isEmpty);
    expect(tracker.tick(s(30)), isEmpty);
  });

  test('a new title on the same station is the same listen', () {
    tracker.observe(playing, s(0));
    tracker.tick(s(30));
    final titled = RadioSession.onAir(
      Journey(landed: paris, trips: 1),
      paris,
      playback: OnAirPlayback.playing,
      trackTitle: 'Song',
    );
    expect(tracker.observe(titled, s(40)), isEmpty);
    expect(tracker.tick(s(60)), [const UpdateListen(60)]);
  });

  group('a short network stall', () {
    final buffering = onAir(OnAirPlayback.buffering);
    const reconnecting = RadioSession.flying(
      Journey(),
      kind: FlightKind.reconnect,
    );

    test('on the same station does not split the listen', () {
      tracker.observe(playing, s(0));
      tracker.tick(s(30));
      expect(tracker.observe(buffering, s(40)), isEmpty);
      expect(tracker.tick(s(45)), isEmpty);
      expect(tracker.observe(playing, s(46)), isEmpty);
      expect(tracker.tick(s(60)), [const UpdateListen(54)]);
    });

    test('with a reconnect that lands back keeps the listen', () {
      tracker.observe(playing, s(0));
      tracker.tick(s(30));
      tracker.observe(buffering, s(40));
      expect(tracker.observe(reconnecting, s(50)), isEmpty);
      expect(tracker.observe(playing, s(55)), isEmpty);
      expect(tracker.observe(onAir(OnAirPlayback.paused), s(75)), [
        FinishListen(paris, seconds: 60),
      ]);
    });

    test('longer than thirty seconds ends the listen where it began', () {
      tracker.observe(playing, s(0));
      tracker.tick(s(30));
      tracker.observe(buffering, s(40));
      expect(tracker.tick(s(70)), isEmpty);
      expect(tracker.tick(s(71)), [FinishListen(paris, seconds: 40)]);
      expect(tracker.observe(playing, s(80)), isEmpty);
      expect(tracker.tick(s(110)), [
        StartListen(paris, since: s(80), seconds: 30),
      ]);
    });

    test('followed by another flight ends the listen where it began', () {
      tracker.observe(playing, s(0));
      tracker.tick(s(30));
      tracker.observe(buffering, s(40));
      expect(tracker.observe(flying, s(45)), [
        FinishListen(paris, seconds: 40),
      ]);
    });

    test('followed by a pause ends the listen where it began', () {
      tracker.observe(playing, s(0));
      tracker.tick(s(30));
      tracker.observe(buffering, s(40));
      expect(tracker.observe(onAir(OnAirPlayback.paused), s(42)), [
        FinishListen(paris, seconds: 40),
      ]);
    });
  });
}
