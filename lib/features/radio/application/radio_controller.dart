import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/radio_player_state.dart';
import '../domain/radio_repository.dart';
import '../domain/radio_station.dart';
import 'radio_audio_service.dart';

class RadioController extends StateNotifier<RadioPlayerState> {
  RadioController({
    required RadioRepository repository,
    required RadioAudioService audioService,
  }) : _repository = repository,
       _audioService = audioService,
       super(const RadioPlayerState()) {
    _statusSubscription = _audioService.playbackStatusStream.listen((status) {
      if (mounted && state.status != PlaybackStatus.tuning) {
        state = state.copyWith(status: status);
      }
    });
    _trackSubscription = _audioService.trackTitleStream.listen((title) {
      if (mounted &&
          state.station != null &&
          state.status != PlaybackStatus.tuning) {
        state = state.copyWith(
          trackTitle: title,
          clearTrackTitle: title == null,
        );
      }
    });
  }

  final RadioRepository _repository;
  final RadioAudioService _audioService;
  StreamSubscription<PlaybackStatus>? _statusSubscription;
  StreamSubscription<String?>? _trackSubscription;
  Object? _currentTuneToken;

  /// Tunes to a random station.
  /// If [countryCode] is specified, restricts search to that country.
  Future<void> tuneRandom({String? countryCode}) async {
    final token = Object();
    _currentTuneToken = token;

    state = state.copyWith(
      status: PlaybackStatus.tuning,
      clearError: true,
      clearTrackTitle: true,
    );

    try {
      final RadioStation? station;
      try {
        final (found, _) = await (
          _repository.getRandomStation(countryCode: countryCode),
          _holdTuningSound(),
        ).wait;
        station = found;
      } finally {
        if (_currentTuneToken == token && mounted) {
          await _audioService.stopTuningSound();
        }
      }

      // Check if another tune operation started while waiting
      if (_currentTuneToken != token || !mounted) {
        return;
      }

      if (station == null) {
        state = state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: 'Nessuna stazione trovata',
        );
        return;
      }

      state = state.copyWith(
        status: PlaybackStatus.buffering,
        station: station,
        clearTrackTitle: true,
        clearError: true,
      );

      await _audioService.playStation(station);
    } catch (e) {
      if (_currentTuneToken == token && mounted) {
        state = state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: 'Impossibile riprodurre lo stream audio',
        );
      }
    }
  }

  Future<void> _holdTuningSound() async {
    await _audioService.startTuningSound();
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  /// Explicitly tune to a specific station (e.g. from candidate list).
  Future<void> tuneTo(RadioStation station) async {
    final token = Object();
    _currentTuneToken = token;

    state = state.copyWith(
      status: PlaybackStatus.buffering,
      station: station,
      clearTrackTitle: true,
      clearError: true,
    );

    try {
      await _audioService.stopTuningSound();
      if (_currentTuneToken != token || !mounted) return;
      await _audioService.playStation(station);
    } catch (_) {
      if (_currentTuneToken == token && mounted) {
        state = state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: 'Impossibile riprodurre lo stream audio',
        );
      }
    }
  }

  Future<void> play() async {
    if (state.station != null) {
      await _audioService.play();
    }
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> stop() async {
    final token = Object();
    _currentTuneToken = token;
    await _audioService.stopTuningSound();
    if (_currentTuneToken != token || !mounted) return;
    await _audioService.stop();
    if (_currentTuneToken == token && mounted) {
      state = state.copyWith(
        status: PlaybackStatus.idle,
        clearError: true,
        clearTrackTitle: true,
      );
    }
  }

  @override
  void dispose() {
    _currentTuneToken = null;
    _statusSubscription?.cancel();
    _trackSubscription?.cancel();
    unawaited(_audioService.stopTuningSound());
    super.dispose();
  }
}
