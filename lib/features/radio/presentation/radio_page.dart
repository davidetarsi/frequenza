import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../diary/presentation/diary_route.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../../ui/widgets/count_pulse.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../favorites/presentation/favorites_sheet.dart';
import '../../journey/presentation/journey_texts.dart';
import '../../journey/presentation/route_map.dart';
import '../../songs/presentation/save_song.dart';
import '../application/radio_controller.dart';
import 'radio_display.dart';
import 'copy_track_title.dart';
import 'radio_cabinet.dart';
import 'radio_keys.dart';

/// The radio's screen: the diary grows out of it.
final radioScreenKey = GlobalKey(debugLabel: 'radio-screen');

class RadioPage extends ConsumerWidget {
  const RadioPage({
    super.key,
    required this.appName,
    required this.settingsAction,
  });
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
    };
    final distance = display.leg?.distance;
    final countryDetail = distance == null
        ? null
        : '${distance.approximate ? '≈ ' : ''}${LocaleKeys.distanceKm.tr(context: context, args: [NumberFormat.decimalPattern(context.locale.toLanguageTag()).format(distance.km)])}';
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
            final largeText =
                MediaQuery.textScalerOf(
                  context,
                ).scale(TravelRadioLayout.referenceTextSize) >
                TravelRadioLayout.largeTextThreshold;
            final compact =
                wide ||
                constraints.maxHeight <
                    (largeText
                        ? TravelRadioLayout.compactHeightWithLargeText
                        : TravelRadioLayout.compactHeight);
            final heading = Text(
              appName.toLowerCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (compact
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.headlineMedium)
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: TravelRadioLayout.headingTracking,
                      ),
            );
            final favoritesLabel =
                '${LocaleKeys.favorites.tr(context: context)} · $favoritesCount';
            final favoritesButton = AppIconButton(
              variant: AppIconButtonVariant.outlined,
              key: const ValueKey('favorites-open'),
              tooltip: favoritesLabel,
              foregroundColor: theme.colorScheme.primary,
              onPressed: () => showFavorites(context),
              // The heart is the save key's alone: this is where it saves.
              icon: CountPulse(
                count: favorites?.stations.length,
                child: Badge.count(
                  count: favoritesCount,
                  isLabelVisible: favoritesCount > 0,
                  largeSize: RadioFavoritesDesign.countSize,
                  offset: RadioFavoritesDesign.countOffset,
                  padding: RadioFavoritesDesign.countPadding,
                  textStyle: RadioFavoritesDesign.countText,
                  backgroundColor: theme.colorScheme.primary,
                  textColor: theme.colorScheme.onPrimary,
                  child: const Icon(Icons.queue_music_outlined),
                ),
              ),
            );
            final cabinet = RadioCabinetHero(
              child: RadioCabinet(
                screenKey: radioScreenKey,
                onScreenTap: () => openDiary(context, radioScreenKey),
                screenLabel: LocaleKeys.diaryLabel.tr(context: context),
                screenLabelSemantics: LocaleKeys.diaryOpen.tr(context: context),
                compact: compact,
                horizontal: wide,
                country: text(display.country),
                countryDetail: countryDetail,
                station: text(display.title),
                detail: display.busy
                    ? ''
                    : song ??
                          station?.tags.take(2).join(' · ') ??
                          LocaleKeys.firstTrip.tr(context: context),
                onDetailTap: track == null || station == null
                    ? null
                    : () => saveSong(context, ref, track, station),
                onDetailLongPress: song == null
                    ? null
                    : () => copyTrackTitle(context, song),
                detailAction: track == null || station == null
                    ? null
                    : SongBookmark(track: track, station: station),
                status: display.statusKey.tr(context: context),
                flying: display.flying,
                landings: journey.trips,
                map: RouteMap(
                  flight: display.phase,
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
                        args: ['${journey.trips}'],
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
                  child: Column(
                    children: [
                      nextStop,
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: TravelRadioLayout.landscapeControlsWidth,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: heading),
                                      favoritesButton,
                                      settingsAction,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.standard),
                            Expanded(child: cabinet),
                          ],
                        ),
                      ),
                      credits,
                    ],
                  ),
                ),
              );
            }
            // The header spans the screen; the radio takes its share of it.
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Expanded(child: heading),
                    favoritesButton,
                    settingsAction,
                  ],
                ),
                nextStop,
                SizedBox(
                  width: TravelRadioLayout.cabinetWidth(
                    screenWidth,
                    constraints.maxWidth,
                  ),
                  child: cabinet,
                ),
                credits,
              ],
            );
          },
        ),
      ),
    );
  }
}
