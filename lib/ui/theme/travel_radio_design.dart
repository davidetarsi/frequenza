import 'package:flutter/material.dart';

import 'app_spacing.dart';

abstract final class TravelRadioLayout {
  static const cabinetWidth = 344.0;
  static const landscapeMinWidth = 520.0;
  static const landscapeMaxHeight = 560.0;
  static const landscapeContentWidth = 720.0;
  static const landscapeControlsWidth = 160.0;
  static const compactHeight = 740.0;
  static const compactHeightWithLargeText = 900.0;
  static const referenceTextSize = 16.0;
  static const largeTextThreshold = 20.0;
  static const headingTracking = -1.0;
  static const captionLineHeight = 1.1;
  static const captionTracking = 0.0;
  static const headerIconSize = 18.0;
}

abstract final class RadioCabinetDesign {
  static const compact = (
    diameter: 76.0,
    stationSize: 22.0,
    frameInset: 6.0,
    shellInset: 6.0,
    screenInset: 6.0,
    countryGap: 4.0,
    detailGap: 4.0,
    statusGap: 4.0,
    detailHeightFactor: 1.25,
    statusHeightFactor: 1.45,
    dialLabelGap: 4.0,
    dialLabelSize: 10.0,
    dialLabelHeightFactor: 1.25,
    handleHeight: 20.0,
    controlsGap: 6.0,
    textLines: 1,
  );
  static const regular = (
    diameter: 104.0,
    stationSize: 26.0,
    frameInset: 8.0,
    shellInset: 12.0,
    screenInset: 12.0,
    countryGap: 14.0,
    detailGap: 8.0,
    statusGap: 12.0,
    detailHeightFactor: 2.5,
    statusHeightFactor: 2.8,
    dialLabelGap: 10.0,
    dialLabelSize: 12.0,
    dialLabelHeightFactor: 2.8,
    handleHeight: 30.0,
    controlsGap: 20.0,
    textLines: 2,
  );

  static const screenFrameInset = 5.0;
  static const screenFrameRadius = BorderRadius.all(Radius.circular(15));
  static const screenRadius = BorderRadius.all(Radius.circular(10));
  static const screenLandscapeInset = 2.0;
  static const frameRadius = BorderRadius.all(Radius.circular(30));
  static const shellRadius = BorderRadius.all(Radius.circular(23));
  static const handleWidth = 156.0;
  static const handleSideInset = 8.0;
  static const handleShoulder = 17.0;
  static const handleTop = 6.0;
  static const handleCornerEnd = 21.0;
  static const handleStroke = 11.0;
  static const handleHighlightOffset = Offset(0, -2);
  static const brandGap = 15.0;
  static const trimGap = 20.0;
  static const hairline = 1.0;
  static const hairlineOpacity = .18;
  static const screenHighlightOpacity = .7;
  static const screenHighlightOffset = Offset(0, 1);
  static const indicatorSize = 7.0;
  static const indicatorGlowOpacity = .35;
  static const frameShadowOpacity = .18;
  static const frameShadowOffset = Offset(0, 12);
  static const frameShadowBlur = 22.0;
  static const frameTrimOffset = Offset(0, 6);
  static const shellBorderOpacity = .65;
  static const trimLineOpacity = .6;
  static const screenItemGap = AppSpacing.small;
  static const screwSize = 8.0;
  static const screwSlotWidth = 4.0;
  static const countryText = TextStyle(fontSize: 12, letterSpacing: 1.4);
  static const brandText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
  );
  static const detailText = TextStyle(fontSize: 14, height: 1.2);
  static const statusText = TextStyle(fontSize: 12, height: 1.15);
  static const stationText = TextStyle(
    fontWeight: FontWeight.w600,
    height: 1.15,
  );
  static const stationHeightFactor = 1.2;
  static const dialLabelText = TextStyle(
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );
  static const dialLabelCompactHeight = 1.2;
  static const dialBorderWidth = 4.0;
  static const dialRingRatio = .48;
  static const dialTickCount = 21;
  static const dialTickSweepStart = 135.0;
  static const dialTickStep = 13.5;
  static const dialTickStroke = 1.5;
  static const dialLongTickEvery = 5;
  static const dialLongTickInset = 6.0;
  static const dialShortTickInset = 4.0;
  static const speakerRimInset = 3.0;
  static const speakerMeshInset = 6.0;
  static const speakerPerforationInset = 9.0;
  static const speakerPerforationGrid = 9;
  static const speakerPerforationSpacing = 5.5;
  static const speakerPerforationRadius = 1.25;
  static const dialTickInset = 9.0;
  static const dialMarkerTop = 8.0;
  static const dialMarkerWidth = 4.0;
  static const dialMarkerHeight = 17.0;
  static const dialMarkerRadius = BorderRadius.all(Radius.circular(3));
  static const dialShadowOpacity = .25;
  static const dialShadowBlur = 8.0;
  static const dialShadowOffset = Offset(0, 5);
}

abstract final class RadioEqualizerDesign {
  static const height = 26.0;
  static const compactHeight = 14.0;
  static const compactWidth = 56.0;
  static const cycle = Duration(milliseconds: 1800);
  static const levels = [2, 4, 3, 6, 5, 7, 4, 5, 3, 6, 4, 2, 5, 3, 2, 4, 2, 1];
  static const segments = 7;
  static const primaryHarmonic = 2;
  static const secondaryHarmonic = 3;
  static const primaryColumnPhase = 1.3;
  static const secondaryColumnPhase = .8;
  static const primaryAmplitude = 1.6;
  static const segmentHeightRatio = .65;
  static const segmentSideInset = 1.0;
  static const activeOpacity = .65;
  static const idleOpacity = .25;
}

abstract final class RadioFavoritesDesign {
  static const initialHeight = .62;
  static const minHeight = .3;
  static const maxHeight = .94;
  static const barrierOpacity = .48;
  static const sheetRadius = BorderRadius.vertical(top: Radius.circular(32));
  static const sheetPadding = EdgeInsets.fromLTRB(22, 12, 22, 24);
  static const shadowOpacity = .22;
  static const shadowBlur = 28.0;
  static const shadowOffset = Offset(0, -5);
  static const handleSize = Size(36, 4);
  static const handleRadius = BorderRadius.all(Radius.circular(4));
  static const headerGap = 22.0;
  static const titleTracking = -.6;
  static const titleGap = 5.0;
  static const closeIconSize = 20.0;
  static const contentGap = 20.0;
  static const emptyIconSize = 28.0;
  static const footerGap = 10.0;
  static const footerIconSize = 14.0;
  static const footerIconGap = 6.0;
  static const activeSubtitleOpacity = .85;
  static const presetPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 18,
  );
  static const presetCodeSize = Size(42, 46);
  static const inactivePresetBorderOpacity = .55;
  static const presetGlobeSize = 18.0;
  static const presetCodeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );
  static const removeIconSize = 19.0;
  static const trailingInset = 4.0;
}

abstract final class RadioDiagnosticsDesign {
  static const cardElevation = 2.0;
  static const iconSize = 32.0;
  static const badgeIconSize = 16.0;
  static const inlineGap = 4.0;
  static const logHeight = 200.0;
  static const logRadius = BorderRadius.all(Radius.circular(8));
  static const logFont = TextStyle(fontFamily: 'monospace', fontSize: 11);
}

abstract final class RouteMapDesign {
  static const height = 96.0;
  static const north = 80.0;
  static const south = -60.0;
  static const dotRadius = .55;
  static const dotOpacity = .22;
  static const historyOpacity = .25;
  static const historyStroke = .8;
  static const historyDash = 3.0;
  static const arcOpacity = .9;
  static const arcStroke = 1.4;
  static const arcLift = .25;
  static const pointRadius = 2.4;
  static const radarRings = 3;
  static const radarRadius = 26.0;
  static const radarStroke = 1.0;
  static const radarCycle = Duration(milliseconds: 1800);
  static const arrivalPulseRadius = 7.0;
  static const arrivalCycle = Duration(milliseconds: 2400);
  static const landing = Duration(milliseconds: 600);
  static const landingBlur = 6.0;
  static const dotsCycle = Duration(milliseconds: 1200);
}
