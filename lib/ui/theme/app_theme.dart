import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData create(Color seedColor, Brightness brightness) => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF242B28)
        : const Color(0xFFFAF7EF),
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
  );
}
