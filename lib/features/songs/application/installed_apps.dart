import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/platform/application/app_platform_provider.dart';
import '../domain/song_search.dart';

part 'installed_apps.g.dart';

/// The music apps on the phone, asked once per launch.
@Riverpod(keepAlive: true)
Future<Set<String>> installedSearchApps(Ref ref) =>
    ref.watch(appPlatformProvider).installedPackages([
      for (final service in SearchService.values) ?service.package,
    ]);
