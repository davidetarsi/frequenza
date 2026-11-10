import 'package:flutter/material.dart';

abstract final class AppMotion {
  static Duration standard(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 200);
}
