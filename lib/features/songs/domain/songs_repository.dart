import 'saved_song.dart';

abstract interface class SongsRepository {
  Future<List<SavedSong>> load();
  Future<void> save(List<SavedSong> songs);
}
