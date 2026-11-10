import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'features/radio/radio_controller_test.dart';
import 'features/favorites/favorites_test.dart';

void main() {
  testWidgets(
    'knob tunes; save persists; favorite selection starts the station',
    (tester) async {
      final repository = FakeRadioRepository()..stationToReturn = station;
      final audio = FakeAudioService();
      addTearDown(audio.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            radioRepositoryProvider.overrideWithValue(repository),
            radioAudioServiceProvider.overrideWithValue(audio),
            favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
          ],
          child: const StarterApp(locale: Locale('it')),
        ),
      );
      await tester.pumpAndSettle();
      expect(audio.lastPlayedStation, isNull);
      expect(find.text('Dove andiamo?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tune-knob')));
      await tester.pumpAndSettle();
      expect(find.text('Radio'), findsOneWidget);
      await tester.ensureVisible(find.text('Salva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();
      expect(find.text('Salvata'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('favorites-open')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('favorites-open')));
      await tester.pumpAndSettle();
      expect(find.text('Le tue frequenze'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('favorite-play-id')));
      await tester.pumpAndSettle();
      expect(find.text('Le tue frequenze'), findsNothing);
      expect(audio.lastPlayedStation?.id, 'id');
    },
  );
  testWidgets('travel radio remains usable with narrow screen and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    final saved = MemoryFavorites()
      ..items = const [
        RadioStation(
          id: 'long',
          name: 'Una stazione dal nome molto lungo da mostrare senza tagli',
          streamUrl: 'https://example.com/live',
          country: 'Italia',
          countryCode: 'IT',
        ),
      ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(saved),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('favorites-open')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('favorites-open')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorites-open')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('favorite-play-long')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Una stazione dal nome'), findsOneWidget);
  });
}
