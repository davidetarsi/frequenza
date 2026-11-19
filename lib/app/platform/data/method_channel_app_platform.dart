import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/app_platform.dart';
import '../../network/domain/https_uri.dart';
import 'native_channel.dart';

class MethodChannelAppPlatform implements AppPlatform {
  static const _timeout = Duration(seconds: 1);

  Future<T?> _ask<T>(String method, [Object? arguments]) async {
    try {
      return await nativeChannel
          .invokeMethod<T>(method, arguments)
          .timeout(_timeout);
    } catch (_) {
      return null;
    }
  }

  @override
  String get deviceLanguageCode =>
      PlatformDispatcher.instance.locale.languageCode;

  @override
  Future<void> updateNotificationChannel(String id, String name) async {
    await _ask<void>('notificationChannel', {'id': id, 'name': name});
  }

  @override
  Future<String> appVersion() async => await _ask<String>('appVersion') ?? '';

  @override
  Future<String> deviceDescription() async =>
      await _ask<String>('deviceInfo') ?? '';

  @override
  Future<int> androidSdk() async => await _ask<int>('sdkInt') ?? 0;

  @override
  Future<Set<String>> installedPackages(Iterable<String> packages) async {
    final requested = packages.toSet();
    final installed = await _ask<List<Object?>>(
      'installedApps',
      requested.toList(),
    );
    return {...?installed?.whereType<String>().where(requested.contains)};
  }

  @override
  Future<Uri?> notificationArtwork() async {
    try {
      final folder = await _ask<String>('cacheDir');
      if (folder == null) return null;
      final art = await rootBundle.load('assets/images/notification_art.png');
      final file = File('$folder/notification_art.png');
      await file.writeAsBytes(art.buffer.asUint8List(), flush: true);
      return Uri.file(file.path);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    await HapticFeedback.lightImpact();
    return defaultTargetPlatform == TargetPlatform.android &&
        await androidSdk() >= 33;
  }

  @override
  Future<bool> openExternal(Uri uri) async {
    final spotifySearch =
        uri.scheme == 'spotify' && uri.path.startsWith('search:');
    if (httpsUri(uri.toString()) == null && !spotifySearch) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
