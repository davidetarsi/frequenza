import 'package:freezed_annotation/freezed_annotation.dart';

import 'radio_session.dart';
import 'radio_station.dart';
import 'track_title.dart';

part 'radio_bar_state.freezed.dart';

/// What the second line of the bar says.
enum BarNote { tuning, connecting, track, playing, paused, ready, noSignal }

/// The bar's main key.
enum BarKey { pause, play, retry }

/// The player bar under a page opened over the radio: what the radio is
/// doing, told in one line. It invents nothing the radio does not show.
@freezed
sealed class RadioBarState with _$RadioBarState {
  const RadioBarState._();

  /// The radio is off: no bar.
  const factory RadioBarState.hidden() = BarHidden;

  /// Looking for a station: the destination stays hidden until landing.
  const factory RadioBarState.flying() = BarFlying;

  /// A station plays, or is connecting.
  const factory RadioBarState.playing(
    RadioStation station, {
    TrackTitle? track,
    @Default(false) bool connecting,
  }) = BarPlaying;

  /// A station paused, with the last song heard.
  const factory RadioBarState.paused(
    RadioStation station, {
    TrackTitle? track,
  }) = BarPaused;

  /// The stream ended: play reconnects it.
  const factory RadioBarState.stopped(RadioStation station) = BarStopped;

  /// The flight failed or the station broke: the bar offers a new flight.
  const factory RadioBarState.failed() = BarFailed;

  /// The station on air, the only one the heart can save.
  RadioStation? get station => switch (this) {
    BarPlaying(:final station) ||
    BarPaused(:final station) ||
    BarStopped(:final station) => station,
    BarHidden() || BarFlying() || BarFailed() => null,
  };

  /// The song, only while it plays or pauses, as on the radio.
  TrackTitle? get track => switch (this) {
    BarPlaying(:final track, connecting: false) => track,
    BarPaused(:final track) => track,
    _ => null,
  };

  BarNote? get note => switch (this) {
    BarHidden() => null,
    BarFlying() => BarNote.tuning,
    BarPlaying(connecting: true) => BarNote.connecting,
    BarPlaying() || BarPaused() when track != null => BarNote.track,
    BarPlaying() => BarNote.playing,
    BarPaused() => BarNote.paused,
    BarStopped() => BarNote.ready,
    BarFailed() => BarNote.noSignal,
  };

  /// The same key as the radio's play key; a new flight where the radio
  /// retries with the knob.
  BarKey? get mainKey => switch (this) {
    BarHidden() => null,
    BarPlaying() => BarKey.pause,
    BarFlying() || BarPaused() || BarStopped() => BarKey.play,
    BarFailed() => BarKey.retry,
  };

  bool get mainKeyEnabled => switch (this) {
    BarHidden() || BarFlying() => false,
    _ => true,
  };
}

/// | RadioSession        | RadioBarState | Note        | Key   | On  |
/// |---------------------|---------------|-------------|-------|-----|
/// | Off                 | hidden        | —           | —     | —   |
/// | Flying              | flying        | tuning      | play  | no  |
/// | Failed              | failed        | noSignal    | retry | yes |
/// | OnAir(broken)       | failed        | noSignal    | retry | yes |
/// | OnAir(playing)      | playing       | track/playing | pause | yes |
/// | OnAir(buffering)    | playing, connecting | connecting | pause | yes |
/// | OnAir(paused)       | paused        | track/paused | play | yes |
/// | OnAir(ended)        | stopped       | ready       | play  | yes |
RadioBarState radioBarOf(RadioSession session) => switch (session) {
  Off() => const RadioBarState.hidden(),
  Flying() => const RadioBarState.flying(),
  Failed() => const RadioBarState.failed(),
  OnAir(playback: OnAirPlayback.broken) => const RadioBarState.failed(),
  OnAir(:final station, playback: OnAirPlayback.ended) => RadioBarState.stopped(
    station,
  ),
  OnAir(:final station, playback: OnAirPlayback.buffering) =>
    RadioBarState.playing(station, connecting: true),
  OnAir(:final station, playback: OnAirPlayback.paused, :final trackTitle) =>
    RadioBarState.paused(station, track: _track(trackTitle, station)),
  OnAir(:final station, playback: OnAirPlayback.playing, :final trackTitle) =>
    RadioBarState.playing(station, track: _track(trackTitle, station)),
};

TrackTitle? _track(String? title, RadioStation station) =>
    title == null ? null : TrackTitle.parse(title, stationName: station.name);
