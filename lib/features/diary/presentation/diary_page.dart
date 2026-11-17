import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/presentation/radio_bar.dart';
import '../application/diary_summary_provider.dart';
import '../domain/diary_flight.dart';
import '../domain/diary_period.dart';
import '../domain/diary_summary.dart';
import 'country_name.dart';
import 'country_sheet.dart';
import 'diary_duration.dart';
import 'diary_map.dart';

/// The travel diary: a panel over the radio, with the player bar below it.
class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  // The page's own view state: it does not outlive the page.
  var _period = DiaryPeriod.month;
  String? _selected;
  var _showAll = false;

  /// The open country sheet, if any.
  CountryCard? _card;
  final _map = TransformationController();

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(AppEvent.diaryOpened(_period));
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _back() => Navigator.of(context).maybePop();

  void _pick(DiarySummary summary, String code) {
    final card = cardFor(summary, code);
    setState(() {
      _selected = code;
      _card = card;
    });
    ref.read(analyticsProvider).track(AppEvent.diaryCountryOpened(code, card));
  }

  void _close() => setState(() {
    _card = null;
    _selected = null;
  });

  /// Flights stay in the diary: the bar shows them.
  void _fly(
    DiaryFlightSource source,
    Future<void> Function(RadioController) go,
  ) {
    ref.read(analyticsProvider).track(AppEvent.diaryFlight(source));
    final radio = ref.read(radioControllerProvider.notifier);
    _close();
    go(radio);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    final summary =
        ref.watch(diarySummaryProvider(_period)).valueOrNull ??
        const DiarySummary.empty();
    final route = ModalRoute.of(context)?.animation;
    final bar = Padding(
      padding: DiaryDesign.barInset,
      child: RadioBar(onBackToRadio: _back),
    );
    return PopScope(
      canPop: _card == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.shellTop, p.shellBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => Stack(
                      children: [
                        Positioned.fill(child: _panel(context, summary)),
                        if (_card case final card?)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    box.maxHeight * DiaryDesign.sheetMaxShare,
                              ),
                              child: CountrySheet(
                                card: card,
                                onClose: _close,
                                onFly: (station) => _fly(
                                  DiaryFlightSource.countryStation,
                                  (radio) => radio.tuneTo(station),
                                ),
                                onFlyRandom: (code) => _fly(
                                  DiaryFlightSource.randomInCountry,
                                  (radio) =>
                                      radio.tuneRandom(countries: {code}),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (route == null)
                  bar
                else
                  SlideTransition(
                    position:
                        Tween(
                          begin: const Offset(0, 1.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: route,
                            curve: const Interval(0.55, 1),
                          ),
                        ),
                    child: bar,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context, DiarySummary summary) {
    String t(String key, [List<String>? args]) =>
        key.tr(context: context, args: args);
    final ink = TravelRadioPalette.screenInk;
    final muted = ink.withValues(alpha: DiaryDesign.mutedOpacity);
    final (countries, total) = switch (summary) {
      DiaryEmpty() => (0, 0),
      final DiaryFilled filled => (filled.stopped.length, filled.totalSeconds),
    };
    final countryCount = LocaleKeys.diaryCountryCount.plural(
      countries,
      context: context,
    );
    final mapLabel = switch (summary) {
      DiaryFilled(:final topStop?) => t(LocaleKeys.diaryMapSummary, [
        countryCount,
        countryName(context, topStop.code, fallback: topStop.name),
      ]),
      _ => t(LocaleKeys.diaryMapEmpty),
    };
    return Container(
      decoration: BoxDecoration(
        color: TravelRadioPalette.screen,
        borderRadius: const BorderRadius.vertical(
          bottom: DiaryDesign.panelRadius,
        ),
        border: Border(
          bottom: BorderSide(
            color: TravelRadioPalette.screenBorder,
            width: DiaryDesign.panelBorder,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ink),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mapHeight = (constraints.maxHeight * DiaryDesign.mapMaxShare)
                .clamp(DiaryDesign.mapMinHeight, double.infinity);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: DiaryDesign.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: t(LocaleKeys.backToRadio),
                            onPressed: _back,
                            color: ink,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Text(
                              t(LocaleKeys.diaryTitle).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DiaryDesign.titleText,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              total == 0
                                  ? countryCount
                                  : '$countryCount · ${diaryDuration(context, total)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DiaryDesign.numbersText,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final (period, key) in const [
                            (DiaryPeriod.week, LocaleKeys.diaryWeek),
                            (DiaryPeriod.month, LocaleKeys.diaryMonth),
                            (DiaryPeriod.year, LocaleKeys.diaryYear),
                            (DiaryPeriod.always, LocaleKeys.diaryAlways),
                          ])
                            _PeriodPill(
                              label: t(key),
                              selected: _period == period,
                              onTap: () => setState(() {
                                _period = period;
                                _showAll = false;
                              }),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  key: const ValueKey('diary-map'),
                  height: mapHeight,
                  child: DiaryMap(
                    summary: summary,
                    selected: _selected,
                    controller: _map,
                    onCountry: (code) => _pick(summary, code),
                    zoomInLabel: t(LocaleKeys.diaryZoomIn),
                    zoomOutLabel: t(LocaleKeys.diaryZoomOut),
                    semanticsLabel: mapLabel,
                  ),
                ),
                Expanded(
                  child: ListView(
                    key: const ValueKey('diary-list'),
                    padding: DiaryDesign.pagePadding,
                    children: switch (summary) {
                      DiaryEmpty() => [
                        Text(
                          t(LocaleKeys.diaryEmpty),
                          style: TextStyle(color: muted),
                        ),
                      ],
                      final DiaryFilled filled => _list(context, filled, muted),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _list(BuildContext context, DiaryFilled summary, Color muted) {
    String t(String key, [List<String>? args]) =>
        key.tr(context: context, args: args);
    final top = summary.top;
    final stops = summary.stopped;
    final shown = _showAll ? stops : stops.take(10).toList();
    final longest = stops.isEmpty ? 0 : stops.first.seconds;
    return [
      Text(
        t(LocaleKeys.diaryTop).toUpperCase(),
        style: DiaryDesign.sectionText.copyWith(color: muted),
      ),
      const SizedBox(height: 6),
      Material(
        color: TravelRadioPalette.screenHighlight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: TravelRadioPalette.screenInk.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _fly(
            DiaryFlightSource.topStation,
            (radio) => radio.tuneTo(top.station),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${top.station.name} · ${countryName(context, top.station.countryCode, fallback: top.station.country)} · ${diaryDuration(context, top.seconds)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(t(LocaleKeys.flyThere)),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        t(LocaleKeys.diaryCountries).toUpperCase(),
        style: DiaryDesign.sectionText.copyWith(color: muted),
      ),
      for (final country in shown)
        InkWell(
          onTap: () => _pick(summary, country.code),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                SizedBox(
                  width: DiaryDesign.rankNameWidth,
                  child: Text(
                    countryName(context, country.code, fallback: country.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: longest == 0 ? 0 : country.seconds / longest,
                    child: Container(
                      height: DiaryDesign.barHeight,
                      decoration: BoxDecoration(
                        color: TravelRadioPalette.screenInk,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: DiaryDesign.rankTimeWidth,
                  child: Text(
                    diaryDuration(context, country.seconds),
                    textAlign: TextAlign.end,
                    style: DiaryDesign.numbersText,
                  ),
                ),
              ],
            ),
          ),
        ),
      if (!_showAll && stops.length > 10)
        TextButton(
          onPressed: () => setState(() => _showAll = true),
          child: Text(t(LocaleKeys.diaryShowAll, ['${stops.length}'])),
        ),
      if (summary.longestTripKm case final km?) ...[
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Text(
                t(LocaleKeys.diaryLongestTrip),
                style: TextStyle(color: muted),
              ),
            ),
            Text(
              t(LocaleKeys.diaryKm, [
                NumberFormat.decimalPattern(
                  context.locale.toLanguageTag(),
                ).format(km.round()),
              ]),
              style: DiaryDesign.numbersText,
            ),
          ],
        ),
      ],
    ];
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = TravelRadioPalette.screenInk;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? ink : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? ink : ink.withValues(alpha: 0.4)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? TravelRadioPalette.screen : ink,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
