import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/bottom_fade.dart';
import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/domain/radio_bar_state.dart';
import '../../radio/presentation/radio_bar.dart';
import '../application/diary_summary_provider.dart';
import '../domain/diary_flight.dart';
import '../domain/diary_period.dart';
import '../domain/diary_summary.dart';
import 'country_name.dart';
import 'country_sheet.dart';
import 'diary_duration.dart';
import 'diary_map.dart';

/// The travel diary, with a floating player above its scrolling contents.
class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  // The page's own view state: it does not outlive the page.
  var _period = DiaryPeriod.month;
  var _showAll = false;

  /// The country whose sheet is open; its card follows the summary.
  String? _selected;

  /// The last summary read, kept while another period loads.
  DiarySummary? _last;
  final _map = TransformationController();
  var _mapPointers = 0;
  var _exploringMap = false;

  void _startMapPointer(PointerDownEvent event) {
    setState(() {
      _mapPointers++;
      _exploringMap =
          _exploringMap ||
          _mapPointers > 1 ||
          _map.value.getMaxScaleOnAxis() > DiaryDesign.minScale;
    });
  }

  void _endMapPointer(PointerEvent event) {
    setState(() {
      _mapPointers--;
      if (_mapPointers == 0) _exploringMap = false;
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(const AppEvent.diaryOpened());
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  /// Back closes the sheet first, then the diary.
  void _back() => Navigator.of(context).maybePop();

  /// The bar is the player: one touch is always back to the radio.
  void _backToRadio() => Navigator.of(context).pop();

  void _pick(DiarySummary summary, String code) {
    setState(() {
      _selected = code;
    });
    ref
        .read(analyticsProvider)
        .track(AppEvent.diaryCountryOpened(code, cardFor(summary, code)));
  }

  void _choose(DiaryPeriod period) {
    setState(() {
      _period = period;
      _showAll = false;
    });
    ref.read(analyticsProvider).track(AppEvent.diaryPeriodChosen(period));
  }

  void _close() => setState(() => _selected = null);

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
    final read = ref.watch(diarySummaryProvider(_period));
    if (read.valueOrNull case final summary?) _last = summary;
    final summary = _last;
    final failed = summary == null && read.hasError;
    final card = switch ((summary, _selected)) {
      (final summary?, final code?) => cardFor(summary, code),
      _ => null,
    };
    final hasPlayer = ref.watch(
      radioControllerProvider.select(
        (session) => radioBarOf(session) is! BarHidden,
      ),
    );
    final route = ModalRoute.of(context)?.animation;
    final bar = BottomFade(
      key: const ValueKey('player-backdrop'),
      tint: TravelRadioPalette.screen.withValues(
        alpha: DiaryDesign.playerBackdropTint,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: DiaryDesign.barInset.copyWith(top: 0),
          child: RadioBar(onBackToRadio: _backToRadio),
        ),
      ),
    );
    return PopScope(
      canPop: card == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: TravelRadioPalette.screen,
        extendBody: true,
        // Keep the measured inset while the country card hides the player.
        bottomNavigationBar: hasPlayer
            ? Visibility(
                visible: card == null,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Padding(
                  // The clear gap sits outside the fade, which starts at the player.
                  padding: EdgeInsets.only(top: DiaryDesign.barInset.top),
                  child: route == null || !AppMotion.enabled(context)
                      ? bar
                      : SlideTransition(
                          position:
                              Tween(
                                begin: AppMotion.diaryBarFrom,
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: route,
                                  curve: const Interval(
                                    AppMotion.diaryBarStart,
                                    1,
                                  ),
                                ),
                              ),
                          child: bar,
                        ),
                ),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Positioned.fill(
                  child: _panel(
                    context,
                    summary ?? const DiarySummary.empty(),
                    loading: summary == null && !failed,
                    failed: failed,
                  ),
                ),
                if (card != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.viewPaddingOf(context).bottom,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: box.maxHeight * DiaryDesign.sheetMaxShare,
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
                          (radio) => radio.tuneRandom(countries: {code}),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(
    BuildContext context,
    DiarySummary summary, {
    required bool loading,
    required bool failed,
  }) {
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
      color: TravelRadioPalette.screen,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ink),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: DiaryDesign.pagePadding.copyWith(left: 0),
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
                  Padding(
                    padding: EdgeInsets.only(
                      left: DiaryDesign.pagePadding.left,
                    ),
                    child: Wrap(
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
                            onTap: () => _choose(period),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, room) {
                  // The map takes most of the room, the list keeps a
                  // line or two even on a phone held sideways.
                  final mapHeight = math.max(
                    0.0,
                    math.min(
                      room.maxHeight - DiaryDesign.listMinHeight,
                      math.max(
                        DiaryDesign.mapMinHeight,
                        room.maxHeight * DiaryDesign.mapShare,
                      ),
                    ),
                  );
                  final content = switch (summary) {
                    _ when failed => [
                      Text(
                        t(LocaleKeys.diaryError),
                        style: TextStyle(color: muted),
                      ),
                    ],
                    _ when loading => <Widget>[],
                    DiaryEmpty() => [
                      Text(
                        t(LocaleKeys.diaryEmpty),
                        style: TextStyle(color: muted),
                      ),
                    ],
                    final DiaryFilled filled => _list(context, filled, muted),
                  };
                  return CustomScrollView(
                    key: const ValueKey('diary-list'),
                    physics: _exploringMap
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          key: const ValueKey('diary-map'),
                          height: mapHeight,
                          child: Listener(
                            onPointerDown: _startMapPointer,
                            onPointerUp: _endMapPointer,
                            onPointerCancel: _endMapPointer,
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
                        ),
                      ),
                      SliverPadding(
                        padding: DiaryDesign.pagePadding.copyWith(
                          bottom:
                              DiaryDesign.pagePadding.bottom +
                              MediaQuery.paddingOf(context).bottom,
                        ),
                        sliver: SliverList.list(children: content),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
        textStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: TravelRadioPalette.screenInk),
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
                const SizedBox(width: AppSpacing.medium),
                Text(t(LocaleKeys.flyThere)),
                const SizedBox(width: AppSpacing.small),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: TravelRadioPalette.screenInk,
                ),
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
