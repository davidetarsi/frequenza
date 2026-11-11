import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/application/radio_audio_service.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/domain/radio_player_state.dart';
import 'package:frequenza/features/radio/domain/radio_repository.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

class FakeRadioRepository implements RadioRepository {
  Completer<RadioStation?>? pendingStation;
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
    if (errorToThrow != null) throw errorToThrow!;
    if (pendingStation != null) return pendingStation!.future;
    return stationToReturn;
  }
}

class FakeAudioService implements RadioAudioService {
  final _statusController = StreamController<PlaybackStatus>.broadcast();
  final trackTitles = StreamController<String?>.broadcast();

  @override
  Stream<String?> get trackTitleStream => trackTitles.stream;

  PlaybackStatus _currentStatus = PlaybackStatus.idle;
  RadioStation? lastPlayedStation;
  bool isDisposed = false;

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
    emitStatus(PlaybackStatus.playing);
  }

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
    emitStatus(PlaybackStatus.idle);
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
    await _statusController.close();
    await trackTitles.close();
  }
}

void main() {
  group('RadioController', () {
    late FakeRadioRepository repository;
    late FakeAudioService audioService;
    late RadioController controller;

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
      controller = RadioController(
        repository: repository,
        audioService: audioService,
      );
    });

    tearDown(() {
      controller.dispose();
      audioService.dispose();
    });

    test('initial state is idle without station', () {
      expect(controller.state.status, PlaybackStatus.idle);
      expect(controller.state.station, isNull);
      expect(controller.state.errorMessage, isNull);
    });

    test('tuneRandom fetches station and starts playback', () async {
      repository.stationToReturn = testStation;

      final future = controller.tuneRandom();
      expect(controller.state.status, PlaybackStatus.tuning);

      await future;

      expect(controller.state.status, PlaybackStatus.playing);
      expect(controller.state.station, testStation);
      expect(audioService.lastPlayedStation, testStation);
    });

    test(
      'race condition: newer tune cancels previous pending request',
      () async {
        final firstPending = Completer<RadioStation?>();
        repository.pendingStation = firstPending;

        // Start first tune
        final firstFuture = controller.tuneRandom();
        expect(controller.state.status, PlaybackStatus.tuning);

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

        expect(controller.state.station, secondStation);
        expect(audioService.lastPlayedStation, secondStation);

        // Complete the first (older) request late
        firstPending.complete(testStation);
        await firstFuture;

        // Ensure state was NOT overwritten by the old first request
        expect(controller.state.station, secondStation);
        expect(audioService.lastPlayedStation, secondStation);
      },
    );

    test('handles repository error gracefully', () async {
      repository.errorToThrow = Exception('Network down');

      await controller.tuneRandom();

      expect(controller.state.status, PlaybackStatus.error);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('a new tune clears the error from a failed attempt', () async {
      repository.errorToThrow = Exception('Offline');
      await controller.tuneRandom();
      expect(controller.state.errorMessage, isNotNull);
      repository.errorToThrow = null;
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(controller.state.status, PlaybackStatus.playing);
      expect(controller.state.errorMessage, isNull);
    });

    test('pause and stop control audio service', () async {
      repository.stationToReturn = testStation;
      await controller.tuneRandom();
      expect(controller.state.status, PlaybackStatus.playing);

      await controller.pause();
      expect(controller.state.status, PlaybackStatus.paused);

      await controller.stop();
      expect(controller.state.status, PlaybackStatus.idle);
    });
  });
}
