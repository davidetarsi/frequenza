import 'package:freezed_annotation/freezed_annotation.dart';

import 'journey.dart';
import 'radio_audio_service.dart';
import 'radio_station.dart';

part 'radio_session.freezed.dart';

/// How the station on air sounds.
enum OnAirPlayback { playing, paused, buffering, ended, broken }

/// The radio, one state at a time. Only [OnAir] has a station.
@freezed
sealed class RadioSession with _$RadioSession {
  const factory RadioSession.off(Journey journey) = Off;

  /// Looking for a station: the destination stays hidden until landing.
  const factory RadioSession.flying(
    Journey journey, {
    required FlightKind kind,
    @Default(0) int attempt,
    @Default(false) bool signalLost,
  }) = Flying;

  const factory RadioSession.onAir(
    Journey journey,
    RadioStation station, {
    required OnAirPlayback playback,
    String? trackTitle,
  }) = OnAir;

  /// Every attempt of the last flight failed.
  const factory RadioSession.failed(Journey journey) = Failed;
}

/// What happened to the radio.
@freezed
sealed class RadioEvent with _$RadioEvent {
  const factory RadioEvent.flightStarted(
    FlightKind kind, {
    RadioStation? target,
  }) = FlightStarted;
  const factory RadioEvent.attemptFailed({required bool retrying}) =
      AttemptFailed;
  const factory RadioEvent.retryStarted() = RetryStarted;

  /// Includes a pause/title received during flight before landing.
  const factory RadioEvent.landed(
    RadioStation station, {
    required bool paused,
    String? trackTitle,
  }) = Landed;
  const factory RadioEvent.playbackChanged(PlaybackStatus status) =
      PlaybackChanged;
  const factory RadioEvent.trackChanged(String? title) = TrackChanged;
  const factory RadioEvent.switchedOff() = SwitchedOff;
}

/// The radio's transitions. Every other pair keeps the same session.
///
/// | From     | Event                        | To                                        |
/// |----------|------------------------------|-------------------------------------------|
/// | any      | FlightStarted(kind, target)  | Flying; a forward flight leaves the       |
/// |          |                              | station on air behind                     |
/// | Flying   | AttemptFailed(retrying)      | Flying, signal lost                       |
/// | Flying   | AttemptFailed(not retrying)  | Failed                                    |
/// | Flying   | RetryStarted                 | Flying, next attempt                      |
/// | Flying   | Landed(station, paused,      | OnAir, playing or paused, with the title  |
/// |          |   trackTitle)                | heard during the flight                   |
/// | OnAir    | PlaybackChanged(status)      | OnAir with that playback                  |
/// | OnAir    | TrackChanged(title)          | OnAir with that title                     |
/// | any      | SwitchedOff                  | Off, without the last leg                 |
RadioSession next(RadioSession session, RadioEvent event) =>
    switch ((session, event)) {
      (_, FlightStarted(:final kind, :final target)) => RadioSession.flying(
        kind == FlightKind.forward
            ? session.journey.leave(target: target)
            : session.journey,
        kind: kind,
      ),
      (final Flying flight, AttemptFailed(retrying: true)) => flight.copyWith(
        signalLost: true,
      ),
      (Flying(:final journey), AttemptFailed(retrying: false)) =>
        RadioSession.failed(journey),
      (final Flying flight, RetryStarted()) => flight.copyWith(
        attempt: flight.attempt + 1,
        signalLost: false,
      ),
      (
        Flying(:final journey, :final kind),
        Landed(:final station, :final paused, :final trackTitle),
      ) =>
        RadioSession.onAir(
          journey.arrive(station, kind),
          station,
          playback: paused ? OnAirPlayback.paused : OnAirPlayback.playing,
          trackTitle: trackTitle,
        ),
      (final OnAir onAir, PlaybackChanged(:final status)) => onAir.copyWith(
        playback: switch (status) {
          PlaybackStatus.playing => OnAirPlayback.playing,
          PlaybackStatus.paused => OnAirPlayback.paused,
          PlaybackStatus.buffering => OnAirPlayback.buffering,
          PlaybackStatus.idle => OnAirPlayback.ended,
          PlaybackStatus.error => OnAirPlayback.broken,
        },
      ),
      (final OnAir onAir, TrackChanged(:final title)) => onAir.copyWith(
        trackTitle: title,
      ),
      (_, SwitchedOff()) => RadioSession.off(session.journey.switchOff()),
      _ => session,
    };
