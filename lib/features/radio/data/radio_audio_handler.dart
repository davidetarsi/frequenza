import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/radio_station.dart';
import 'radio_media_session.dart';

class RadioAudioHandler extends BaseAudioHandler implements RadioMediaSession {
  RadioAudioHandler(this.player) {
    _events = player.playbackEventStream.listen(
      _publish,
      onError: (Object error) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            playing: false,
          ),
        );
      },
    );
  }

  final AudioPlayer player;
  late final StreamSubscription<PlaybackEvent> _events;

  static const _processingStates = {
    ProcessingState.idle: AudioProcessingState.idle,
    ProcessingState.loading: AudioProcessingState.loading,
    ProcessingState.buffering: AudioProcessingState.buffering,
    ProcessingState.ready: AudioProcessingState.ready,
    ProcessingState.completed: AudioProcessingState.completed,
  };

  void _publish(PlaybackEvent event) {
    // just_audio keeps `playing` true after a stream ends, until pause or stop.
    final playing =
        player.playing &&
        event.processingState != ProcessingState.idle &&
        event.processingState != ProcessingState.completed;
    playbackState.add(
      PlaybackState(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0],
        processingState: _processingStates[event.processingState]!,
        playing: playing,
        updatePosition: event.updatePosition,
        bufferedPosition: event.bufferedPosition,
      ),
    );
  }

  @override
  void showStation(RadioStation station) {
    mediaItem.add(
      MediaItem(
        id: station.id,
        title: station.name,
        artist: station.country,
        artUri: station.faviconUrl != null
            ? Uri.tryParse(station.faviconUrl!)
            : null,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    // play() completes when live playback stops, not when it starts.
    unawaited(player.play().catchError((Object _) {}));
  }

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  Future<void> dispose() => _events.cancel();
}
