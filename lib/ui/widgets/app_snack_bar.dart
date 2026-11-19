import 'package:flutter/material.dart';

import '../theme/app_component_design.dart';

/// Transient feedback, with enough time to use actions when navigation is
/// accessibility-driven. Flutter otherwise persists every snackbar with an action.
SnackBar appSnackBar(
  BuildContext context, {
  required String message,
  SnackBarAction? action,
}) => SnackBar(
  content: Text(message),
  action: action,
  duration: AppMessageDesign.snackBarDuration,
  persist: action != null && MediaQuery.accessibleNavigationOf(context),
);
