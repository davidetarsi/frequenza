import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audio_service_platform_interface/method_channel_audio_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/bootstrap.dart';
import 'package:frequenza/app/localization/application/notification_localization.dart';
import 'package:frequenza/app/localization/domain/app_language.dart';
import 'package:frequenza/app/platform/data/native_channel.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
import 'package:frequenza/features/radio/application/flight_timing.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_notification.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/data/just_audio_service.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

import '../favorites/favorites_test.dart' show MemoryFavorites;
import 'radio_controller_test.dart' show FakeRadioRepository;
import 'radio_notification_test.dart' show SharedPlayer, numbered;

class NoArtworkCache extends Fake implements BaseCacheManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Android channel commands reach the shared player and controller',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const clientChannel = MethodChannel(
        'com.ryanheise.audio_service.client.methods',
      );
      const handlerChannel = MethodChannel(
        'com.ryanheise.audio_service.handler.methods',
      );
      final nativeCalls = <MethodCall>[];
      messenger.setMockMethodCallHandler(clientChannel, (_) async => null);
      messenger.setMockMethodCallHandler(handlerChannel, (call) async {
        nativeCalls.add(call);
        return null;
      });
      messenger.setMockMethodCallHandler(nativeChannel, (_) async => null);
      addTearDown(() {
        messenger.setMockMethodCallHandler(clientChannel, null);
        messenger.setMockMethodCallHandler(handlerChannel, null);
        messenger.setMockMethodCallHandler(nativeChannel, null);
      });
      AudioServicePlatform.instance = MethodChannelAudioService();
      final player = SharedPlayer();
      final handler = await AudioService.init(
        builder: () => RadioAudioHandler(
          player,
          flightTitle: 'Frequenza',
          flightSubtitle: 'In volo',
          saveLabel: 'Salva',
          removeLabel: 'Togli',
        ),
        config: radioServiceConfig(channelName: 'Frequenza'),
        cacheManager: NoArtworkCache(),
      );
      handler.updateLocalization(notificationLocalization(AppLanguage.it));
      final engine = JustAudioService(player: player, mediaSession: handler);
      final repository = FakeRadioRepository()..stationToReturn = numbered(1);
      final favorites = MemoryFavorites();
      final container = ProviderContainer(
        overrides: [
          radioMediaSessionProvider.overrideWithValue(handler),
          radioAudioServiceProvider.overrideWithValue(engine),
          radioRepositoryProvider.overrideWithValue(repository),
          favoritesRepositoryProvider.overrideWithValue(favorites),
          flightTimingProvider.overrideWithValue(
            const FlightTiming(
              minimum: Duration(milliseconds: 20),
              attemptTimeout: Duration(milliseconds: 300),
            ),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await handler.dispose();
        await engine.dispose();
      });
      container.read(radioNotificationProvider);
      await container.read(favoritesProvider.future);
      final radio = container.read(radioControllerProvider.notifier);
      await radio.tuneRandom();
      Future<void> command(String name, [Map<String, dynamic>? args]) async {
        final done = Completer<void>();
        messenger.handlePlatformMessage(
          handlerChannel.name,
          handlerChannel.codec.encodeMethodCall(MethodCall(name, args ?? {})),
          (reply) {
            try {
              handlerChannel.codec.decodeEnvelope(reply!);
              done.complete();
            } catch (error, stack) {
              done.completeError(error, stack);
            }
          },
        );
        await done.future;
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }

      await command('pause');
      expect(player.playing, false);
      expect(
        (container.read(radioControllerProvider) as OnAir).playback,
        OnAirPlayback.paused,
      );
      await command('play');
      expect(player.playing, true);
      repository.stationToReturn = numbered(2);
      await command('skipToNext');
      expect(
        (container.read(radioControllerProvider) as OnAir).station,
        numbered(2),
      );
      await command('skipToPrevious');
      expect(
        (container.read(radioControllerProvider) as OnAir).station,
        numbered(1),
      );
      await command('customAction', {'name': 'favorite', 'extras': null});
      expect(favorites.items, [numbered(1)]);
      expect(nativeCalls.any((c) => c.method == 'setState'), true);
      await command('onTaskRemoved');
      expect(container.read(radioControllerProvider), isA<Off>());
      expect(player.playing, false);
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
      expect(handler.playbackState.value.controls, isEmpty);
      expect(nativeCalls.any((c) => c.method == 'stopService'), true);

      // A new UI session can play; removing a paused task stops it too.
      await radio.tuneRandom();
      await command('pause');
      await command('onTaskRemoved');
      expect(container.read(radioControllerProvider), isA<Off>());
      expect(player.playing, false);

      // A directory request can complete after close. It must neither start
      // a new stream nor bring the notification back.
      final request = Completer<RadioStation?>();
      repository.pendingStation = request;
      final flight = radio.tuneRandom();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(radioControllerProvider), isA<Flying>());
      await command('onTaskRemoved');
      final startsBeforeReply = player.plays;
      request.complete(numbered(3));
      await flight;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(player.plays, startsBeforeReply);
      expect(player.playing, false);
      expect(container.read(radioControllerProvider), isA<Off>());
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
    },
  );
}
