import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frequenza/app/platform/data/native_channel.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/flight_timing.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_notification.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/data/just_audio_service.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';
import 'package:frequenza/features/radio/domain/radio_audio_service.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:just_audio/just_audio.dart';
import '../favorites/favorites_test.dart';
import 'radio_audio_handler_test.dart';
import 'radio_controller_test.dart';
import 'radio_session_matchers.dart';

RadioStation numbered(int n) => RadioStation(
  id: 'station-$n',
  name: 'Radio $n',
  streamUrl: 'https://stream.test/$n.mp3',
  country: 'Italy',
  countryCode: 'IT',
);

/// One player for the real audio engine and the real notification: what
/// the engine does to the stream reaches the notification as it would on
/// a phone.
class SharedPlayer extends EventPlayer {
  final states = StreamController<PlayerState>.broadcast();
  final volumes = <double>[];

  void _publish(ProcessingState state, {required bool playing}) {
    processingState = state;
    this.playing = playing;
    events.add(PlaybackEvent(processingState: state));
    states.add(PlayerState(playing, state));
  }

  @override
  Stream<PlayerState> get playerStateStream => states.stream;

  @override
  Stream<IcyMetadata?> get icyMetadataStream => const Stream.empty();

  @override
  Future<void> setVolume(double volume) async => volumes.add(volume);

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    _publish(ProcessingState.loading, playing: playing);
    return null;
  }

  @override
  Future<void> play() {
    plays++;
    _publish(ProcessingState.ready, playing: true);
    return playback.future;
  }

  @override
  Future<void> pause() async {
    pauses++;
    _publish(processingState, playing: false);
  }

  @override
  Future<void> stop() async {
    stops++;
    _publish(ProcessingState.idle, playing: false);
  }

  @override
  Future<void> dispose() async {
    if (!playback.isCompleted) playback.complete();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RadioAudioHandler handler;
  late FakeRadioRepository repository;
  late FakeAudioService audio;
  late MemoryFavorites favorites;
  late ProviderContainer container;

  ProviderContainer open({RadioAudioHandler? session}) {
    final opened = ProviderContainer(
      overrides: [
        radioMediaSessionProvider.overrideWithValue(session),
        radioRepositoryProvider.overrideWithValue(repository),
        radioAudioServiceProvider.overrideWithValue(audio),
        favoritesRepositoryProvider.overrideWithValue(favorites),
        flightTimingProvider.overrideWithValue(
          const FlightTiming(
            minimum: Duration(milliseconds: 20),
            attemptTimeout: Duration(milliseconds: 300),
            signalLostPause: Duration(milliseconds: 10),
          ),
        ),
      ],
    );
    addTearDown(opened.dispose);
    opened.read(radioNotificationProvider);
    return opened;
  }

  setUp(() async {
    handler = RadioAudioHandler(
      EventPlayer(),
      flightTitle: 'Frequenza',
      flightSubtitle: 'In volo…',
      saveLabel: 'Salva',
      removeLabel: 'Togli',
    );
    repository = FakeRadioRepository();
    audio = FakeAudioService();
    favorites = MemoryFavorites();
    container = open(session: handler);
    await container.read(favoritesProvider.future);
  });
  tearDown(() async {
    await handler.dispose();
    await audio.dispose();
  });

  RadioController controller() =>
      container.read(radioControllerProvider.notifier);
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 150));
  String heartIcon() => handler.playbackState.value.controls
      .singleWhere((c) => c.action == MediaAction.custom)
      .androidIcon;
  bool backOffered() => handler.playbackState.value.controls.any(
    (c) => c.action == MediaAction.skipToPrevious,
  );

  test('next from the notification flies to a new station', () async {
    repository.stationToReturn = numbered(1);
    await handler.skipToNext();
    await settle();
    expect(container.read(radioControllerProvider).station, numbered(1));
  });

  test('resume from the notification reconnects the ended station', () async {
    repository.stationToReturn = numbered(1);
    await controller().tuneRandom();
    audio.emitStatus(PlaybackStatus.idle);
    await Future<void>.delayed(Duration.zero);
    await handler.play();
    await settle();
    expect(audio.played, [numbered(1), numbered(1)]);
    expect(container.read(radioControllerProvider).station, numbered(1));
  });

  test('previous flies back, then reconnects with an empty stack', () async {
    repository.stationToReturn = numbered(1);
    await controller().tuneRandom();
    expect(backOffered(), isTrue);
    repository.stationToReturn = numbered(2);
    await controller().tuneRandom();
    await handler.skipToPrevious();
    await settle();
    expect(container.read(radioControllerProvider).station, numbered(1));
    expect(container.read(radioControllerProvider).previous, isEmpty);
    final played = audio.played.length;
    await handler.skipToPrevious();
    await settle();
    expect(audio.played, hasLength(played + 1));
    expect(audio.played.last, numbered(1));
    expect(backOffered(), isTrue);
  });

  test('during a flight the notification stays up, connecting', () async {
    final pending = Completer<RadioStation?>();
    repository.pendingStation = pending;
    final flight = controller().tuneRandom();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.loading,
    );
    repository.pendingStation = null;
    pending.complete(numbered(1));
    await flight;
    expect(
      handler.playbackState.value.processingState,
      isNot(AudioProcessingState.loading),
    );
  });

  test('the heart saves and unsaves the station on air', () async {
    repository.stationToReturn = numbered(1);
    await controller().tuneRandom();
    expect(heartIcon(), 'drawable/ic_favorite_border');
    await handler.customAction('favorite');
    await settle();
    expect(favorites.items, [numbered(1)]);
    expect(heartIcon(), 'drawable/ic_favorite');
    await handler.customAction('favorite');
    await settle();
    expect(favorites.items, isEmpty);
    expect(heartIcon(), 'drawable/ic_favorite_border');
  });

  test(
    'removing a favorite in the app empties the notification heart',
    () async {
      repository.stationToReturn = numbered(1);
      await controller().tuneRandom();
      await container.read(favoritesProvider.notifier).toggle(numbered(1));
      expect(heartIcon(), 'drawable/ic_favorite');
      await container.read(favoritesProvider.notifier).toggle(numbered(1));
      expect(heartIcon(), 'drawable/ic_favorite_border');
    },
  );

  test('a retune from a station on air keeps the notification up', () async {
    final player = SharedPlayer();
    final shared = RadioAudioHandler(
      player,
      flightTitle: 'Frequenza',
      flightSubtitle: 'In volo…',
      saveLabel: 'Salva',
      removeLabel: 'Togli',
    );
    final engine = JustAudioService(player: player, mediaSession: shared);
    addTearDown(() async {
      await engine.dispose();
      await shared.dispose();
    });
    final live = ProviderContainer(
      overrides: [
        radioMediaSessionProvider.overrideWithValue(shared),
        radioRepositoryProvider.overrideWithValue(repository),
        radioAudioServiceProvider.overrideWithValue(engine),
        favoritesRepositoryProvider.overrideWithValue(favorites),
        flightTimingProvider.overrideWithValue(
          const FlightTiming(
            minimum: Duration(milliseconds: 20),
            attemptTimeout: Duration(milliseconds: 300),
            signalLostPause: Duration(milliseconds: 10),
          ),
        ),
      ],
    );
    addTearDown(live.dispose);
    live.read(radioNotificationProvider);
    final radio = live.read(radioControllerProvider.notifier);
    repository.stationToReturn = numbered(1);
    await radio.tuneRandom();
    expect(live.read(radioControllerProvider).station, numbered(1));

    final published = <AudioProcessingState>[];
    final watching = shared.playbackState.listen(
      (state) => published.add(state.processingState),
    );
    addTearDown(watching.cancel);
    repository.stationToReturn = numbered(2);
    await radio.tuneRandom();

    expect(player.stops, greaterThan(0), reason: 'the old stream stopped');
    expect(live.read(radioControllerProvider).station, numbered(2));
    expect(
      published,
      isNot(contains(AudioProcessingState.idle)),
      reason: 'an idle state would close the notification mid-flight',
    );
  });

  testWidgets(
    'notification next and previous keep the new stream muted for one second in background',
    (tester) async {
      final sounds = <String>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(nativeChannel, (call) async {
        sounds.add(call.method);
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(nativeChannel, null),
      );
      final player = SharedPlayer();
      final shared = RadioAudioHandler(
        player,
        flightTitle: 'Frequenza',
        flightSubtitle: 'In volo…',
        saveLabel: 'Salva',
        removeLabel: 'Togli',
      );
      final engine = JustAudioService(player: player, mediaSession: shared);
      final live = ProviderContainer(
        overrides: [
          radioMediaSessionProvider.overrideWithValue(shared),
          radioRepositoryProvider.overrideWithValue(repository),
          radioAudioServiceProvider.overrideWithValue(engine),
          favoritesRepositoryProvider.overrideWithValue(favorites),
          flightTimingProvider.overrideWithValue(const FlightTiming()),
        ],
      );
      addTearDown(() async {
        live.dispose();
        await engine.dispose();
        await shared.dispose();
        await player.states.close();
        await player.events.close();
      });
      live.read(radioNotificationProvider);
      repository.stationToReturn = numbered(1);
      final first = live.read(radioControllerProvider.notifier).tuneRandom();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await first;
      await tester.pump(const Duration(milliseconds: 400));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      repository.stationToReturn = numbered(2);
      for (final command in [shared.skipToNext, shared.skipToPrevious]) {
        sounds.clear();
        player.volumes.clear();
        await command();
        await tester.pump();
        expect(live.read(radioControllerProvider), isFlying());
        expect(sounds, contains('start'));
        expect(player.volumes.last, 0);
        await tester.pump(const Duration(milliseconds: 999));
        expect(live.read(radioControllerProvider), isFlying());
        expect(player.volumes.last, 0);
        expect(sounds, isNot(contains('fadeOut')));
        await tester.pump(const Duration(milliseconds: 1));
        expect(live.read(radioControllerProvider), isNot(isFlying()));
        expect(sounds, contains('fadeOut'));
        expect(player.volumes.last, greaterThan(0));
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(live.read(radioControllerProvider).station, numbered(1));
    },
  );

  test('heart before any station does nothing', () async {
    await handler.customAction('favorite');
    await settle();
    expect(favorites.items, isEmpty);
  });

  test('no handler, no errors', () async {
    final bare = open();
    expect(() => bare.read(radioNotificationProvider), returnsNormally);
    expect(bare.read(radioControllerProvider).station, isNull);
  });
}
