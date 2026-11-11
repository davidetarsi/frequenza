import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/just_audio_service.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:just_audio/just_audio.dart';

class LivePlayer extends Fake implements AudioPlayer {
  final playback = Completer<void>();

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
  Future<void> play() => playback.future;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    if (!playback.isCompleted) playback.complete();
  }
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
}
