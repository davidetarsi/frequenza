import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../application/radio_audio_service.dart';
import '../domain/radio_player_state.dart';
import '../domain/radio_station.dart';

class JustAudioService implements RadioAudioService {
  JustAudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _initAudioSession();
    _subscribeToPlayerState();
  }

  final AudioPlayer _player;
  final _statusController = StreamController<PlaybackStatus>.broadcast();
  PlaybackStatus _currentStatus = PlaybackStatus.idle;

  @override
  Stream<PlaybackStatus> get playbackStatusStream => _statusController.stream;

  @override
  PlaybackStatus get currentStatus => _currentStatus;

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      session.becomingNoisyEventStream.listen((_) {
        pause();
      });

      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.2);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    } catch (_) {
      // AudioSession may not be available on some platforms/tests
    }
  }

  void _subscribeToPlayerState() {
    _player.playerStateStream.listen(
      (state) {
        final status = _mapPlayerState(state);
        _updateStatus(status);
      },
      onError: (Object error) {
        _updateStatus(PlaybackStatus.error);
      },
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
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  @override
  Future<void> playStation(RadioStation station) async {
    try {
      _updateStatus(PlaybackStatus.buffering);

      final audioSource = AudioSource.uri(
        Uri.parse(station.streamUrl),
        tag: MediaItem(
          id: station.id,
          title: station.name,
          artist: station.country,
          artUri: station.faviconUrl != null
              ? Uri.tryParse(station.faviconUrl!)
              : null,
        ),
      );

      await _player.stop();
      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      _updateStatus(PlaybackStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (_) {
      _updateStatus(PlaybackStatus.error);
    }
  }

  @override
  Future<void> pause() async {
    try {
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
    await _player.dispose();
    await _statusController.close();
  }
}
