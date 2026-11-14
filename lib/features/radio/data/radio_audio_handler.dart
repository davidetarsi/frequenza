import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/radio_station.dart';
import 'radio_media_session.dart';

class RadioAudioHandler extends BaseAudioHandler implements RadioMediaSession {
  RadioAudioHandler(
    this.player, {
    required this.flightTitle,
    required this.flightSubtitle,
    required this.saveLabel,
    required this.removeLabel,
    this.fallbackArt,
  }) {
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
  final String flightTitle, flightSubtitle, saveLabel, removeLabel;

  /// Frequenza's logo, for stations without one.
  final Uri? fallbackArt;
  late final StreamSubscription<PlaybackEvent> _events;
  final _commands = StreamController<RadioMediaCommand>.broadcast();
  PlaybackEvent? _event;
  bool _flying = false, _saved = false;

  static const favoriteAction = 'favorite';

  static const _processingStates = {
    ProcessingState.idle: AudioProcessingState.idle,
    ProcessingState.loading: AudioProcessingState.loading,
    ProcessingState.buffering: AudioProcessingState.buffering,
    ProcessingState.ready: AudioProcessingState.ready,
    ProcessingState.completed: AudioProcessingState.completed,
  };

  void _publish(PlaybackEvent event) {
    _event = event;
    _republish();
  }

  void _republish() {
    final event = _event;
    final processing = event?.processingState ?? ProcessingState.idle;
    // just_audio keeps `playing` true after a stream ends, until pause or stop.
    final playing =
        player.playing &&
        processing != ProcessingState.idle &&
        processing != ProcessingState.completed;
    final playPause = playing ? MediaControl.pause : MediaControl.play;
    final controls = _flying
        ? [playPause]
        : [
            MediaControl.skipToPrevious,
            playPause,
            MediaControl.skipToNext,
            MediaControl.custom(
              androidIcon: _saved
                  ? 'drawable/ic_favorite'
                  : 'drawable/ic_favorite_border',
              label: _saved ? removeLabel : saveLabel,
              name: favoriteAction,
            ),
          ];
    final compact = _flying ? const [0] : const [0, 1, 2];
    playbackState.add(
      PlaybackState(
        controls: controls,
        androidCompactActionIndices: compact,
        processingState: _processingStates[processing]!,
        playing: playing,
        updatePosition: event?.updatePosition ?? Duration.zero,
        bufferedPosition: event?.bufferedPosition ?? Duration.zero,
      ),
    );
  }

  @override
  Stream<RadioMediaCommand> get commands => _commands.stream;

  @override
  void showControls({required bool saved}) {
    _flying = false;
    _saved = saved;
    _republish();
  }

  @override
  void showStation(RadioStation station) {
    mediaItem.add(
      MediaItem(
        id: station.id,
        title: station.name,
        artist: station.country,
        artUri:
            (station.faviconUrl == null
                ? null
                : Uri.tryParse(station.faviconUrl!)) ??
            fallbackArt,
      ),
    );
  }

  @override
  void showFlight() {
    mediaItem.add(
      MediaItem(id: 'flight', title: flightTitle, artist: flightSubtitle),
    );
    _flying = true;
    _republish();
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

  @override
  Future<void> skipToNext() async => _commands.add(RadioMediaCommand.next);

  @override
  Future<void> skipToPrevious() async =>
      _commands.add(RadioMediaCommand.previous);

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == favoriteAction) _commands.add(RadioMediaCommand.toggleFavorite);
  }

  Future<void> dispose() async {
    await _events.cancel();
    await _commands.close();
  }
}
