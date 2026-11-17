import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/links/app_version.dart';
import '../../../app/theme/app_theme_mode.dart';
import '../../radio/data/native_channel.dart';
import '../domain/app_event.dart';
import 'analytics_consent.dart';
import 'analytics_providers.dart';
import 'radio_analytics.dart';

/// Starts the statistics before any flight can: reads the choice,
/// describes the launch, watches the radio and counts the launch. Unknown
/// details stay empty or zero, and nothing here waits more than a second.
Future<void> startAnalytics(
  ProviderContainer container, {
  required bool firstOpen,
  required String locale,
}) async {
  await container.read(analyticsConsentProvider.future);
  final (version, theme, sdk) = await (
    _appVersion(container),
    _theme(container),
    _androidSdk(),
  ).wait;
  container.read(analyticsSessionDetailsProvider.notifier).describe({
    'app_version': version,
    'locale': locale,
    'theme': theme.name,
    'android_sdk': sdk,
  });
  container.read(radioAnalyticsProvider);
  container
      .read(analyticsProvider)
      .track(AppEvent.appOpened(firstOpen: firstOpen));
}

Future<String> _appVersion(ProviderContainer container) async {
  try {
    return await container
        .read(appVersionProvider.future)
        .timeout(const Duration(seconds: 1));
  } catch (_) {
    return '';
  }
}

Future<ThemeMode> _theme(ProviderContainer container) async {
  try {
    return await container
        .read(appThemeModeProvider.future)
        .timeout(const Duration(seconds: 1));
  } catch (_) {
    return ThemeMode.system;
  }
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
