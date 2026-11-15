import 'package:flutter/material.dart';

import '../theme/app_shape.dart';
import '../theme/app_spacing.dart';

class AppSettingsOption extends StatelessWidget {
  const AppSettingsOption({
    super.key,
    required this.leading,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  /// An icon, or a [CodeBadge] where a code says more.
  final Widget leading;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Shown when the option is not selected, e.g. a sign that it leaves
  /// the app.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    shape: const RoundedRectangleBorder(borderRadius: AppShape.controlRadius),
    minTileHeight: AppShape.minControlHeight,
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
    leading: leading,
    title: Text(label),
    selected: selected,
    trailing: selected ? const Icon(Icons.check) : trailing,
    enabled: onTap != null,
    onTap: onTap,
  );
}
