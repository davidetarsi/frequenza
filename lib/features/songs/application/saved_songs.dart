import '../../analytics/application/analytics_providers.dart';
import '../../analytics/domain/app_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/state/latest_save.dart';
import '../../../app/state/serial_tasks.dart';
import '../domain/song_save_result.dart';
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
  final _tasks = SerialTasks();

  @override
  Future<List<SavedSong>> build() {
    final repository = ref.watch(songsRepositoryProvider);
    _save.start(ref);
    _tasks.start(ref);
    return _tasks.settled.then((_) => repository.load());
  }

  bool contains(TrackTitle track, RadioStation station) {
    final key = SavedSong.keyOf(track, station);
    return state.valueOrNull?.any((song) => song.key == key) ?? false;
  }

  /// Compatibility convenience; presentation uses the typed result below.
  Future<bool> save(TrackTitle track, RadioStation station) async =>
      await saveResult(track, station) is SongSaved;

  Future<SongSaveResult> saveResult(
    TrackTitle track,
    RadioStation station,
  ) async =>
      await _tasks.run<SongSaveResult>((currentTask) async {
        final current = state.valueOrNull;
        if (current == null) return const SongSaveResult.unavailable();
        if (contains(track, station)) return const SongSaveResult.duplicate();
        final song = SavedSong(
          artist: track.artist,
          title: track.title,
          station: station,
          savedAt: DateTime.now(),
        );
        final result = await _update([...current, song]);
        if (!currentTask()) return const SongSaveResult.unavailable();
        if (result.hasError) return const SongSaveResult.failed();
        ref.read(analyticsProvider).track(AppEvent.songSaved(station));
        return const SongSaveResult.saved();
      }) ??
      const SongSaveResult.unavailable();

  Future<void> remove(SavedSong song) async {
    await _tasks.run<bool>((currentTask) async {
      final current = state.valueOrNull;
      if (current == null || !current.any((saved) => saved.key == song.key)) {
        return false;
      }
      final result = await _update([
        for (final saved in current)
          if (saved.key != song.key) saved,
      ]);
      if (!currentTask() || result.hasError) return false;
      ref.read(analyticsProvider).track(AppEvent.songRemoved(song.station));
      return true;
    });
  }

  Future<void> restore(SavedSong song, int index) async {
    await _tasks.run<bool>((currentTask) async {
      final current = state.valueOrNull;
      if (current == null || current.any((saved) => saved.key == song.key)) {
        return false;
      }
      final next = [...current]..insert(index.clamp(0, current.length), song);
      final result = await _update(next);
      return currentTask() && !result.hasError;
    });
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
