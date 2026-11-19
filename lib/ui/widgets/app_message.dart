import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_shape.dart';
import '../theme/app_component_design.dart';
import '../theme/travel_radio_palette.dart';
import 'app_button.dart';

class AppMessage extends StatelessWidget {
  const AppMessage({
    super.key,
    this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  }) : leading = null,
       messageStyle = null,
       _panelIcon = null,
       _error = false;

  const AppMessage.error({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  }) : title = null,
       leading = null,
       messageStyle = null,
       _panelIcon = null,
       _error = true;

  const AppMessage.emptyPanel({
    super.key,
    required this.message,
    required IconData icon,
  }) : title = null,
       actionLabel = null,
       onAction = null,
       leading = null,
       messageStyle = null,
       _panelIcon = icon,
       _error = false;

  const AppMessage.empty({
    super.key,
    required this.message,
    required this.leading,
    this.messageStyle,
  }) : title = null,
       actionLabel = null,
       onAction = null,
       _panelIcon = null,
       _error = false;

  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? leading;
  final TextStyle? messageStyle;
  final IconData? _panelIcon;
  final bool _error;

  @override
  Widget build(BuildContext context) {
    if (_panelIcon case final icon?) {
      final palette = TravelRadioPalette.of(context);
      return Container(
        padding: AppMessageDesign.panelPadding,
        decoration: BoxDecoration(
          color: palette.paperRaised,
          borderRadius: AppShape.panelRadius,
        ),
        child: AppMessage.empty(
          leading: Icon(
            icon,
            color: palette.muted,
            size: AppMessageDesign.emptyIconSize,
          ),
          message: message,
          messageStyle: TextStyle(color: palette.ink),
        ),
      );
    }
    return Column(
      crossAxisAlignment: _error
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.stretch,
      children: [
        if (title case final title?) ...[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.small),
        ],
        if (leading case final leading?) ...[
          Center(child: leading),
          const SizedBox(height: AppSpacing.medium),
        ],
        Text(
          message,
          textAlign: leading != null ? TextAlign.center : null,
          style: _error
              ? TextStyle(color: Theme.of(context).colorScheme.error)
              : messageStyle,
        ),
        if (actionLabel case final label?) ...[
          if (!_error) const SizedBox(height: AppSpacing.medium),
          AppButton(
            label: label,
            onPressed: onAction,
            variant: _error ? AppButtonVariant.text : AppButtonVariant.filled,
          ),
        ],
      ],
    );
  }
}
