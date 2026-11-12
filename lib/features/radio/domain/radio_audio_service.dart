import 'radio_player_state.dart';
import 'radio_station.dart';

abstract interface class RadioAudioService {
  Stream<PlaybackStatus> get playbackStatusStream;
  PlaybackStatus get currentStatus;
  Stream<String?> get trackTitleStream;

  Future<void> startTuningSound();
  Future<void> stopTuningSound();

  /// Starts [station] silently, showing only a flight in the media session.
  Future<void> playStation(RadioStation station);

  /// Makes the started station audible and names it in the media session.
  Future<void> land(RadioStation station);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
