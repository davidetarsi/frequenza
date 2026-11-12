import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:just_audio/just_audio.dart';

class EventPlayer extends Fake implements AudioPlayer {
  final events = StreamController<PlaybackEvent>.broadcast();
  final playback = Completer<void>();
  @override
  bool playing = false;
  int pauses = 0;
  int plays = 0;
  int stops = 0;

  @override
  Stream<PlaybackEvent> get playbackEventStream => events.stream;

  @override
  Future<void> play() {
    plays++;
    return playback.future;
  }

  @override
  Future<void> pause() async => pauses++;

  @override
  Future<void> stop() async => stops++;
}

void main() {
  late EventPlayer player;
  late RadioAudioHandler handler;

  setUp(() {
    player = EventPlayer();
    handler = RadioAudioHandler(player);
  });
  tearDown(() => handler.dispose());

  Future<PlaybackState> emit(ProcessingState state, {required bool playing}) {
    player.playing = playing;
    final next = handler.playbackState.skip(1).first;
    player.events.add(PlaybackEvent(processingState: state));
    return next;
  }

  test('publishes pause control and ready state while playing', () async {
    final state = await emit(ProcessingState.ready, playing: true);
    expect(state.playing, isTrue);
    expect(state.processingState, AudioProcessingState.ready);
    expect(state.controls.first, MediaControl.pause);
    expect(state.controls, contains(MediaControl.stop));
  });

  test('publishes play control while paused', () async {
    final state = await emit(ProcessingState.ready, playing: false);
    expect(state.controls.first, MediaControl.play);
  });

  test('maps buffering and idle', () async {
    expect(
      (await emit(ProcessingState.buffering, playing: true)).processingState,
      AudioProcessingState.buffering,
    );
    expect(
      (await emit(ProcessingState.idle, playing: false)).processingState,
      AudioProcessingState.idle,
    );
  });

  test('play returns without waiting for live playback', () async {
    await handler.play().timeout(const Duration(seconds: 1));
    expect(player.plays, 1);
  });

  test('pause and stop reach the player', () async {
    await handler.pause();
    await handler.stop();
    expect(player.pauses, 1);
    expect(player.stops, 1);
  });

  test('click toggles playback', () async {
    await emit(ProcessingState.ready, playing: true);
    await handler.click();
    expect(player.pauses, 1);
    await emit(ProcessingState.ready, playing: false);
    await handler.click();
    expect(player.plays, 1);
  });

  test('showStation publishes station metadata', () {
    handler.showStation(
      const RadioStation(
        id: 'fip',
        name: 'FIP',
        streamUrl: 'https://example.com/fip',
        country: 'France',
        countryCode: 'FR',
        faviconUrl: 'https://example.com/i.png',
      ),
    );
    final item = handler.mediaItem.value!;
    expect(item.id, 'fip');
    expect(item.title, 'FIP');
    expect(item.artist, 'France');
    expect(item.artUri, Uri.parse('https://example.com/i.png'));

    handler.showStation(
      const RadioStation(
        id: 'kexp',
        name: 'KEXP',
        streamUrl: 'https://example.com/kexp',
        country: 'United States',
        countryCode: 'US',
      ),
    );
    expect(handler.mediaItem.value!.artUri, isNull);
  });

  test('player event errors become error state', () async {
    final next = handler.playbackState.skip(1).first;
    player.events.addError(StateError('Disconnected'));
    final state = await next;
    expect(state.processingState, AudioProcessingState.error);
    expect(state.playing, isFalse);
  });
}
