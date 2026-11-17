import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/links/app_version.dart';
import '../../../app/theme/app_theme_mode.dart';
import '../../radio/data/native_channel.dart';
import '../domain/app_event.dart';
import 'analytics_providers.dart';

/// Describes this launch, then counts it. Unknown values stay empty or
/// zero: the launch is counted anyway.
Future<void> describeAnalyticsSession(
  ProviderContainer container, {
  required bool firstOpen,
  required String locale,
}) async {
  final version = await container.read(appVersionProvider.future);
  ThemeMode theme;
  try {
    theme = await container.read(appThemeModeProvider.future);
  } catch (_) {
    theme = ThemeMode.system;
  }
  final analytics = container.read(analyticsProvider);
  analytics.describeSession({
    'app_version': version,
    'locale': locale,
    'theme': theme.name,
    'android_sdk': await _androidSdk(),
  });
  analytics.track(AppEvent.appOpened(firstOpen: firstOpen));
}

Future<int> _androidSdk() async {
  try {
    return await nativeChannel
            .invokeMethod<int>('sdkInt')
            .timeout(const Duration(seconds: 1)) ??
        0;
  } catch (_) {
    return 0;
  }
}
