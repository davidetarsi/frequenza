import 'package:flutter/material.dart';

import '../theme/app_shape.dart';
import '../theme/travel_radio_design.dart';
import '../theme/travel_radio_palette.dart';

/// A short code on a plate, like the favorites' country codes: it stands
/// where an icon would and takes the icon's colour, selection included.
class CodeBadge extends StatelessWidget {
  const CodeBadge(this.code, {super.key, this.backgroundColor});

  final String code;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ink = IconTheme.of(context).color;
    return ExcludeSemantics(
      child: Container(
        width: CodeBadgeDesign.size.width,
        height: CodeBadgeDesign.size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? TravelRadioPalette.of(context).paper,
          borderRadius: AppShape.controlRadius,
          border: Border.all(
            color: (ink ?? TravelRadioPalette.of(context).trim).withValues(
              alpha: CodeBadgeDesign.borderOpacity,
            ),
          ),
        ),
        child: Text(
          code,
          style: RadioFavoritesDesign.presetCodeText.copyWith(color: ink),
        ),
      ),
    );
  }
}
