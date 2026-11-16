import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/journey.dart';
import '../domain/radio_audio_service.dart';
import '../domain/radio_session.dart';
import '../domain/radio_station.dart';
import 'flight_timing.dart';
import 'radio_providers.dart';

part 'radio_controller.g.dart';

/// Runs the radio's effects (static, stream, timers); every change of
/// state is decided by [next].
@Riverpod(keepAlive: true)
class RadioController extends _$RadioController {
  Object? _currentTuneToken;

  /// Runs while the station on air buffers: a stream that stays silent
  /// is reconnected instead of leaving the radio stuck.
  Timer? _stall;

  /// Runs while the station on air is paused: a long pause closes the
  /// stream, and with it the notification.
  Timer? _pause;

  RadioAudioService get _audioService => ref.read(radioAudioServiceProvider);

  void _apply(RadioEvent event) => state = next(state, event);

  @override
  RadioSession build() {
    final audio = ref.watch(radioAudioServiceProvider);
    var active = true;
    final statusSubscription = audio.playbackStatusStream.listen((status) {
      if (!active) return;
      _apply(PlaybackChanged(status));
      _watchStall();
      _watchPause();
    });
    final trackSubscription = audio.trackTitleStream.listen((title) {
      if (active) _apply(TrackChanged(title));
    });
    // A pause from the system ends a flight; on air the player already
    // paused, and the status reports it.
    final pauseSubscription = audio.systemPauses.listen((_) {
      if (active && state is Flying) unawaited(stop());
    });
    ref.onDispose(() {
      active = false;
      _stall?.cancel();
      _pause?.cancel();
      unawaited(pauseSubscription.cancel());
      _currentTuneToken = null;
      unawaited(statusSubscription.cancel());
      unawaited(trackSubscription.cancel());
      unawaited(audio.stopTuningSound());
    });
    return const RadioSession.off(Journey());
  }

  /// Flies to a random station, retrying after a lost signal, away from the
  /// stations just heard. [countries] limits it to the chosen ones.
  Future<void> tuneRandom({Set<String>? countries}) => _fly(
    () => ref
        .read(radioRepositoryProvider)
        .getRandomStation(countries: countries, avoid: _justHeard()),
    retries: ref.read(flightTimingProvider).autoRetries,
  );

  /// The stations left behind and the last one that landed.
  Set<String> _justHeard() {
    final journey = state.journey;
    return {
      for (final station in journey.previous) station.id,
      ?journey.landed?.id,
    };
  }

  /// Flies to a chosen station (e.g. a favorite), without retrying.
  Future<void> tuneTo(RadioStation station) async =>
      _fly(() async => station, retries: 0, target: station);

  /// Flies back to the last station left behind; it leaves the stack only
  /// once landed, so a failed or cancelled return keeps it. With nothing
  /// left behind it reconnects the last station that landed.
  Future<void> tuneBack() async {
    final journey = state.journey;
    if (journey.canGoBack) {
      final station = journey.previous.last;
      return _fly(() async => station, retries: 0, kind: FlightKind.back);
    }
    final station = journey.landed;
    if (station == null) return;
    await _fly(() async => station, retries: 0, kind: FlightKind.reconnect);
  }

  void _watchStall() {
    _stall?.cancel();
    final session = state;
    if (session is! OnAir || session.playback != OnAirPlayback.buffering) {
      return;
    }
    final station = session.station;
    _stall = Timer(ref.read(flightTimingProvider).stallTimeout, () {
      final now = state;
      if (now is! OnAir ||
          now.playback != OnAirPlayback.buffering ||
          now.station != station) {
        return;
      }
      unawaited(
        _fly(
          () async => station,
          retries: ref.read(flightTimingProvider).autoRetries,
          kind: FlightKind.reconnect,
        ),
      );
    });
  }

  void _watchPause() {
    _pause?.cancel();
    final session = state;
    if (session is! OnAir || session.playback != OnAirPlayback.paused) return;
    final station = session.station;
    _pause = Timer(ref.read(flightTimingProvider).pauseTimeout, () {
      final now = state;
      if (now is OnAir &&
          now.playback == OnAirPlayback.paused &&
          now.station == station) {
        unawaited(_audioService.stop());
      }
    });
  }

  /// One flight: every attempt lasts at least [FlightTiming.minimum] and
  /// lands only once the station really plays.
  Future<void> _fly(
    Future<RadioStation?> Function() pick, {
    required int retries,
    FlightKind kind = FlightKind.forward,
    RadioStation? target,
  }) async {
    final token = Object();
    _currentTuneToken = token;
    _stall?.cancel();
    _pause?.cancel();
    bool current() => _currentTuneToken == token;
    final timing = ref.read(flightTimingProvider);

    _apply(FlightStarted(kind, target: target));
    await _audioService.startTuningSound();

    for (var attempt = 0; current(); attempt++) {
      if (attempt > 0) _apply(const RetryStarted());
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
      final retrying = attempt < retries;
      if (!retrying) {
        await _audioService.stopTuningSound();
        if (current()) _apply(const AttemptFailed(retrying: false));
        return;
      }
      _apply(const AttemptFailed(retrying: true));
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
    await _audioService.stopTuningSound(fade: true);
    if (!current()) return;
    await _audioService.land(station);
    if (!current()) return;
    // A pause may have arrived while the flight ignored audio events.
    _apply(
      Landed(
        station,
        paused: _audioService.currentStatus == PlaybackStatus.paused,
      ),
    );
  }

  /// Resumes the station on air; once its stream has closed (a long pause,
  /// the app swiped away) it reconnects the station instead.
  Future<void> play() async {
    final session = state;
    if (session is! OnAir) return;
    if (session.playback != OnAirPlayback.ended) {
      return _audioService.play();
    }
    final station = session.station;
    await _fly(
      () async => station,
      retries: ref.read(flightTimingProvider).autoRetries,
      kind: FlightKind.reconnect,
    );
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> stop() async {
    final token = Object();
    _currentTuneToken = token;
    _stall?.cancel();
    _pause?.cancel();
    await _audioService.stopTuningSound();
    if (_currentTuneToken != token) return;
    await _audioService.stop();
    if (_currentTuneToken == token) _apply(const SwitchedOff());
  }
}
