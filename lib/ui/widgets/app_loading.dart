import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.large),
    child: Center(child: CircularProgressIndicator(semanticsLabel: label)),
  );
}
