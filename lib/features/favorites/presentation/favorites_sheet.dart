import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/widgets/app_button.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../../../ui/widgets/app_message.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../radio/application/radio_controller.dart';
import '../application/favorites_controller.dart';

Future<void> showFavorites(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  barrierColor: TravelRadioPalette.of(context).ink.withValues(alpha: .48),
  constraints: const BoxConstraints(maxWidth: 520),
  builder: (_) => const FavoritesSheet(),
);

class FavoritesSheet extends ConsumerWidget {
  const FavoritesSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoritesProvider);
    final player = ref.watch(radioControllerProvider);
    final p = TravelRadioPalette.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .62,
      minChildSize: .3,
      maxChildSize: .94,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: p.paper,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: p.metalLight)),
          boxShadow: [
            BoxShadow(
              color: p.ink.withValues(alpha: .22),
              blurRadius: 28,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Material(
            color: p.paper,
            child: SafeArea(
              top: false,
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: p.trim,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.favoritesTitle,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: p.ink,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.6,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              l.favoritesSubtitle,
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
                        tooltip: l.close,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...favorites.when(
                    skipLoadingOnRefresh: false,
                    loading: () => [
                      if (!favorites.hasValue)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.large),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                    error: (_, _) => [
                      Text(
                        l.favoritesError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      AppButton(
                        variant: AppButtonVariant.text,
                        onPressed: ref.read(favoritesProvider.notifier).load,
                        label: l.retry,
                      ),
                    ],
                    data: (data) => [
                      if (data.stations.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.large),
                          decoration: BoxDecoration(
                            color: p.paperRaised,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppMessage.empty(
                            leading: Icon(
                              Icons.favorite_border,
                              color: p.muted,
                              size: 28,
                            ),
                            message: l.favoritesEmpty,
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
                            l.playing
                          else
                            l.tapToListen,
                        ].where((s) => s.isNotEmpty).join(' · '),
                        active:
                            player.station?.id == station.id &&
                            player.isPlaying,
                        removeLabel: l.removeFavorite,
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_android_outlined,
                        size: 14,
                        color: p.muted,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.savedOnDevice,
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
        ? TravelRadioPalette.screenInk.withValues(alpha: .85)
        : p.muted;
    return Material(
      color: active ? TravelRadioPalette.screen : p.paperRaised,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('favorite-play-$id'),
              onTap: onPlay,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 18,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 42,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? TravelRadioPalette.hardware : p.paper,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active
                                ? const Color(0xFF65765A)
                                : p.trim.withValues(alpha: .55),
                          ),
                        ),
                        child: code.isEmpty
                            ? Icon(Icons.public, size: 18, color: ink)
                            : Text(
                                code,
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
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
                          const SizedBox(height: 5),
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
            icon: const Icon(Icons.favorite, size: 19),
            foregroundColor: ink,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
