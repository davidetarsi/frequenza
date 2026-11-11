import 'package:flutter/material.dart';

enum AppIconButtonVariant { standard, outlined, tonal }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.standard,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
    return switch (variant) {
      AppIconButtonVariant.standard => IconButton(
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
        style: style,
      ),
      AppIconButtonVariant.outlined => IconButton.outlined(
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
        style: style,
      ),
      AppIconButtonVariant.tonal => IconButton.filledTonal(
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
        style: style,
      ),
    };
  }
}
