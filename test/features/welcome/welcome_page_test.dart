import 'dart:ui' show SemanticsAction;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome_flow_test.dart' show launch;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('IT changes the approved copy and stays available after tuning', (
    tester,
  ) async {
    final container = await launch(tester);
    await tester.tap(find.text('IT'));
    await tester.pumpAndSettle();
    expect(find.text('Accendi la radio'), findsOneWidget);
    expect(
      find.text(
        'Ogni giro è una radio in diretta da qualche parte nel mondo. Quelle che ami le tieni con il cuore.',
      ),
      findsOneWidget,
    );
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('tune-knob'))),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('I tuoi preferiti'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Your favorites'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('welcome-guide')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Your travel diary'), findsOneWidget);
    expect(find.text('IT'), findsOneWidget);
    await container.read(radioControllerProvider.notifier).stop();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 1));
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('the guide fits $size with large text and reduced motion', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await launch(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.text('Turn on the radio'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });
  }

  testWidgets('screen readers can activate the dial and advance the guide', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final container = await launch(tester);
      final node = tester.getSemantics(find.text('Tap the dial to turn it on'));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      await tester.pump();
      expect(find.text('Your favorites'), findsOneWidget);
      final next = tester.getSemantics(find.text('Tap to continue'));
      expect(next.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      next.owner!.performAction(next.id, SemanticsAction.tap);
      await tester.pump();
      await tester.pump();
      expect(find.text('Your travel diary'), findsOneWidget);
      await container.read(radioControllerProvider.notifier).stop();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(minutes: 1));
    } finally {
      semantics.dispose();
    }
  });
}
