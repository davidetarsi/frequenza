import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData create(Color seedColor, Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
  );
}
