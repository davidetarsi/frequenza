import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../radio/data/station_record.dart';
import '../domain/saved_song.dart';
import '../domain/songs_repository.dart';

/// The saved songs, on the phone only. They move to the diary's database
/// when it arrives.
class PreferencesSongsRepository implements SongsRepository {
  static const _key = 'frequenza.songs.v1';

  @override
  Future<List<SavedSong>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Invalid songs');
    return [for (final entry in decoded) ?_song(entry)];
  }

  @override
  Future<void> save(List<SavedSong> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode([
      for (final song in songs)
        {
          'artist': ?song.artist,
          'title': song.title,
          'at': song.savedAt.toUtc().toIso8601String(),
          'station': stationRecord(song.station),
        },
    ]);
    if (!await prefs.setString(_key, encoded)) {
      throw StateError('Songs not saved');
    }
  }

  static SavedSong? _song(Object? entry) {
    if (entry is! Map<String, dynamic>) return null;
    final title = entry['title'], artist = entry['artist'], at = entry['at'];
    if (title is! String || title.trim().isEmpty || at is! String) return null;
    final savedAt = DateTime.tryParse(at);
    final station = stationFromRecord(entry['station']);
    if (savedAt == null || station == null) return null;
    return SavedSong(
      artist: artist is String && artist.trim().isNotEmpty ? artist : null,
      title: title,
      station: station,
      savedAt: savedAt,
    );
  }
}
