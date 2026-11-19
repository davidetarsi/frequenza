import '../../journey/presentation/country_name.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../songs/presentation/save_song.dart';
import '../application/radio_controller.dart';
import '../domain/radio_bar_state.dart';
import '../domain/radio_station.dart';

/// The player bar under a page opened over the radio. Touching the station
/// goes back to the radio; the keys do what the radio's keys do. No next
/// or previous: those stay on the radio.
class RadioBar extends ConsumerWidget {
  const RadioBar({super.key, required this.onBackToRadio});

  final VoidCallback onBackToRadio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = radioBarOf(ref.watch(radioControllerProvider));
    if (state is BarHidden) return const SizedBox.shrink();
    final controller = ref.read(radioControllerProvider.notifier);
    String t(String key) => key.tr(context: context);

    final title = switch (state) {
      BarPlaying(:final station) ||
      BarPaused(:final station) ||
      BarStopped(:final station) => LocaleKeys.stationCountry.tr(
        context: context,
        namedArgs: {
          'station': station.name,
          'country': countryName(
            context,
            station.countryCode,
            fallback: station.country,
          ),
        },
      ),
      BarFlying() => t(LocaleKeys.barFlying),
      BarFailed() => t(LocaleKeys.barNoSignal),
      BarHidden() => '',
    };
    final detail = switch (state.note) {
      BarNote.track => state.track!.display,
      BarNote.tuning => t(LocaleKeys.barTuning).toUpperCase(),
      BarNote.connecting => t(LocaleKeys.barConnecting),
      BarNote.playing => t(LocaleKeys.playing),
      BarNote.paused => t(LocaleKeys.paused),
      BarNote.ready => t(LocaleKeys.ready),
      BarNote.noSignal => t(LocaleKeys.barFlightFailed),
      null => '',
    };
    final keys = <Widget>[
      if (state.station case final station?) _heart(context, ref, station),
      if ((state.station, state.track) case (final station?, final track?))
        SongBookmark.player(track: track, station: station),
      if (state.mainKey case final key?)
        _key(
          icon: switch (key) {
            BarKey.pause => Icons.pause,
            BarKey.play => Icons.play_arrow,
            BarKey.retry => Icons.refresh,
          },
          tooltip: switch (key) {
            BarKey.pause => t(LocaleKeys.pause),
            BarKey.play => t(LocaleKeys.resume),
            BarKey.retry => t(LocaleKeys.retry),
          },
          onPressed: !state.mainKeyEnabled
              ? null
              : switch (key) {
                  BarKey.pause => controller.pause,
                  BarKey.play => controller.play,
                  BarKey.retry => controller.tuneRandom,
                },
        ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        // Grows with large text instead of cutting it.
        constraints: const BoxConstraints(minHeight: RadioBarDesign.height),
        padding: RadioBarDesign.padding,
        decoration: BoxDecoration(
          color: TravelRadioPalette.screenInk,
          borderRadius: BorderRadius.circular(RadioBarDesign.radius),
          border: Border.all(
            color: TravelRadioPalette.screenBorder,
            width: RadioBarDesign.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: LocaleKeys.barBackToRadio.tr(
                  context: context,
                  namedArgs: {'title': title, 'detail': detail},
                ),
                excludeSemantics: true,
                child: InkWell(
                  onTap: onBackToRadio,
                  borderRadius: BorderRadius.circular(RadioBarDesign.radius),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RadioBarDesign.titleText.copyWith(
                          color: TravelRadioPalette.screen,
                        ),
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RadioBarDesign.detailText.copyWith(
                          color: TravelRadioPalette.screen.withValues(
                            alpha: RadioBarDesign.detailOpacity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ...keys,
          ],
        ),
      ),
    );
  }

  Widget _heart(BuildContext context, WidgetRef ref, RadioStation station) {
    final favorites = ref.watch(favoritesProvider);
    final saved = favorites.valueOrNull?.contains(station.id) ?? false;
    return _icon(
      icon: saved ? Icons.favorite : Icons.favorite_border,
      color: saved ? RadioBarDesign.savedHeart : null,
      tooltip: (saved ? LocaleKeys.barRemoveStation : LocaleKeys.barSaveStation)
          .tr(context: context),
      onPressed: favorites.hasValue && !favorites.isLoading
          ? () => ref.read(favoritesProvider.notifier).toggle(station)
          : null,
    );
  }

  Widget _icon({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
  }) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    iconSize: RadioBarDesign.iconSize,
    color: color ?? TravelRadioPalette.screen,
    disabledColor: color ?? TravelRadioPalette.screen,
    constraints: const BoxConstraints.tightFor(
      width: RadioBarDesign.key,
      height: RadioBarDesign.key,
    ),
    icon: Icon(icon),
  );

  Widget _key({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    iconSize: RadioBarDesign.keyIconSize,
    constraints: const BoxConstraints.tightFor(
      width: RadioBarDesign.key,
      height: RadioBarDesign.key,
    ),
    style: IconButton.styleFrom(
      backgroundColor: TravelRadioPalette.screen,
      foregroundColor: TravelRadioPalette.screenInk,
      disabledBackgroundColor: TravelRadioPalette.screen.withValues(
        alpha: RadioBarDesign.disabledKeyOpacity,
      ),
      disabledForegroundColor: TravelRadioPalette.screenInk,
    ),
    icon: Icon(icon),
  );
}
