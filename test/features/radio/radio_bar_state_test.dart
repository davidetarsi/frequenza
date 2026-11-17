import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_bar_state.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/presentation/radio_display.dart';

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
  const song = 'Ana Moura - Desfado';

  final sessions = <RadioSession>[
    const RadioSession.off(Journey()),
    const RadioSession.flying(Journey(), kind: FlightKind.forward),
    const RadioSession.failed(Journey()),
    for (final playback in OnAirPlayback.values) onAir(playback, title: song),
  ];

  // | RadioSession     | state    | note       | key    | on  | track |
  final table = <(RadioSession, Type, BarNote?, BarKey?, bool, bool)>[
    (sessions[0], BarHidden, null, null, false, false),
    (sessions[1], BarFlying, BarNote.tuning, BarKey.play, false, false),
    (sessions[2], BarFailed, BarNote.noSignal, BarKey.retry, true, false),
    (
      onAir(OnAirPlayback.playing, title: song),
      BarPlaying,
      BarNote.track,
      BarKey.pause,
      true,
      true,
    ),
    (
      onAir(OnAirPlayback.playing),
      BarPlaying,
      BarNote.playing,
      BarKey.pause,
      true,
      false,
    ),
    (
      onAir(OnAirPlayback.buffering, title: song),
      BarPlaying,
      BarNote.connecting,
      BarKey.pause,
      true,
      false,
    ),
    (
      onAir(OnAirPlayback.paused, title: song),
      BarPaused,
      BarNote.track,
      BarKey.play,
      true,
      true,
    ),
    (
      onAir(OnAirPlayback.paused),
      BarPaused,
      BarNote.paused,
      BarKey.play,
      true,
      false,
    ),
    (
      onAir(OnAirPlayback.ended),
      BarStopped,
      BarNote.ready,
      BarKey.play,
      true,
      false,
    ),
    (
      onAir(OnAirPlayback.broken),
      BarFailed,
      BarNote.noSignal,
      BarKey.retry,
      true,
      false,
    ),
  ];

  for (final (session, type, note, key, enabled, track) in table) {
    test('$session → $type', () {
      final state = radioBarOf(session);
      expect(state.runtimeType.toString(), contains('$type'));
      expect(state.note, note);
      expect(state.mainKey, key);
      expect(state.mainKeyEnabled, enabled);
      expect(state.track != null, track);
    });
  }

  test('the song is the clean title', () {
    final state = radioBarOf(onAir(OnAirPlayback.playing, title: song));
    expect(state.track?.display, 'Ana Moura — Desfado');
  });

  test('the main key does what the radio play key does', () {
    for (final session in sessions) {
      final state = radioBarOf(session);
      if (state is BarHidden || state is BarFailed) continue;
      final display = RadioDisplay.of(session);
      expect(state.mainKeyEnabled, display.playKeyEnabled, reason: '$session');
      expect(
        state.mainKey == BarKey.pause,
        display.playKeyOn,
        reason: '$session',
      );
    }
  });

  test('only a station on air can be saved', () {
    for (final session in sessions) {
      final state = radioBarOf(session);
      expect(
        state.station != null,
        session is OnAir && session.playback != OnAirPlayback.broken,
        reason: '$session',
      );
    }
  });
}
