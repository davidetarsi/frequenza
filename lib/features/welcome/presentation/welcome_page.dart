import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_router.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/widgets/app_button.dart';
import '../application/welcome_seen.dart';

/// Shown on the first launch only, before the radio.
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Center(
        child: AppButton(
          label: LocaleKeys.welcomeStart.tr(context: context),
          onPressed: () async {
            await ref.read(welcomeSeenProvider.notifier).markSeen();
            if (context.mounted) context.go(AppRoutes.home);
          },
        ),
      ),
    ),
  );
}
