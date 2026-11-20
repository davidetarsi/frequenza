import 'dart:async';

import 'package:audio_session/audio_session.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/just_audio_service.dart';
import 'package:frequenza/app/platform/data/native_channel.dart';
import 'package:frequenza/features/radio/domain/radio_media_session.dart';
import 'package:frequenza/features/radio/domain/radio_media_localization.dart';
import 'package:frequenza/features/radio/domain/radio_audio_service.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:just_audio/just_audio.dart';

class LivePlayer extends Fake implements AudioPlayer {
  final playback = Completer<void>();
  final calls = <String>[];
  final states = StreamController<PlayerState>.broadcast();
  final icy = StreamController<IcyMetadata?>.broadcast();

  @override
  Future<void> setVolume(double volume) async => calls.add('volume $volume');

  @override
  Stream<PlayerState> get playerStateStream => states.stream;

  @override
  Stream<IcyMetadata?> get icyMetadataStream => icy.stream;

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
  Future<void> pause() async => calls.add('pause');

  @override
  bool get playing => false;

  @override
  Future<void> dispose() async {
    if (!playback.isCompleted) playback.complete();
  }
}

class RecordingSession implements RadioMediaSession {
  @override
  void updateLocalization(RadioMediaLocalization localization) {}
  RadioStation? shown;
  var flights = 0;

  @override
  void showStation(RadioStation station) => shown = station;

  @override
  void showFlight() => flights++;

  @override
  void showControls({required bool flying, required bool saved}) {}

  @override
  void setStopHandler(Future<void> Function()? stop) {}

  @override
  Stream<RadioMediaCommand> get commands => const Stream.empty();
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

  test('a paused stream still buffering reads as paused', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    final statuses = <PlaybackStatus>[];
    service.playbackStatusStream.listen(statuses.add);

    player.states
      ..add(PlayerState(true, ProcessingState.buffering))
      ..add(PlayerState(false, ProcessingState.buffering));
    await pumpEventQueue();

    expect(statuses, [PlaybackStatus.buffering, PlaybackStatus.paused]);
  });

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

  test('a new station starts without the title of the last one', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    final titles = <String?>[];
    service.trackTitleStream.listen(titles.add);

    player.icy.add(
      IcyMetadata(info: IcyInfo(title: ' Old song ', url: null), headers: null),
    );
    await pumpEventQueue();
    await service.playStation(station).timeout(const Duration(seconds: 1));
    await pumpEventQueue();

    expect(titles, ['Old song', null]);
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
    expect(session.shown?.id, station.id);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(player.calls.last, 'volume 1.0');
  });

  List<double> volumes(LivePlayer player) => [
    for (final call in player.calls)
      if (call.startsWith('volume ')) double.parse(call.substring(7)),
  ];

  test('only a landing fades the static out', () async {
    final methods = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, (call) async {
          methods.add(call.method);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nativeChannel, null),
    );
    final service = JustAudioService(player: LivePlayer());
    addTearDown(service.dispose);
    await service.startTuningSound();
    await service.stopTuningSound(fade: true);
    await service.startTuningSound();
    await service.stopTuningSound();
    expect(methods, ['start', 'fadeOut', 'start', 'stop']);
  });

  test('the station fades in', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await service.playStation(station);
    final before = volumes(player).length;
    await service.land(station);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final fade = volumes(player).sublist(before);
    expect(fade.length, greaterThan(2));
    expect(fade.first, lessThan(0.5));
    expect(fade.last, 1.0);
    for (var i = 1; i < fade.length; i++) {
      expect(fade[i], greaterThan(fade[i - 1]));
    }
  });

  test('a new flight during the fade keeps the next station silent', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await service.playStation(station);
    await service.land(station);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await service.playStation(station);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(volumes(player).last, 0.0);
  });

  test('a duck during the fade ends ducked', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await service.playStation(station);
    await service.land(station);
    service.handleInterruption(
      AudioInterruptionEvent(true, AudioInterruptionType.duck),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(volumes(player).last, 0.2);
  });

  test('a system pause is reported and pauses the player', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    await pumpEventQueue();
    var reported = 0;
    final subscription = service.systemPauses.listen((_) => reported++);
    addTearDown(subscription.cancel);
    await service.playStation(station);
    service.handleInterruption(
      AudioInterruptionEvent(true, AudioInterruptionType.pause),
    );
    await pumpEventQueue();
    expect(reported, 1);
    expect(player.calls, contains('pause'));
  });

  test('a pause asked by the app is not a system pause', () async {
    final player = LivePlayer();
    final service = JustAudioService(player: player);
    addTearDown(service.dispose);
    var reported = 0;
    final subscription = service.systemPauses.listen((_) => reported++);
    addTearDown(subscription.cancel);
    await service.playStation(station);
    await service.pause();
    await service.land(station);
    await service.pause();
    await pumpEventQueue();
    expect(reported, 0);
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(player.calls.last, 'volume 0.2');
  });
}
