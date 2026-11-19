import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/app/links/external_links.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../features/favorites/favorites_test.dart';
import '../features/radio/radio_controller_test.dart';
import '../features/welcome/welcome_seen_test.dart' show BrokenStore;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<List<Uri>> openPrivacy(WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final audio = FakeAudioService();
    addTearDown(audio.dispose);
    final opened = <Uri>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioRepositoryProvider.overrideWithValue(FakeRadioRepository()),
          radioAudioServiceProvider.overrideWithValue(audio),
          favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
          openExternalProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Informativa sulla privacy'),
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    return opened;
  }

  bool switchOn(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch)).value;

  testWidgets('the switch turns statistics off and on', (tester) async {
    await openPrivacy(tester);
    expect(find.text('Privacy'), findsOneWidget);
    expect(
      find.text(
        "Eventi d'uso e dati tecnici per migliorare la radio. Puoi disattivarli quando vuoi.",
      ),
      findsOneWidget,
    );
    expect(switchOn(tester), isTrue);

    await tester.tap(find.text("Statistiche d'uso"));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app.analyticsOn'), isFalse);
    expect(switchOn(tester), isFalse);

    await tester.tap(find.text("Statistiche d'uso"));
    await tester.pumpAndSettle();
    expect(prefs.getBool('app.analyticsOn'), isTrue);
  });

  testWidgets('a failed save says so', (tester) async {
    final previous = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = BrokenStore();
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    await openPrivacy(tester);
    expect(switchOn(tester), isFalse);
    await tester.tap(find.text("Statistiche d'uso"));
    await tester.pumpAndSettle();
    expect(
      find.text('Non è stato possibile salvare la scelta. Riprova.'),
      findsOneWidget,
    );
  });

  testWidgets('the privacy link opens the policy', (tester) async {
    final opened = await openPrivacy(tester);
    await tester.tap(find.text('Informativa sulla privacy'));
    await tester.pumpAndSettle();
    expect(opened, [
      Uri.parse('https://davidetarsi.github.io/frequenza/privacy.html#it'),
    ]);
  });
}
