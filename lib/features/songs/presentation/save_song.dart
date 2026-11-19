import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_component_design.dart';
import '../../../ui/widgets/app_snack_bar.dart';
import '../../radio/domain/radio_station.dart';
import '../../radio/domain/track_title.dart';
import '../application/saved_songs.dart';
import '../domain/saved_song.dart';
import '../domain/song_save_result.dart';

/// Saves the song on air and says so at the bottom, with an undo. A song
/// already saved stays as it is.
Future<void> saveSong(
  BuildContext context,
  WidgetRef ref,
  TrackTitle track,
  RadioStation station,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = LocaleKeys.songSaved.tr(context: context);
  final undo = LocaleKeys.undo.tr(context: context);
  final songs = ref.read(savedSongsProvider.notifier);
  final result = await songs.saveResult(track, station);
  if (!context.mounted) return;
  switch (result) {
    case SongDuplicate():
      return;
    case SongSaveFailed() || SongsUnavailable():
      messenger.showSnackBar(
        SnackBar(content: Text(LocaleKeys.songSaveError.tr(context: context))),
      );
      return;
    case SongSaved():
      break;
  }
  final key = SavedSong.keyOf(track, station);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      appSnackBar(
        message: message,
        action: SnackBarAction(
          label: undo,
          onPressed: () {
            final saved = ref.read(savedSongsProvider).valueOrNull ?? [];
            for (final song in saved) {
              if (song.key == key) songs.remove(song);
            }
          },
        ),
      ),
    );
}

/// The bookmark beside the song on air: empty with a plus, full with a
/// tick once saved.
class SongBookmark extends ConsumerWidget {
  const SongBookmark({super.key, required this.track, required this.station});

  final TrackTitle track;
  final RadioStation station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(savedSongsProvider);
    final saved = ref
        .read(savedSongsProvider.notifier)
        .contains(track, station);
    final size = IconTheme.of(context).size ?? SongBookmarkDesign.iconSize;
    return IconButton(
      tooltip: LocaleKeys.saveSong.tr(context: context),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: size + SongBookmarkDesign.widthInset,
        height: size + SongBookmarkDesign.heightInset,
      ),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      iconSize: size,
      color: IconTheme.of(context).color,
      onPressed: saved ? null : () => saveSong(context, ref, track, station),
      icon: Icon(saved ? Icons.bookmark_added : Icons.bookmark_add_outlined),
      disabledColor: IconTheme.of(context).color,
    );
  }
}
