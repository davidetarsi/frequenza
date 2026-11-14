import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/favorites/application/favorites_controller.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/flight_timing.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_notification.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import '../favorites/favorites_test.dart';
import 'radio_audio_handler_test.dart';
import 'radio_controller_test.dart';

RadioStation numbered(int n) => RadioStation(
  id: 'station-$n',
  name: 'Radio $n',
  streamUrl: 'https://stream.test/$n.mp3',
  country: 'Italy',
  countryCode: 'IT',
);

void main() {
  late RadioAudioHandler handler;
  late FakeRadioRepository repository;
  late FakeAudioService audio;
  late MemoryFavorites favorites;
  late ProviderContainer container;

  ProviderContainer open({RadioAudioHandler? session}) {
    final opened = ProviderContainer(
      overrides: [
        radioAudioHandlerProvider.overrideWithValue(session),
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

  test('previous flies back, and the key follows the stack', () async {
    repository.stationToReturn = numbered(1);
    await controller().tuneRandom();
    expect(backOffered(), isFalse);
    repository.stationToReturn = numbered(2);
    await controller().tuneRandom();
    expect(backOffered(), isTrue);
    await handler.skipToPrevious();
    await settle();
    expect(container.read(radioControllerProvider).station, numbered(1));
    expect(backOffered(), isFalse);
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
