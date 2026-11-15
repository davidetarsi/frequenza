import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/ui/widgets/marquee_text.dart';

const _style = TextStyle(fontSize: 12);

Future<void> pumpLabel(
  WidgetTester tester,
  String text, {
  required double width,
  bool animations = true,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: !animations);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox(
          width: width,
          child: MarqueeText(text, style: _style),
        ),
      ),
    ),
  );
}

double lineHeight(WidgetTester tester) {
  final painter = TextPainter(
    text: const TextSpan(text: 'A', style: _style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.height;
}

void main() {
  testWidgets('a label that fits stays still, on one line', (tester) async {
    await pumpLabel(tester, 'TUNE', width: 200);
    await tester.pumpAndSettle();
    expect(find.text('TUNE'), findsOneWidget);
    expect(tester.getSize(find.byType(MarqueeText)).height, lineHeight(tester));
  });

  testWidgets('a long label never wraps and scrolls left', (tester) async {
    await pumpLabel(tester, 'SINTONIZZAZIONE…', width: 60);
    await tester.pump();
    expect(tester.getSize(find.byType(MarqueeText)).height, lineHeight(tester));
    final first = find.text('SINTONIZZAZIONE…').first;
    final start = tester.getTopLeft(first).dx;
    await tester.pump(const Duration(milliseconds: 1000));
    expect(tester.getTopLeft(first).dx, start, reason: 'still reading');
    await tester.pump(const Duration(milliseconds: 1000));
    expect(tester.getTopLeft(first).dx, lessThan(start));
    expect(tester.takeException(), isNull);
  });

  testWidgets('after a few laps the label rests at its start', (tester) async {
    await pumpLabel(tester, 'SINTONIZZAZIONE…', width: 60);
    await tester.pump();
    final first = find.text('SINTONIZZAZIONE…').first;
    final start = tester.getTopLeft(first).dx;
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      find
          .text('SINTONIZZAZIONE…')
          .evaluate()
          .map((e) => tester.getTopLeft(find.byWidget(e.widget).first).dx),
      contains(start),
    );
  });

  testWidgets('screen readers hear the label once', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpLabel(tester, 'SINTONIZZAZIONE…', width: 60);
    await tester.pump();
    expect(find.bySemanticsLabel('SINTONIZZAZIONE…'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('with animations off a long label is cut on one line', (
    tester,
  ) async {
    await pumpLabel(tester, 'SINTONIZZAZIONE…', width: 60, animations: false);
    await tester.pumpAndSettle();
    expect(find.text('SINTONIZZAZIONE…'), findsOneWidget);
    expect(tester.getSize(find.byType(MarqueeText)).height, lineHeight(tester));
  });
}
