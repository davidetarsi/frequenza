import 'package:flutter/material.dart';

import '../theme/app_component_design.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.icon,
  }) : _emphasized = false;

  const AppButton.emphasized({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : variant = AppButtonVariant.filled,
       _emphasized = true;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool _emphasized;

  @override
  Widget build(BuildContext context) {
    final action = isLoading ? null : onPressed;
    final content = isLoading
        ? SizedBox.square(
            dimension: AppButtonDesign.loadingSize,
            child: CircularProgressIndicator(
              strokeWidth: AppButtonDesign.loadingStroke,
              semanticsLabel: label,
            ),
          )
        : Text(
            label,
            textAlign: TextAlign.center,
            maxLines: variant == AppButtonVariant.outlined && icon == null
                ? 1
                : null,
            overflow: variant == AppButtonVariant.outlined && icon == null
                ? TextOverflow.ellipsis
                : null,
          );
    return switch (variant) {
      AppButtonVariant.filled => FilledButton.icon(
        onPressed: action,
        icon: icon,
        style: _emphasized ? AppButtonDesign.emphasizedStyle : null,
        label: Padding(
          padding: _emphasized
              ? EdgeInsets.zero
              : AppButtonDesign.filledLabelPadding,
          child: content,
        ),
      ),
      AppButtonVariant.outlined => OutlinedButton.icon(
        onPressed: action,
        icon: icon,
        style: icon == null
            ? OutlinedButton.styleFrom(padding: AppButtonDesign.outlinedPadding)
            : null,
        label: content,
      ),
      AppButtonVariant.text => TextButton.icon(
        onPressed: action,
        icon: icon,
        label: content,
      ),
    };
  }
}
