import 'package:flutter/material.dart';

import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/travel_radio_design.dart';
import 'diary_page.dart';

/// Opens the diary over the radio: the panel grows out of the radio's
/// screen ([screenKey]) and the bar rises after it; closing plays it
/// backwards. Not a Hero: the whole radio is already one.
Future<void> openDiary(
  BuildContext context,
  GlobalKey screenKey, {
  DiaryPage page = const DiaryPage(),
}) {
  final box = screenKey.currentContext?.findRenderObject() as RenderBox?;
  final from = box != null && box.hasSize
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
  return Navigator.of(context).push(_DiaryRoute(page: page, from: from));
}

class _DiaryRoute extends PageRouteBuilder<void> {
  _DiaryRoute({required DiaryPage page, required Rect? from})
    : super(
        transitionDuration: AppMotion.diaryOpen,
        reverseTransitionDuration: AppMotion.diaryClose,
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (context, animation, _, child) {
          if (from == null || !AppMotion.enabled(context)) {
            return FadeTransition(opacity: animation, child: child);
          }
          final grow = CurvedAnimation(
            parent: animation,
            curve: AppMotion.diaryOpenCurve,
            reverseCurve: AppMotion.diaryCloseCurve,
          );
          return AnimatedBuilder(
            animation: grow,
            child: child,
            builder: (context, child) => ClipRRect(
              clipper: _GrowClipper(from: from, t: grow.value),
              child: child,
            ),
          );
        },
      );
}

class _GrowClipper extends CustomClipper<RRect> {
  _GrowClipper({required this.from, required this.t});

  final Rect from;
  final double t;

  @override
  RRect getClip(Size size) => RRect.fromRectAndRadius(
    Rect.lerp(from, Offset.zero & size, t)!,
    Radius.circular(DiaryDesign.growRadius * (1 - t)),
  );

  @override
  bool shouldReclip(_GrowClipper old) => old.t != t || old.from != from;
}
