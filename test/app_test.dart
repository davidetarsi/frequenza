import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/radio/presentation/radio_cabinet.dart';
import 'features/radio/radio_controller_test.dart';
import 'features/favorites/favorites_test.dart';

void expectKeysInsideRadio(WidgetTester tester) {
  final radio = tester.getRect(find.byType(RadioCabinet));
  for (final key in ['radio-key-play', 'radio-key-save']) {
    final rect = tester.getRect(find.byKey(ValueKey(key)));
    expect(
      radio.contains(rect.topLeft) && radio.contains(rect.bottomRight),
      isTrue,
      reason: '$key outside the radio',
    );
    expect(rect.height, greaterThanOrEqualTo(44));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'knob tunes; save persists; favorite selection starts the station',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
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
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(390, 900);
      await tester.pumpAndSettle();
      final cabinet = find.byType(RadioCabinet);
      final initialSize = tester.getSize(cabinet);
      tester.view.physicalSize = const Size(620, 900);
      await tester.pumpAndSettle();
      expect(tester.getSize(cabinet), initialSize);
      expect(find.text('Tocca la manopola per cambiare radio'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('tune-knob')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 999));
      expect(audio.landed, isEmpty);
      expect(audio.tuningSoundActive, isTrue);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Radio'), findsOneWidget);
      expect(audio.tuningSoundActive, isFalse);
      expect(tester.getSize(cabinet), initialSize);
      final speaker = tester.getRect(
        find.byKey(const ValueKey('radio-speaker')),
      );
      final dial = tester.getRect(
        find.byKey(const ValueKey('radio-dial-face')),
      );
      expect(dial.size, speaker.size);
      expect(dial.center.dy, speaker.center.dy);
      expect(find.byKey(const ValueKey('route-map')), findsOneWidget);
      audio.trackTitles.add('Artista — Titolo');
      await tester.pumpAndSettle();
      expect(find.text('Artista — Titolo'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tune-knob')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Artista — Titolo'), findsNothing);
      expect(find.byType(Scrollable), findsNothing);
      expect(find.byTooltip('Salva').hitTestable(), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('radio-key-save')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Salvata'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('favorites-open')));
      await tester.pumpAndSettle();
      expect(find.text('Le tue frequenze'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('favorite-play-id')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Le tue frequenze'), findsNothing);
      expect(audio.lastPlayedStation?.id, 'id');
      expect(tester.binding.hasScheduledFrame, isFalse);
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.tap(find.byKey(const ValueKey('radio-key-play')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-map')), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.tap(find.byTooltip('Impostazioni'));
      await tester.pumpAndSettle();
      expect(find.text('Aspetto e lingua della radio.'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      await tester.tap(find.text('Scuro'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Aspetto'))).brightness,
        Brightness.dark,
      );
      await tester.tap(find.text('Inglese'));
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsNothing);
      expect(find.text('Next stop: anywhere'), findsOneWidget);
      expect(tester.getSize(cabinet), initialSize);
      expect(find.byType(Scrollable), findsNothing);
    },
  );
  testWidgets('travel radio remains usable with narrow screen and 200% text', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPadding);
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
          radioRepositoryProvider.overrideWithValue(
            FakeRadioRepository()..stationToReturn = saved.items.single,
          ),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(saved),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsNothing);
    final credits = find.text('WEB RADIO · SENZA CONFINI');
    final nextStop = find.text('Prossima fermata: ovunque');
    expect(nextStop.hitTestable(), findsOneWidget);
    expect(
      tester.getRect(nextStop).bottom,
      lessThan(tester.getRect(find.byType(RadioCabinet)).top),
    );
    expect(
      tester.getRect(credits).top,
      greaterThan(tester.getRect(find.byType(RadioCabinet)).bottom),
    );
    expect(credits.hitTestable(), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tune-knob')).hitTestable(),
      findsOneWidget,
    );
    expect(find.byTooltip('Salva').hitTestable(), findsOneWidget);
    expect(find.byTooltip('Riprendi').hitTestable(), findsOneWidget);
    expectKeysInsideRadio(tester);
    await tester.tap(find.byKey(const ValueKey('tune-knob')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Pausa').hitTestable(), findsOneWidget);
    expect(find.byTooltip('Salvata').hitTestable(), findsOneWidget);
    expectKeysInsideRadio(tester);
    expect(
      // On air, the station's local time takes the bars' place.
      find.byIcon(Icons.schedule).hitTestable(),
      findsOneWidget,
    );
    tester.view.physicalSize = const Size(640, 320);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(credits.hitTestable(), findsOneWidget);
    expect(nextStop.hitTestable(), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tune-knob')).hitTestable(),
      findsOneWidget,
    );
    expect(find.byTooltip('Salvata').hitTestable(), findsOneWidget);
    expectKeysInsideRadio(tester);
    tester.view.physicalSize = const Size(320, 640);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorites-open')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('favorite-play-long')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('favorite-play-long')),
        matching: find.textContaining('Una stazione dal nome'),
      ),
      findsOneWidget,
    );
  });
  testWidgets(
    'favorites recover from load failure and can be removed from the sheet',
    (tester) async {
      final favorites = MemoryFavorites()
        ..items = [station]
        ..failLoad = true;
      final audio = FakeAudioService();
      addTearDown(audio.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
            radioAudioServiceProvider.overrideWithValue(audio),
            favoritesRepositoryProvider.overrideWithValue(favorites),
          ],
          child: const StarterApp(locale: Locale('it')),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('favorites-open')));
      await tester.pumpAndSettle();
      expect(find.text('Riprova'), findsOneWidget);
      favorites.failLoad = false;
      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('favorite-play-id')), findsOneWidget);
      await tester.tap(find.byTooltip('Rimuovi dai preferiti'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('favorite-play-id')), findsNothing);
      expect(find.textContaining('tasto con il cuore'), findsOneWidget);
    },
  );
  testWidgets(
    'favorites button is a heart with the count in the primary colour',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final audio = FakeAudioService();
      addTearDown(audio.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
            radioAudioServiceProvider.overrideWithValue(audio),
            favoritesRepositoryProvider.overrideWithValue(
              MemoryFavorites()..items = [station],
            ),
          ],
          child: const StarterApp(locale: Locale('it')),
        ),
      );
      await tester.pumpAndSettle();
      final button = find.byKey(const ValueKey('favorites-open'));
      final badge = tester.widget<Badge>(
        find.descendant(of: button, matching: find.byType(Badge)),
      );
      final scheme = Theme.of(tester.element(button)).colorScheme;
      expect(badge.backgroundColor, scheme.primary);
      expect(badge.textColor, scheme.onPrimary);
      expect(badge.isLabelVisible, isTrue);
      expect(
        find.descendant(of: button, matching: find.text('1')),
        findsOneWidget,
      );
      expect(find.text('Preferiti · 1'), findsNothing);
      expect(find.byTooltip('Preferiti · 1'), findsOneWidget);
    },
  );
  testWidgets('radio keys do nothing before the first station', (tester) async {
    final favorites = MemoryFavorites();
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(favorites),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    for (final key in ['radio-key-play', 'radio-key-save']) {
      expect(
        tester.getSemantics(find.byKey(ValueKey(key))),
        containsSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      await tester.tap(find.byKey(ValueKey(key)), warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    expect(favorites.items, isEmpty);
    expect(audio.lastPlayedStation, isNull);
  });
}
