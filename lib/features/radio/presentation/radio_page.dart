import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../favorites/presentation/favorites_sheet.dart';
import '../../journey/presentation/journey_texts.dart';
import '../../journey/presentation/route_map.dart';
import '../application/radio_controller.dart';
import '../domain/radio_player_state.dart';
import 'radio_cabinet.dart';
import 'radio_keys.dart';

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
    final player = ref.watch(radioControllerProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.valueOrNull;
    final favoritesCount = favorites?.stations.length ?? 0;
    final controller = ref.read(radioControllerProvider.notifier);
    final station = player.station;
    final busy = player.isLoading;
    final idle = station == null;
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
    final status = switch (player.status) {
      PlaybackStatus.idle => LocaleKeys.ready.tr(context: context),
      PlaybackStatus.tuning => LocaleKeys.searching.tr(context: context),
      PlaybackStatus.buffering => LocaleKeys.connecting.tr(context: context),
      PlaybackStatus.playing => LocaleKeys.playing.tr(context: context),
      PlaybackStatus.paused => LocaleKeys.paused.tr(context: context),
      PlaybackStatus.error => LocaleKeys.stationError.tr(context: context),
    };
    final tuning = player.status == PlaybackStatus.tuning;
    final flying = tuning && player.flight == FlightPhase.flying;
    final title = flying
        ? LocaleKeys.flyingTo.tr(context: context)
        : player.flight == FlightPhase.signalLost
        ? LocaleKeys.signalLost.tr(context: context)
        : station?.name ?? LocaleKeys.whereTo.tr(context: context);
    final distance = station == null ? null : player.leg?.distance;
    final country = tuning
        ? ''
        : station?.country ?? LocaleKeys.worldAwaits.tr(context: context);
    final countryDetail = tuning || distance == null
        ? null
        : '${distance.approximate ? '≈ ' : ''}${LocaleKeys.distanceKm.tr(context: context, args: [NumberFormat.decimalPattern(context.locale.toLanguageTag()).format(distance.km)])}';
    final label = busy
        ? LocaleKeys.tuning.tr(context: context)
        : player.status == PlaybackStatus.error
        ? LocaleKeys.retry.tr(context: context)
        : idle
        ? LocaleKeys.powerOn.tr(context: context)
        : LocaleKeys.tune.tr(context: context);
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard,
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
              icon: Badge.count(
                count: favoritesCount,
                isLabelVisible: favoritesCount > 0,
                backgroundColor: theme.colorScheme.primary,
                textColor: theme.colorScheme.onPrimary,
                child: const Icon(Icons.favorite_border),
              ),
            );
            final cabinet = RadioCabinet(
              compact: compact,
              horizontal: wide,
              country: country,
              countryDetail: countryDetail,
              station: title,
              detail: busy
                  ? ''
                  : (player.isPlaying || player.status == PlaybackStatus.paused
                            ? player.trackTitle
                            : null) ??
                        station?.tags.take(2).join(' · ') ??
                        LocaleKeys.firstTrip.tr(context: context),
              status: status,
              flying: flying,
              landings: player.trips,
              map: RouteMap(
                flight: player.flight,
                playing: player.isPlaying,
                departure: player.departure,
                leg: player.leg,
                history: player.history,
                trips: player.trips,
              ),
              localTime: station == null || busy
                  ? null
                  : LocalTimeText(
                      station: station,
                      style: RadioCabinetDesign.statusText,
                    ),
              tripLabel: player.trips == 0
                  ? null
                  : LocaleKeys.tripNumber.tr(
                      context: context,
                      args: ['${player.trips}'],
                    ),
              knobLabel: label.toUpperCase(),
              tuneLabel: LocaleKeys.tuneAccessibility.tr(context: context),
              onTune: busy ? null : () => controller.tuneRandom(),
              playKey: RadioKey(
                key: const ValueKey('radio-key-play'),
                icon: player.isPlaying ? Icons.pause : Icons.play_arrow,
                label: player.isPlaying
                    ? LocaleKeys.pause.tr(context: context)
                    : LocaleKeys.resume.tr(context: context),
                down: player.status == PlaybackStatus.paused,
                onPressed: idle || busy || player.status == PlaybackStatus.error
                    ? null
                    : () => player.isPlaying
                          ? controller.pause()
                          : controller.play(),
              ),
              saveKey: RadioKey(
                key: const ValueKey('radio-key-save'),
                icon: saved ? Icons.favorite : Icons.favorite_border,
                iconColor: saved ? TravelRadioPalette.accent : null,
                label: saved
                    ? LocaleKeys.saved.tr(context: context)
                    : LocaleKeys.save.tr(context: context),
                down: saved,
                onPressed:
                    idle ||
                        busy ||
                        favorites == null ||
                        favoritesState.isLoading
                    ? null
                    : () =>
                          ref.read(favoritesProvider.notifier).toggle(station),
              ),
              isBusy: busy,
              isPlaying: player.isPlaying,
            );
            final nextStop = Text(
              (tuning ? LocaleKeys.nextStopPending : LocaleKeys.nextStop).tr(
                context: context,
              ),
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
            return Center(
              child: SizedBox(
                width: TravelRadioLayout.cabinetWidth,
                height: double.infinity,
                child: Column(
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
                    cabinet,
                    credits,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
