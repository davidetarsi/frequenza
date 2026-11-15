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
sealed class RadioEvent {
  const RadioEvent();
}

final class FlightStarted extends RadioEvent {
  const FlightStarted(this.kind, {this.target});
  final FlightKind kind;

  /// The station chosen, when the flight is not random.
  final RadioStation? target;
}

final class AttemptFailed extends RadioEvent {
  const AttemptFailed({required this.retrying});
  final bool retrying;
}

final class RetryStarted extends RadioEvent {
  const RetryStarted();
}

final class Landed extends RadioEvent {
  const Landed(this.station, {required this.paused});
  final RadioStation station;

  /// A pause that arrived during the flight.
  final bool paused;
}

final class PlaybackChanged extends RadioEvent {
  const PlaybackChanged(this.status);
  final PlaybackStatus status;
}

final class TrackChanged extends RadioEvent {
  const TrackChanged(this.title);
  final String? title;
}

final class SwitchedOff extends RadioEvent {
  const SwitchedOff();
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
/// | Flying   | Landed(station, paused)      | OnAir, playing or paused                  |
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
        Landed(:final station, :final paused),
      ) =>
        RadioSession.onAir(
          journey.arrive(station, kind),
          station,
          playback: paused ? OnAirPlayback.paused : OnAirPlayback.playing,
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
