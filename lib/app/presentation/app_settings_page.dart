import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/locale_keys.g.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_settings_option.dart';
import '../config/app_localization.dart';
import '../theme/app_theme_mode.dart';

class AppSettingsPage extends ConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeModeProvider);
    final currentMode = theme.valueOrNull ?? ThemeMode.system;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.settings.tr(context: context))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                Text(
                  LocaleKeys.appearance.tr(context: context),
                  style: textTheme.titleMedium,
                ),
                for (final (mode, label, icon) in const [
                  (
                    ThemeMode.system,
                    LocaleKeys.themeSystem,
                    Icons.brightness_auto_outlined,
                  ),
                  (
                    ThemeMode.light,
                    LocaleKeys.themeLight,
                    Icons.light_mode_outlined,
                  ),
                  (
                    ThemeMode.dark,
                    LocaleKeys.themeDark,
                    Icons.dark_mode_outlined,
                  ),
                ])
                  AppSettingsOption(
                    icon: icon,
                    label: label.tr(context: context),
                    selected: currentMode == mode,
                    onTap: theme.isLoading
                        ? null
                        : () async {
                            final saved = await ref
                                .read(appThemeModeProvider.notifier)
                                .select(mode);
                            if (!saved && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleKeys.themeSaveError.tr(
                                      context: context,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  LocaleKeys.language.tr(context: context),
                  style: textTheme.titleMedium,
                ),
                for (final (locale, label) in const [
                  (AppLocalization.italian, LocaleKeys.italian),
                  (AppLocalization.english, LocaleKeys.english),
                ])
                  AppSettingsOption(
                    icon: Icons.language,
                    label: label.tr(context: context),
                    selected: context.locale == locale,
                    onTap: () => context.setLocale(locale),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
