import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/presentation/radio_display.dart';
import 'package:frequenza/l10n/locale_keys.g.dart';

import 'journey_test.dart' show station;

void main() {
  final paris = station(1, lat: 48.86, lon: 2.35);
  final journey = const Journey().arrive(paris, FlightKind.forward);
  RadioSession onAir(OnAirPlayback playback) => RadioSession.onAir(
    journey,
    paris,
    playback: playback,
    trackTitle: 'Song',
  );

  test('off waits for the first flight', () {
    final display = RadioDisplay.of(const RadioSession.off(Journey()));
    expect(display.title, const Translated(LocaleKeys.whereTo));
    expect(display.country, const Translated(LocaleKeys.worldAwaits));
    expect(display.statusKey, LocaleKeys.ready);
    expect(display.knobKey, LocaleKeys.powerOn);
    expect(display.phase, FlightPhase.grounded);
    expect(display.knobEnabled, isTrue);
    expect(display.playKeyEnabled, isFalse);
    expect(display.saveEnabled, isFalse);
    expect(display.busy, isFalse);
    expect(display.station, isNull);
    expect(display.leg, isNull);
  });

  test('a flight hides the destination and takes the controls', () {
    final display = RadioDisplay.of(
      RadioSession.flying(journey, kind: FlightKind.forward),
    );
    expect(display.title, const Translated(LocaleKeys.flyingTo));
    expect(display.country, const Verbatim(''));
    expect(display.statusKey, LocaleKeys.searching);
    expect(display.knobKey, LocaleKeys.tuning);
    expect(display.phase, FlightPhase.flying);
    expect(display.flying, isTrue);
    expect(display.busy, isTrue);
    expect(display.nextStopPending, isTrue);
    expect(display.knobEnabled, isFalse);
    expect(display.playKeyEnabled, isFalse);
    expect(display.saveEnabled, isFalse);
    expect(display.station, isNull);
    expect(display.leg, isNull);
  });

  test('a lost signal during the flight says so', () {
    final display = RadioDisplay.of(
      RadioSession.flying(journey, kind: FlightKind.forward, signalLost: true),
    );
    expect(display.title, const Translated(LocaleKeys.signalLost));
    expect(display.phase, FlightPhase.signalLost);
    expect(display.flying, isFalse);
    expect(display.knobKey, LocaleKeys.tuning);
  });

  test('on air shows the station and its controls', () {
    final display = RadioDisplay.of(onAir(OnAirPlayback.playing));
    expect(display.title, Verbatim(paris.name));
    expect(display.country, Verbatim(paris.country));
    expect(display.statusKey, LocaleKeys.playing);
    expect(display.knobKey, LocaleKeys.tune);
    expect(display.phase, FlightPhase.grounded);
    expect(display.playing, isTrue);
    expect(display.playKeyOn, isTrue);
    expect(display.playKeyDown, isFalse);
    expect(display.playKeyEnabled, isTrue);
    expect(display.saveEnabled, isTrue);
    expect(display.song, 'Song');
    expect(display.station, paris);
    expect(display.leg, journey.leg);
    expect(display.busy, isFalse);
  });

  test('paused on air keeps the song and presses the key', () {
    final display = RadioDisplay.of(onAir(OnAirPlayback.paused));
    expect(display.statusKey, LocaleKeys.paused);
    expect(display.playKeyOn, isFalse);
    expect(display.playKeyDown, isTrue);
    expect(display.song, 'Song');
    expect(display.playing, isFalse);
  });

  test(
    'buffering on air keeps the controls but hides the song and the local time',
    () {
      final display = RadioDisplay.of(onAir(OnAirPlayback.buffering));
      expect(display.statusKey, LocaleKeys.connecting);
      expect(display.knobKey, LocaleKeys.tune);
      expect(display.busy, isTrue);
      expect(display.knobEnabled, isTrue);
      expect(display.playKeyOn, isTrue);
      expect(display.playKeyEnabled, isTrue);
      expect(display.song, isNull);
    },
  );

  test('an ended stream is ready again', () {
    final display = RadioDisplay.of(onAir(OnAirPlayback.ended));
    expect(display.statusKey, LocaleKeys.ready);
    expect(display.knobKey, LocaleKeys.tune);
    expect(display.playKeyEnabled, isTrue);
    expect(display.playKeyOn, isFalse);
    expect(display.song, isNull);
  });

  test('a broken stream on air offers retry and keeps the heart', () {
    final display = RadioDisplay.of(onAir(OnAirPlayback.broken));
    expect(display.statusKey, LocaleKeys.stationError);
    expect(display.knobKey, LocaleKeys.retry);
    expect(display.playKeyEnabled, isFalse);
    expect(display.saveEnabled, isTrue);
    expect(display.title, Verbatim(paris.name));
  });

  test('a failed flight offers retry', () {
    final display = RadioDisplay.of(RadioSession.failed(journey));
    expect(display.title, const Translated(LocaleKeys.signalLost));
    expect(display.country, const Translated(LocaleKeys.worldAwaits));
    expect(display.statusKey, LocaleKeys.stationError);
    expect(display.knobKey, LocaleKeys.retry);
    expect(display.phase, FlightPhase.signalLost);
    expect(display.knobEnabled, isTrue);
    expect(display.playKeyEnabled, isFalse);
    expect(display.saveEnabled, isFalse);
    expect(display.station, isNull);
  });

  test('a station without a country says so', () {
    final nowhere = station(9, code: '').copyWith(country: '');
    final display = RadioDisplay.of(
      RadioSession.onAir(
        const Journey(),
        nowhere,
        playback: OnAirPlayback.playing,
      ),
    );
    expect(display.country, const Translated(LocaleKeys.unknownCountry));
  });
}
