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
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.small),
      Text(message),
      const SizedBox(height: AppSpacing.medium),
      AppButton(label: actionLabel, onPressed: onAction),
    ],
  );
}
