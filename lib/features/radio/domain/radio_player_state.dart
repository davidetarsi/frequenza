import 'radio_station.dart';

enum PlaybackStatus { idle, tuning, buffering, playing, paused, error }

class RadioPlayerState {
  const RadioPlayerState({
    this.status = PlaybackStatus.idle,
    this.station,
    this.errorMessage,
    this.trackTitle,
  });

  final PlaybackStatus status;
  final RadioStation? station;
  final String? errorMessage;
  final String? trackTitle;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading =>
      status == PlaybackStatus.tuning || status == PlaybackStatus.buffering;

  RadioPlayerState copyWith({
    PlaybackStatus? status,
    RadioStation? station,
    String? errorMessage,
    bool clearError = false,
    String? trackTitle,
    bool clearTrackTitle = false,
  }) => RadioPlayerState(
    status: status ?? this.status,
    station: station ?? this.station,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    trackTitle: clearTrackTitle ? null : trackTitle ?? this.trackTitle,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioPlayerState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          station == other.station &&
          errorMessage == other.errorMessage &&
          trackTitle == other.trackTitle;

  @override
  int get hashCode => Object.hash(status, station, errorMessage, trackTitle);

  @override
  String toString() =>
      'RadioPlayerState(status: $status, station: ${station?.name}, error: $errorMessage)';
}
