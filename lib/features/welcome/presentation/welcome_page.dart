import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_localization.dart';
import '../../../app/routing/app_router.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/app_button.dart';
import '../../../ui/widgets/code_badge.dart';
import '../application/welcome_seen.dart';
import 'welcome_demo.dart';

/// Shown on the first launch only: the radio at work, the language, and
/// the way in.
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.large),
        child: LayoutBuilder(
          builder: (context, constraints) =>
              _content(context, ref, constraints.maxHeight),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, double height) {
    final theme = Theme.of(context);
    final palette = TravelRadioPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (final (locale, name) in const [
              (AppLocalization.english, LocaleKeys.english),
              (AppLocalization.italian, LocaleKeys.italian),
            ])
              IconButton(
                tooltip: name.tr(context: context),
                isSelected: context.locale == locale,
                color: context.locale == locale
                    ? theme.colorScheme.primary
                    : palette.muted,
                icon: CodeBadge(locale.languageCode.toUpperCase()),
                onPressed: () => context.setLocale(locale),
              ),
          ],
        ),
        Expanded(
          child: Semantics(
            image: true,
            label: LocaleKeys.welcomeDemo.tr(context: context),
            child: ExcludeSemantics(
              child: IgnorePointer(
                // A picture of the radio: it keeps its proportions
                // whatever the text size.
                child: MediaQuery.withNoTextScaling(
                  child: const FittedBox(
                    child: SizedBox(
                      width: WelcomeDemo.width,
                      child: WelcomeDemo(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        // The words never push the radio off the screen: with little
        // room and large text, they scroll.
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height * 0.45),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LocaleKeys.welcomeTitle.tr(context: context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  LocaleKeys.welcomeBody.tr(context: context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        AppButton(
          label: LocaleKeys.welcomeStart.tr(context: context),
          onPressed: () async {
            await ref.read(welcomeSeenProvider.notifier).markSeen();
            if (context.mounted) context.go(AppRoutes.home);
          },
        ),
      ],
    );
  }
}
