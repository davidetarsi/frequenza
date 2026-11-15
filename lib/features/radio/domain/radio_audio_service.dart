import 'radio_station.dart';

/// What the audio engine reports about the stream.
enum PlaybackStatus { idle, buffering, playing, paused, error }

abstract interface class RadioAudioService {
  Stream<PlaybackStatus> get playbackStatusStream;
  PlaybackStatus get currentStatus;
  Stream<String?> get trackTitleStream;

  /// Pauses asked by the system (headphones unplugged, a call…), already
  /// applied to the player: the radio decides what they mean.
  Stream<void> get systemPauses;

  Future<void> startTuningSound();

  /// Stops the static: at once, or with [fade] while a landing station
  /// rises.
  Future<void> stopTuningSound({bool fade = false});

  /// Starts [station] silently, showing only a flight in the media session.
  Future<void> playStation(RadioStation station);

  /// Makes the started station audible and names it in the media session.
  Future<void> land(RadioStation station);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
