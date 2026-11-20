import '../../journey/presentation/country_name.dart';
import '../../radio/domain/radio_station.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/app_shape.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/app_component_design.dart';
import '../../../ui/theme/travel_sheet_design.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../../ui/widgets/code_badge.dart';
import '../../../ui/widgets/app_message.dart';
import '../../../ui/widgets/app_loading.dart';
import '../../../ui/widgets/travel_sheet.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/domain/radio_session.dart';
import '../../songs/presentation/songs_tab.dart';
import '../application/favorites_controller.dart';
import 'toggle_favorite.dart';

Future<void> showFavorites(BuildContext context) =>
    showTravelSheet(context, builder: (_) => const FavoritesSheet());

/// The stations to come back to and the songs found on the road, in two
/// tabs. It opens on the stations.
class FavoritesSheet extends ConsumerStatefulWidget {
  const FavoritesSheet({super.key});

  @override
  ConsumerState<FavoritesSheet> createState() => _FavoritesSheetState();
}

enum _Tab { stations, songs }

class _FavoritesSheetState extends ConsumerState<FavoritesSheet> {
  var _tab = _Tab.stations;

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    // The station that plays now, to mark its preset.
    final playing = switch (ref.watch(radioControllerProvider)) {
      OnAir(:final station, playback: OnAirPlayback.playing) => station.id,
      _ => null,
    };
    final p = TravelRadioPalette.of(context);
    return TravelSheet(
      title: LocaleKeys.favoritesTitle.tr(context: context),
      subtitle: switch (_tab) {
        _Tab.stations => LocaleKeys.favoritesSubtitle.tr(context: context),
        _Tab.songs => LocaleKeys.songsSubtitle.tr(context: context),
      },
      children: [
        SegmentedButton<_Tab>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: _Tab.stations,
              icon: const Icon(Icons.radio_outlined),
              label: Text(LocaleKeys.tabStations.tr(context: context)),
            ),
            ButtonSegment(
              value: _Tab.songs,
              icon: const Icon(Icons.bookmarks_outlined),
              label: Text(LocaleKeys.tabSongs.tr(context: context)),
            ),
          ],
          selected: {_tab},
          onSelectionChanged: (selected) =>
              setState(() => _tab = selected.single),
        ),
        const SizedBox(height: TravelSheetDesign.contentGap),
        if (_tab == _Tab.songs) const SongsTab(),
        if (_tab == _Tab.stations)
          ...favorites.when(
            skipLoadingOnRefresh: false,
            loading: () => [
              if (!favorites.hasValue)
                AppLoading(label: LocaleKeys.loading.tr(context: context)),
            ],
            error: (_, _) => [
              AppMessage.error(
                message: LocaleKeys.favoritesError.tr(context: context),
                onAction: ref.read(favoritesProvider.notifier).load,
                actionLabel: LocaleKeys.retry.tr(context: context),
              ),
            ],
            data: (data) => [
              if (data.stations.isEmpty)
                AppMessage.emptyPanel(
                  icon: Icons.favorite_border,
                  message: LocaleKeys.favoritesEmpty.tr(context: context),
                ),
            ],
          ),
        // Saved in order: the newest one comes first.
        if (_tab == _Tab.stations)
          for (final station
              in favorites.valueOrNull?.stations.reversed ?? <RadioStation>[])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.standard),
              child: _StationPreset(
                id: station.id,
                name: station.name,
                code: station.countryCode,
                subtitle: LocaleKeys.favoriteDetails.tr(
                  context: context,
                  namedArgs: {
                    'country': countryName(
                      context,
                      station.countryCode,
                      fallback: station.country,
                    ),
                    'status':
                        (playing == station.id
                                ? LocaleKeys.playing
                                : LocaleKeys.tapToListen)
                            .tr(context: context),
                  },
                ),
                active: playing == station.id,
                removeLabel: LocaleKeys.removeFavorite.tr(context: context),
                onPlay: () {
                  final controller = ref.read(radioControllerProvider.notifier);
                  Navigator.pop(context);
                  controller.tuneTo(station);
                },
                onRemove: favorites.isLoading
                    ? null
                    : (presetContext) =>
                          toggleFavorite(presetContext, ref, station),
              ),
            ),
        const SizedBox(height: RadioFavoritesDesign.footerGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android_outlined,
              size: RadioFavoritesDesign.footerIconSize,
              color: p.muted,
            ),
            const SizedBox(width: RadioFavoritesDesign.footerIconGap),
            Flexible(
              child: Text(
                LocaleKeys.savedOnDevice.tr(context: context),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: p.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StationPreset extends StatelessWidget {
  const _StationPreset({
    required this.id,
    required this.name,
    required this.code,
    required this.subtitle,
    required this.active,
    required this.removeLabel,
    required this.onPlay,
    required this.onRemove,
  });
  final String id, name, code, subtitle, removeLabel;
  final bool active;
  final VoidCallback onPlay;
  final ValueChanged<BuildContext>? onRemove;
  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    final ink = active ? TravelRadioPalette.screenInk : p.ink;
    final secondary = active
        ? TravelRadioPalette.screenInk.withValues(
            alpha: RadioFavoritesDesign.activeSubtitleOpacity,
          )
        : p.muted;
    return Material(
      color: active ? TravelRadioPalette.screen : p.paperRaised,
      borderRadius: AppShape.panelRadius,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('favorite-play-$id'),
              onTap: onPlay,
              child: Padding(
                padding: RadioFavoritesDesign.presetPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CodeBadge(
                      code,
                      size: RadioFavoritesDesign.presetCodeSize,
                      foregroundColor: ink,
                      backgroundColor: active
                          ? TravelRadioPalette.hardware
                          : p.paper,
                      borderColor: active
                          ? TravelRadioPalette.activePresetBorder
                          : p.trim.withValues(
                              alpha: RadioFavoritesDesign
                                  .inactivePresetBorderOpacity,
                            ),
                      fallbackIcon: Icons.public,
                    ),
                    const SizedBox(width: AppSpacing.standard),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.merge(SavedItemsDesign.titleText)
                                .copyWith(color: ink),
                          ),
                          const SizedBox(height: SavedItemsDesign.titleGap),
                          Text(
                            subtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppIconButton(
            tooltip: removeLabel,
            onPressed: onRemove == null ? null : () => onRemove!(context),
            icon: const Icon(
              Icons.favorite,
              size: RadioFavoritesDesign.removeIconSize,
            ),
            foregroundColor: ink,
          ),
          const SizedBox(width: RadioFavoritesDesign.trailingInset),
        ],
      ),
    );
  }
}
