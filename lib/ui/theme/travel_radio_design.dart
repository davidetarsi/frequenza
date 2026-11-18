import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'travel_radio_palette.dart';

abstract final class TravelRadioLayout {
  /// Side margin: a share of the screen width, within limits.
  static const gutterShare = .03;
  static const minGutter = 12.0;
  static const maxGutter = 24.0;

  /// Radio width: a share of the screen width, within limits; never wider
  /// than the room left by the margins.
  static const cabinetShare = .88;
  static const minCabinetWidth = 280.0;
  static const maxCabinetWidth = 420.0;

  /// Whole points, so the radio's parts stay on the pixel grid.
  static double gutter(double screenWidth) =>
      (screenWidth * gutterShare).clamp(minGutter, maxGutter).floorToDouble();

  static double cabinetWidth(double screenWidth, double available) =>
      (screenWidth * cabinetShare)
          .clamp(minCabinetWidth, maxCabinetWidth)
          .clamp(0.0, available)
          .floorToDouble();

  static const landscapeMinWidth = 520.0;
  static const landscapeMaxHeight = 560.0;
  static const landscapeContentWidth = 720.0;
  static const landscapeControlsWidth = 160.0;
  static const compactHeight = 740.0;
  static const compactHeightWithLargeText = 900.0;
  static const referenceTextSize = 16.0;
  static const largeTextThreshold = 20.0;
  static const headingTracking = -1.0;
  static const headerIconSize = 26.0;
  static const headerActionSize = 48.0;
  static const headerActionGap = 4.0;
  static const captionLineHeight = 1.1;
  static const captionTracking = 0.0;
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
    keyHeight: 44.0,
    keysGap: 6.0,
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
    keyHeight: 46.0,
    keysGap: 16.0,
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

  /// The bookmark beside the song: a little taller than its text.
  static const detailActionSize = 18.0;
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

  /// The welcome page's invitation: a soft accent halo that breathes.
  static const dialGlowOpacity = 0.45;
  static const dialGlowBlur = 22.0;
  static const dialGlowSpread = 6.0;
}

abstract final class RadioKeyDesign {
  static const radius = BorderRadius.all(Radius.circular(8));
  static const slotRadius = BorderRadius.all(Radius.circular(12));
  static const slotPadding = 6.0;
  static const slotHighlightOpacity = .35;
  static const slotHighlightOffset = Offset(0, 1);
  static const iconSize = 22.0;
  static const edgeOffset = Offset(0, 3);
  static const shadowOffset = Offset(0, 4);
  static const shadowBlur = 6.0;
  static const shadowOpacity = .3;
  static const downSlide = Offset(0, .06);
  static const travel = Duration(milliseconds: 90);
  static const disabledOpacity = .45;
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
  static const maxWidth = 520.0;
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
  static const titleTracking = -.6;
  static const titleGap = 5.0;
  static const closeIconSize = 20.0;
  static const contentGap = 20.0;
  static const pullToClose = 24.0;
  static const mutedOpacity = 0.78;
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

  /// The count on the button that opens the list: small, on the rim.
  static const countSize = 14.0;
  static const countOffset = Offset(11, -11);
  static const countPadding = EdgeInsets.symmetric(horizontal: 3);
  static const countText = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 1,
  );
}

abstract final class CodeBadgeDesign {
  static const size = Size(34, 26);
  static const borderOpacity = .55;
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
  static const height = 84.0;
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
  static const clockIconGap = 3.0;
  static const localTimeLabelOpacity = .75;
  static const localTimeLabelText = TextStyle(
    fontSize: 9,
    height: 1.1,
    letterSpacing: 1.5,
  );
}

/// The player bar under the pages opened over the radio.
abstract final class RadioBarDesign {
  static const height = 60.0;
  static const radius = 30.0;
  static const border = 2.0;
  static const key = 44.0;
  static const iconSize = 20.0;
  static const keyIconSize = 16.0;
  static const padding = EdgeInsets.fromLTRB(16, 0, 6, 0);
  static const titleText = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const detailText = TextStyle(fontSize: 12);
  static const detailOpacity = 0.8;
  static const savedHeart = TravelRadioPalette.accent;
}

/// The travel diary: the radio's screen, enlarged.
abstract final class DiaryDesign {
  /// The touched country, on the screen.
  static const selected = Color(0xFFF0A47E);

  /// Dot opacity: never heard, passing through, then the four levels of
  /// the stops.
  static const offOpacity = 0.16;
  static const passingOpacity = 0.38;
  static const levelOpacity = [0.55, 0.7, 0.85, 1.0];

  /// A dot's radius, as a share of its cell; bigger for the two top levels.
  static const dotShare = 0.35;
  static const bigDotShare = 0.44;

  static const minScale = 1.0;
  static const maxScale = 6.0;
  static const zoomStep = 2.0;
  static const zoomKey = 36.0;
  static const zoomKeyRadius = 8.0;
  static const zoomIconSize = 16.0;
  static const zoomInset = 10.0;

  static const mapMinHeight = 180.0;
  static const mapMaxShare = 0.45;
  static const panelRadius = Radius.circular(22);
  static const panelBorder = 3.0;
  static const playerBackdropTint = 0.88;
  static const barInset = EdgeInsets.fromLTRB(12, 12, 12, 14);
  static const pagePadding = EdgeInsets.fromLTRB(16, 14, 16, 10);
  static const periodGap = 8.0;
  static const periodPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const titleText = TextStyle(
    fontSize: 13,
    letterSpacing: 2.4,
    fontWeight: FontWeight.w500,
  );
  static const numbersText = TextStyle(
    fontSize: 13,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
  );
  static const sectionText = TextStyle(fontSize: 11, letterSpacing: 1.8);
  static const mutedOpacity = 0.78;
  static const barHeight = 6.0;
  static const rankNameWidth = 96.0;
  static const rankTimeWidth = 52.0;
  static const sheetRow = 54.0;
  static const sheetButton = 48.0;
  static const sheetMaxShare = 0.62;

  /// The «touch a country» pill in the map's corner.
  static const hintRadius = 10.0;
  static const hintPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const hintText = TextStyle(fontSize: 11);

  /// The map takes this share of the room under the header, never less
  /// than [mapMinHeight] unless the list would drop under [listMinHeight].
  static const mapShare = 0.6;
  static const listMinHeight = 64.0;

  /// The corner of the diary's panel while it grows out of the screen.
  static const growRadius = 16.0;
}
