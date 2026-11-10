import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

import 'features/radio/radio_controller_test.dart';

void main() {
  group('StarterApp integration', () {
    late FakeRadioRepository repository;
    late FakeAudioService audioService;

    const testStation = RadioStation(
      id: 'app-station-1',
      name: 'Radio Frequenza Test',
      streamUrl: 'https://stream.frequenza.it/live.mp3',
      country: 'Italy',
      countryCode: 'IT',
      codec: 'MP3',
      bitrate: 192,
    );

    setUp(() {
      repository = FakeRadioRepository();
      audioService = FakeAudioService();
    });

    testWidgets('renders RadioProofPage and tunes to station', (tester) async {
      repository.stationToReturn = testStation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            radioRepositoryProvider.overrideWithValue(repository),
            radioAudioServiceProvider.overrideWithValue(audioService),
          ],
          child: const StarterApp(locale: Locale('it')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Frequenza'), findsOneWidget);
      expect(find.text('Nessuna stazione sintonizzata'), findsOneWidget);

      await tester.tap(find.text('Sintonizza'));
      await tester.pumpAndSettle();

      expect(find.text('Radio Frequenza Test'), findsOneWidget);
      expect(find.text('In riproduzione'), findsOneWidget);
    });

    testWidgets('remains usable with large text on a narrow display', (
      tester,
    ) async {
      repository.stationToReturn = testStation;

      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            radioRepositoryProvider.overrideWithValue(repository),
            radioAudioServiceProvider.overrideWithValue(audioService),
          ],
          child: const StarterApp(locale: Locale('it')),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final tuneBtn = find.text('Sintonizza').hitTestable();
      final mainScrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(tuneBtn, 200, scrollable: mainScrollable);
      await tester.tap(tuneBtn);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Radio Frequenza Test'),
        -200,
        scrollable: mainScrollable,
      );
      expect(find.text('Radio Frequenza Test'), findsOneWidget);
    });
  });
}
