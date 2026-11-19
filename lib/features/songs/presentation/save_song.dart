import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_component_design.dart';
import '../../../ui/widgets/app_snack_bar.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../radio/domain/radio_station.dart';
import '../../radio/domain/track_title.dart';
import '../application/saved_songs.dart';
import '../domain/song_save_result.dart';

/// A tap on the title only saves; the bookmark is the explicit toggle.
Future<void> saveSong(
  BuildContext context,
  WidgetRef ref,
  TrackTitle track,
  RadioStation station,
) async {
  final result = await ref
      .read(savedSongsProvider.notifier)
      .saveResult(track, station);
  if (!context.mounted) return;
  switch (result) {
    case SongDuplicate() || SongSaved():
      return;
    case SongSaveFailed() || SongsUnavailable():
      _showError(context, LocaleKeys.songSaveError);
  }
}

Future<void> toggleSong(
  BuildContext context,
  WidgetRef ref,
  TrackTitle track,
  RadioStation station,
) async {
  final updated = await ref
      .read(savedSongsProvider.notifier)
      .toggle(track, station);
  if (!updated && context.mounted) _showError(context, LocaleKeys.songsError);
}

void _showError(BuildContext context, String key) => ScaffoldMessenger.of(
  context,
).showSnackBar(appSnackBar(message: key.tr(context: context)));

/// Shared bookmark for the radio and player bar. A saved song keeps its
/// filled icon and remains tappable to remove it.
class SongBookmark extends ConsumerWidget {
  const SongBookmark({super.key, required this.track, required this.station})
    : _inPlayer = false;

  const SongBookmark.player({
    super.key,
    required this.track,
    required this.station,
  }) : _inPlayer = true;

  final bool _inPlayer;
  final TrackTitle track;
  final RadioStation station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(savedSongsProvider);
    final saved = ref
        .read(savedSongsProvider.notifier)
        .contains(track, station);
    final size = _inPlayer
        ? RadioBarDesign.iconSize
        : IconTheme.of(context).size ?? SongBookmarkDesign.iconSize;
    final color = _inPlayer
        ? TravelRadioPalette.screen
        : IconTheme.of(context).color;
    return Semantics(
      toggled: saved,
      child: IconButton(
        tooltip: (saved ? LocaleKeys.removeSong : LocaleKeys.saveSong).tr(
          context: context,
        ),
        padding: _inPlayer ? null : EdgeInsets.zero,
        constraints: _inPlayer
            ? const BoxConstraints.tightFor(
                width: RadioBarDesign.key,
                height: RadioBarDesign.key,
              )
            : BoxConstraints.tightFor(
                width: size + SongBookmarkDesign.widthInset,
                height: size + SongBookmarkDesign.heightInset,
              ),
        style: _inPlayer
            ? null
            : const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
        iconSize: size,
        color: color,
        onPressed: songs.hasValue && !songs.isLoading
            ? () => toggleSong(context, ref, track, station)
            : null,
        icon: Icon(saved ? Icons.bookmark_added : Icons.bookmark_add_outlined),
        disabledColor: color,
      ),
    );
  }
}
