import 'package:flutter/material.dart';

import '../theme/app_shape.dart';
import '../theme/app_spacing.dart';

class AppSettingsOption extends StatelessWidget {
  const AppSettingsOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    shape: const RoundedRectangleBorder(borderRadius: AppShape.controlRadius),
    minTileHeight: AppShape.minControlHeight,
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
    leading: Icon(icon),
    title: Text(label),
    selected: selected,
    trailing: selected ? const Icon(Icons.check) : null,
    enabled: onTap != null,
    onTap: onTap,
  );
}
