import 'radio_station.dart';

enum PlaybackStatus { idle, tuning, buffering, playing, paused, error }

class RadioPlayerState {
  const RadioPlayerState({
    this.status = PlaybackStatus.idle,
    this.station,
    this.errorMessage,
  });

  final PlaybackStatus status;
  final RadioStation? station;
  final String? errorMessage;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading =>
      status == PlaybackStatus.tuning || status == PlaybackStatus.buffering;

  RadioPlayerState copyWith({
    PlaybackStatus? status,
    RadioStation? station,
    String? errorMessage,
  }) => RadioPlayerState(
    status: status ?? this.status,
    station: station ?? this.station,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioPlayerState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          station == other.station &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, station, errorMessage);

  @override
  String toString() =>
      'RadioPlayerState(status: $status, station: ${station?.name}, error: $errorMessage)';
}
