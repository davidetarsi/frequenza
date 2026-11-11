import 'package:flutter/material.dart';

abstract final class AppMotion {
  static bool enabled(BuildContext context) =>
      !MediaQuery.disableAnimationsOf(context);

  static Duration standard(BuildContext context) =>
      enabled(context) ? const Duration(milliseconds: 200) : Duration.zero;
}
