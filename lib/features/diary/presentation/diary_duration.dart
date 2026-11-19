import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../l10n/locale_keys.g.dart';
import '../domain/diary_duration.dart';

/// A diary time in words: «meno di 1 min», «12 min», «2 h».
String diaryDuration(BuildContext context, int seconds) =>
    switch (diaryDurationOf(seconds)) {
      UnderAMinute() => LocaleKeys.diaryUnderAMinute.tr(context: context),
      DiaryMinutes(:final minutes) => LocaleKeys.diaryMinutes.tr(
        context: context,
        args: [
          NumberFormat.decimalPattern(
            context.locale.toLanguageTag(),
          ).format(minutes),
        ],
      ),
      DiaryHours(:final hours) => LocaleKeys.diaryHours.tr(
        context: context,
        args: [
          NumberFormat.decimalPattern(
            context.locale.toLanguageTag(),
          ).format(hours),
        ],
      ),
    };
