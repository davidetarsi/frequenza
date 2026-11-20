import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../l10n/locale_keys.g.dart';

/// Optional pieces of external metadata, separated according to the dictionary.
String detailText(BuildContext context, Iterable<String?> values) => values
    .whereType<String>()
    .where((value) => value.isNotEmpty)
    .join(LocaleKeys.detailsSeparator.tr(context: context));
