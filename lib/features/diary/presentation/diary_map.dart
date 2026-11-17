import 'package:flutter/material.dart';

import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../journey/data/world_atlas.g.dart';
import '../domain/diary_summary.dart';
import '../domain/world_cells.dart';

/// The diary's world: every country's dots lit by the time spent there.
/// Pinch and drag to explore, or use the keys; a tap picks a country.
class DiaryMap extends StatefulWidget {
  const DiaryMap({
    super.key,
    required this.summary,
    required this.selected,
    required this.controller,
    required this.onCountry,
    required this.zoomInLabel,
    required this.zoomOutLabel,
    required this.semanticsLabel,
    this.hint,
  });

  final DiarySummary summary;
  final String? selected;
  final TransformationController controller;
  final ValueChanged<String> onCountry;
  final String zoomInLabel, zoomOutLabel, semanticsLabel;

  /// A short invitation in the map's corner, until a country is picked.
  final String? hint;

  @override
  State<DiaryMap> createState() => _DiaryMapState();
}

class _DiaryMapState extends State<DiaryMap> {
  // Worked out once per summary: the painter repaints only on a change.
  late var _looks = _looksOf(widget.summary);

  @override
  void didUpdateWidget(DiaryMap old) {
    super.didUpdateWidget(old);
    if (old.summary != widget.summary) _looks = _looksOf(widget.summary);
  }

  static int get _columns => worldDotRows.first.length;

  TransformationController get controller => widget.controller;

  void _zoom(double factor, Size view, Size map) {
    final scale = controller.value.getMaxScaleOnAxis();
    final target = (scale * factor).clamp(
      DiaryDesign.minScale,
      DiaryDesign.maxScale,
    );
    if (target == DiaryDesign.minScale) {
      // Back to the whole world.
      controller.value = Matrix4.identity();
      return;
    }
    final centre = view.center(Offset.zero);
    final focus = controller.toScene(centre);
    final shift = centre - focus * target;
    // Never past the edges of the world.
    double inside(double value, double viewSide, double mapSide) {
      final scaled = mapSide * target;
      return scaled <= viewSide ? 0 : value.clamp(viewSide - scaled, 0);
    }

    controller.value = Matrix4.identity()
      ..translateByDouble(
        inside(shift.dx, view.width, map.width),
        inside(shift.dy, view.height, map.height),
        0,
        1,
      )
      ..scaleByDouble(target, target, 1, 1);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cell = constraints.maxWidth / _columns;
      final mapSize = Size(constraints.maxWidth, worldDotRows.length * cell);
      final view = Size(constraints.maxWidth, constraints.maxHeight);
      return Stack(
        children: [
          Semantics(
            label: widget.semanticsLabel,
            image: true,
            child: InteractiveViewer(
              transformationController: controller,
              minScale: DiaryDesign.minScale,
              maxScale: DiaryDesign.maxScale,
              boundaryMargin: EdgeInsets.zero,
              constrained: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final p = details.localPosition;
                  final code = countryNear(
                    worldDotNorth - p.dy / cell * worldDotStep,
                    -180 + p.dx / cell * worldDotStep,
                  );
                  if (code != null) widget.onCountry(code);
                },
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: const ValueKey('diary-map-paint'),
                    size: mapSize,
                    painter: DiaryMapPainter(
                      looks: _looks,
                      selected: widget.selected,
                      cell: cell,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.hint case final hint?)
            Positioned(
              left: DiaryDesign.zoomInset,
              bottom: DiaryDesign.zoomInset,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: TravelRadioPalette.screenHighlight,
                    borderRadius: BorderRadius.circular(DiaryDesign.hintRadius),
                  ),
                  child: Padding(
                    padding: DiaryDesign.hintPadding,
                    child: Text(
                      hint,
                      style: DiaryDesign.hintText.copyWith(
                        color: TravelRadioPalette.screenInk.withValues(
                          alpha: DiaryDesign.mutedOpacity,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: DiaryDesign.zoomInset,
            bottom: DiaryDesign.zoomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: DiaryDesign.zoomInset / 2,
              children: [
                _ZoomKey(
                  icon: Icons.add,
                  tooltip: widget.zoomInLabel,
                  onPressed: () => _zoom(DiaryDesign.zoomStep, view, mapSize),
                ),
                _ZoomKey(
                  icon: Icons.remove,
                  tooltip: widget.zoomOutLabel,
                  onPressed: () =>
                      _zoom(1 / DiaryDesign.zoomStep, view, mapSize),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  /// Each heard country's opacity; countries not here were never heard.
  static Map<String, double> _looksOf(DiarySummary summary) =>
      switch (summary) {
        DiaryEmpty() => const {},
        DiaryFilled(:final countries) => {
          for (final country in countries)
            country.code: country.level == 0
                ? DiaryDesign.passingOpacity
                : DiaryDesign.levelOpacity[country.level - 1],
        },
      };
}

class _ZoomKey extends StatelessWidget {
  const _ZoomKey({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    constraints: const BoxConstraints.tightFor(
      width: DiaryDesign.zoomKey,
      height: DiaryDesign.zoomKey,
    ),
    padding: EdgeInsets.zero,
    style: IconButton.styleFrom(
      backgroundColor: TravelRadioPalette.screenHighlight,
      foregroundColor: TravelRadioPalette.screenInk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DiaryDesign.zoomKeyRadius),
        side: BorderSide(
          color: TravelRadioPalette.screenInk.withValues(
            alpha: DiaryDesign.passingOpacity,
          ),
        ),
      ),
    ),
    icon: Icon(icon, size: DiaryDesign.zoomIconSize),
  );
}

class DiaryMapPainter extends CustomPainter {
  DiaryMapPainter({
    required this.looks,
    required this.selected,
    required this.cell,
  });

  final Map<String, double> looks;
  final String? selected;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final dot in countryDots()) {
      final opacity = looks[dot.code] ?? DiaryDesign.offOpacity;
      final chosen = dot.code == selected;
      paint.color = chosen
          ? DiaryDesign.selected
          : TravelRadioPalette.screenInk.withValues(alpha: opacity);
      final big = chosen || opacity >= DiaryDesign.levelOpacity[2];
      canvas.drawCircle(
        Offset((dot.col + 0.5) * cell, (dot.row + 0.5) * cell),
        cell * (big ? DiaryDesign.bigDotShare : DiaryDesign.dotShare),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DiaryMapPainter old) =>
      !identical(old.looks, looks) ||
      old.selected != selected ||
      old.cell != cell;
}
