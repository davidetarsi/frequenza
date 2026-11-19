import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/domain/diary_summary.dart';
import 'package:frequenza/features/diary/presentation/diary_map.dart';
import 'package:frequenza/features/journey/domain/atlas/world_atlas.g.dart';

void main() {
  const width = 360.0;
  final cell = width / worldDotRows.first.length;
  // Brasilia, in the map's own coordinates.
  final brasilia = Offset(
    (-47.9 + 180) / worldDotStep * cell,
    (worldDotNorth - -15.8) / worldDotStep * cell,
  );

  Future<(List<String>, TransformationController)> show(
    WidgetTester tester, {
    double? height,
  }) async {
    final tapped = <String>[];
    final controller = TransformationController();
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: height ?? worldDotRows.length * cell,
            child: DiaryMap(
              summary: const DiarySummary.empty(),
              selected: null,
              controller: controller,
              onCountry: tapped.add,
              zoomInLabel: 'Ingrandisci',
              zoomOutLabel: 'Rimpicciolisci',
              semanticsLabel: 'Mappa',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return (tapped, controller);
  }

  testWidgets('a tall viewport is filled without stretching the world', (
    tester,
  ) async {
    final (tapped, controller) = await show(tester, height: 480);
    final map = tester.getSize(find.byKey(const ValueKey('diary-map-paint')));
    expect(map.height, closeTo(480, 0.01));
    expect(
      map.width / map.height,
      closeTo(worldDotRows.first.length / worldDotRows.length, 0.001),
    );
    final paintBox = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('diary-map-paint')),
    );
    final point = brasilia * (map.width / width);
    controller.value = Matrix4.identity()
      ..translateByDouble(
        (width / 2 - point.dx).clamp(width - map.width, 0),
        0,
        0,
        1,
      );
    await tester.pump();
    await tester.tapAt(paintBox.localToGlobal(point));
    expect(tapped, ['BR']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('button zoom interpolates and a gesture interrupts it', (
    tester,
  ) async {
    final (_, controller) = await show(tester);
    await tester.tap(find.byTooltip('Ingrandisci'));
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), 1);
    await tester.pump(const Duration(milliseconds: 80));
    final scale = controller.value.getMaxScaleOnAxis();
    expect(scale, greaterThan(1));
    expect(scale, lessThan(2));
    await tester.dragFrom(const Offset(150, 80), const Offset(-25, -10));
    final stopped = controller.value.getMaxScaleOnAxis();
    await tester.pumpAndSettle();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(stopped, 0.001));
  });

  testWidgets('the tall viewport can be dragged from its lower half', (
    tester,
  ) async {
    final (tapped, controller) = await show(tester, height: 480);
    final before = controller.value.getTranslation().x;
    await tester.dragFrom(const Offset(160, 380), const Offset(70, 0));
    await tester.pumpAndSettle();
    expect(controller.value.getTranslation().x, greaterThan(before));
    expect(tapped, isEmpty);
  });

  testWidgets('pinch scales continuously without selecting a country', (
    tester,
  ) async {
    final (tapped, controller) = await show(tester, height: 480);
    final first = await tester.startGesture(const Offset(140, 250), pointer: 1);
    final second = await tester.startGesture(
      const Offset(220, 250),
      pointer: 2,
    );
    await tester.pump();
    await first.moveTo(const Offset(130, 250));
    await second.moveTo(const Offset(230, 250));
    await tester.pump();
    final start = controller.value.getMaxScaleOnAxis();
    await first.moveTo(const Offset(120, 250));
    await second.moveTo(const Offset(240, 250));
    await tester.pump();
    final middle = controller.value.getMaxScaleOnAxis();
    await first.moveTo(const Offset(110, 250));
    await second.moveTo(const Offset(250, 250));
    await tester.pump();
    final end = controller.value.getMaxScaleOnAxis();
    expect(middle, greaterThan(start));
    expect(end, greaterThan(middle));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    expect(tapped, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('button zoom respects reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final (_, controller) = await show(tester);
    await tester.tap(find.byTooltip('Ingrandisci'));
    expect(controller.value.getMaxScaleOnAxis(), 2);
    await tester.pumpAndSettle();
  });

  testWidgets('a tap on Brasilia picks Brazil', (tester) async {
    final (tapped, _) = await show(tester);
    await tester.tapAt(brasilia);
    expect(tapped, ['BR']);
  });

  testWidgets('zoomed in and moved, Brasilia is still Brazil', (tester) async {
    final (tapped, controller) = await show(tester);
    controller.value = Matrix4.identity()
      ..translateByDouble(-300, -250, 0, 1)
      ..scaleByDouble(4, 4, 1, 1);
    await tester.pump();
    await tester.tapAt(MatrixUtils.transformPoint(controller.value, brasilia));
    expect(tapped, ['BR']);
  });

  testWidgets('a tap on the open ocean picks nothing', (tester) async {
    final (tapped, _) = await show(tester);
    await tester.tapAt(
      Offset(
        (-20 + 180) / worldDotStep * cell,
        (worldDotNorth + 30) / worldDotStep * cell,
      ),
    );
    expect(tapped, isEmpty);
  });

  testWidgets('the plus key zooms in, the minus key back out', (tester) async {
    final (_, controller) = await show(tester);
    await tester.tap(find.byTooltip('Ingrandisci'));
    await tester.pumpAndSettle();
    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1.5));
    await tester.tap(find.byTooltip('Rimpicciolisci'));
    await tester.pumpAndSettle();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(1, 0.01));
  });

  testWidgets('the map paints in its own layer, and only when it changes', (
    tester,
  ) async {
    await show(tester);
    final paint = find.descendant(
      of: find.byType(DiaryMap),
      matching: find.byKey(const ValueKey('diary-map-paint')),
    );
    expect(
      find.ancestor(of: paint, matching: find.byType(RepaintBoundary)),
      findsWidgets,
    );
    final first = tester.widget<CustomPaint>(paint).painter!;
    await show(tester);
    final again = tester.widget<CustomPaint>(paint).painter!;
    expect(again.shouldRepaint(first), isFalse);
  });

  testWidgets('zooming out near an edge stays inside the world', (
    tester,
  ) async {
    final (_, controller) = await show(tester);
    // Zoomed in 4×, then pushed past the left edge of the world.
    controller.value = Matrix4.identity()
      ..translateByDouble(200, 0, 0, 1)
      ..scaleByDouble(4, 4, 1, 1);
    await tester.pump();
    await tester.tap(find.byTooltip('Rimpicciolisci'));
    await tester.pumpAndSettle();
    final scale = controller.value.getMaxScaleOnAxis();
    final shift = controller.value.getTranslation();
    final height = worldDotRows.length * cell;
    expect(scale, greaterThan(1));
    expect(shift.x, lessThanOrEqualTo(0));
    expect(shift.x, greaterThanOrEqualTo(width - width * scale));
    expect(shift.y, lessThanOrEqualTo(0));
    expect(shift.y, greaterThanOrEqualTo(height - height * scale));
  });
}
