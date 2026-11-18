import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/radio/presentation/radio_page.dart';
import '../../features/welcome/application/welcome_seen.dart';
import '../../features/welcome/presentation/welcome_page.dart';
import '../../l10n/locale_keys.g.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_icon_button.dart';
import '../../ui/widgets/app_message.dart';
import '../presentation/app_settings_sheet.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const welcome = '/welcome';
}

@riverpod
GoRouter appRouter(Ref ref, String appName) {
  final router = GoRouter(
    // Bootstrap reads the flag before the first frame; until it is known
    // (only in tests) the radio opens.
    redirect: (_, state) =>
        state.matchedLocation == AppRoutes.home &&
            ref.read(welcomeSeenProvider).valueOrNull == false
        ? AppRoutes.welcome
        : null,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => WelcomePage(appName: appName),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, _) => RadioPage(
          appName: appName,
          settingsAction: AppIconButton(
            tooltip: LocaleKeys.settings.tr(context: context),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showSettings(context),
          ),
        ),
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
