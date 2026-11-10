import 'package:flutter/material.dart';
import 'travel_radio_palette.dart';

abstract final class AppTheme {
  static ThemeData create(Color seedColor, Brightness brightness) => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: TravelRadioPalette.forBrightness(brightness).paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
  );
}
