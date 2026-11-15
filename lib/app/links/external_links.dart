import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_links.g.dart';

/// Where the app points outside itself.
abstract final class AppLinks {
  static final project = Uri.parse('https://github.com/davidetarsi/frequenza');

  /// The Google form for ideas and bugs, with the app [version] filled in.
  static Uri feedback(String version) => Uri.https(
    'docs.google.com',
    '/forms/d/e/1FAIpQLScfBxq-YDkcOEW5GE0aeJw4X6Ol-Ydb8ycL7HVyXlt4ujJ26Q/viewform',
    {'usp': 'pp_url', 'entry.1664657182': version},
  );
}

/// Opens [Uri] in the browser or the app that handles it; false when
/// nothing could open it.
typedef OpenExternal = Future<bool> Function(Uri uri);

@Riverpod(keepAlive: true)
OpenExternal openExternal(Ref ref) =>
    (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
