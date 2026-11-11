import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/radio/presentation/radio_proof_page.dart';

import 'radio_controller_test.dart';

void main() {
  group('RadioProofPage', () {
    late FakeRadioRepository repository;
    late FakeAudioService audioService;

    const testStation = RadioStation(
      id: 'uuid-proof',
      name: 'Radio Capital',
      streamUrl: 'https://stream.capital.it/live.mp3',
      country: 'Italy',
      countryCode: 'IT',
      codec: 'MP3',
      bitrate: 128,
    );

    setUp(() {
      repository = FakeRadioRepository();
      audioService = FakeAudioService();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          radioRepositoryProvider.overrideWithValue(repository),
          radioAudioServiceProvider.overrideWithValue(audioService),
        ],
        child: const MaterialApp(home: RadioProofPage(appName: 'Frequenza')),
      );
    }

    testWidgets('renders initial idle UI', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Frequenza'), findsOneWidget);
      expect(find.text('Nessuna stazione sintonizzata'), findsOneWidget);
      expect(find.text('Sintonizza'), findsOneWidget);
      expect(find.text('Inattivo'), findsOneWidget);
    });

    testWidgets(
      'tune button updates UI with station details and playing badge',
      (tester) async {
        final completer = Completer<RadioStation?>();
        repository.pendingStation = completer;

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Sintonizza'));
        await tester.pump(); // Enter tuning state

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Sintonizzazione...'), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        expect(audioService.tuningSoundActive, isTrue);
        expect(audioService.lastPlayedStation, isNull);
        completer.complete(testStation);
        await tester.pumpAndSettle(); // Resolve station and settle playback

        expect(audioService.tuningSoundActive, isFalse);
        expect(find.text('Radio Capital'), findsOneWidget);
        expect(find.text('Italy (IT)'), findsOneWidget);
        expect(find.text('In riproduzione'), findsOneWidget);
        expect(find.text('MP3 128 kbps'), findsOneWidget);
        expect(find.text('Sintonizza'), findsOneWidget);
      },
    );

    testWidgets('pause and stop buttons update UI correctly', (tester) async {
      repository.stationToReturn = testStation;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Sintonizza'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('In riproduzione'), findsOneWidget);

      final mainScrollable = find.byType(Scrollable).first;

      // Tap pause button
      final pauseBtn = find.byKey(const ValueKey('play-pause-button'));
      await tester.scrollUntilVisible(
        pauseBtn,
        200,
        scrollable: mainScrollable,
      );
      await tester.tap(pauseBtn);
      await tester.pumpAndSettle();
      expect(find.text('In pausa'), findsOneWidget);

      // Tap stop button
      final stopBtn = find.byKey(const ValueKey('stop-button'));
      await tester.scrollUntilVisible(stopBtn, 200, scrollable: mainScrollable);
      await tester.tap(stopBtn);
      await tester.pumpAndSettle();
      expect(find.text('Inattivo'), findsOneWidget);
    });
  });
}
