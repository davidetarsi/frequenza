import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/theme/app_theme.dart';
import '../ui/theme/travel_radio_palette.dart';
import 'config/app_config.dart';
import 'config/app_localization.dart';
import 'routing/app_router.dart';
import 'theme/app_theme_mode.dart';

class StarterApp extends StatelessWidget {
  const StarterApp({super.key, this.config = const AppConfig(), this.locale});

  final AppConfig config;
  final Locale? locale;

  @override
  Widget build(BuildContext context) => AppLocalization(
    startLocale: locale,
    child: _RoutedApp(config: config),
  );
}

class _RoutedApp extends ConsumerWidget {
  const _RoutedApp({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: config.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.create(
      config.seedColor,
      Brightness.light,
      background: TravelRadioPalette.forBrightness(Brightness.light).paper,
    ),
    darkTheme: AppTheme.create(
      config.seedColor,
      Brightness.dark,
      background: TravelRadioPalette.forBrightness(Brightness.dark).paper,
    ),
    themeMode: ref.watch(appThemeModeProvider).valueOrNull ?? ThemeMode.system,
    locale: context.locale,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    routerConfig: ref.watch(appRouterProvider(config.appName)),
  );
}
