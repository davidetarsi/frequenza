import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../radio/application/radio_providers.dart';
import '../application/favorites_providers.dart';

Future<void> showFavorites(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const FavoritesSheet(),
);

class FavoritesSheet extends ConsumerWidget {
  const FavoritesSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoritesProvider);
    final player = ref.watch(radioControllerProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .55,
      minChildSize: .3,
      maxChildSize: .9,
      builder: (context, scroll) => SafeArea(
        top: false,
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.favoritesTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: l.close,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(l.favoritesSubtitle),
            const SizedBox(height: 16),
            if (favorites.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (favorites.hasError) ...[
              Text(
                l.favoritesError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: favorites.isSaving
                    ? null
                    : ref.read(favoritesProvider.notifier).load,
                child: Text(l.retry),
              ),
            ],
            if (!favorites.isLoading &&
                favorites.stations.isEmpty &&
                !favorites.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.favoritesEmpty),
              ),
            for (final station in favorites.stations)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      key: ValueKey('favorite-play-${station.id}'),
                      title: Text(station.name),
                      subtitle: Text(
                        [
                          station.country,
                          if (player.station?.id == station.id &&
                              player.isPlaying)
                            l.playing
                          else
                            l.tapToListen,
                        ].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ref
                            .read(radioControllerProvider.notifier)
                            .tuneTo(station);
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: l.removeFavorite,
                    onPressed: favorites.isSaving
                        ? null
                        : () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(station),
                    icon: const Icon(Icons.favorite),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text(l.savedOnDevice, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
