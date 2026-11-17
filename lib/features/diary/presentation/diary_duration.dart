import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../l10n/locale_keys.g.dart';

/// Hours from one hour on, minutes below.
String diaryDuration(BuildContext context, int seconds) => seconds >= 3600
    ? LocaleKeys.diaryHours.tr(context: context, args: ['${seconds ~/ 3600}'])
    : LocaleKeys.diaryMinutes.tr(
        context: context,
        args: ['${(seconds / 60).round()}'],
      );
