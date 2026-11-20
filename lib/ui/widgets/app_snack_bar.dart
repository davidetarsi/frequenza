import 'package:flutter/material.dart';

import '../theme/app_component_design.dart';

/// Transient feedback with an explicit deadline, including when navigation is
/// accessibility-driven. An action must not turn a confirmation into a sticky notice.
SnackBar appSnackBar({required String message, SnackBarAction? action}) =>
    SnackBar(
      content: Text(message),
      action: action,
      duration: AppMessageDesign.snackBarDuration,
      persist: false,
    );
