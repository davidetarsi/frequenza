import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_links.g.dart';

/// Where the app points outside itself.
abstract final class AppLinks {
  static final project = Uri.parse('https://github.com/davidetarsi/frequenza');
}

/// Opens [Uri] in the browser or the app that handles it; false when
/// nothing could open it.
typedef OpenExternal = Future<bool> Function(Uri uri);

@Riverpod(keepAlive: true)
OpenExternal openExternal(Ref ref) =>
    (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
