import 'package:flutter/material.dart';

/// Surface and layout shared by every modal and embedded bottom sheet.
abstract final class TravelSheetDesign {
  static const maxWidth = 520.0;
  static const initialHeight = .62;
  static const minHeight = .3;
  static const maxHeight = .94;
  static const barrierOpacity = .48;
  static const radius = BorderRadius.vertical(top: Radius.circular(32));
  static const padding = EdgeInsets.fromLTRB(22, 12, 22, 24);
  static const shadowOpacity = .22;
  static const shadowBlur = 28.0;
  static const shadowOffset = Offset(0, -5);
  static const handleSize = Size(36, 4);
  static const handleRadius = BorderRadius.all(Radius.circular(4));
  static const handleOpacity = .6;
  static const titleText = TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: -.6,
  );
  static const titleGap = 5.0;
  static const closeIconSize = 20.0;
  static const closeBackgroundOpacity = .08;
  static const contentGap = 20.0;
  static const pullToClose = 24.0;
  static const mutedOpacity = .78;
}
