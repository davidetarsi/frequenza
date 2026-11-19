import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/radio_station.dart';
import '../../../app/platform/data/native_channel.dart';
import '../domain/radio_media_session.dart';
import '../domain/radio_media_localization.dart';
import '../../journey/domain/country_name.dart';

class RadioAudioHandler extends BaseAudioHandler implements RadioMediaSession {
  RadioAudioHandler(
    this.player, {
    required this.flightTitle,
    required this.flightSubtitle,
    required this.saveLabel,
    required this.removeLabel,
    this.fallbackArt,
    Future<void> Function()? leaveForeground,
  }) : _leaveForeground = leaveForeground ?? _nativeLeaveForeground {
    _events = player.playbackEventStream.listen(
      _publish,
      onError: (Object error) {
        _show(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            playing: false,
          ),
        );
      },
    );
  }

  final AudioPlayer player;
  final String flightTitle;
  String flightSubtitle, saveLabel, removeLabel;
  RadioMediaLocalization? _localization;
  RadioStation? _station;
  bool _flightItem = false;

  /// Frequenza's logo, for stations without one.
  final Uri? fallbackArt;
  late final StreamSubscription<PlaybackEvent> _events;
  final _commands = StreamController<RadioMediaCommand>.broadcast();
  PlaybackEvent? _event;
  bool _flying = false, _saved = false;

  /// The service stays in the foreground while paused, so the radio can
  /// resume from the background; once it has really stopped (stopped,
  /// ended, broken) it leaves, which also lets the notification close.
  final Future<void> Function() _leaveForeground;
  bool _stopped = true;

  static const _stoppedStates = {
    AudioProcessingState.idle,
    AudioProcessingState.completed,
    AudioProcessingState.error,
  };

  static Future<void> _nativeLeaveForeground() async {
    try {
      await nativeChannel.invokeMethod<void>('leaveForeground');
    } catch (_) {
      // Without the native side the service simply stays as it is.
    }
  }

  /// Asked before the state is shown: on idle the plugin closes the
  /// service, and a service still in the foreground keeps its notification.
  void _show(PlaybackState state) {
    final stopped =
        !state.playing && _stoppedStates.contains(state.processingState);
    if (stopped && !_stopped) unawaited(_leaveForeground());
    _stopped = stopped;
    playbackState.add(state);
  }

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
    // In flight the player stops and reloads: shown as connecting, so the
    // notification never closes between two stations.
    final playing =
        _flying ||
        player.playing &&
            processing != ProcessingState.idle &&
            processing != ProcessingState.completed;
    _show(
      PlaybackState(
        controls: [
          _localization == null
              ? MediaControl.skipToPrevious
              : MediaControl.skipToPrevious.copyWith(
                  label: _localization!.previous,
                ),
          playing
              ? (_localization == null
                    ? MediaControl.pause
                    : MediaControl.pause.copyWith(label: _localization!.pause))
              : (_localization == null
                    ? MediaControl.play
                    : MediaControl.play.copyWith(label: _localization!.play)),
          _localization == null
              ? MediaControl.skipToNext
              : MediaControl.skipToNext.copyWith(label: _localization!.next),
          MediaControl.custom(
            androidIcon: _saved
                ? 'drawable/ic_favorite'
                : 'drawable/ic_favorite_border',
            label: _saved ? removeLabel : saveLabel,
            name: favoriteAction,
          ),
        ],
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _flying
            ? AudioProcessingState.loading
            : _processingStates[processing]!,
        playing: playing,
        updatePosition: event?.updatePosition ?? Duration.zero,
        bufferedPosition: event?.bufferedPosition ?? Duration.zero,
      ),
    );
  }

  @override
  Stream<RadioMediaCommand> get commands => _commands.stream;

  @override
  void showControls({required bool flying, required bool saved}) {
    _flying = flying;
    _saved = saved;
    _republish();
  }

  @override
  void updateLocalization(RadioMediaLocalization localization) {
    _localization = localization;
    flightSubtitle = localization.flying;
    saveLabel = localization.save;
    removeLabel = localization.remove;
    if (mediaItem.value != null) {
      if (_flightItem) {
        showFlight();
      } else if (_station case final station?) {
        showStation(station);
      }
    }
    _republish();
  }

  @override
  void showStation(RadioStation station) {
    _station = station;
    _flightItem = false;
    final labels = _localization;
    mediaItem.add(
      MediaItem(
        id: station.id,
        title: station.name,
        artist: labels == null
            ? (station.country.isEmpty ? null : station.country)
            : localizedCountryName(
                station.countryCode,
                labels.language,
                fallback: station.country.isEmpty
                    ? labels.unknownCountry
                    : station.country,
              ),
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
    _flightItem = true;
    mediaItem.add(
      MediaItem(id: 'flight', title: flightTitle, artist: flightSubtitle),
    );
  }

  @override
  Future<void> play() async {
    if (_flying) return;
    if (player.processingState == ProcessingState.idle) {
      return _send(RadioMediaCommand.resume);
    }
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    // play() completes when live playback stops, not when it starts.
    unawaited(player.play().catchError((Object _) {}));
  }

  @override
  Future<void> pause() async {
    if (!_flying) await player.pause();
  }

  @override
  Future<void> stop() => player.stop();

  /// The app swiped away from the recent apps: a radio that is not playing
  /// (paused, or a stream that ended on its own) closes with it; one that
  /// plays or flies carries on. Read from what the notification shows,
  /// which already counts a flight as playing.
  @override
  Future<void> onTaskRemoved() async {
    if (!playbackState.value.playing) await stop();
  }

  @override
  Future<void> skipToNext() async => _send(RadioMediaCommand.next);

  @override
  Future<void> skipToPrevious() async => _send(RadioMediaCommand.previous);

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == favoriteAction) _send(RadioMediaCommand.toggleFavorite);
  }

  /// The keys wait for the landing: nothing is sent while flying.
  void _send(RadioMediaCommand command) {
    if (!_flying) _commands.add(command);
  }

  Future<void> dispose() async {
    await _events.cancel();
    await _commands.close();
  }
}
