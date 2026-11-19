import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/locale_keys.g.dart';
import '../links/external_links.dart';

/// Common feedback for an external link, including launch/build failures.
Future<void> openAppLink(
  BuildContext context,
  WidgetRef ref,
  Future<Uri> Function() link,
) async {
  var opened = false;
  try {
    final open = ref.read(openExternalProvider);
    opened = await open(await link());
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.linkError.tr(context: context))),
    );
  }
}
