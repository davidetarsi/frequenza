import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/locale_keys.g.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_settings_option.dart';
import '../../ui/widgets/code_badge.dart';
import '../../ui/widgets/travel_sheet.dart';
import '../config/app_localization.dart';
import '../links/external_links.dart';
import '../theme/app_theme_mode.dart';

Future<void> showSettings(BuildContext context) =>
    showTravelSheet(context, builder: (_) => const AppSettingsSheet());

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeModeProvider);
    final currentMode = theme.valueOrNull ?? ThemeMode.system;
    final textTheme = Theme.of(context).textTheme;
    return TravelSheet(
      title: LocaleKeys.settings.tr(context: context),
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
          (ThemeMode.light, LocaleKeys.themeLight, Icons.light_mode_outlined),
          (ThemeMode.dark, LocaleKeys.themeDark, Icons.dark_mode_outlined),
        ])
          AppSettingsOption(
            leading: Icon(icon),
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
                            LocaleKeys.themeSaveError.tr(context: context),
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
            leading: CodeBadge(locale.languageCode.toUpperCase()),
            label: label.tr(context: context),
            selected: context.locale == locale,
            onTap: () => context.setLocale(locale),
          ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          LocaleKeys.about.tr(context: context),
          style: textTheme.titleMedium,
        ),
        AppSettingsOption(
          leading: const Icon(Icons.code),
          label: LocaleKeys.viewOnGitHub.tr(context: context),
          selected: false,
          trailing: const Icon(Icons.open_in_new),
          onTap: () async {
            final opened = await ref.read(openExternalProvider)(
              AppLinks.project,
            );
            if (!opened && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocaleKeys.linkError.tr(context: context)),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
