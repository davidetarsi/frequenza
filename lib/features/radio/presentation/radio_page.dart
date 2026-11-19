import '../../journey/presentation/country_name.dart';
import '../../../app/localization/presentation/detail_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../../ui/widgets/adaptive_fit.dart';
import '../../diary/presentation/diary_route.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../favorites/presentation/favorites_sheet.dart';
import '../../journey/presentation/journey_texts.dart';
import '../../journey/presentation/route_map.dart';
import '../../songs/presentation/save_song.dart';
import '../application/radio_controller.dart';
import '../domain/radio_session.dart';
import '../domain/journey.dart';
import 'radio_display.dart';
import 'copy_track_title.dart';
import 'radio_cabinet.dart';
import 'radio_keys.dart';

/// The radio's screen: the diary grows out of it.
final radioScreenKey = GlobalKey(debugLabel: 'radio-screen');

/// Anchors belong to this page, including while its cabinet flies to the home.
class RadioPageAnchors {
  final screen = GlobalKey(debugLabel: 'radio-guide-screen');
  final dial = GlobalKey(debugLabel: 'radio-guide-dial');
  final favorites = GlobalKey(debugLabel: 'radio-guide-favorites');
  final diary = GlobalKey(debugLabel: 'radio-guide-diary');
}

class RadioPage extends ConsumerWidget {
  const RadioPage({
    super.key,
    required this.appName,
    required this.settingsAction,
    this.tourTargets,
  });
  final RadioPageAnchors? tourTargets;
  final String appName;
  final Widget settingsAction;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(radioControllerProvider);
    final display = RadioDisplay.of(session);
    final journey = session.journey;
    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.valueOrNull;
    final favoritesCount = favorites?.stations.length ?? 0;
    final controller = ref.read(radioControllerProvider.notifier);
    final station = display.station;
    final song = display.song;
    final track = display.track;
    final saved = station != null && favorites?.contains(station.id) == true;
    final theme = Theme.of(context);
    ref.listen(favoritesProvider, (before, after) {
      if (after.hasError && before?.hasError != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.favoritesError.tr(context: context)),
          ),
        );
      }
    });
    String text(DisplayText text) => switch (text) {
      Translated(:final key) => key.tr(context: context),
      Verbatim(:final text) => text,
      CountryText(:final code, :final fallback) => countryName(
        context,
        code,
        fallback: fallback,
      ),
    };
    final distance = display.leg?.distance;
    final distanceLabel = distance == null
        ? null
        : LocaleKeys.distanceKm.tr(
            context: context,
            args: [
              NumberFormat.decimalPattern(
                context.locale.toLanguageTag(),
              ).format(distance.km),
            ],
          );
    final countryDetail = distanceLabel == null
        ? null
        : distance!.approximate
        ? LocaleKeys.approximateDistance.tr(
            context: context,
            namedArgs: {'distance': distanceLabel},
          )
        : distanceLabel;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.symmetric(
          horizontal: TravelRadioLayout.gutter(screenWidth),
          vertical: AppSpacing.small,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= TravelRadioLayout.landscapeMinWidth &&
                constraints.maxHeight < TravelRadioLayout.landscapeMaxHeight;
            Widget heading(double density) => Text(
              appName.toLowerCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle.lerp(
                theme.textTheme.titleMedium,
                theme.textTheme.headlineMedium,
                density,
              )?.merge(TravelRadioLayout.headingText),
            );
            final favoritesLabel = LocaleKeys.favoritesCount.tr(
              context: context,
              namedArgs: {
                'count': NumberFormat.decimalPattern(
                  context.locale.toLanguageTag(),
                ).format(favoritesCount),
              },
            );
            final favoritesButton = AppIconButton(
              key: tourTargets?.favorites ?? const ValueKey('favorites-open'),
              tooltip: favoritesLabel,
              onPressed: () => showFavorites(context),
              icon: const Icon(Icons.queue_music_outlined),
            );
            final diaryButton = AppIconButton(
              key: tourTargets?.diary ?? const ValueKey('diary-open'),
              tooltip: LocaleKeys.diaryOpen.tr(context: context),
              onPressed: () => openDiary(context, radioScreenKey),
              icon: const Icon(Icons.map_outlined),
            );
            final actions = IconButtonTheme(
              data: IconButtonThemeData(
                style: IconButton.styleFrom(
                  iconSize: TravelRadioLayout.headerIconSize,
                  fixedSize: const Size.square(
                    TravelRadioLayout.headerActionSize,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: TravelRadioLayout.headerActionGap,
                children: [favoritesButton, diaryButton, settingsAction],
              ),
            );
            Widget cabinet({
              required bool compact,
              double density = 1,
            }) => RadioCabinetHero(
              child: RadioCabinet(
                screenKey: tourTargets?.screen ?? radioScreenKey,
                dialKey: tourTargets?.dial,
                compact: compact,
                density: density,
                horizontal: wide,
                country: text(display.country),
                countryDetail: countryDetail,
                station: text(display.title),
                detail: display.busy
                    ? ''
                    : song ??
                          (station == null
                              ? null
                              : detailText(context, station.tags.take(2))) ??
                          LocaleKeys.firstTrip.tr(context: context),
                onDetailTap: track == null || station == null
                    ? null
                    : () => saveSong(context, ref, track, station),
                onDetailLongPress: song == null
                    ? null
                    : () => copyTrackTitle(context, ref, song),
                detailAction: track == null || station == null
                    ? null
                    : SongBookmark(track: track, station: station),
                status: display.statusKey.tr(context: context),
                flying: display.flying,
                landings: journey.trips,
                map: RouteMap(
                  flight: display.phase,
                  reconnecting:
                      session is Flying && session.kind == FlightKind.reconnect,
                  playing: display.playing,
                  departure: journey.departure,
                  leg: journey.leg,
                  history: journey.history,
                  trips: journey.trips,
                ),
                localTime: station == null || display.busy
                    ? null
                    : LocalTimeText(
                        station: station,
                        stacked: !compact,
                        style: RadioCabinetDesign.statusText,
                      ),
                tripLabel: journey.trips == 0
                    ? null
                    : LocaleKeys.tripNumber.tr(
                        context: context,
                        args: [
                          NumberFormat.decimalPattern(
                            context.locale.toLanguageTag(),
                          ).format(journey.trips),
                        ],
                      ),
                knobLabel: display.knobKey.tr(context: context).toUpperCase(),
                tuneLabel: LocaleKeys.tuneAccessibility.tr(context: context),
                onTune: display.knobEnabled
                    ? () => controller.tuneRandom()
                    : null,
                playKey: RadioKey(
                  key: const ValueKey('radio-key-play'),
                  toggles: false,
                  icon: display.playKeyOn ? Icons.pause : Icons.play_arrow,
                  label: display.playKeyOn
                      ? LocaleKeys.pause.tr(context: context)
                      : LocaleKeys.resume.tr(context: context),
                  down: display.playKeyDown,
                  onPressed: !display.playKeyEnabled
                      ? null
                      : () => display.playKeyOn
                            ? controller.pause()
                            : controller.play(),
                ),
                saveKey: RadioKey(
                  key: const ValueKey('radio-key-save'),
                  icon: saved ? Icons.favorite : Icons.favorite_border,
                  iconColor: saved ? theme.colorScheme.primary : null,
                  label: saved
                      ? LocaleKeys.saved.tr(context: context)
                      : LocaleKeys.save.tr(context: context),
                  down: saved,
                  onPressed:
                      station == null ||
                          !display.saveEnabled ||
                          favorites == null ||
                          favoritesState.isLoading
                      ? null
                      : () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(station),
                ),
                isBusy: display.busy,
                isPlaying: display.playing,
              ),
            );
            final nextStop = Text(
              (display.nextStopPending
                      ? LocaleKeys.nextStopPending
                      : LocaleKeys.nextStop)
                  .tr(context: context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: TravelRadioLayout.captionLineHeight,
                letterSpacing: TravelRadioLayout.captionTracking,
              ),
            );
            final credits = Text(
              LocaleKeys.footer.tr(context: context),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                height: TravelRadioLayout.captionLineHeight,
                letterSpacing: TravelRadioLayout.captionTracking,
              ),
            );
            if (wide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: TravelRadioLayout.landscapeContentWidth,
                  ),
                  child: AdaptiveFit(
                    builder: (context, density, compact, freeSpace) {
                      final gap =
                          (compact ? 0 : TravelRadioLayout.minPageGap) +
                          freeSpace / TravelRadioLayout.landscapeGapCount;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: gap),
                          nextStop,
                          SizedBox(height: gap),
                          Row(
                            children: [
                              SizedBox(
                                width: TravelRadioLayout.landscapeControlsWidth,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    heading(density),
                                    const SizedBox(height: AppSpacing.large),
                                    actions,
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.standard),
                              Expanded(
                                child: cabinet(
                                  compact: compact,
                                  density: density,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                gap +
                                (compact
                                    ? 0
                                    : TravelRadioLayout.mapFooterClearance),
                          ),
                          credits,
                          SizedBox(height: gap),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
            return AdaptiveFit(
              builder: (context, density, compact, freeSpace) {
                final gap =
                    (compact ? 0 : TravelRadioLayout.minPageGap) +
                    freeSpace / TravelRadioLayout.pageGapCount;
                final width = TravelRadioLayout.fittingWidth(
                  TravelRadioLayout.cabinetWidth(
                    screenWidth,
                    constraints.maxWidth,
                  ),
                  density,
                );
                return SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: gap),
                      SizedBox(
                        width: width,
                        child: Row(
                          children: [
                            Expanded(child: heading(density)),
                            actions,
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      nextStop,
                      SizedBox(height: gap),
                      SizedBox(
                        width: width,
                        child: cabinet(compact: compact, density: density),
                      ),
                      SizedBox(
                        height:
                            gap +
                            (compact
                                ? 0
                                : TravelRadioLayout.mapFooterClearance),
                      ),
                      credits,
                      SizedBox(height: gap),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
