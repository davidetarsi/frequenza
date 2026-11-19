import '../../journey/presentation/country_name.dart';
import '../../../app/localization/presentation/detail_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/presentation/open_app_link.dart';
import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_shape.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/theme/app_component_design.dart';
import '../../../ui/widgets/app_loading.dart';
import '../../../ui/widgets/app_message.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/presentation/copy_track_title.dart';
import '../application/saved_songs.dart';
import '../application/installed_apps.dart';
import '../domain/saved_song.dart';
import '../domain/song_search.dart';

/// The saved songs, grouped by the country they were found in, the most
/// recent first. Each one can be searched, copied, tuned in again or
/// removed, with an undo.
class SongsTab extends ConsumerStatefulWidget {
  const SongsTab({super.key});

  @override
  ConsumerState<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends ConsumerState<SongsTab> {
  /// Swiped away and still being removed: a dismissed row must leave the
  /// list at once.
  final _leaving = <String>{};

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(savedSongsProvider);
    final visible = [
      for (final song in songs.valueOrNull ?? <SavedSong>[])
        if (!_leaving.contains(song.key)) song,
    ];
    if (songs.hasError && !songs.isLoading) {
      return AppMessage.error(
        message: LocaleKeys.songsError.tr(context: context),
        onAction: () => ref.invalidate(savedSongsProvider),
        actionLabel: LocaleKeys.retry.tr(context: context),
      );
    }
    if (!songs.hasValue) {
      return AppLoading(label: LocaleKeys.loading.tr(context: context));
    }
    if (visible.isEmpty) {
      return AppMessage.emptyPanel(
        icon: Icons.bookmark_border,
        message: LocaleKeys.songsEmpty.tr(context: context),
      );
    }
    // Countries in the order of their latest song.
    final groups = <String, List<SavedSong>>{};
    final newestFirst = [...visible]
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    for (final song in newestFirst) {
      groups.putIfAbsent(song.station.countryCode, () => []).add(song);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups.values) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Text(
              countryName(
                context,
                group.first.station.countryCode,
                fallback: group.first.station.country,
              ),
              style: Theme.of(context).textTheme.titleSmall
                  ?.merge(SavedItemsDesign.groupText)
                  .copyWith(color: TravelRadioPalette.of(context).muted),
            ),
          ),
          for (final song in group)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.standard),
              child: _SongRow(
                song: song,
                onDismissed: () => _remove(song),
                onSelected: (choice) => _choose(song, choice),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _choose(SavedSong song, Object choice) async {
    switch (choice) {
      case (final SearchService service, final Uri link):
        ref.read(analyticsProvider).track(AppEvent.songSearchOpened(service));
        await openAppLink(context, ref, () async => link);
      case _Choice.copy:
        ref.read(analyticsProvider).track(AppEvent.songCopied());
        await copyTrackTitle(context, ref, song.display);
      case _Choice.tune:
        ref.read(analyticsProvider).track(AppEvent.stationRetuned());
        final controller = ref.read(radioControllerProvider.notifier);
        Navigator.pop(context);
        await controller.tuneTo(song.station);
      case _Choice.remove:
        await _remove(song);
    }
  }

  Future<void> _remove(SavedSong song) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = LocaleKeys.songRemoved.tr(context: context);
    final undo = LocaleKeys.undo.tr(context: context);
    final songs = ref.read(savedSongsProvider.notifier);
    final index = ref.read(savedSongsProvider).valueOrNull?.indexOf(song) ?? 0;
    setState(() => _leaving.add(song.key));
    await songs.remove(song);
    if (!mounted) return;
    if (ref.read(savedSongsProvider).hasError) {
      setState(() => _leaving.remove(song.key));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: undo,
            onPressed: () {
              if (mounted) setState(() => _leaving.remove(song.key));
              songs.restore(song, index);
            },
          ),
        ),
      );
  }
}

enum _Choice { copy, tune, remove }

class _SongRow extends ConsumerWidget {
  const _SongRow({
    required this.song,
    required this.onDismissed,
    required this.onSelected,
  });

  final SavedSong song;
  final VoidCallback onDismissed;
  final ValueChanged<Object> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = TravelRadioPalette.of(context);
    final error = Theme.of(context).colorScheme.error;
    final installed = ref.watch(installedSearchAppsProvider).valueOrNull ?? {};
    final station = song.station;
    final day = DateFormat.yMMMd(
      context.locale.toLanguageTag(),
    ).format(song.savedAt.toLocal());
    final details = detailText(context, [
      ?song.artist,
      station.name,
      ?station.region,
      day,
    ]);
    final removeLabel = LocaleKeys.removeSong.tr(context: context);
    return Dismissible(
      key: ValueKey('song-${song.key}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        decoration: BoxDecoration(
          color: error.withValues(
            alpha: SavedItemsDesign.removeBackgroundOpacity,
          ),
          borderRadius: AppShape.panelRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: error),
            const SizedBox(width: AppSpacing.small),
            Text(removeLabel, style: TextStyle(color: error)),
          ],
        ),
      ),
      child: Material(
        color: p.paperRaised,
        borderRadius: AppShape.panelRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.large),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.standard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.merge(SavedItemsDesign.titleText)
                            .copyWith(color: p.ink),
                      ),
                      const SizedBox(height: SavedItemsDesign.titleGap),
                      Text(
                        details,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: p.muted),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<Object>(
                tooltip: LocaleKeys.songOptions.tr(context: context),
                icon: Icon(Icons.more_vert, color: p.ink),
                onSelected: onSelected,
                itemBuilder: (context) => [
                  for (final (service, link) in SongSearch.links(
                    song.query,
                    installed,
                  ))
                    PopupMenuItem<Object>(
                      value: (service, link),
                      child: Text(switch (service.label) {
                        final label? => LocaleKeys.searchOn.tr(
                          context: context,
                          args: [label],
                        ),
                        null => LocaleKeys.searchWeb.tr(context: context),
                      }),
                    ),
                  PopupMenuItem<Object>(
                    value: _Choice.copy,
                    child: Text(LocaleKeys.copy.tr(context: context)),
                  ),
                  PopupMenuItem<Object>(
                    value: _Choice.tune,
                    child: Text(
                      LocaleKeys.tuneAgain.tr(
                        context: context,
                        args: [station.name],
                      ),
                    ),
                  ),
                  PopupMenuItem<Object>(
                    value: _Choice.remove,
                    child: Text(removeLabel, style: TextStyle(color: error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
