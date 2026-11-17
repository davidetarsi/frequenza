import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/domain/diary_summary.dart';
import 'package:frequenza/features/diary/presentation/diary_map.dart';
import 'package:frequenza/features/journey/data/world_atlas.g.dart';

void main() {
  const width = 360.0;
  final cell = width / worldDotRows.first.length;
  // Brasilia, in the map's own coordinates.
  final brasilia = Offset(
    (-47.9 + 180) / worldDotStep * cell,
    (worldDotNorth - -15.8) / worldDotStep * cell,
  );

  Future<(List<String>, TransformationController)> show(
    WidgetTester tester,
  ) async {
    final tapped = <String>[];
    final controller = TransformationController();
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: worldDotRows.length * cell,
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
    return (tapped, controller);
  }

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
}
