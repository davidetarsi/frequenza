import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final action = isLoading ? null : onPressed;
    final content = isLoading
        ? SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
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
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: content,
        ),
      ),
      AppButtonVariant.outlined => OutlinedButton.icon(
        onPressed: action,
        icon: icon,
        style: icon == null
            ? OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                ),
              )
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
