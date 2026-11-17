import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_bar_state.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';

import 'journey_test.dart' show station;

void main() {
  final paris = station(1);
  RadioSession onAir(OnAirPlayback playback, {String? title}) =>
      RadioSession.onAir(
        Journey(landed: paris, trips: 1),
        paris,
        playback: playback,
        trackTitle: title,
      );

  final cases = <(String, RadioSession, RadioBarState)>[
    (
      'off hides the bar',
      const RadioSession.off(Journey()),
      const RadioBarState.hidden(),
    ),
    (
      'a flight hides the destination',
      const RadioSession.flying(Journey(), kind: FlightKind.forward),
      const RadioBarState.flying(),
    ),
    (
      'a failed flight',
      const RadioSession.failed(Journey()),
      const RadioBarState.failed(),
    ),
    (
      'a broken station is a failure',
      onAir(OnAirPlayback.broken),
      const RadioBarState.failed(),
    ),
  ];
  for (final (name, session, state) in cases) {
    test(name, () => expect(radioBarOf(session), state));
  }

  test('on air with a title carries the clean song', () {
    final state =
        radioBarOf(onAir(OnAirPlayback.playing, title: 'Ana Moura - Desfado'))
            as BarOnAir;
    expect(state.station, paris);
    expect(state.track?.display, 'Ana Moura — Desfado');
    expect(state.playing, isTrue);
    expect(state.connecting, isFalse);
  });

  test('paused keeps the song; buffering is connecting', () {
    final paused =
        radioBarOf(onAir(OnAirPlayback.paused, title: 'Ana Moura - Desfado'))
            as BarOnAir;
    expect(paused.playing, isFalse);
    expect(paused.track, isNotNull);
    final buffering =
        radioBarOf(onAir(OnAirPlayback.buffering, title: 'Ana Moura - Desfado'))
            as BarOnAir;
    expect(buffering.connecting, isTrue);
    expect(buffering.track, isNull);
  });

  test('an ended stream is on air, not playing', () {
    final ended = radioBarOf(onAir(OnAirPlayback.ended)) as BarOnAir;
    expect(ended.playing, isFalse);
    expect(ended.connecting, isFalse);
  });
}
