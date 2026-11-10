import 'package:flutter/material.dart';

import '../features/radio/presentation/radio_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../ui/theme/app_theme.dart';
import 'config/app_config.dart';

class StarterApp extends StatelessWidget {
  const StarterApp({super.key, this.config = const AppConfig(), this.locale});

  final AppConfig config;
  final Locale? locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: config.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.create(config.seedColor, Brightness.light),
    darkTheme: AppTheme.create(config.seedColor, Brightness.dark),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: RadioPage(appName: config.appName),
  );
}
