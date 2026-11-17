import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/geo_point.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/radio/application/flight_timing.dart';
import 'package:frequenza/features/radio/domain/radio_audio_service.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';

import 'radio_session_matchers.dart';
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

  Set<String>? lastCountries;
  Set<String> lastAvoid = const {};
  final avoids = <Set<String>>[];

  @override
  Future<RadioStation?> getRandomStation({
    Set<String>? countries,
    Set<String> avoid = const {},
  }) async {
    randomCalls++;
    lastCountries = countries;
    lastAvoid = avoid;
    avoids.add(avoid);
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
  Stream<void> get systemPauses => interruptions.stream;

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
  Future<void> stopTuningSound({bool fade = false}) async {
    tuningSoundActive = false;
    tuningStops.add(fade);
  }

  /// Whether each stop of the static faded it out.
  final tuningStops = <bool>[];

  @override
  Stream<PlaybackStatus> get playbackStatusStream => _statusController.stream;

  @override
  PlaybackStatus get currentStatus => _currentStatus;

  void emitStatus(PlaybackStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// The title each station sends as soon as it connects, by id.
  final titlesOnConnect = <String, String>{};

  @override
  Future<void> playStation(RadioStation station) async {
    lastPlayedStation = station;
    played.add(station);
    trackTitles.add(null);
    final title = titlesOnConnect[station.id];
    if (title != null) trackTitles.add(title);
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
  stallTimeout: Duration(milliseconds: 100),
  pauseTimeout: Duration(milliseconds: 100),
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
      expect(container.read(radioControllerProvider), isOff);
      expect(container.read(radioControllerProvider).station, isNull);
    });

    test('a landed station stuck buffering reconnects by itself', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      final trips = container.read(radioControllerProvider).trips;

      audioService.emitStatus(PlaybackStatus.buffering);
      await wait(400);

      final state = container.read(radioControllerProvider);
      expect(audioService.played, [testStation, testStation]);
      expect(state, isOnAir(OnAirPlayback.playing));
      expect(state.station, testStation);
      expect(state.trips, trips, reason: 'a reconnect is not a new trip');
    });

    test('a short buffering does not reconnect', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();

      audioService.emitStatus(PlaybackStatus.buffering);
      await wait(30);
      audioService.emitStatus(PlaybackStatus.playing);
      await wait(200);

      expect(audioService.played, [testStation]);
    });

    test('a paused station is never reconnected', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();

      await controller.pause();
      await wait(200);

      expect(audioService.played, [testStation]);
    });

    test(
      'a stall timer left from the station on air does not hijack a new flight',
      () async {
        const other = RadioStation(
          id: 'station-2',
          name: 'Other Radio',
          streamUrl: 'https://stream.test/other.mp3',
          country: 'France',
          countryCode: 'FR',
        );
        repository.stationToReturn = testStation;
        await controller.tuneRandom();

        audioService.emitStatus(PlaybackStatus.buffering);
        await wait(30);
        repository.stationToReturn = other;
        await controller.tuneRandom();
        await wait(300);

        expect(audioService.played, [testStation, other]);
        expect(container.read(radioControllerProvider).station, other);
      },
    );

    test('a stall timer does not wake a radio switched off', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();

      audioService.emitStatus(PlaybackStatus.buffering);
      await wait(30);
      await controller.stop();
      await wait(300);

      expect(audioService.played, [testStation]);
      expect(container.read(radioControllerProvider), isOff);
    });

    test('tuneRandom fetches station and starts playback', () async {
      repository.stationToReturn = testStation;

      final future = controller.tuneRandom();
      expect(container.read(radioControllerProvider), isFlying());

      await future;

      expect(
        container.read(radioControllerProvider),
        isOnAir(OnAirPlayback.playing),
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
        expect(container.read(radioControllerProvider), isFlying());

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

      expect(container.read(radioControllerProvider), isFailed);
      expect(audioService.tuningSoundActive, isFalse);
    });

    test('a new tune clears the error from a failed attempt', () async {
      repository.errorToThrow = Exception('Offline');
      await controller.tuneRandom();
      expect(container.read(radioControllerProvider), isFailed);
      repository.errorToThrow = null;
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(
        container.read(radioControllerProvider),
        isOnAir(OnAirPlayback.playing),
      );
    });

    RadioSession read() => container.read(radioControllerProvider);

    test(
      'lands only after the minimum even if playing arrives at once',
      () async {
        final flight = controller.tuneTo(testStation);
        await wait(20);
        expect(read(), isFlying());
        expect(read(), isFlying(signalLost: false));
        expect(audioService.landed, isEmpty);
        await flight;
        expect(read(), isOnAir(OnAirPlayback.playing));
        expect(read(), isNot(isA<Flying>()));
        expect(audioService.landed, [testStation]);
      },
    );

    test('waits for playback beyond the minimum', () async {
      audioService.autoPlay = false;
      final flight = controller.tuneTo(testStation);
      await wait(100);
      expect(read(), isFlying());
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
      expect(read(), isFailed);
      expect(read(), anyOf(isFlying(signalLost: true), isFailed));
      expect(audioService.tuningSoundActive, isFalse);
      expect(audioService.landed, isEmpty);
      expect(read().departure, homePlace);
    });

    test('a retry does not pick again a station that failed to play', () async {
      audioService.autoPlay = false;
      repository.stationToReturn = testStation;

      await controller.tuneRandom();

      expect(repository.avoids, hasLength(3));
      expect(repository.avoids.first, isNot(contains('station-1')));
      expect(repository.avoids[1], contains('station-1'));
      expect(repository.avoids[2], contains('station-1'));
    });

    test('favorite does not retry', () async {
      audioService.autoPlay = false;
      await controller.tuneTo(testStation);
      expect(audioService.played, hasLength(1));
      expect(read(), isFailed);
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
      expect(read(), isFailed);
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

    test('tuning avoids the stations just heard', () async {
      const paris = RadioStation(
        id: 'paris',
        name: 'FIP',
        streamUrl: 'https://stream.test/fip.mp3',
        country: 'France',
        countryCode: 'FR',
      );
      await controller.tuneTo(paris);
      await controller.tuneTo(testStation);
      repository.stationToReturn = testStation;

      await controller.tuneRandom(countries: {'IT', 'FR'});

      expect(repository.lastAvoid, {'paris', 'station-1'});
      expect(repository.lastCountries, {'IT', 'FR'});
    });

    test('the title sent while flying shows once landed', () async {
      repository.stationToReturn = testStation;
      audioService.titlesOnConnect[testStation.id] = 'Artista - Titolo';
      await controller.tuneRandom();

      expect(
        container.read(radioControllerProvider),
        isA<OnAir>().having((s) => s.trackTitle, 'title', 'Artista - Titolo'),
      );
    });

    test('a station without titles does not show the previous one', () async {
      const silent = RadioStation(
        id: 'station-2',
        name: 'Radio Muta',
        streamUrl: 'https://stream.test/muta.mp3',
        country: 'Italy',
        countryCode: 'IT',
      );
      repository.stationToReturn = testStation;
      audioService.titlesOnConnect[testStation.id] = 'Artista - Titolo';
      await controller.tuneRandom();
      repository.stationToReturn = silent;
      await controller.tuneRandom();

      expect(
        container.read(radioControllerProvider),
        isA<OnAir>().having((s) => s.trackTitle, 'title', isNull),
      );
    });

    test('stop during flight grounds the radio', () async {
      audioService.autoPlay = false;
      final flight = controller.tuneTo(testStation);
      await wait(20);
      await controller.stop();
      await flight;
      expect(read(), isOff);
      expect(read(), isNot(isA<Flying>()));
      expect(audioService.tuningSoundActive, isFalse);
      expect(audioService.landed, isEmpty);
    });

    test('landing reports a pause that arrived during the flight', () async {
      final flight = controller.tuneTo(testStation);
      await wait(10);
      audioService.emitStatus(PlaybackStatus.paused);
      await flight;
      expect(read().station, testStation);
      expect(read(), isOnAir(OnAirPlayback.paused));
    });

    test('a system pause during the flight cancels it', () async {
      audioService.autoPlay = false;
      repository.stationToReturn = testStation;
      final flight = controller.tuneRandom();
      await wait(20);
      audioService.interruptions.add(null);
      await flight;
      expect(read(), isOff);
      expect(read(), isNot(isA<Flying>()));
      expect(audioService.played, hasLength(1));
      expect(audioService.landed, isEmpty);
      expect(audioService.tuningSoundActive, isFalse);
    });

    test('landing fades the static out, a stop cuts it', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(audioService.tuningStops.last, isTrue);

      audioService.autoPlay = false;
      final flight = controller.tuneRandom();
      await wait(20);
      audioService.interruptions.add(null);
      await flight;
      expect(audioService.tuningStops.last, isFalse);
    });

    test('a long pause closes the stream', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      final stops = audioService.stops;

      await controller.pause();
      await wait(250);

      expect(audioService.stops, stops + 1);
      expect(read(), isOnAir(OnAirPlayback.ended));
    });

    test('resuming before the timeout keeps the stream', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      final stops = audioService.stops;

      await controller.pause();
      await wait(30);
      await controller.play();
      await wait(200);

      expect(audioService.stops, stops);
      expect(read(), isOnAir(OnAirPlayback.playing));
    });

    test('a flight cancels the pause timer', () async {
      const other = RadioStation(
        id: 'station-2',
        name: 'Other Radio',
        streamUrl: 'https://stream.test/other.mp3',
        country: 'France',
        countryCode: 'FR',
      );
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      await controller.pause();
      await wait(30);
      repository.stationToReturn = other;
      await controller.tuneRandom();
      final stops = audioService.stops;
      await wait(200);

      expect(audioService.stops, stops);
      expect(read(), isOnAir(OnAirPlayback.playing));
      expect(read().station, other);
    });

    test('a stop cancels the pause timer', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      await controller.pause();
      await wait(30);
      await controller.stop();
      final stops = audioService.stops;
      await wait(200);

      expect(audioService.stops, stops);
      expect(read(), isOff);
    });

    test('play on an ended station reconnects it', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      final trips = read().trips;

      audioService.emitStatus(PlaybackStatus.idle);
      await wait(10);
      await controller.play();

      expect(audioService.played, [testStation, testStation]);
      expect(read(), isOnAir(OnAirPlayback.playing));
      expect(read().trips, trips);
    });

    test('play with nothing on air does nothing', () async {
      await controller.play();
      expect(audioService.played, isEmpty);
      expect(read(), isOff);
    });

    test('a system pause on air only pauses', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      final stops = audioService.stops;

      audioService.interruptions.add(null);
      audioService.emitStatus(PlaybackStatus.paused);
      await wait(20);

      expect(read(), isOnAir(OnAirPlayback.paused));
      expect(audioService.stops, stops);
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

    RadioStation numbered(int n) => RadioStation(
      id: 'station-$n',
      name: 'Radio $n',
      streamUrl: 'https://stream.test/$n.mp3',
      country: 'Italy',
      countryCode: 'IT',
    );

    Future<void> landOn(RadioStation station) async {
      repository.stationToReturn = station;
      await controller.tuneRandom();
    }

    test('forward landings stack the stations left behind', () async {
      for (final n in [1, 2, 3]) {
        await landOn(numbered(n));
      }
      expect(read().previous, [numbered(1), numbered(2)]);
      expect(read().canGoBack, isTrue);
    });

    test('tuneBack flies to the last station and pops it', () async {
      for (final n in [1, 2, 3]) {
        await landOn(numbered(n));
      }
      await controller.tuneBack();
      expect(read().station, numbered(2));
      expect(read().previous, [numbered(1)]);
      expect(read().trips, 4);
      await controller.tuneBack();
      expect(read().station, numbered(1));
      expect(read().previous, isEmpty);
      expect(read().canGoBack, isFalse);
    });

    test('a favorite chosen in the app is a forward flight', () async {
      await landOn(numbered(1));
      await controller.tuneTo(numbered(2));
      expect(read().previous, [numbered(1)]);
    });

    test('the stack keeps the last 10', () async {
      for (var n = 1; n <= 12; n++) {
        await landOn(numbered(n));
      }
      expect(read().previous, hasLength(10));
      expect(read().previous.first, numbered(2));
      expect(read().previous.last, numbered(11));
    });

    test('a failed flight back keeps the stack', () async {
      await landOn(numbered(1));
      await landOn(numbered(2));
      audioService.autoPlay = false;
      await controller.tuneBack();
      expect(read(), isFailed);
      expect(read().previous, [numbered(1)]);
    });

    test('tuneBack with nothing on air does nothing', () async {
      await controller.tuneBack();
      expect(read(), isOff);
      expect(audioService.played, isEmpty);
    });

    test('tuneBack with an empty stack reconnects the station', () async {
      await landOn(numbered(1));
      final before = read();
      await controller.tuneBack();
      expect(audioService.played, [numbered(1), numbered(1)]);
      expect(read().station, numbered(1));
      expect(read(), isOnAir(OnAirPlayback.playing));
      expect(read().trips, before.trips);
      expect(read().leg, before.leg);
      expect(read().history, before.history);
      expect(read().previous, isEmpty);
    });

    test('back after a failed flight returns to the station left', () async {
      await landOn(numbered(1));
      await landOn(numbered(2));
      audioService.autoPlay = false;
      await landOn(numbered(3));
      expect(read(), isFailed);
      audioService.autoPlay = true;
      await controller.tuneBack();
      expect(read().station, numbered(2));
      expect(read().previous, [numbered(1)]);
    });

    test('a favorite already on air does not stack itself', () async {
      await landOn(numbered(1));
      await landOn(numbered(2));
      await controller.tuneTo(numbered(2));
      expect(read().previous, [numbered(1)]);
    });

    test('pause and stop control audio service', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(
        container.read(radioControllerProvider),
        isOnAir(OnAirPlayback.playing),
      );

      await controller.pause();
      expect(
        container.read(radioControllerProvider),
        isOnAir(OnAirPlayback.paused),
      );

      await controller.stop();
      expect(container.read(radioControllerProvider), isOff);
    });
  });
}
