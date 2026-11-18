/// Where a saved song can be looked for.
enum SearchService {
  spotify('com.spotify.music', 'Spotify'),
  youtube('com.google.android.youtube', 'YouTube'),
  amazonMusic('com.amazon.mp3', 'Amazon Music'),
  web(null, null);

  const SearchService(this.package, this.label);

  /// The Android app that opens the link, or null for the browser.
  final String? package;

  /// The service's own name, never translated.
  final String? label;
}

abstract final class SongSearch {
  /// The searches for [query]: the installed apps first, the web always.
  static List<(SearchService, Uri)> links(
    String query,
    Set<String> installedPackages,
  ) {
    final q = Uri.encodeComponent(query);
    return [
      for (final service in SearchService.values)
        if (service.package == null ||
            installedPackages.contains(service.package))
          (service, Uri.parse(_link(service, q))),
    ];
  }

  static String _link(SearchService service, String q) => switch (service) {
    SearchService.spotify => 'spotify:search:$q',
    SearchService.youtube => 'https://www.youtube.com/results?search_query=$q',
    SearchService.amazonMusic => 'https://music.amazon.com/search/$q',
    SearchService.web => 'https://www.google.com/search?q=$q',
  };
}
