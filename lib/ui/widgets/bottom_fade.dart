import 'package:flutter/material.dart';

/// Fades the background towards [tint], while keeping [child] sharp.
class BottomFade extends StatelessWidget {
  const BottomFade({super.key, required this.tint, required this.child});

  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tint.withValues(alpha: 0), tint],
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}
