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

  /// The favorites count swelling when a station is saved.
  static const countPulse = Duration(milliseconds: 400);

  /// The diary growing out of the radio's screen, and back.
  static const diaryOpen = Duration(milliseconds: 520);
  static const diaryClose = Duration(milliseconds: 340);

  /// The player bar rises in the last part of the opening, from below.
  static const diaryBarStart = 0.55;
  static const diaryBarFrom = Offset(0, 1.5);

  static Duration standard(BuildContext context) =>
      enabled(context) ? const Duration(milliseconds: 200) : Duration.zero;
}
