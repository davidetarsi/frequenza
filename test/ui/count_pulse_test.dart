import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/ui/widgets/count_pulse.dart';

Future<void> pumpCount(
  WidgetTester tester,
  int? count, {
  bool animations = true,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: !animations);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: CountPulse(
          count: count,
          child: const SizedBox.square(dimension: 40),
        ),
      ),
    ),
  );
}

double scale(WidgetTester tester) => tester
    .widget<ScaleTransition>(
      find.descendant(
        of: find.byType(CountPulse),
        matching: find.byType(ScaleTransition),
      ),
    )
    .scale
    .value;

void main() {
  testWidgets('a new favorite makes the count pulse once', (tester) async {
    await pumpCount(tester, 1);
    expect(scale(tester), 1);
    await pumpCount(tester, 2);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(tester), greaterThan(1));
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
  });

  testWidgets('the count arriving after loading does not pulse', (
    tester,
  ) async {
    await pumpCount(tester, null);
    await pumpCount(tester, 3);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(tester), 1);
  });

  testWidgets('removing a favorite does not pulse', (tester) async {
    await pumpCount(tester, 2);
    await pumpCount(tester, 1);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(tester), 1);
  });

  testWidgets('with reduced motion the count stays still', (tester) async {
    await pumpCount(tester, 1, animations: false);
    await pumpCount(tester, 2, animations: false);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(tester), 1);
  });
}
