import 'package:freezed_annotation/freezed_annotation.dart';

import 'radio_station.dart';

part 'radio_player_state.freezed.dart';

enum PlaybackStatus { idle, tuning, buffering, playing, paused, error }

@freezed
class RadioPlayerState with _$RadioPlayerState {
  const RadioPlayerState._();

  const factory RadioPlayerState({
    @Default(PlaybackStatus.idle) PlaybackStatus status,
    RadioStation? station,
    String? errorMessage,
    String? trackTitle,
  }) = _RadioPlayerState;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading =>
      status == PlaybackStatus.tuning || status == PlaybackStatus.buffering;
}
