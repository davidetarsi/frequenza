import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Swells its child once when [count] grows, so a station saved with the
/// heart key shows where it went. A null [count] is still loading: the first
/// number to arrive does not pulse. Still with reduced motion.
class CountPulse extends StatefulWidget {
  const CountPulse({required this.count, required this.child, super.key});

  final int? count;
  final Widget child;

  @override
  State<CountPulse> createState() => _CountPulseState();
}

class _CountPulseState extends State<CountPulse>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.countPulse,
  );
  late final _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didUpdateWidget(CountPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    final (before, now) = (oldWidget.count, widget.count);
    if (before != null &&
        now != null &&
        now > before &&
        AppMotion.enabled(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}
