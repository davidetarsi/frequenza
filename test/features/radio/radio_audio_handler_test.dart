import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';
import 'package:frequenza/features/radio/data/radio_media_session.dart';
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
  final seeks = <Duration?>[];
  @override
  ProcessingState processingState = ProcessingState.idle;

  @override
  Future<void> seek(Duration? position, {int? index}) async =>
      seeks.add(position);

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

final fallbackArt = Uri.file('/cache/notification_art.png');

void main() {
  late EventPlayer player;
  late RadioAudioHandler handler;

  setUp(() {
    player = EventPlayer();
    handler = RadioAudioHandler(
      player,
      flightTitle: 'Frequenza',
      flightSubtitle: 'In volo…',
      saveLabel: 'Salva',
      removeLabel: 'Togli',
      fallbackArt: fallbackArt,
    );
  });
  tearDown(() => handler.dispose());

  Future<PlaybackState> emit(ProcessingState state, {required bool playing}) {
    player.playing = playing;
    player.processingState = state;
    final next = handler.playbackState.skip(1).first;
    player.events.add(PlaybackEvent(processingState: state));
    return next;
  }

  test('publishes pause control and ready state while playing', () async {
    final state = await emit(ProcessingState.ready, playing: true);
    expect(state.playing, isTrue);
    expect(state.processingState, AudioProcessingState.ready);
    expect(state.controls.first, MediaControl.pause);
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
    expect(handler.mediaItem.value!.artUri, fallbackArt);
  });

  test('player event errors become error state', () async {
    final next = handler.playbackState.skip(1).first;
    player.events.addError(StateError('Disconnected'));
    final state = await next;
    expect(state.processingState, AudioProcessingState.error);
    expect(state.playing, isFalse);
  });

  test('a completed live stream is published as not playing', () async {
    final state = await emit(ProcessingState.completed, playing: true);
    expect(state.playing, isFalse);
    expect(state.controls.first, MediaControl.play);
  });

  test('play after a completed stream restarts it', () async {
    await emit(ProcessingState.completed, playing: true);
    await handler.play().timeout(const Duration(seconds: 1));
    expect(player.seeks, [Duration.zero]);
    expect(player.plays, 1);
  });

  test('showFlight hides the destination', () {
    handler.showFlight();
    final item = handler.mediaItem.value!;
    expect(item.title, 'Frequenza');
    expect(item.artist, 'In volo…');
    expect(item.artUri, isNull);
  });

  const station = RadioStation(
    id: 'fip',
    name: 'FIP',
    streamUrl: 'https://example.com/fip',
    country: 'France',
    countryCode: 'FR',
  );

  List<MediaControl> controls() => handler.playbackState.value.controls;
  List<int> compact() =>
      handler.playbackState.value.androidCompactActionIndices ?? const [];
  MediaControl heart() =>
      controls().singleWhere((c) => c.action == MediaAction.custom);

  test('flight shows only play/pause', () async {
    await emit(ProcessingState.ready, playing: true);
    handler.showControls(canGoBack: true, saved: true);
    handler.showFlight();
    expect(controls(), [MediaControl.pause]);
    expect(compact(), [0]);
  });

  test('grounded shows previous, play/pause, next and heart', () async {
    await emit(ProcessingState.ready, playing: true);
    handler.showStation(station);
    handler.showControls(canGoBack: true, saved: false);
    expect(controls().map((c) => c.action), [
      MediaAction.skipToPrevious,
      MediaAction.pause,
      MediaAction.skipToNext,
      MediaAction.custom,
    ]);
    expect(compact(), [0, 1, 2]);
    expect(heart().androidIcon, 'drawable/ic_favorite_border');
    expect(heart().label, 'Salva');
    expect(heart().customAction?.name, 'favorite');
  });

  test('no previous with an empty stack', () async {
    await emit(ProcessingState.ready, playing: false);
    handler.showStation(station);
    handler.showControls(canGoBack: false, saved: false);
    expect(controls().map((c) => c.action), [
      MediaAction.play,
      MediaAction.skipToNext,
      MediaAction.custom,
    ]);
    expect(compact(), [0, 1]);
  });

  test('saved station fills the heart', () async {
    handler.showStation(station);
    handler.showControls(canGoBack: false, saved: true);
    expect(heart().androidIcon, 'drawable/ic_favorite');
    expect(heart().label, 'Togli');
  });

  test('landing brings the keys back after the flight', () async {
    handler.showControls(canGoBack: true, saved: false);
    handler.showFlight();
    handler.showStation(station);
    expect(controls(), hasLength(4));
  });

  test('notification buttons become commands', () async {
    final commands = handler.commands.take(3).toList();
    await handler.skipToNext();
    await handler.skipToPrevious();
    await handler.customAction('favorite');
    expect(await commands, [
      RadioMediaCommand.next,
      RadioMediaCommand.previous,
      RadioMediaCommand.toggleFavorite,
    ]);
  });

  test('stop is never offered', () async {
    for (final playing in [true, false]) {
      await emit(ProcessingState.ready, playing: playing);
      handler.showStation(station);
      handler.showControls(canGoBack: true, saved: true);
      expect(
        controls().map((c) => c.action),
        isNot(contains(MediaAction.stop)),
      );
      handler.showFlight();
      expect(
        controls().map((c) => c.action),
        isNot(contains(MediaAction.stop)),
      );
    }
  });
}
