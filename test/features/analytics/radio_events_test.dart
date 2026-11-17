import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/analytics/domain/radio_events.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';

import '../radio/journey_test.dart' show station;

void main() {
  final paris = station(1, lat: 48.86, lon: 2.35);
  const off = RadioSession.off(Journey());
  RadioSession onAir(OnAirPlayback playback, {String? title}) =>
      RadioSession.onAir(
        Journey(landed: paris, trips: 1),
        paris,
        playback: playback,
        trackTitle: title,
      );
  RadioSession flying(
    FlightKind kind, {
    int attempt = 0,
    bool signalLost = false,
  }) => RadioSession.flying(
    const Journey(),
    kind: kind,
    attempt: attempt,
    signalLost: signalLost,
  );
  const forward = FlightKind.forward;

  final cases = <(String, RadioSession, RadioSession, List<AppEvent>)>[
    (
      'a flight from off starts',
      off,
      flying(forward),
      [AppEvent.flightStarted(forward)],
    ),
    (
      'a flight back from on air starts',
      onAir(OnAirPlayback.playing),
      flying(FlightKind.back),
      [AppEvent.flightStarted(FlightKind.back)],
    ),
    (
      'a new turn during a retry starts again',
      flying(forward, attempt: 1),
      flying(forward),
      [AppEvent.flightStarted(forward)],
    ),
    (
      'a lost signal is no event',
      flying(forward),
      flying(forward, signalLost: true),
      [],
    ),
    (
      'a retry is no event',
      flying(forward, signalLost: true),
      flying(forward, attempt: 1),
      [],
    ),
    (
      'a landing counts the attempts',
      flying(forward, attempt: 2),
      onAir(OnAirPlayback.playing),
      [AppEvent.flightLanded(paris, kind: forward, attempts: 3)],
    ),
    (
      'a failed flight counts the attempts',
      flying(FlightKind.reconnect),
      const RadioSession.failed(Journey()),
      [AppEvent.flightFailed(kind: FlightKind.reconnect, attempts: 1)],
    ),
    (
      'a station that breaks on air',
      onAir(OnAirPlayback.playing),
      onAir(OnAirPlayback.broken),
      [AppEvent.playbackBroken(paris)],
    ),
    (
      'a broken station with a new title is no new event',
      onAir(OnAirPlayback.broken),
      onAir(OnAirPlayback.broken, title: 'Song'),
      [],
    ),
    (
      'a pause is no event',
      onAir(OnAirPlayback.playing),
      onAir(OnAirPlayback.paused),
      [],
    ),
    ('switching off is no event', onAir(OnAirPlayback.playing), off, []),
  ];

  for (final (name, before, after, events) in cases) {
    test(name, () => expect(radioEvents(before, after), events));
  }
}
