import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/code_badge.dart';
import '../../radio/domain/radio_station.dart';
import '../domain/diary_summary.dart';
import 'country_name.dart';
import 'diary_duration.dart';

/// The sheet of a touched country, inside the diary's panel and above the
/// player bar: its stations if it was heard, an invitation if not.
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
    final p = TravelRadioPalette.of(context);
    final theme = Theme.of(context);
    String t(String key, [List<String>? args]) =>
        key.tr(context: context, args: args);
    final name = switch (card) {
      StoppedCountry(:final country) || PassingCountry(:final country) =>
        countryName(context, country.code, fallback: country.name),
      UnvisitedCountry(:final code) => countryName(context, code),
    };
    final muted = p.muted;
    final ink = p.ink;

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
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: TravelRadioPalette.accent,
            foregroundColor: p.paper,
            minimumSize: const Size.fromHeight(DiaryDesign.sheetButton),
          ),
          onPressed: () => onFlyRandom(code),
          icon: const Icon(Icons.arrow_forward),
          label: Text(t(LocaleKeys.diaryFlyTo, [name])),
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

    return GestureDetector(
      key: const ValueKey('country-sheet'),
      // A drag down closes the sheet.
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 0) onClose();
      },
      child: Material(
        color: p.paper,
        borderRadius: const BorderRadius.vertical(
          top: DiaryDesign.sheetRadius,
          bottom: DiaryDesign.panelRadius,
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: name,
            child: SingleChildScrollView(
              padding: DiaryDesign.sheetPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Semantics(
                      button: true,
                      label: t(LocaleKeys.diaryCloseSheet),
                      onTap: onClose,
                      child: GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: p.trim,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      CodeBadge(_code),
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (summary case final summary?)
                        Text(
                          summary,
                          style: DiaryDesign.numbersText.copyWith(
                            color: ink,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...body,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
