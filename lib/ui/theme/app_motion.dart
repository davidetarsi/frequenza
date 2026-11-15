import 'package:flutter/material.dart';

abstract final class AppMotion {
  static bool enabled(BuildContext context) =>
      !MediaQuery.disableAnimationsOf(context);

  /// Scrolling text: speed in points per second, space between the copies,
  /// the stop before each lap and how many laps before it rests.
  static const marqueeSpeed = 30.0;
  static const marqueeGap = 24.0;
  static const marqueePause = Duration(milliseconds: 1200);
  static const marqueeLaps = 3;

  static Duration standard(BuildContext context) =>
      enabled(context) ? const Duration(milliseconds: 200) : Duration.zero;
}
