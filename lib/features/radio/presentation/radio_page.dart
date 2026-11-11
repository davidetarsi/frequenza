import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../favorites/application/favorites_providers.dart';
import '../../favorites/presentation/favorites_sheet.dart';
import '../application/radio_providers.dart';
import '../domain/radio_player_state.dart';
import 'radio_cabinet.dart';

class RadioPage extends ConsumerWidget {
  const RadioPage({super.key, required this.appName});
  final String appName;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final player = ref.watch(radioControllerProvider);
    final favorites = ref.watch(favoritesProvider);
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
    final sectionGap = (MediaQuery.sizeOf(context).height * .035).clamp(
      20.0,
      36.0,
    );
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: sectionGap,
              ),
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName.toLowerCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(l.tagline, style: theme.textTheme.bodySmall),
                      ],
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('favorites-open'),
                      onPressed: () => showFavorites(context),
                      icon: const Icon(Icons.favorite_border, size: 18),
                      label: Text(
                        '${l.favorites} · ${favorites.stations.length}',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                Text(
                  l.nextStop,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: 360,
                    child: RadioCabinet(
                      country: country,
                      station: title,
                      detail: busy
                          ? ''
                          : (player.isPlaying ||
                                        player.status == PlaybackStatus.paused
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
                    ),
                  ),
                ),
                SizedBox(height: sectionGap),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          idle || busy || player.status == PlaybackStatus.error
                          ? null
                          : () => player.isPlaying
                                ? controller.pause()
                                : controller.play(),
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(player.isPlaying ? l.pause : l.resume),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          idle ||
                              busy ||
                              !favorites.hasLoaded ||
                              favorites.isLoading ||
                              favorites.isSaving
                          ? null
                          : () => ref
                                .read(favoritesProvider.notifier)
                                .toggle(station),
                      icon: Icon(
                        station != null && favorites.contains(station.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        station != null && favorites.contains(station.id)
                            ? l.saved
                            : l.save,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (player.status == PlaybackStatus.error)
                  Text(
                    l.stationErrorHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                else
                  Text(
                    player.status == PlaybackStatus.paused
                        ? l.pauseHint
                        : l.travelHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 24),
                Text(
                  l.footer,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
