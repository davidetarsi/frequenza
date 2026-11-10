import 'package:flutter/material.dart';

/// Product styling: shared by the receiver and saved-station drawer only.
@immutable
class TravelRadioPalette {
  const TravelRadioPalette({
    required this.paper,
    required this.paperRaised,
    required this.ink,
    required this.muted,
    required this.shellTop,
    required this.shellBottom,
    required this.trim,
    required this.metalLight,
    required this.metalDark,
  });
  final Color paper,
      paperRaised,
      ink,
      muted,
      shellTop,
      shellBottom,
      trim,
      metalLight,
      metalDark;
  static const screen = Color(0xFF203C33);
  static const screenInk = Color(0xFFE4EBC5);
  static const hardware = Color(0xFF354B3F);
  static const accent = Color(0xFFAD4823);
  static TravelRadioPalette of(BuildContext context) =>
      forBrightness(Theme.of(context).brightness);
  static TravelRadioPalette forBrightness(Brightness brightness) =>
      brightness == Brightness.dark
      ? const TravelRadioPalette(
          paper: Color(0xFF242C27),
          paperRaised: Color(0xFF303A32),
          ink: Color(0xFFECEEDD),
          muted: Color(0xFFBBC7B8),
          shellTop: Color(0xFF6E7767),
          shellBottom: Color(0xFF495747),
          trim: Color(0xFF89917C),
          metalLight: Color(0xFFC3C7AF),
          metalDark: Color(0xFF7D8971),
        )
      : const TravelRadioPalette(
          paper: Color(0xFFFAF7EF),
          paperRaised: Color(0xFFF0EBDC),
          ink: Color(0xFF213E34),
          muted: Color(0xFF5E7060),
          shellTop: Color(0xFFEEE9D9),
          shellBottom: Color(0xFFCECBB4),
          trim: Color(0xFFABA991),
          metalLight: Color(0xFFF1F0D9),
          metalDark: Color(0xFFA1AC90),
        );
}
