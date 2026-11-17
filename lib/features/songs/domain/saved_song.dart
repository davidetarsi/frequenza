import 'package:freezed_annotation/freezed_annotation.dart';

import '../../radio/domain/radio_station.dart';
import '../../radio/domain/track_title.dart';

part 'saved_song.freezed.dart';

/// A song kept from the radio, with the station and the day it played.
@freezed
class SavedSong with _$SavedSong {
  const SavedSong._();

  const factory SavedSong({
    String? artist,
    required String title,
    required RadioStation station,
    required DateTime savedAt,
  }) = _SavedSong;

  /// The same song on the same station, whatever the case or the spaces.
  static String keyOf(TrackTitle track, RadioStation station) =>
      '${station.id}|${_normalized(track.artist)}|${_normalized(track.title)}';

  static String _normalized(String? text) =>
      (text ?? '').trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  TrackTitle get track => TrackTitle(artist: artist, title: title);

  String get key => keyOf(track, station);
  String get display => track.display;
  String get query => track.query;
}
