import 'radio_player_state.dart';
import 'radio_station.dart';

abstract interface class RadioAudioService {
  Stream<PlaybackStatus> get playbackStatusStream;
  PlaybackStatus get currentStatus;
  Stream<String?> get trackTitleStream;

  Future<void> startTuningSound();
  Future<void> stopTuningSound();
  Future<void> playStation(RadioStation station);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
