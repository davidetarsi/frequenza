import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../radio/data/native_channel.dart';
import '../domain/song_search.dart';

/// Which of [packages] are installed on the phone. Without an answer (no
/// channel, an error, a slow phone) none is: the web search still works.
Future<Set<String>> installedPackages(Iterable<String> packages) async {
  try {
    final installed = await nativeChannel
        .invokeMethod<List<Object?>>('installedApps', packages.toList())
        .timeout(const Duration(seconds: 1));
    return {...?installed?.whereType<String>()};
  } on Exception {
    // PlatformException, MissingPluginException, TimeoutException.
    return {};
  }
}

/// The music apps on the phone, asked once per launch.
final installedPackagesProvider = FutureProvider<Set<String>>(
  (ref) => installedPackages([
    for (final service in SearchService.values) ?service.package,
  ]),
);
