import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// One line of text that never wraps: when it does not fit, it scrolls to
/// the left for a few laps, then rests at its start; with animations off it
/// is cut with an ellipsis.
class MarqueeText extends StatelessWidget {
  const MarqueeText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(this.style);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final width = painter.width;
        final height = painter.height;
        painter.dispose();
        if (width <= constraints.maxWidth || !AppMotion.enabled(context)) {
          return Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          );
        }
        return Semantics(
          label: text,
          excludeSemantics: true,
          // At the top, like a still Text in a slot taller than the line.
          child: Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: 1,
            child: SizedBox(
              height: height,
              child: _Scrolling(text: text, style: style, textWidth: width),
            ),
          ),
        );
      },
    );
  }
}

class _Scrolling extends StatefulWidget {
  const _Scrolling({
    required this.text,
    required this.style,
    required this.textWidth,
  });

  final String text;
  final TextStyle style;
  final double textWidth;

  @override
  State<_Scrolling> createState() => _ScrollingState();
}

class _ScrollingState extends State<_Scrolling>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lap = AnimationController(
    vsync: this,
    duration: _lapDuration,
  )..repeat(count: AppMotion.marqueeLaps);

  double get _distance => widget.textWidth + AppMotion.marqueeGap;

  Duration get _scroll => Duration(
    milliseconds: (_distance / AppMotion.marqueeSpeed * 1000).round(),
  );

  /// Each lap waits with the start in view, then scrolls one copy out while
  /// the next one comes in.
  Duration get _lapDuration => AppMotion.marqueePause + _scroll;

  double get _scrolled => Interval(
    AppMotion.marqueePause.inMicroseconds / _lapDuration.inMicroseconds,
    1,
  ).transform(_lap.value);

  @override
  void didUpdateWidget(_Scrolling old) {
    super.didUpdateWidget(old);
    if (old.textWidth != widget.textWidth) {
      _lap
        ..duration = _lapDuration
        ..repeat(count: AppMotion.marqueeLaps);
    }
  }

  @override
  void dispose() {
    _lap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = Text(
      widget.text,
      style: widget.style,
      maxLines: 1,
      softWrap: false,
    );
    return ClipRect(
      child: AnimatedBuilder(
        animation: _lap,
        builder: (context, child) => OverflowBox(
          alignment: AlignmentDirectional.centerStart,
          minWidth: 0,
          maxWidth: double.infinity,
          child: Transform.translate(
            offset: Offset(-_scrolled * _distance, 0),
            child: child,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            copy,
            const SizedBox(width: AppMotion.marqueeGap),
            copy,
          ],
        ),
      ),
    );
  }
}
