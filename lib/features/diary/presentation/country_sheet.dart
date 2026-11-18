import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
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
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: TravelRadioPalette.accent,
            foregroundColor: TravelRadioPalette.screenInk,
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
        color: TravelRadioPalette.screenInk,
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
            child: _PullToClose(
              onClose: onClose,
              child: SingleChildScrollView(
                padding: DiaryDesign.sheetPadding.copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Semantics(
                        button: true,
                        label: t(LocaleKeys.diaryCloseSheet),
                        onTap: onClose,
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onClose,
                          // A thin bar, in an area big enough to touch.
                          child: SizedBox.square(
                            dimension: DiaryDesign.handleTouch,
                            child: Center(
                              child: Container(
                                width: DiaryDesign.handleWidth,
                                height: DiaryDesign.handleHeight,
                                decoration: BoxDecoration(
                                  color: muted,
                                  borderRadius: BorderRadius.circular(
                                    DiaryDesign.handleHeight / 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        IconTheme(
                          data: const IconThemeData(
                            color: TravelRadioPalette.screenInk,
                          ),
                          child: CodeBadge(
                            _code,
                            backgroundColor: TravelRadioPalette.screen,
                          ),
                        ),
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
                          Flexible(
                            child: Text(
                              summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: DiaryDesign.numbersText.copyWith(
                                color: ink,
                                fontSize: 14,
                              ),
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
      ),
    );
  }
}

/// Closes the sheet when its content, already at the top, is pulled down
/// far enough: a drag down closes it even when it scrolls.
class _PullToClose extends StatefulWidget {
  const _PullToClose({required this.onClose, required this.child});

  final VoidCallback onClose;
  final Widget child;

  @override
  State<_PullToClose> createState() => _PullToCloseState();
}

class _PullToCloseState extends State<_PullToClose> {
  var _pulled = 0.0;

  bool _onScroll(ScrollNotification event) {
    switch (event) {
      case OverscrollNotification(:final overscroll, dragDetails: _?)
          when overscroll < 0:
        _pulled -= overscroll;
        if (_pulled >= DiaryDesign.sheetPullToClose) {
          _pulled = 0;
          widget.onClose();
        }
      case ScrollEndNotification() || ScrollStartNotification():
        _pulled = 0;
      default:
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      );
}
