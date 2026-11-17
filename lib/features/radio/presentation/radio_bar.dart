import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../songs/application/saved_songs.dart';
import '../../songs/presentation/save_song.dart';
import '../application/radio_controller.dart';
import '../domain/radio_bar_state.dart';
import '../domain/radio_station.dart';
import '../domain/track_title.dart';
import 'radio_display.dart';

/// The player bar under a page opened over the radio. Touching the station
/// goes back to the radio; the keys do what the radio's keys do. No next
/// or previous: those stay on the radio.
class RadioBar extends ConsumerWidget {
  const RadioBar({super.key, required this.onBackToRadio});

  final VoidCallback onBackToRadio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(radioControllerProvider);
    final state = radioBarOf(session);
    if (state is BarHidden) return const SizedBox.shrink();
    final controller = ref.read(radioControllerProvider.notifier);
    final display = RadioDisplay.of(session);
    String t(String key) => key.tr(context: context);

    final (title, detail) = switch (state) {
      BarOnAir(:final station, :final track, :final connecting) => (
        '${station.name} · ${station.country.isEmpty ? t(LocaleKeys.unknownCountry) : station.country}',
        connecting
            ? t(LocaleKeys.barConnecting)
            : track?.display ?? t(display.statusKey),
      ),
      BarFlying() => (
        t(LocaleKeys.barFlying),
        t(LocaleKeys.barTuning).toUpperCase(),
      ),
      BarFailed() => (t(LocaleKeys.barNoSignal), t(LocaleKeys.barFlightFailed)),
      BarHidden() => ('', ''),
    };

    final keys = <Widget>[
      if (state case BarOnAir(:final station)) _heart(context, ref, station),
      if (state case BarOnAir(:final station, :final track?))
        _bookmark(context, ref, track, station),
      switch (state) {
        BarFailed() => _key(
          icon: Icons.refresh,
          tooltip: t(LocaleKeys.retry),
          onPressed: controller.tuneRandom,
        ),
        _ => _key(
          icon: display.playKeyOn ? Icons.pause : Icons.play_arrow,
          tooltip: display.playKeyOn
              ? t(LocaleKeys.pause)
              : t(LocaleKeys.resume),
          onPressed: state is BarOnAir && display.playKeyEnabled
              ? () => display.playKeyOn ? controller.pause() : controller.play()
              : null,
        ),
      },
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: RadioBarDesign.height,
        padding: RadioBarDesign.padding,
        decoration: BoxDecoration(
          color: TravelRadioPalette.screen,
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
                  args: ['$title, $detail'],
                ),
                excludeSemantics: true,
                child: InkWell(
                  onTap: onBackToRadio,
                  borderRadius: BorderRadius.circular(RadioBarDesign.radius),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RadioBarDesign.titleText.copyWith(
                          color: TravelRadioPalette.screenInk,
                        ),
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RadioBarDesign.detailText.copyWith(
                          color: TravelRadioPalette.screenInk.withValues(
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

  Widget _bookmark(
    BuildContext context,
    WidgetRef ref,
    TrackTitle track,
    RadioStation station,
  ) {
    ref.watch(savedSongsProvider);
    final saved = ref
        .read(savedSongsProvider.notifier)
        .contains(track, station);
    return _icon(
      icon: saved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
      tooltip: LocaleKeys.saveSong.tr(context: context),
      onPressed: saved ? null : () => saveSong(context, ref, track, station),
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
    color: color ?? TravelRadioPalette.screenInk,
    disabledColor: color ?? TravelRadioPalette.screenInk,
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
      backgroundColor: TravelRadioPalette.screenInk,
      foregroundColor: TravelRadioPalette.screen,
      disabledBackgroundColor: TravelRadioPalette.screenInk.withValues(
        alpha: 0.45,
      ),
      disabledForegroundColor: TravelRadioPalette.screen,
    ),
    icon: Icon(icon),
  );
}
