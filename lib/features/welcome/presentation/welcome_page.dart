import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_localization.dart';
import '../../../app/routing/app_router.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/code_badge.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/presentation/radio_cabinet.dart';
import '../application/welcome_seen.dart';
import 'welcome_demo.dart';

/// Shown on the first launch only: what the radio does, then the radio
/// itself, whose dial turns it on.
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  /// Turning the dial turns the radio on: the first flight starts while the
  /// radio grows into its own page.
  Future<void> _turnOn(BuildContext context, WidgetRef ref) async {
    await ref.read(welcomeSeenProvider.notifier).markSeen();
    if (!context.mounted) return;
    unawaited(ref.read(radioControllerProvider.notifier).tuneRandom());
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.large),
      child: LayoutBuilder(
        builder: (context, constraints) =>
            _content(context, ref, constraints.maxHeight),
      ),
    ),
  );

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
        // The words come first; with little room and large text they
        // scroll, so the radio stays in view.
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height * 0.4),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    LocaleKeys.welcomeTitle.tr(context: context),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
        Expanded(
          child: Semantics(
            button: true,
            label: LocaleKeys.welcomeStart.tr(context: context),
            onTap: () => _turnOn(context, ref),
            child: ExcludeSemantics(
              child: GestureDetector(
                key: const ValueKey('welcome-radio'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _turnOn(context, ref),
                // A picture of the radio: its own keys do not answer, and it
                // keeps its proportions whatever the text size.
                child: IgnorePointer(
                  child: MediaQuery.withNoTextScaling(
                    child: FittedBox(
                      child: HeroMode(
                        enabled: AppMotion.enabled(context),
                        child: const RadioCabinetHero(
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
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          LocaleKeys.welcomeHint.tr(context: context),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: palette.muted),
        ),
      ],
    );
  }
}
