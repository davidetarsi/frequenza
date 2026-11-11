import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/radio_player_state.dart';
import '../domain/radio_audio_service.dart';
import '../domain/radio_station.dart';
import 'radio_providers.dart';

part 'radio_controller.g.dart';

@Riverpod(keepAlive: true)
class RadioController extends _$RadioController {
  Object? _currentTuneToken;

  RadioAudioService get _audioService => ref.read(radioAudioServiceProvider);

  @override
  RadioPlayerState build() {
    final audio = ref.watch(radioAudioServiceProvider);
    var active = true;
    final statusSubscription = audio.playbackStatusStream.listen((status) {
      if (active && state.status != PlaybackStatus.tuning) {
        state = state.copyWith(status: status);
      }
    });
    final trackSubscription = audio.trackTitleStream.listen((title) {
      if (active &&
          state.station != null &&
          state.status != PlaybackStatus.tuning) {
        state = state.copyWith(trackTitle: title);
      }
    });
    ref.onDispose(() {
      active = false;
      _currentTuneToken = null;
      unawaited(statusSubscription.cancel());
      unawaited(trackSubscription.cancel());
      unawaited(audio.stopTuningSound());
    });
    return const RadioPlayerState();
  }

  /// Tunes to a random station.
  /// If [countryCode] is specified, restricts search to that country.
  Future<void> tuneRandom({String? countryCode}) async {
    final token = Object();
    _currentTuneToken = token;

    state = state.copyWith(
      status: PlaybackStatus.tuning,
      errorMessage: null,
      trackTitle: null,
    );

    try {
      final RadioStation? station;
      try {
        final (found, _) = await (
          ref
              .read(radioRepositoryProvider)
              .getRandomStation(countryCode: countryCode),
          _holdTuningSound(),
        ).wait;
        station = found;
      } finally {
        if (_currentTuneToken == token) {
          await _audioService.stopTuningSound();
        }
      }

      // Check if another tune operation started while waiting
      if (_currentTuneToken != token) {
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
        trackTitle: null,
        errorMessage: null,
      );

      await _audioService.playStation(station);
    } catch (e) {
      if (_currentTuneToken == token) {
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
      trackTitle: null,
      errorMessage: null,
    );

    try {
      await _audioService.stopTuningSound();
      if (_currentTuneToken != token) return;
      await _audioService.playStation(station);
    } catch (_) {
      if (_currentTuneToken == token) {
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
    if (_currentTuneToken != token) return;
    await _audioService.stop();
    if (_currentTuneToken == token) {
      state = state.copyWith(
        status: PlaybackStatus.idle,
        errorMessage: null,
        trackTitle: null,
      );
    }
  }
}
