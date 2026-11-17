import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
    final encoded = jsonEncode([for (final song in songs) song.toJson()]);
    if (!await prefs.setString(_key, encoded)) {
      throw StateError('Songs not saved');
    }
  }

  /// A broken entry is skipped: the others still load.
  static SavedSong? _song(Object? entry) {
    if (entry is! Map<String, dynamic>) return null;
    try {
      final song = SavedSong.fromJson(entry);
      return song.title.trim().isEmpty ? null : song;
    } on Object {
      // FormatException from the station, TypeError from a wrong field.
      return null;
    }
  }
}
