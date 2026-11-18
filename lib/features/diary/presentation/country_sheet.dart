import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/code_badge.dart';
import '../../../ui/widgets/travel_sheet.dart';
import '../../radio/domain/radio_station.dart';
import '../domain/diary_summary.dart';
import 'country_name.dart';
import 'diary_duration.dart';

/// Country-specific content for the shared bottom sheet in the diary.
class CountrySheet extends StatelessWidget {
  const CountrySheet({
    super.key,
    required this.card,
    required this.onFly,
    required this.onFlyRandom,
    required this.onClose,
  });

  final CountryCard card;
  final ValueChanged<RadioStation> onFly;
  final ValueChanged<String> onFlyRandom;
  final VoidCallback onClose;

  String get _code => switch (card) {
    StoppedCountry(:final country) ||
    PassingCountry(:final country) => country.code,
    UnvisitedCountry(:final code) => code,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String t(String key, [List<String>? args]) =>
        key.tr(context: context, args: args);
    final name = switch (card) {
      StoppedCountry(:final country) || PassingCountry(:final country) =>
        countryName(context, country.code, fallback: country.name),
      UnvisitedCountry(:final code) => countryName(context, code),
    };
    const ink = TravelRadioPalette.screen;
    final muted = ink.withValues(alpha: DiaryDesign.mutedOpacity);

    Widget station(StationTime heard) => InkWell(
      onTap: () => onFly(heard.station),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DiaryDesign.sheetRow),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    heard.station.name,
                    style: theme.textTheme.titleSmall?.copyWith(color: ink),
                  ),
                  Text(
                    [
                      ?heard.station.region,
                      diaryDuration(context, heard.seconds),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Text(
              t(LocaleKeys.flyThere),
              style: theme.textTheme.labelLarge?.copyWith(
                color: TravelRadioPalette.accent,
              ),
            ),
          ],
        ),
      ),
    );

    final body = switch (card) {
      StoppedCountry(:final country) => [
        for (final heard in country.stations) station(heard),
        const SizedBox(height: 8),
        Text(
          t(LocaleKeys.diaryLastListen, [
            DateFormat.yMMMd(
              context.locale.toLanguageTag(),
            ).add_Hm().format(country.lastListen.toLocal()),
          ]),
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
      PassingCountry(:final country, :final thresholdSeconds) => [
        Text(
          t(LocaleKeys.diaryPassing, [
            diaryDuration(context, country.seconds),
            diaryDuration(context, thresholdSeconds),
          ]),
          style: theme.textTheme.bodyMedium?.copyWith(color: ink),
        ),
        const SizedBox(height: 10),
        Text(
          t(LocaleKeys.diaryHeardHere).toUpperCase(),
          style: DiaryDesign.sectionText.copyWith(color: muted),
        ),
        for (final heard in country.stations) station(heard),
      ],
      UnvisitedCountry(:final code) => [
        Text(
          t(LocaleKeys.diaryUnvisited),
          style: theme.textTheme.bodyMedium?.copyWith(color: ink),
        ),
        const SizedBox(height: 14),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: TravelRadioPalette.accent,
            foregroundColor: TravelRadioPalette.screenInk,
            minimumSize: const Size.fromHeight(DiaryDesign.sheetButton),
          ),
          onPressed: () => onFlyRandom(code),
          child: Text(t(LocaleKeys.diaryFlyTo, [name])),
        ),
        const SizedBox(height: 8),
        Text(
          t(LocaleKeys.diaryRandomIn),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    };

    final summary = switch (card) {
      StoppedCountry(:final country) =>
        '${diaryDuration(context, country.seconds)} · ${LocaleKeys.diaryRadios.plural(country.stations.length, context: context)}',
      PassingCountry(:final country) => diaryDuration(context, country.seconds),
      UnvisitedCountry() => null,
    };

    return TravelSheet(
      key: const ValueKey('country-sheet'),
      title: name,
      presentation: TravelSheetPresentation.embedded,
      backgroundColor: TravelRadioPalette.screenInk,
      foregroundColor: ink,
      onClose: onClose,
      leading: IconTheme(
        data: const IconThemeData(color: TravelRadioPalette.screenInk),
        child: CodeBadge(_code, backgroundColor: TravelRadioPalette.screen),
      ),
      trailing: summary == null
          ? null
          : Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: DiaryDesign.numbersText.copyWith(color: ink, fontSize: 14),
            ),
      children: body,
    );
  }
}
