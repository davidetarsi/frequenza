import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_audio_service.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';

import 'journey_test.dart' show station;

void main() {
  final paris = station(1, lat: 48.86, lon: 2.35);
  final berlin = station(2, code: 'DE', lat: 52.52, lon: 13.4);
  const off = RadioSession.off(Journey());
  final onAir = RadioSession.onAir(
    Journey(landed: paris, trips: 1),
    paris,
    playback: OnAirPlayback.playing,
    trackTitle: 'Song',
  );
  const flying = RadioSession.flying(Journey(), kind: FlightKind.forward);

  group('a flight starts', () {
    test('from off', () {
      expect(
        next(off, const FlightStarted(FlightKind.forward)),
        const RadioSession.flying(Journey(), kind: FlightKind.forward),
      );
    });

    test('a new flight from on air clears station and title', () {
      final session = next(onAir, const FlightStarted(FlightKind.forward));
      expect(
        session,
        RadioSession.flying(
          Journey(trips: 1, previous: [paris]),
          kind: FlightKind.forward,
        ),
      );
    });

    test('back and reconnect flights keep the journey', () {
      for (final kind in [FlightKind.back, FlightKind.reconnect]) {
        expect(
          next(onAir, FlightStarted(kind)),
          RadioSession.flying(onAir.journey, kind: kind),
        );
      }
    });

    test('towards the station on air it is not stacked', () {
      final session = next(
        onAir,
        FlightStarted(FlightKind.forward, target: paris),
      );
      expect(session.journey, onAir.journey);
    });

    test('a flight restarts a flight', () {
      final lost = next(flying, const AttemptFailed(retrying: true));
      expect(
        next(lost, const FlightStarted(FlightKind.back)),
        const RadioSession.flying(Journey(), kind: FlightKind.back),
      );
    });
  });

  group('during a flight', () {
    test('a failed attempt that retries loses the signal', () {
      expect(
        next(flying, const AttemptFailed(retrying: true)),
        const RadioSession.flying(
          Journey(),
          kind: FlightKind.forward,
          signalLost: true,
        ),
      );
    });

    test('the last failed attempt fails the flight', () {
      expect(
        next(flying, const AttemptFailed(retrying: false)),
        const RadioSession.failed(Journey()),
      );
    });

    test('a retry flies again', () {
      final lost = next(flying, const AttemptFailed(retrying: true));
      expect(
        next(lost, const RetryStarted()),
        const RadioSession.flying(
          Journey(),
          kind: FlightKind.forward,
          attempt: 1,
        ),
      );
    });

    test('landing puts the station on air, playing or paused', () {
      for (final paused in [false, true]) {
        expect(
          next(flying, Landed(berlin, paused: paused)),
          RadioSession.onAir(
            const Journey().arrive(berlin, FlightKind.forward),
            berlin,
            playback: paused ? OnAirPlayback.paused : OnAirPlayback.playing,
          ),
        );
      }
    });

    test('a back landing pops the stack', () {
      final back = RadioSession.flying(
        Journey(previous: [paris, berlin]),
        kind: FlightKind.back,
      );
      final session = next(back, Landed(berlin, paused: false));
      expect(session.journey.previous, [paris]);
    });

    test('audio events from the old stream do not touch a flight', () {
      for (final status in [
        PlaybackStatus.idle,
        PlaybackStatus.error,
        PlaybackStatus.buffering,
        PlaybackStatus.playing,
      ]) {
        expect(next(flying, PlaybackChanged(status)), same(flying));
      }
    });

    test('a track title during a flight is dropped', () {
      expect(next(flying, const TrackChanged('Old song')), same(flying));
    });
  });

  group('on air', () {
    test('playback changes keep station and title', () {
      const expected = {
        PlaybackStatus.playing: OnAirPlayback.playing,
        PlaybackStatus.paused: OnAirPlayback.paused,
        PlaybackStatus.buffering: OnAirPlayback.buffering,
        PlaybackStatus.idle: OnAirPlayback.ended,
        PlaybackStatus.error: OnAirPlayback.broken,
      };
      for (final MapEntry(key: status, value: playback) in expected.entries) {
        expect(
          next(onAir, PlaybackChanged(status)),
          RadioSession.onAir(
            onAir.journey,
            paris,
            playback: playback,
            trackTitle: 'Song',
          ),
        );
      }
    });

    test('a track title is shown', () {
      expect(
        next(onAir, const TrackChanged('Next')),
        RadioSession.onAir(
          onAir.journey,
          paris,
          playback: OnAirPlayback.playing,
          trackTitle: 'Next',
        ),
      );
    });

    test('a landing shows the title heard during the flight', () {
      expect(
        next(flying, Landed(berlin, paused: false, trackTitle: 'First song')),
        RadioSession.onAir(
          flying.journey.arrive(berlin, FlightKind.forward),
          berlin,
          playback: OnAirPlayback.playing,
          trackTitle: 'First song',
        ),
      );
    });

    test('a landing without a flight changes nothing', () {
      expect(next(onAir, Landed(berlin, paused: false)), same(onAir));
    });
  });

  test('switching off keeps the journey without its leg', () {
    final landed = next(flying, Landed(berlin, paused: false));
    expect(
      next(landed, const SwitchedOff()),
      RadioSession.off(landed.journey.switchOff()),
    );
    expect(
      next(flying, const SwitchedOff()),
      const RadioSession.off(Journey()),
    );
  });

  test('events on off or failed change nothing', () {
    const failed = RadioSession.failed(Journey());
    for (final session in [off, failed]) {
      for (final RadioEvent event in [
        const PlaybackChanged(PlaybackStatus.playing),
        const TrackChanged('Song'),
        Landed(paris, paused: false),
        const AttemptFailed(retrying: true),
        const RetryStarted(),
      ]) {
        expect(next(session, event), same(session));
      }
    }
  });
}
