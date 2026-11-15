import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/radio/data/native_channel.dart';

part 'app_version.g.dart';

/// The installed version, as `0.2.1+2`; empty when Android cannot tell.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) => _ask('appVersion');

/// The phone, as `Google Pixel 8 · Android 16`; empty when Android cannot
/// tell.
@Riverpod(keepAlive: true)
Future<String> deviceInfo(Ref ref) => _ask('deviceInfo');

Future<String> _ask(String method) async {
  try {
    return await nativeChannel.invokeMethod<String>(method) ?? '';
  } catch (_) {
    return '';
  }
}
