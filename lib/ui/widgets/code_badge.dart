import 'package:flutter/material.dart';

import '../theme/app_shape.dart';
import '../theme/travel_radio_design.dart';
import '../theme/travel_radio_palette.dart';

/// A short code on a plate, like the favorites' country codes: it stands
/// where an icon would and takes the icon's colour, selection included.
class CodeBadge extends StatelessWidget {
  const CodeBadge(
    this.code, {
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.size = CodeBadgeDesign.size,
    this.fallbackIcon,
  });

  final String code;
  final Color? backgroundColor, foregroundColor, borderColor;
  final Size size;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final ink = foregroundColor ?? IconTheme.of(context).color;
    return ExcludeSemantics(
      child: Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? TravelRadioPalette.of(context).paper,
          borderRadius: AppShape.controlRadius,
          border: Border.all(
            color:
                borderColor ??
                (ink ?? TravelRadioPalette.of(context).trim).withValues(
                  alpha: CodeBadgeDesign.borderOpacity,
                ),
          ),
        ),
        child: code.isEmpty && fallbackIcon != null
            ? Icon(
                fallbackIcon,
                size: CodeBadgeDesign.fallbackIconSize,
                color: ink,
              )
            : Text(code, style: CodeBadgeDesign.text.copyWith(color: ink)),
      ),
    );
  }
}
