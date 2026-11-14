import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../journey/domain/station_place.dart';
import '../../journey/domain/travel_leg.dart';
import '../domain/radio_player_state.dart';
import '../domain/radio_audio_service.dart';
import '../domain/radio_station.dart';
import 'flight_timing.dart';
import 'radio_providers.dart';

part 'radio_controller.g.dart';

const _historyLength = 5;

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
    final interruptionSubscription = audio.flightInterruptions.listen((_) {
      if (active && state.flight == FlightPhase.flying) unawaited(stop());
    });
    ref.onDispose(() {
      active = false;
      unawaited(interruptionSubscription.cancel());
      _currentTuneToken = null;
      unawaited(statusSubscription.cancel());
      unawaited(trackSubscription.cancel());
      unawaited(audio.stopTuningSound());
    });
    return const RadioPlayerState();
  }

  /// Flies to a random station, retrying after a lost signal.
  /// If [countryCode] is specified, restricts search to that country.
  Future<void> tuneRandom({String? countryCode}) => _fly(
    () => ref
        .read(radioRepositoryProvider)
        .getRandomStation(countryCode: countryCode),
    retries: ref.read(flightTimingProvider).autoRetries,
  );

  /// Flies to a chosen station (e.g. a favorite), without retrying.
  Future<void> tuneTo(RadioStation station) async =>
      _fly(() async => station, retries: 0);

  /// One flight: every attempt lasts at least [FlightTiming.minimum] and
  /// lands only once the station really plays.
  Future<void> _fly(
    Future<RadioStation?> Function() pick, {
    required int retries,
  }) async {
    final token = Object();
    _currentTuneToken = token;
    bool current() => _currentTuneToken == token;
    final timing = ref.read(flightTimingProvider);

    state = state.copyWith(
      status: PlaybackStatus.tuning,
      station: null,
      trackTitle: null,
      errorMessage: null,
      flight: FlightPhase.flying,
    );
    await _audioService.startTuningSound();

    for (var attempt = 0; current(); attempt++) {
      if (attempt > 0) state = state.copyWith(flight: FlightPhase.flying);
      RadioStation? station;
      try {
        station = await _attempt(pick, timing, current);
      } catch (_) {
        station = null;
      }
      if (!current()) return;
      if (station != null) return _land(station, current);

      await _audioService.stop();
      if (!current()) return;
      state = state.copyWith(flight: FlightPhase.signalLost);
      if (attempt >= retries) {
        await _audioService.stopTuningSound();
        if (current()) {
          state = state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'Impossibile riprodurre lo stream audio',
          );
        }
        return;
      }
      await Future<void>.delayed(timing.signalLostPause);
    }
  }

  Future<RadioStation> _attempt(
    Future<RadioStation?> Function() pick,
    FlightTiming timing,
    bool Function() current,
  ) async {
    var expired = false;
    bool alive() => current() && !expired;
    Future<RadioStation> connect() async {
      final station = await pick();
      if (station == null) throw StateError('No station found');
      if (!alive()) throw StateError('Flight cancelled');
      await _audioService.playStation(station);
      if (!alive()) throw StateError('Flight cancelled');
      await _untilPlaying();
      return station;
    }

    try {
      final (station, _) = await (
        connect().timeout(timing.attemptTimeout),
        Future<void>.delayed(timing.minimum),
      ).wait;
      return station;
    } finally {
      expired = true;
    }
  }

  Future<void> _untilPlaying() async {
    final audio = _audioService;
    var status = audio.currentStatus;
    if (status != PlaybackStatus.playing && status != PlaybackStatus.error) {
      status = await audio.playbackStatusStream.firstWhere(
        (s) => s == PlaybackStatus.playing || s == PlaybackStatus.error,
      );
    }
    if (status == PlaybackStatus.error) throw StateError('Stream failed');
  }

  Future<void> _land(RadioStation station, bool Function() current) async {
    await _audioService.stopTuningSound();
    if (!current()) return;
    await _audioService.land(station);
    if (!current()) return;
    final to = placeOf(station);
    final leg = TravelLeg(from: state.departure, to: to);
    final history = [...state.history, if (to != null) leg];
    state = state.copyWith(
      // A pause may have arrived while the status listener ignored events.
      status: _audioService.currentStatus == PlaybackStatus.paused
          ? PlaybackStatus.paused
          : PlaybackStatus.playing,
      station: station,
      flight: FlightPhase.grounded,
      leg: leg,
      departure: to ?? state.departure,
      history: history.length > _historyLength
          ? history.sublist(history.length - _historyLength)
          : history,
      trips: state.trips + 1,
    );
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
        flight: FlightPhase.grounded,
        leg: null,
      );
    }
  }
}
