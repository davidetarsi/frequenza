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
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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

  testWidgets('the dial starts audio, then two taps complete the guide', (
    tester,
  ) async {
    final container = await launch(tester);
    expect(find.text('Turn on the radio'), findsOneWidget);
    await tester.tapAt(const Offset(10, 200));
    await tester.pump();
    expect(find.text('Turn on the radio'), findsOneWidget);
    expect(container.read(radioControllerProvider), isA<Off>());
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('tune-knob'))),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Your favorites'), findsOneWidget);
    expect(container.read(radioControllerProvider), isA<Flying>());
    var preferences = await tester.runAsync(SharedPreferences.getInstance);
    expect(preferences!.getInt(WelcomeSeen.revisionKey), isNull);
    await tester.tap(find.byKey(const ValueKey('welcome-guide')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Your travel diary'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('welcome-guide')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('welcome-guide')), findsNothing);
    expect(find.text('EN'), findsNothing);
    preferences = await tester.runAsync(SharedPreferences.getInstance);
    expect(
      preferences!.getInt(WelcomeSeen.revisionKey),
      WelcomeSeen.currentRevision,
    );
    await container.read(radioControllerProvider.notifier).stop();
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('the final animated passage preserves the radio text style', (
    tester,
  ) async {
    final container = await launch(tester, animations: true);
    await tester.pump();
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('tune-knob'))),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('welcome-guide')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('welcome-guide')));
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final broken = tester
        .widgetList<RichText>(find.byType(RichText))
        .where((t) => t.text.style?.decorationColor == const Color(0xFFFFFF00));
    expect(broken, isEmpty);
    expect(find.byKey(const ValueKey('welcome-guide')), findsNothing);
    expect(tester.takeException(), isNull);
    await container.read(radioControllerProvider.notifier).stop();
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('Android back dismisses the guide without starting a flight', (
    tester,
  ) async {
    final container = await launch(tester);
    await tester.binding.handlePopRoute();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('welcome-guide')), findsNothing);
    expect(container.read(radioControllerProvider), isA<Off>());
    expect(container.read(welcomeSeenProvider).valueOrNull, isTrue);
  });

  testWidgets('an update from the old guide opens the new guide once', (
    tester,
  ) async {
    await launch(tester, preferences: {'app.welcomeSeen': true});
    expect(find.text('Turn on the radio'), findsOneWidget);
    await tester.binding.handlePopRoute();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final preferences = await tester.runAsync(SharedPreferences.getInstance);
    expect(
      preferences!.getInt(WelcomeSeen.revisionKey),
      WelcomeSeen.currentRevision,
    );
    expect(find.byKey(const ValueKey('welcome-guide')), findsNothing);
  });

  testWidgets('a later launch opens the radio', (tester) async {
    await launch(
      tester,
      preferences: {
        'app.welcomeSeen': true,
        WelcomeSeen.revisionKey: WelcomeSeen.currentRevision,
      },
    );
    expect(find.byKey(const ValueKey('welcome-guide')), findsNothing);
    expect(find.text('Where shall we go?'), findsOneWidget);
  });
}
