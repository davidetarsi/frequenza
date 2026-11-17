/// A song title as a station sends it, cleaned: no on-air prefixes, no
/// adverts, the artist apart when the station writes "artist - title".
final class TrackTitle {
  const TrackTitle({required this.title, this.artist});

  final String? artist;
  final String title;

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

  @override
  bool operator ==(Object other) =>
      other is TrackTitle && other.artist == artist && other.title == title;

  @override
  int get hashCode => Object.hash(artist, title);
}
