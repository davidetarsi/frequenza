import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../radio/data/native_channel.dart';
import '../domain/song_search.dart';

part 'installed_apps.g.dart';

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
@Riverpod(keepAlive: true)
Future<Set<String>> installedSearchApps(Ref ref) => installedPackages([
  for (final service in SearchService.values) ?service.package,
]);
