import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/config/app_localization.dart';
import 'package:frequenza/features/welcome/presentation/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpWelcome(
  WidgetTester tester, {
  bool animations = true,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: !animations);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    AppLocalization(
      startLocale: AppLocalization.english,
      child: Builder(
        builder: (context) => ProviderScope(
          child: MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: const WelcomePage(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('the demo flies and lands', (tester) async {
    await pumpWelcome(tester);
    expect(find.text('Where shall we go?'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Flying to'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Radio Paraíso'), findsOneWidget);
    // Past the end of the loop, the radio is off again.
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('Where shall we go?'), findsOneWidget);
  });

  testWidgets('choosing IT switches the page to Italian', (tester) async {
    await pumpWelcome(tester, animations: false);
    expect(find.text('Turn it on'), findsOneWidget);
    await tester.tap(find.text('IT'));
    await tester.pumpAndSettle();
    expect(find.text('Accendi la radio'), findsOneWidget);
  });

  testWidgets('with reduced motion the demo rests on the landed station', (
    tester,
  ) async {
    await pumpWelcome(tester, animations: false);
    await tester.pumpAndSettle();
    expect(find.text('Radio Paraíso'), findsOneWidget);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpWelcome(
      tester,
      animations: false,
      size: const Size(320, 568),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Turn it on'), findsOneWidget);
  });
}
