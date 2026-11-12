import 'package:freezed_annotation/freezed_annotation.dart';

import '../../journey/domain/station_place.dart';
import '../../journey/domain/travel_leg.dart';
import 'radio_station.dart';

part 'radio_player_state.freezed.dart';

enum PlaybackStatus { idle, tuning, buffering, playing, paused, error }

/// The journey on the display: the flight hides the destination until landing.
enum FlightPhase { grounded, flying, signalLost }

@freezed
class RadioPlayerState with _$RadioPlayerState {
  const RadioPlayerState._();

  const factory RadioPlayerState({
    @Default(PlaybackStatus.idle) PlaybackStatus status,
    RadioStation? station,
    String? errorMessage,
    String? trackTitle,
    @Default(FlightPhase.grounded) FlightPhase flight,

    /// Where the next flight leaves from: the last placed landing.
    @Default(homePlace) StationPlace departure,

    /// The leg that brought the radio to [station].
    TravelLeg? leg,

    /// The last placed legs of this session, oldest first.
    @Default(<TravelLeg>[]) List<TravelLeg> history,
    @Default(0) int trips,
  }) = _RadioPlayerState;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading =>
      status == PlaybackStatus.tuning || status == PlaybackStatus.buffering;
}
