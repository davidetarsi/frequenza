import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/widgets/app_button.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../favorites/presentation/favorites_sheet.dart';
import '../application/radio_controller.dart';
import '../domain/radio_player_state.dart';
import 'radio_cabinet.dart';

class RadioPage extends ConsumerWidget {
  const RadioPage({super.key, required this.appName});
  final String appName;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.favoritesError)));
      }
    });
    final status = switch (player.status) {
      PlaybackStatus.idle => l.ready,
      PlaybackStatus.tuning => l.searching,
      PlaybackStatus.buffering => l.connecting,
      PlaybackStatus.playing => l.playing,
      PlaybackStatus.paused => l.paused,
      PlaybackStatus.error => l.stationError,
    };
    final title = player.status == PlaybackStatus.tuning
        ? l.exploring
        : station?.name ?? l.whereTo;
    final country = player.status == PlaybackStatus.tuning
        ? l.findingPlace
        : station?.country ?? l.worldAwaits;
    final label = busy
        ? l.tuning
        : player.status == PlaybackStatus.error
        ? l.retry
        : idle
        ? l.powerOn
        : l.tune;
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard,
          vertical: AppSpacing.small,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 520 && constraints.maxHeight < 560;
            final largeText = MediaQuery.textScalerOf(context).scale(16) > 20;
            final compact =
                wide || constraints.maxHeight < (largeText ? 900 : 740);
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
                        letterSpacing: -1,
                      ),
            );
            final favoritesLabel = '${l.favorites} · $favoritesCount';
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
                    icon: const Icon(Icons.favorite_border, size: 18),
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
                        l.firstTrip,
              status: status,
              knobLabel: label.toUpperCase(),
              tuneLabel: l.tuneAccessibility,
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
              label: player.isPlaying ? l.pause : l.resume,
            );
            final save = AppButton(
              variant: AppButtonVariant.outlined,
              onPressed:
                  idle || busy || favorites == null || favoritesState.isLoading
                  ? null
                  : () => ref.read(favoritesProvider.notifier).toggle(station),
              label: station != null && favorites?.contains(station.id) == true
                  ? l.saved
                  : l.save,
            );
            final nextStop = Text(
              l.nextStop,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.1,
                letterSpacing: 0,
              ),
            );
            final credits = Text(
              l.footer,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                height: 1.1,
                letterSpacing: 0,
              ),
            );
            if (wide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      nextStop,
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 160,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: heading),
                                      favoritesButton,
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
                width: 344,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Expanded(child: heading),
                        favoritesButton,
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
