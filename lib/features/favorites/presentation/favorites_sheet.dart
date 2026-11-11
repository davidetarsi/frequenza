import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/app_shape.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/widgets/app_button.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../../ui/widgets/app_message.dart';
import '../../../ui/widgets/app_loading.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../radio/application/radio_controller.dart';
import '../application/favorites_controller.dart';

Future<void> showFavorites(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  barrierColor: TravelRadioPalette.of(
    context,
  ).ink.withValues(alpha: RadioFavoritesDesign.barrierOpacity),
  constraints: const BoxConstraints(maxWidth: 520),
  builder: (_) => const FavoritesSheet(),
);

class FavoritesSheet extends ConsumerWidget {
  const FavoritesSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final player = ref.watch(radioControllerProvider);
    final p = TravelRadioPalette.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: RadioFavoritesDesign.initialHeight,
      minChildSize: RadioFavoritesDesign.minHeight,
      maxChildSize: RadioFavoritesDesign.maxHeight,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: p.paper,
          borderRadius: RadioFavoritesDesign.sheetRadius,
          border: Border(top: BorderSide(color: p.metalLight)),
          boxShadow: [
            BoxShadow(
              color: p.ink.withValues(
                alpha: RadioFavoritesDesign.shadowOpacity,
              ),
              blurRadius: RadioFavoritesDesign.shadowBlur,
              offset: RadioFavoritesDesign.shadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: RadioFavoritesDesign.sheetRadius,
          child: Material(
            color: p.paper,
            child: SafeArea(
              top: false,
              child: ListView(
                controller: scroll,
                padding: RadioFavoritesDesign.sheetPadding,
                children: [
                  Center(
                    child: Container(
                      width: RadioFavoritesDesign.handleSize.width,
                      height: RadioFavoritesDesign.handleSize.height,
                      decoration: BoxDecoration(
                        color: p.trim,
                        borderRadius: RadioFavoritesDesign.handleRadius,
                      ),
                    ),
                  ),
                  const SizedBox(height: RadioFavoritesDesign.headerGap),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.favoritesTitle.tr(context: context),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: p.ink,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing:
                                        RadioFavoritesDesign.titleTracking,
                                  ),
                            ),
                            const SizedBox(
                              height: RadioFavoritesDesign.titleGap,
                            ),
                            Text(
                              LocaleKeys.favoritesSubtitle.tr(context: context),
                              style: TextStyle(color: p.muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.standard),
                      AppIconButton(
                        variant: AppIconButtonVariant.tonal,
                        backgroundColor: p.paperRaised,
                        foregroundColor: p.ink,
                        tooltip: LocaleKeys.close.tr(context: context),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          size: RadioFavoritesDesign.closeIconSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RadioFavoritesDesign.contentGap),
                  ...favorites.when(
                    skipLoadingOnRefresh: false,
                    loading: () => [
                      if (!favorites.hasValue)
                        AppLoading(
                          label: LocaleKeys.loading.tr(context: context),
                        ),
                    ],
                    error: (_, _) => [
                      Text(
                        LocaleKeys.favoritesError.tr(context: context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      AppButton(
                        variant: AppButtonVariant.text,
                        onPressed: ref.read(favoritesProvider.notifier).load,
                        label: LocaleKeys.retry.tr(context: context),
                      ),
                    ],
                    data: (data) => [
                      if (data.stations.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.large),
                          decoration: BoxDecoration(
                            color: p.paperRaised,
                            borderRadius: AppShape.panelRadius,
                          ),
                          child: AppMessage.empty(
                            leading: Icon(
                              Icons.favorite_border,
                              color: p.muted,
                              size: RadioFavoritesDesign.emptyIconSize,
                            ),
                            message: LocaleKeys.favoritesEmpty.tr(
                              context: context,
                            ),
                            messageStyle: TextStyle(color: p.ink),
                          ),
                        ),
                    ],
                  ),
                  for (final station in favorites.valueOrNull?.stations ?? [])
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.standard,
                      ),
                      child: _StationPreset(
                        id: station.id,
                        name: station.name,
                        code: station.countryCode,
                        subtitle: [
                          station.country,
                          if (player.station?.id == station.id &&
                              player.isPlaying)
                            LocaleKeys.playing.tr(context: context)
                          else
                            LocaleKeys.tapToListen.tr(context: context),
                        ].where((s) => s.isNotEmpty).join(' · '),
                        active:
                            player.station?.id == station.id &&
                            player.isPlaying,
                        removeLabel: LocaleKeys.removeFavorite.tr(
                          context: context,
                        ),
                        onPlay: () {
                          final controller = ref.read(
                            radioControllerProvider.notifier,
                          );
                          Navigator.pop(context);
                          controller.tuneTo(station);
                        },
                        onRemove: favorites.isLoading
                            ? null
                            : () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(station),
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
              ),
            ),
          ),
        ),
      ),
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
  final VoidCallback? onRemove;
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
                    ExcludeSemantics(
                      child: Container(
                        width: RadioFavoritesDesign.presetCodeSize.width,
                        height: RadioFavoritesDesign.presetCodeSize.height,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? TravelRadioPalette.hardware : p.paper,
                          borderRadius: AppShape.controlRadius,
                          border: Border.all(
                            color: active
                                ? TravelRadioPalette.activePresetBorder
                                : p.trim.withValues(
                                    alpha: RadioFavoritesDesign
                                        .inactivePresetBorderOpacity,
                                  ),
                          ),
                        ),
                        child: code.isEmpty
                            ? Icon(
                                Icons.public,
                                size: RadioFavoritesDesign.presetGlobeSize,
                                color: ink,
                              )
                            : Text(
                                code,
                                style: RadioFavoritesDesign.presetCodeText
                                    .copyWith(color: ink),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.standard),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: ink,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: RadioFavoritesDesign.titleGap),
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
            onPressed: onRemove,
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
