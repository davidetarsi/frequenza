import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../app/platform/application/app_platform_provider.dart';

/// Copies the song on air, with a light buzz; says so only where the
/// phone would not.
Future<void> copyTrackTitle(
  BuildContext context,
  WidgetRef ref,
  String title,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = LocaleKeys.titleCopied.tr(context: context);
  final confirmed = await ref.read(appPlatformProvider).copyText(title);
  if (confirmed || !context.mounted) return;
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
