import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/widgets/app_button.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../favorites/presentation/favorites_sheet.dart';
import '../application/radio_controller.dart';
import '../domain/radio_player_state.dart';
import 'radio_cabinet.dart';

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
    final title = player.status == PlaybackStatus.tuning
        ? LocaleKeys.exploring.tr(context: context)
        : station?.name ?? LocaleKeys.whereTo.tr(context: context);
    final country = player.status == PlaybackStatus.tuning
        ? LocaleKeys.findingPlace.tr(context: context)
        : station?.country ?? LocaleKeys.worldAwaits.tr(context: context);
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
            final favoritesButton = compact
                ? AppIconButton(
                    variant: AppIconButtonVariant.outlined,
                    key: const ValueKey('favorites-open'),
                    tooltip: favoritesLabel,
                    onPressed: () => showFavorites(context),
                    icon: Badge.count(
                      count: favoritesCount,
                      isLabelVisible: favoritesCount > 0,
                      child: const Icon(Icons.favorite_border),
                    ),
                  )
                : AppButton(
                    variant: AppButtonVariant.outlined,
                    key: const ValueKey('favorites-open'),
                    onPressed: () => showFavorites(context),
                    icon: const Icon(
                      Icons.favorite_border,
                      size: TravelRadioLayout.headerIconSize,
                    ),
                    label: favoritesLabel,
                  );
            final cabinet = RadioCabinet(
              compact: compact,
              horizontal: wide,
              country: country,
              station: title,
              detail: busy
                  ? ''
                  : (player.isPlaying || player.status == PlaybackStatus.paused
                            ? player.trackTitle
                            : null) ??
                        station?.tags.take(2).join(' · ') ??
                        LocaleKeys.firstTrip.tr(context: context),
              status: status,
              knobLabel: label.toUpperCase(),
              tuneLabel: LocaleKeys.tuneAccessibility.tr(context: context),
              onTune: busy ? null : () => controller.tuneRandom(),
              isBusy: busy,
              isPlaying: player.isPlaying,
            );
            final pause = AppButton(
              variant: AppButtonVariant.outlined,
              onPressed: idle || busy || player.status == PlaybackStatus.error
                  ? null
                  : () => player.isPlaying
                        ? controller.pause()
                        : controller.play(),
              label: player.isPlaying
                  ? LocaleKeys.pause.tr(context: context)
                  : LocaleKeys.resume.tr(context: context),
            );
            final save = AppButton(
              variant: AppButtonVariant.outlined,
              onPressed:
                  idle || busy || favorites == null || favoritesState.isLoading
                  ? null
                  : () => ref.read(favoritesProvider.notifier).toggle(station),
              label: station != null && favorites?.contains(station.id) == true
                  ? LocaleKeys.saved.tr(context: context)
                  : LocaleKeys.save.tr(context: context),
            );
            final nextStop = Text(
              LocaleKeys.nextStop.tr(context: context),
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
                                  pause,
                                  save,
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
                    Row(
                      children: [
                        Expanded(child: pause),
                        const SizedBox(width: AppSpacing.standard),
                        Expanded(child: save),
                      ],
                    ),
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
