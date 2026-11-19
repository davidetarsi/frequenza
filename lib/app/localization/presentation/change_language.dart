import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../application/app_language_provider.dart';
import '../domain/app_language.dart';

/// Persistence is owned by application; the root locale bridge applies it even
/// if the originating sheet has closed in the meantime.
Future<void> changeLanguage(
  BuildContext context,
  WidgetRef ref,
  Locale locale,
) async {
  final language = AppLanguage.fromTag(locale.languageCode);
  if (language == null) return;
  final saved = await ref
      .read(languagePreferenceProvider.notifier)
      .select(language);
  if (!saved && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.languageSaveError.tr(context: context)),
      ),
    );
  }
}
