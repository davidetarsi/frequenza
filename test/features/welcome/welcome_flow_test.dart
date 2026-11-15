import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../favorites/favorites_test.dart';
import '../radio/radio_controller_test.dart';

/// The app as bootstrap starts it: with the welcome flag already read.
Future<ProviderContainer> launch(
  WidgetTester tester, {
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
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
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('a first launch opens the welcome, then the radio stays', (
    tester,
  ) async {
    await launch(tester);
    expect(find.text('Turn it on'), findsOneWidget);
    await tester.tap(find.text('Turn it on'));
    await tester.pumpAndSettle();
    expect(find.text('Turn it on'), findsNothing);
    expect(find.text('Where shall we go?'), findsOneWidget);
    final preferences = await tester.runAsync(SharedPreferences.getInstance);
    expect(preferences!.getBool('app.welcomeSeen'), isTrue);
  });

  testWidgets('a later launch opens the radio', (tester) async {
    await launch(tester, preferences: {'app.welcomeSeen': true});
    expect(find.text('Turn it on'), findsNothing);
    expect(find.text('Where shall we go?'), findsOneWidget);
  });
}
