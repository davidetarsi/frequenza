import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/state/latest_save.dart';
import '../../radio/domain/radio_station.dart';
import '../../radio/domain/track_title.dart';
import '../data/preferences_songs_repository.dart';
import '../domain/saved_song.dart';
import '../domain/songs_repository.dart';

part 'saved_songs.g.dart';

@Riverpod(keepAlive: true)
SongsRepository songsRepository(Ref ref) => PreferencesSongsRepository();

/// The songs saved from the radio, in the order they were saved.
@Riverpod(keepAlive: true)
class SavedSongs extends _$SavedSongs {
  final _save = LatestSave();

  @override
  Future<List<SavedSong>> build() {
    final repository = ref.watch(songsRepositoryProvider);
    _save.start(ref);
    return repository.load();
  }

  bool contains(TrackTitle track, RadioStation station) {
    final key = SavedSong.keyOf(track, station);
    return state.valueOrNull?.any((song) => song.key == key) ?? false;
  }

  /// Saves [track] heard on [station]; false when it was already saved, or
  /// the songs are not loaded.
  Future<bool> save(TrackTitle track, RadioStation station) async {
    final current = state.valueOrNull;
    if (current == null || contains(track, station)) return false;
    final song = SavedSong(
      artist: track.artist,
      title: track.title,
      station: station,
      savedAt: DateTime.now(),
    );
    final result = await _update([...current, song]);
    return !result.hasError;
  }

  Future<void> remove(SavedSong song) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _update([
      for (final saved in current)
        if (saved.key != song.key) saved,
    ]);
  }

  /// Puts [song] back at [index], as it was before a removal.
  Future<void> restore(SavedSong song, int index) async {
    final current = state.valueOrNull;
    if (current == null || current.any((saved) => saved.key == song.key)) {
      return;
    }
    final next = [...current]..insert(index.clamp(0, current.length), song);
    await _update(next);
  }

  Future<AsyncValue<List<SavedSong>>> _update(List<SavedSong> next) =>
      _save.run(
        shown: state,
        emit: (value) => state = value,
        action: () async {
          await ref.read(songsRepositoryProvider).save(next);
          return next;
        },
      );
}
