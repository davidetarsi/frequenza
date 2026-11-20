import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_component_design.dart';

/// Measures one live subtree, choosing the largest density that actually fits.
/// Density runs from comfortable (1) to tight (0); compact is the last resort.
/// Text scaling and hit targets are owned by the builder, never transformed.
/// Requires bounded width and height; freeSpace can be distributed as gaps.
class AdaptiveFit extends StatefulWidget {
  const AdaptiveFit({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    double density,
    bool compact,
    double freeSpace,
  )
  builder;

  @override
  State<AdaptiveFit> createState() => _AdaptiveFitState();
}

class _AdaptiveFitState extends State<AdaptiveFit> {
  // Keep the fallback's scroll offset when the live content changes and is
  // measured again; each instance has its own storage identity.
  final _scrollKey = PageStorageKey(Object());

  @override
  Widget build(BuildContext context) => _FitViewport(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final fit = constraints as _FitConstraints;
        final content = widget.builder(
          context,
          fit.density,
          fit.compact,
          fit.freeSpace,
        );
        return fit.scrolling
            ? SingleChildScrollView(key: _scrollKey, child: content)
            : content;
      },
    ),
  );
}

class _FitConstraints extends BoxConstraints {
  const _FitConstraints({
    required double width,
    super.height,
    required this.density,
    required this.compact,
    this.scrolling = false,
    this.freeSpace = 0,
  }) : super.tightFor(width: width);

  final double density, freeSpace;
  final bool compact, scrolling;

  @override
  bool operator ==(Object other) =>
      other is _FitConstraints &&
      super == other &&
      density == other.density &&
      compact == other.compact &&
      scrolling == other.scrolling &&
      freeSpace == other.freeSpace;

  @override
  int get hashCode =>
      Object.hash(super.hashCode, density, compact, scrolling, freeSpace);
}

class _FitViewport extends SingleChildRenderObjectWidget {
  const _FitViewport({required super.child});

  @override
  _RenderFitViewport createRenderObject(BuildContext context) =>
      _RenderFitViewport();
}

class _RenderFitViewport extends RenderProxyBox {
  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth && constraints.hasBoundedHeight);
    bool fits(double density, bool compact) {
      child!.layout(
        _FitConstraints(
          width: constraints.maxWidth,
          density: density,
          compact: compact,
        ),
        parentUsesSize: true,
      );
      return child!.size.height <= constraints.maxHeight;
    }

    var density = 1.0;
    var compact = false;
    if (!fits(density, compact)) {
      density = 0;
      if (fits(density, compact)) {
        var low = 0.0, high = 1.0;
        for (var step = 0; step < AdaptiveFitDesign.searchSteps; step++) {
          final middle = (low + high) / 2;
          if (fits(middle, false)) {
            low = middle;
          } else {
            high = middle;
          }
        }
        density = low;
      } else {
        compact = true;
      }
    }
    // Recheck the chosen density: the last probe may have been too large.
    fits(density, compact);
    final scrolling = child!.size.height > constraints.maxHeight;
    child!.layout(
      _FitConstraints(
        width: constraints.maxWidth,
        height: scrolling ? constraints.maxHeight : null,
        freeSpace: (constraints.maxHeight - child!.size.height).clamp(
          0.0,
          constraints.maxHeight,
        ),
        density: density,
        compact: compact,
        scrolling: scrolling,
      ),
      parentUsesSize: true,
    );
    size = constraints.biggest;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;
}
