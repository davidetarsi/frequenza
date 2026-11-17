import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/application/analytics_consent.dart';
import '../../l10n/locale_keys.g.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/widgets/app_settings_option.dart';
import '../../ui/widgets/code_badge.dart';
import '../../ui/widgets/travel_sheet.dart';
import '../config/app_localization.dart';
import '../links/app_version.dart';
import '../links/external_links.dart';
import '../theme/app_theme_mode.dart';

Future<void> showSettings(BuildContext context) =>
    showTravelSheet(context, builder: (_) => const AppSettingsSheet());

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeModeProvider);
    final statistics = ref.watch(analyticsConsentProvider);
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
          LocaleKeys.privacy.tr(context: context),
          style: textTheme.titleMedium,
        ),
        AppSettingsOption(
          leading: const Icon(Icons.insights_outlined),
          label: LocaleKeys.analyticsSwitch.tr(context: context),
          selected: false,
          trailing: Switch(
            value: analyticsOn(statistics),
            onChanged: statistics.isLoading
                ? null
                : (on) => _setStatistics(context, ref, on),
          ),
          onTap: statistics.isLoading
              ? null
              : () => _setStatistics(context, ref, !analyticsOn(statistics)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Text(
            LocaleKeys.analyticsHint.tr(context: context),
            style: textTheme.bodySmall,
          ),
        ),
        AppSettingsOption(
          leading: const Icon(Icons.privacy_tip_outlined),
          label: LocaleKeys.privacyPolicy.tr(context: context),
          selected: false,
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _open(context, ref, () async => AppLinks.privacy),
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
          onTap: () => _open(context, ref, () async => AppLinks.project),
        ),
        AppSettingsOption(
          leading: const Icon(Icons.feedback_outlined),
          label: LocaleKeys.sendFeedback.tr(context: context),
          selected: false,
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _open(
            context,
            ref,
            () async => AppLinks.feedback(
              version: await ref.read(appVersionProvider.future),
              phone: await ref.read(deviceInfoProvider.future),
            ),
          ),
        ),
      ],
    );
  }

  /// Saves the statistics choice; says so when it cannot.
  Future<void> _setStatistics(
    BuildContext context,
    WidgetRef ref,
    bool on,
  ) async {
    final saved = await ref.read(analyticsConsentProvider.notifier).select(on);
    if (!saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.analyticsSaveError.tr(context: context)),
        ),
      );
    }
  }

  /// Opens [link]; says so when nothing opens it.
  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Future<Uri> Function() link,
  ) async {
    final opened = await ref.read(openExternalProvider)(await link());
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.linkError.tr(context: context))),
      );
    }
  }
}
