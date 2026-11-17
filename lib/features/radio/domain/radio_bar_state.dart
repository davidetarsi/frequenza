import 'package:freezed_annotation/freezed_annotation.dart';

import 'radio_session.dart';
import 'radio_station.dart';
import 'track_title.dart';

part 'radio_bar_state.freezed.dart';

/// The player bar under a page opened over the radio: what the radio is
/// doing, told in one line. It invents nothing the radio does not show.
@freezed
sealed class RadioBarState with _$RadioBarState {
  /// The radio is off: no bar.
  const factory RadioBarState.hidden() = BarHidden;

  /// Looking for a station: the destination stays hidden until landing.
  const factory RadioBarState.flying() = BarFlying;

  /// A station on air, playing or not; [track] only while it plays or
  /// pauses, as on the radio.
  const factory RadioBarState.onAir(
    RadioStation station, {
    TrackTitle? track,
    required bool playing,
    required bool connecting,
  }) = BarOnAir;

  /// The flight failed or the station broke: the bar offers a new flight.
  const factory RadioBarState.failed() = BarFailed;
}

/// | RadioSession                    | RadioBarState              |
/// |---------------------------------|----------------------------|
/// | Off                             | hidden                     |
/// | Flying                          | flying                     |
/// | Failed                          | failed                     |
/// | OnAir(broken)                   | failed                     |
/// | OnAir(playing, paused, ...)     | onAir, track if playing or |
/// |                                 | paused, connecting if      |
/// |                                 | buffering                  |
RadioBarState radioBarOf(RadioSession session) => switch (session) {
  Off() => const RadioBarState.hidden(),
  Flying() => const RadioBarState.flying(),
  Failed() => const RadioBarState.failed(),
  OnAir(playback: OnAirPlayback.broken) => const RadioBarState.failed(),
  OnAir(:final station, :final playback, :final trackTitle) =>
    RadioBarState.onAir(
      station,
      track:
          trackTitle != null &&
              (playback == OnAirPlayback.playing ||
                  playback == OnAirPlayback.paused)
          ? TrackTitle.parse(trackTitle, stationName: station.name)
          : null,
      playing: playback == OnAirPlayback.playing,
      connecting: playback == OnAirPlayback.buffering,
    ),
};
