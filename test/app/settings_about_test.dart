import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/app.dart';
import 'package:frequenza/app/links/app_version.dart';
import 'package:frequenza/app/links/external_links.dart';
import 'package:frequenza/features/favorites/application/favorites_providers.dart';
import 'package:frequenza/features/radio/application/radio_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/favorites/favorites_test.dart';
import '../features/radio/radio_controller_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<List<Uri>> openSettings(
    WidgetTester tester, {
    bool opens = true,
  }) async {
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
          appVersionProvider.overrideWith((ref) async => '0.2.1+2'),
          openExternalProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return opens;
          }),
        ],
        child: const StarterApp(locale: Locale('it')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('Visualizza progetto su GitHub'),
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    return opened;
  }

  testWidgets('the settings open the project on GitHub', (tester) async {
    final opened = await openSettings(tester);
    expect(find.text('Informazioni'), findsOneWidget);
    await tester.tap(find.text('Visualizza progetto su GitHub'));
    await tester.pumpAndSettle();
    expect(opened, [Uri.parse('https://github.com/davidetarsi/frequenza')]);
  });

  testWidgets('a link that does not open says so', (tester) async {
    await openSettings(tester, opens: false);
    await tester.tap(find.text('Visualizza progetto su GitHub'));
    await tester.pumpAndSettle();
    expect(find.text('Impossibile aprire il link'), findsOneWidget);
  });

  testWidgets('the settings open the feedback form with the app version', (
    tester,
  ) async {
    final opened = await openSettings(tester);
    await tester.dragUntilVisible(
      find.text('Segnala un problema o un\'idea'),
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Segnala un problema o un\'idea'));
    await tester.pumpAndSettle();
    expect(opened, hasLength(1));
    expect(
      opened.single.toString(),
      startsWith(
        'https://docs.google.com/forms/d/e/1FAIpQLScfBxq-YDkcOEW5GE0aeJw4X6Ol-Ydb8ycL7HVyXlt4ujJ26Q/viewform',
      ),
    );
    expect(opened.single.queryParameters, {
      'usp': 'pp_url',
      'entry.1664657182': '0.2.1+2',
    });
  });
}
