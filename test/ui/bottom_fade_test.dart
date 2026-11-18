import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/ui/widgets/bottom_fade.dart';

void main() {
  testWidgets('bottom fade increases continuously without a hard upper edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: const ValueKey('preview'),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _Stripes())),
              Positioned(
                left: 0,
                right: 0,
                top: 80,
                bottom: 0,
                child: BottomFade(
                  tint: Colors.black.withValues(alpha: 0.88),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('preview')),
    );
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      final pixels = await image.toByteData(format: ImageByteFormat.rawRgba);
      image.dispose();
      return pixels!;
    });
    int contrast(int y) =>
        (bytes!.getUint8((y * 240 + 100) * 4) -
                bytes.getUint8((y * 240 + 108) * 4))
            .abs();
    expect(contrast(80), closeTo(contrast(79), 5));
    expect(contrast(160), lessThan(contrast(90)));
    expect(contrast(230), lessThan(contrast(160)));
    for (var row = 80; row < 230; row++) {
      expect((contrast(row + 1) - contrast(row)).abs(), lessThanOrEqualTo(4));
    }
  });
}

class _Stripes extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0; x < size.width; x += 8) {
      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), 0, 8, size.height),
        Paint()..color = (x ~/ 8).isEven ? Colors.white : Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(_Stripes old) => false;
}
