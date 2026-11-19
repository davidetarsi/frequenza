import 'package:flutter/material.dart';

import 'app_shape.dart';
import 'app_spacing.dart';
import 'travel_radio_palette.dart';

abstract final class AppButtonDesign {
  static const loadingSize = 24.0;
  static const loadingStroke = 2.0;
  static const filledLabelPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.small,
  );
  static const outlinedPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.small,
  );
  static final emphasizedStyle = FilledButton.styleFrom(
    backgroundColor: TravelRadioPalette.accent,
    foregroundColor: TravelRadioPalette.screenInk,
    minimumSize: const Size.fromHeight(AppShape.minControlHeight),
  );
}

abstract final class AppMessageDesign {
  static const panelPadding = EdgeInsets.all(AppSpacing.large);
  static const emptyIconSize = 28.0;
}

/// Typography shared by the saved-station and saved-song lists.
abstract final class SavedItemsDesign {
  static const titleGap = 5.0;
  static const titleText = TextStyle(fontWeight: FontWeight.w600);
  static const groupText = titleText;
  static const removeBackgroundOpacity = .12;
}

/// The compact bookmark beside live track metadata.
abstract final class SongBookmarkDesign {
  static const iconSize = 18.0;
  static const widthInset = 8.0;
  static const heightInset = 4.0;
}
