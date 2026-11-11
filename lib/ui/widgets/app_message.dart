import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

class AppMessage extends StatelessWidget {
  const AppMessage({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  }) : leading = null,
       messageStyle = null;

  const AppMessage.empty({
    super.key,
    required this.message,
    required this.leading,
    this.messageStyle,
  }) : title = null,
       actionLabel = null,
       onAction = null;

  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? leading;
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
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
        style: messageStyle,
      ),
      if (actionLabel case final label?) ...[
        const SizedBox(height: AppSpacing.medium),
        AppButton(label: label, onPressed: onAction),
      ],
    ],
  );
}
