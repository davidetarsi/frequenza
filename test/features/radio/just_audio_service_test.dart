import 'dart:async';

import 'package:audio_session/audio_session.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/just_audio_service.dart';
import 'package:frequenza/features/radio/data/radio_media_session.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:just_audio/just_audio.dart';

class LivePlayer extends Fake implements AudioPlayer {
  final playback = Completer<void>();
  final calls = <String>[];

  @override
  Future<void> setVolume(double volume) async => calls.add('volume $volume');

  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();

  @override
  Stream<IcyMetadata?> get icyMetadataStream => const Stream.empty();

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async => null;

  @override
  Future<void> play() {
    calls.add('play');
    return playback.future;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    if (!playback.isCompleted) playback.complete();
  }
}

class RecordingSession implements RadioMediaSession {
  RadioStation? shown;
  var flights = 0;

  @override
  void showStation(RadioStation station) => shown = station;

  @override
  void showFlight() => flights++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const station = RadioStation(
    id: 'live',
    name: 'Live',
    streamUrl: 'https://example.com/live',
    country: 'Italy',
    countryCode: 'IT',
  );

  test('starting live radio does not wait for playback to end', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await service.playStation(station).timeout(const Duration(seconds: 1));
    expect(player.playback.isCompleted, isFalse);
    await service.play().timeout(const Duration(seconds: 1));
  });

  test('late playback errors update status instead of escaping', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await service.playStation(station).timeout(const Duration(seconds: 1));
    final observed = expectLater(
      service.playbackStatusStream,
      emits(PlaybackStatus.error),
    );
    player.playback.completeError(StateError('Disconnected'));
    await observed;
  });

  test('playStation starts silent and shows only the flight', () async {
    final player = LivePlayer();
    final session = RecordingSession();
    final service = JustAudioService(player: player, mediaSession: session);
    addTearDown(service.dispose);
    await service.playStation(station).timeout(const Duration(seconds: 1));
    expect(player.calls, ['volume 0.0', 'play']);
    expect(session.flights, 1);
    expect(session.shown, isNull);
  });

  test('land restores the volume and reveals the station', () async {
    final player = LivePlayer();
    final session = RecordingSession();
    final service = JustAudioService(player: player, mediaSession: session);
    addTearDown(service.dispose);
    await service.playStation(station);
    await service.land(station);
    expect(player.calls.last, 'volume 1.0');
    expect(session.shown?.id, station.id);
  });

  test('a duck ending during the flight keeps the station silent', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await service.playStation(station);
    service.handleInterruption(
      AudioInterruptionEvent(true, AudioInterruptionType.duck),
    );
    service.handleInterruption(
      AudioInterruptionEvent(false, AudioInterruptionType.duck),
    );
    expect(
      player.calls.where((c) => c.startsWith('volume')),
      everyElement('volume 0.0'),
    );
    service.handleInterruption(
      AudioInterruptionEvent(true, AudioInterruptionType.duck),
    );
    await service.land(station);
    expect(player.calls.last, 'volume 0.2');
  });
}
