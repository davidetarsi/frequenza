import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/radio/data/native_channel.dart';

part 'app_version.g.dart';

/// The installed version, as `0.2.1+2`; empty when Android cannot tell.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  try {
    return await nativeChannel.invokeMethod<String>('appVersion') ?? '';
  } catch (_) {
    return '';
  }
}
