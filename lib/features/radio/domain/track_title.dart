import 'package:freezed_annotation/freezed_annotation.dart';

import 'station_input.dart';

part 'track_title.freezed.dart';

/// A song title as a station sends it, cleaned: no on-air prefixes, no
/// adverts, the artist apart when the station writes "artist - title".
@freezed
class TrackTitle with _$TrackTitle {
  const TrackTitle._();
  const factory TrackTitle({required String title, String? artist}) =
      _TrackTitle;

  /// "Artist — Title", or the title alone.
  String get display => artist == null ? title : '$artist — $title';

  /// What to search for in a music app.
  String get query => artist == null ? title : '$artist $title';

  static final _spaces = RegExp(r'\s+');
  static final _prefix = RegExp(
    r'^(now on air|now playing|on air|np)\s*:\s*',
    caseSensitive: false,
  );
  static final _dash = RegExp(r' [-–—] ');
  static final _noLetters = RegExp(r'^[^\p{L}]*$', unicode: true);
  static final _advert = RegExp(
    r'advert|commercial break|pubblicità',
    caseSensitive: false,
  );

  /// Null when [raw] is not a song: empty, digits or punctuation only, an
  /// advert, or just the station's name.
  static TrackTitle? parse(String raw, {String? stationName}) {
    if (raw.length > StationInput.trackTitle) return null;
    final text = _collapse(raw).replaceFirst(_prefix, '');
    if (_noLetters.hasMatch(text) || _advert.hasMatch(text)) return null;
    if (stationName != null &&
        text.toLowerCase() == _collapse(stationName).toLowerCase()) {
      return null;
    }
    final dash = _dash.firstMatch(text);
    if (dash == null) return TrackTitle(title: text);
    final artist = text.substring(0, dash.start).trim();
    final title = text.substring(dash.end).trim();
    if (title.isEmpty || _noLetters.hasMatch(title)) {
      return TrackTitle(title: artist);
    }
    return TrackTitle(artist: artist.isEmpty ? null : artist, title: title);
  }

  static String _collapse(String text) => text.trim().replaceAll(_spaces, ' ');
}
