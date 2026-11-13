import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/geo_point.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/radio/application/flight_timing.dart';
import 'package:frequenza/features/radio/domain/radio_audio_service.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';
import 'package:frequenza/features/radio/domain/radio_repository.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

class FakeRadioRepository implements RadioRepository {
  Completer<RadioStation?>? pendingStation;
  var randomCalls = 0;
  RadioStation? stationToReturn;
  Exception? errorToThrow;

  @override
  Future<List<RadioStation>> getCandidates({
    String? countryCode,
    int limit = 20,
  }) async {
    return stationToReturn != null ? [stationToReturn!] : [];
  }

  @override
  Future<RadioStation?> getRandomStation({String? countryCode}) async {
    randomCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    if (pendingStation != null) return pendingStation!.future;
    return stationToReturn;
  }
}

class FakeAudioService implements RadioAudioService {
  final _statusController = StreamController<PlaybackStatus>.broadcast();
  final trackTitles = StreamController<String?>.broadcast();
  final interruptions = StreamController<void>.broadcast();

  @override
  Stream<void> get flightInterruptions => interruptions.stream;

  @override
  Stream<String?> get trackTitleStream => trackTitles.stream;

  PlaybackStatus _currentStatus = PlaybackStatus.idle;
  RadioStation? lastPlayedStation;
  final played = <RadioStation>[];
  var autoPlay = true;
  var stops = 0;
  bool isDisposed = false;
  bool tuningSoundActive = false;

  @override
  Future<void> startTuningSound() async => tuningSoundActive = true;

  @override
  Future<void> stopTuningSound() async => tuningSoundActive = false;

  @override
  Stream<PlaybackStatus> get playbackStatusStream => _statusController.stream;

  @override
  PlaybackStatus get currentStatus => _currentStatus;

  void emitStatus(PlaybackStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Future<void> playStation(RadioStation station) async {
    lastPlayedStation = station;
    played.add(station);
    emitStatus(PlaybackStatus.buffering);
    if (autoPlay) emitStatus(PlaybackStatus.playing);
  }

  final landed = <RadioStation>[];

  @override
  Future<void> land(RadioStation station) async => landed.add(station);

  @override
  Future<void> play() async {
    emitStatus(PlaybackStatus.playing);
  }

  @override
  Future<void> pause() async {
    emitStatus(PlaybackStatus.paused);
  }

  @override
  Future<void> stop() async {
    stops++;
    emitStatus(PlaybackStatus.idle);
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await _statusController.close();
    await trackTitles.close();
  }
}

const fastFlights = FlightTiming(
  minimum: Duration(milliseconds: 50),
  attemptTimeout: Duration(milliseconds: 300),
  signalLostPause: Duration(milliseconds: 10),
);

Future<void> wait(int milliseconds) =>
    Future<void>.delayed(Duration(milliseconds: milliseconds));

void main() {
  group('RadioController', () {
    late FakeRadioRepository repository;
    late FakeAudioService audioService;
    late RadioController controller;
    late ProviderContainer container;

    const testStation = RadioStation(
      id: 'station-1',
      name: 'Radio Test',
      streamUrl: 'https://stream.test/live.mp3',
      country: 'Italy',
      countryCode: 'IT',
    );

    setUp(() {
      repository = FakeRadioRepository();
      audioService = FakeAudioService();
      container = ProviderContainer(
        overrides: [
          radioRepositoryProvider.overrideWithValue(repository),
          radioAudioServiceProvider.overrideWithValue(audioService),
          flightTimingProvider.overrideWithValue(fastFlights),
        ],
      );
      controller = container.read(radioControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
      audioService.dispose();
    });

    test('initial state is idle without station', () {
      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.idle,
      );
      expect(container.read(radioControllerProvider).station, isNull);
      expect(container.read(radioControllerProvider).errorMessage, isNull);
    });

    test('tuneRandom fetches station and starts playback', () async {
      repository.stationToReturn = testStation;

      final future = controller.tuneRandom();
      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.tuning,
      );

      await future;

      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.playing,
      );
      expect(container.read(radioControllerProvider).station, testStation);
      expect(audioService.lastPlayedStation, testStation);
    });

    test(
      'race condition: newer tune cancels previous pending request',
      () async {
        final firstPending = Completer<RadioStation?>();
        repository.pendingStation = firstPending;

        // Start first tune
        final firstFuture = controller.tuneRandom();
        expect(
          container.read(radioControllerProvider).status,
          PlaybackStatus.tuning,
        );

        // Start second tune immediately with a new station
        const secondStation = RadioStation(
          id: 'station-2',
          name: 'Second Radio',
          streamUrl: 'https://stream.test/second.mp3',
          country: 'France',
          countryCode: 'FR',
        );
        repository.pendingStation = null;
        repository.stationToReturn = secondStation;
        final secondFuture = controller.tuneRandom();

        await secondFuture;

        expect(container.read(radioControllerProvider).station, secondStation);
        expect(audioService.lastPlayedStation, secondStation);

        // Complete the first (older) request late
        firstPending.complete(testStation);
        await firstFuture;

        // Ensure state was NOT overwritten by the old first request
        expect(container.read(radioControllerProvider).station, secondStation);
        expect(audioService.lastPlayedStation, secondStation);
      },
    );

    test('handles repository error gracefully', () async {
      repository.errorToThrow = Exception('Network down');

      await controller.tuneRandom();

      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.error,
      );
      expect(audioService.tuningSoundActive, isFalse);
      expect(container.read(radioControllerProvider).errorMessage, isNotNull);
    });

    test('a new tune clears the error from a failed attempt', () async {
      repository.errorToThrow = Exception('Offline');
      await controller.tuneRandom();
      expect(container.read(radioControllerProvider).errorMessage, isNotNull);
      repository.errorToThrow = null;
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.playing,
      );
      expect(container.read(radioControllerProvider).errorMessage, isNull);
    });

    RadioPlayerState read() => container.read(radioControllerProvider);

    test(
      'lands only after the minimum even if playing arrives at once',
      () async {
        final flight = controller.tuneTo(testStation);
        await wait(20);
        expect(read().status, PlaybackStatus.tuning);
        expect(read().flight, FlightPhase.flying);
        expect(audioService.landed, isEmpty);
        await flight;
        expect(read().status, PlaybackStatus.playing);
        expect(read().flight, FlightPhase.grounded);
        expect(audioService.landed, [testStation]);
      },
    );

    test('waits for playback beyond the minimum', () async {
      audioService.autoPlay = false;
      final flight = controller.tuneTo(testStation);
      await wait(100);
      expect(read().status, PlaybackStatus.tuning);
      expect(read().station, isNull);
      expect(audioService.tuningSoundActive, isTrue);
      expect(audioService.played, [testStation]);
      audioService.emitStatus(PlaybackStatus.playing);
      await flight;
      expect(read().station, testStation);
      expect(audioService.tuningSoundActive, isFalse);
    });

    test('tune retries twice after timeouts then errors', () async {
      audioService.autoPlay = false;
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(repository.randomCalls, 3);
      expect(audioService.played, hasLength(3));
      expect(read().status, PlaybackStatus.error);
      expect(read().flight, FlightPhase.signalLost);
      expect(audioService.tuningSoundActive, isFalse);
      expect(audioService.landed, isEmpty);
      expect(read().departure, homePlace);
    });

    test('favorite does not retry', () async {
      audioService.autoPlay = false;
      await controller.tuneTo(testStation);
      expect(audioService.played, hasLength(1));
      expect(read().status, PlaybackStatus.error);
      expect(audioService.stops, greaterThan(0));
    });

    test('stalled API ends the attempt at the timeout', () async {
      container.updateOverrides([
        radioRepositoryProvider.overrideWithValue(repository),
        radioAudioServiceProvider.overrideWithValue(audioService),
        flightTimingProvider.overrideWithValue(
          const FlightTiming(
            minimum: Duration(milliseconds: 50),
            attemptTimeout: Duration(milliseconds: 300),
            autoRetries: 0,
          ),
        ),
      ]);
      repository.pendingStation = Completer<RadioStation?>();
      final watch = Stopwatch()..start();
      await controller.tuneRandom();
      expect(watch.elapsedMilliseconds, lessThan(400));
      expect(read().status, PlaybackStatus.error);
      repository.pendingStation!.complete(testStation);
      await wait(10);
      expect(audioService.played, isEmpty);
    });

    test('a newer tune cancels the flight', () async {
      const second = RadioStation(
        id: 'station-2',
        name: 'Second Radio',
        streamUrl: 'https://stream.test/second.mp3',
        country: 'France',
        countryCode: 'FR',
      );
      audioService.autoPlay = false;
      final first = controller.tuneTo(testStation);
      await wait(10);
      audioService.autoPlay = true;
      final next = controller.tuneTo(second);
      audioService.emitStatus(PlaybackStatus.playing);
      await Future.wait([first, next]);
      expect(read().station, second);
      expect(read().trips, 1);
      expect(audioService.landed, [second]);
    });

    test('landing records the leg and moves the departure', () async {
      const tokyo = RadioStation(
        id: 'tokyo',
        name: 'Tokyo FM',
        streamUrl: 'https://stream.test/tokyo.mp3',
        country: 'Japan',
        countryCode: 'JP',
        latitude: 35.68,
        longitude: 139.76,
      );
      const paris = RadioStation(
        id: 'paris',
        name: 'FIP',
        streamUrl: 'https://stream.test/fip.mp3',
        country: 'France',
        countryCode: 'FR',
      );
      await controller.tuneTo(tokyo);
      expect(read().leg?.from, homePlace);
      await controller.tuneTo(paris);
      expect(read().trips, 2);
      expect(read().history, hasLength(2));
      expect(read().leg?.from.point, const GeoPoint(35.68, 139.76));
      expect(read().departure.countryCode, 'FR');
      expect(read().departure.approximate, isTrue);
      for (var i = 0; i < 4; i++) {
        await controller.tuneTo(i.isEven ? tokyo : paris);
      }
      expect(read().trips, 6);
      expect(read().history, hasLength(5));
    });

    test('stop during flight grounds the radio', () async {
      audioService.autoPlay = false;
      final flight = controller.tuneTo(testStation);
      await wait(20);
      await controller.stop();
      await flight;
      expect(read().status, PlaybackStatus.idle);
      expect(read().flight, FlightPhase.grounded);
      expect(audioService.tuningSoundActive, isFalse);
      expect(audioService.landed, isEmpty);
    });

    test('landing reports a pause that arrived during the flight', () async {
      final flight = controller.tuneTo(testStation);
      await wait(10);
      audioService.emitStatus(PlaybackStatus.paused);
      await flight;
      expect(read().station, testStation);
      expect(read().status, PlaybackStatus.paused);
    });

    test('a system pause during the flight cancels it', () async {
      audioService.autoPlay = false;
      repository.stationToReturn = testStation;
      final flight = controller.tuneRandom();
      await wait(20);
      audioService.interruptions.add(null);
      await flight;
      expect(read().status, PlaybackStatus.idle);
      expect(read().flight, FlightPhase.grounded);
      expect(audioService.played, hasLength(1));
      expect(audioService.landed, isEmpty);
      expect(audioService.tuningSoundActive, isFalse);
    });

    test('stop during a later flight turns the map off', () async {
      await controller.tuneTo(testStation);
      audioService.autoPlay = false;
      final flight = controller.tuneTo(testStation);
      await wait(10);
      await controller.stop();
      await flight;
      expect(read().leg, isNull);
    });

    test('pause and stop control audio service', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.playing,
      );

      await controller.pause();
      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.paused,
      );

      await controller.stop();
      expect(
        container.read(radioControllerProvider).status,
        PlaybackStatus.idle,
      );
    });
  });
}
