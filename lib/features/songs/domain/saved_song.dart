// Freezed copies the JSON annotations from factory parameters to the fields.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../radio/domain/radio_station.dart';
import '../../radio/domain/station_record.dart';
import '../../radio/domain/track_title.dart';

part 'saved_song.freezed.dart';
part 'saved_song.g.dart';

/// A song kept from the radio, with the station and the day it played.
@freezed
class SavedSong with _$SavedSong {
  const SavedSong._();

  @JsonSerializable(includeIfNull: false)
  const factory SavedSong({
    @JsonKey(fromJson: _text) String? artist,
    required String title,
    @StationRecordConverter() required RadioStation station,
    @JsonKey(name: 'at', toJson: _utc) required DateTime savedAt,
  }) = _SavedSong;

  /// Throws when the station in [json] cannot be tuned in again.
  factory SavedSong.fromJson(Map<String, dynamic> json) =>
      _$SavedSongFromJson(json);

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

/// An artist that is not text, or is blank, is no artist.
String? _text(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

String _utc(DateTime time) => time.toUtc().toIso8601String();
