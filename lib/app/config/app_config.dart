import 'package:flutter/material.dart';
import '../../ui/theme/travel_radio_palette.dart';

class AppConfig {
  const AppConfig({
    this.appName = 'Frequenza',
    this.seedColor = TravelRadioPalette.accent,
  });

  final String appName;
  final Color seedColor;
}
