import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/radio_audio_service.dart';
import '../domain/radio_player_state.dart';
import '../domain/radio_station.dart';
import 'radio_media_session.dart';

class JustAudioService implements RadioAudioService {
  JustAudioService({AudioPlayer? player, RadioMediaSession? mediaSession})
    : _player = player ?? AudioPlayer(),
      _mediaSession = mediaSession {
    _initAudioSession();
    _subscribeToPlayerState();
  }

  static const _tuningChannel = MethodChannel('frequenza/tuning_sound');
  final AudioPlayer _player;
  final RadioMediaSession? _mediaSession;
  Object? _tuningSoundRequest;
  final _statusController = StreamController<PlaybackStatus>.broadcast();
  final _interruptions = StreamController<void>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;
  PlaybackStatus _currentStatus = PlaybackStatus.idle;
  bool _muted = false, _ducked = false;

  double get _volume => _muted
      ? 0
      : _ducked
      ? 0.2
      : 1;

  @override
  Stream<PlaybackStatus> get playbackStatusStream => _statusController.stream;

  @override
  Stream<String?> get trackTitleStream =>
      _player.icyMetadataStream.map((metadata) {
        final title = metadata?.info?.title?.trim();
        return title == null || title.isEmpty ? null : title;
      }).distinct();

  @override
  PlaybackStatus get currentStatus => _currentStatus;

  @override
  Stream<void> get flightInterruptions => _interruptions.stream;

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      if (_disposed) return;

      _subscriptions.add(
        session.becomingNoisyEventStream.listen((_) {
          unawaited(pause());
        }),
      );

      _subscriptions.add(
        session.interruptionEventStream.listen(handleInterruption),
      );
    } catch (_) {
      // AudioSession may not be available on some platforms/tests
    }
  }

  @visibleForTesting
  void handleInterruption(AudioInterruptionEvent event) {
    switch (event.type) {
      case AudioInterruptionType.duck:
        _ducked = event.begin;
        unawaited(_player.setVolume(_volume));
      case AudioInterruptionType.pause:
      case AudioInterruptionType.unknown:
        if (event.begin) unawaited(pause());
    }
  }

  void _subscribeToPlayerState() {
    _subscriptions.add(
      _player.playerStateStream.listen(
        (state) {
          final status = _mapPlayerState(state);
          _updateStatus(status);
        },
        onError: (Object error) {
          _updateStatus(PlaybackStatus.error);
        },
      ),
    );
  }

  PlaybackStatus _mapPlayerState(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        return PlaybackStatus.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return PlaybackStatus.buffering;
      case ProcessingState.ready:
        return state.playing ? PlaybackStatus.playing : PlaybackStatus.paused;
      case ProcessingState.completed:
        return PlaybackStatus.idle;
    }
  }

  void _updateStatus(PlaybackStatus status) {
    if (_disposed) return;
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  @override
  Future<void> startTuningSound() async {
    if (_disposed) return;
    final request = Object();
    _tuningSoundRequest = request;
    try {
      // Silence the previous station before the speaker plays the static.
      if (_player.playing) await _player.pause();
    } on PlatformException {
      return;
    }
    if (_tuningSoundRequest == request) {
      await _sendTuningSoundCommand('start');
    }
  }

  @override
  Future<void> stopTuningSound() async {
    if (_tuningSoundRequest == null) return;
    _tuningSoundRequest = null;
    await _sendTuningSoundCommand('stop');
  }

  Future<void> _sendTuningSoundCommand(String command) async {
    try {
      await _tuningChannel.invokeMethod<void>(command);
    } on MissingPluginException {
      // The optional sound is currently provided by Android.
    } on PlatformException {
      // A sound effect failure must not prevent the station from playing.
    }
  }

  @override
  Future<void> playStation(RadioStation station) async {
    try {
      _updateStatus(PlaybackStatus.buffering);

      final audioSource = AudioSource.uri(Uri.parse(station.streamUrl));

      await _player.stop();
      _mediaSession?.showFlight();
      // Silent until land(): the static plays while the stream loads.
      _muted = true;
      await _player.setVolume(_volume);
      await _player.setAudioSource(audioSource);
      // play() completes when live playback stops, not when it starts.
      _startPlayback();
    } catch (e) {
      _updateStatus(PlaybackStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> land(RadioStation station) async {
    _muted = false;
    await _player.setVolume(_volume);
    _mediaSession?.showStation(station);
  }

  @override
  Future<void> play() async {
    try {
      _startPlayback();
    } catch (_) {
      _updateStatus(PlaybackStatus.error);
    }
  }

  void _startPlayback() {
    if (_disposed) return;
    unawaited(
      _player.play().catchError((Object error, StackTrace stack) {
        _updateStatus(PlaybackStatus.error);
      }),
    );
  }

  @override
  Future<void> pause() async {
    if (_muted && !_disposed) _interruptions.add(null);
    try {
      await stopTuningSound();
      await _player.pause();
    } catch (_) {
      _updateStatus(PlaybackStatus.error);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _updateStatus(PlaybackStatus.idle);
    } catch (_) {
      _updateStatus(PlaybackStatus.error);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopTuningSound();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _player.dispose();
    await _statusController.close();
    await _interruptions.close();
  }
}
