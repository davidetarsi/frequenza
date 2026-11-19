import 'package:flutter/material.dart';

import 'travel_radio_palette.dart';

/// Existing guide styling and arrow geometry, shared by its text and painters.
abstract final class WelcomeTourDesign {
  static const languageBarHeight = 52.0;
  static const screenInset = 1.5;
  static const copyPadding = EdgeInsets.all(18);
  static const copyRadius = Radius.circular(12);
  static const copyBorderRadius = BorderRadius.all(copyRadius);
  static const copyDecoration = BoxDecoration(
    borderRadius: copyBorderRadius,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [TravelRadioPalette.screenHighlight, TravelRadioPalette.screen],
    ),
  );
  static const focusOutset = 7.0;
  static const actionRadius = Radius.circular(32);
  static const focusStroke = 1.5;
  static final shade = TravelRadioPalette.guideShade.withValues(alpha: .64);
  static final arrowShadow = TravelRadioPalette.guideShade.withValues(
    alpha: .6,
  );
  static const arrowShadowStroke = 4.0;
  static const arrowStroke = 1.8;
  static const arrowHeadLength = 10.0;
  static const arrowHeadSpread = .5;
  static const dialArrowStart = Offset(-30, -32);
  static const dialArrowGap = 8.0;
  static const dialArrowFirstControl = Offset(12, 30);
  static const dialArrowLastControl = Offset(10, -22);
  static const actionArrowStart = Offset(-24, 26);
  static const actionArrowGap = 9.0;
  static const actionArrowSideInset = 18.0;
  static const actionArrowBend = 52.0;
  static const actionArrowRise = 75.0;
  static const actionArrowLastControl = Offset(40, 58);

  static final hintText = TextStyle(
    color: TravelRadioPalette.screenInk.withValues(alpha: .7),
    fontSize: 13,
  );
  static final progressText = hintText.copyWith(
    fontFamily: 'monospace',
    letterSpacing: 1.4,
  );
  static const titleText = TextStyle(
    color: TravelRadioPalette.screenInk,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  static final bodyText = TextStyle(
    color: TravelRadioPalette.screenInk.withValues(alpha: .9),
    fontSize: 16,
    height: 1.45,
  );
}
