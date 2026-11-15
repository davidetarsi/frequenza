import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../favorites/favorites_test.dart';
import '../radio/radio_controller_test.dart';

/// The app as bootstrap starts it: with the welcome flag already read.
Future<ProviderContainer> launch(
  WidgetTester tester, {
  Map<String, Object> preferences = const {},
  bool animations = false,
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: !animations);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final audio = FakeAudioService();
  addTearDown(audio.dispose);
  final container = ProviderContainer(
    overrides: [
      radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
      radioAudioServiceProvider.overrideWithValue(audio),
      favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() => container.read(welcomeSeenProvider.future));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const StarterApp(locale: Locale('en')),
    ),
  );
  if (animations) {
    await tester.pump(const Duration(seconds: 1));
  } else {
    await tester.pumpAndSettle();
  }
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('a first launch opens the welcome; the dial turns the radio on', (
    tester,
  ) async {
    final container = await launch(tester);
    expect(find.text('Tap the dial to turn it on'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('welcome-radio')));
    // Through the passage from the small radio to the real one.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Tap the dial to turn it on'), findsNothing);
    expect(container.read(radioControllerProvider), isA<Flying>());
    final preferences = await tester.runAsync(SharedPreferences.getInstance);
    expect(preferences!.getBool('app.welcomeSeen'), isTrue);
    // The flight's own timers end with it.
    await container.read(radioControllerProvider.notifier).stop();
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('the radio keeps its text style while it travels', (
    tester,
  ) async {
    final container = await launch(tester, animations: true);
    await tester.tap(find.byKey(const ValueKey('welcome-radio')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    // Text without a Material above it falls back to Flutter's error style:
    // yellow double underline.
    final broken = tester
        .widgetList<RichText>(find.byType(RichText))
        .where((t) => t.text.style?.decorationColor == const Color(0xFFFFFF00));
    expect(broken, isEmpty);
    await container.read(radioControllerProvider.notifier).stop();
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('a later launch opens the radio', (tester) async {
    await launch(tester, preferences: {'app.welcomeSeen': true});
    expect(find.text('Tap the dial to turn it on'), findsNothing);
    expect(find.text('Where shall we go?'), findsOneWidget);
  });
}
