import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/radio/presentation/radio_page.dart';
import '../../l10n/locale_keys.g.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_icon_button.dart';
import '../../ui/widgets/app_message.dart';
import '../presentation/app_settings_page.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
}

@riverpod
GoRouter appRouter(Ref ref, String appName) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, _) => RadioPage(
          appName: appName,
          settingsAction: AppIconButton(
            tooltip: LocaleKeys.settings.tr(context: context),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const AppSettingsPage(),
      ),
    ],
    errorBuilder: (context, _) => Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: AppMessage(
            message: LocaleKeys.pageNotFound.tr(context: context),
            actionLabel: LocaleKeys.backHome.tr(context: context),
            onAction: () => context.go(AppRoutes.home),
          ),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
}
