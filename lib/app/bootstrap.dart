import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../features/analytics/application/analytics_session.dart';
import '../features/diary/application/listen_recorder.dart';
import '../features/radio/application/radio_notification.dart';
import '../features/radio/application/radio_providers.dart';
import '../features/radio/data/just_audio_service.dart';
import '../features/radio/data/radio_audio_handler.dart';
import '../features/welcome/application/welcome_seen.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'config/notification_config.dart';
import 'preferences/data/shared_preferences_repository.dart';
import 'preferences/application/app_preferences_provider.dart';
import 'localization/application/app_language_provider.dart';
import 'localization/application/language_effects.dart';
import 'localization/application/notification_localization.dart';
import 'platform/application/app_platform_provider.dart';
import 'platform/data/method_channel_app_platform.dart';
import 'platform/domain/app_platform.dart';

Future<void> bootstrap({AppConfig config = const AppConfig()}) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await EasyLocalization.ensureInitialized();
  } catch (_) {
    // A broken preference store must not block the radio. The supported
    // start locale is resolved below and explicitly applied by the UI bridge.
  }
  final AppPlatform platform = MethodChannelAppPlatform();
  final player = AudioPlayer();
  final preferences = SharedPreferencesRepository();
  final language = await resolveInitialLanguage(
    preferences,
    platform.deviceLanguageCode,
  );
  final labels = notificationLocalization(language);
  final fallbackArt = await platform.notificationArtwork();
  final handler = await AudioService.init(
    builder: () => RadioAudioHandler(
      player,
      flightTitle: config.appName,
      flightSubtitle: labels.flying,
      saveLabel: labels.save,
      removeLabel: labels.remove,
      fallbackArt: fallbackArt,
    ),
    config: radioServiceConfig(channelName: labels.channelName),
  );
  final container = ProviderContainer(
    overrides: [
      appPlatformProvider.overrideWithValue(platform),
      appPreferencesRepositoryProvider.overrideWithValue(preferences),
      initialAppLanguageProvider.overrideWithValue(language),
      radioMediaSessionProvider.overrideWithValue(handler),
      radioAudioServiceProvider.overrideWith((ref) {
        final service = JustAudioService(player: player, mediaSession: handler);
        ref.onDispose(() async {
          await handler.dispose();
          await service.dispose();
        });
        return service;
      }),
    ],
  );
  // The first page depends on it: the welcome, or the radio.
  await container.read(welcomeSeenProvider.future);
  final hasSeenGuide = await container
      .read(welcomeSeenProvider.notifier)
      .hasSeenAnyGuide();
  // Before the notification: a flight from the headphones must already be
  // counted whole, with the launch details.
  await startAnalytics(
    container,
    firstOpen: !hasSeenGuide,
    locale: language.name,
  );
  container.read(appLanguageEffectsProvider);
  // The diary writes down every listen, from the first one.
  container.read(listenRecorderProvider);
  // The notification answers from the start, before any page is built.
  container.read(radioNotificationProvider);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: StarterApp(config: config, locale: Locale(language.name)),
    ),
  );
}

/// The service stays in the foreground, paused too: Android forbids
/// going back to it from the background, so a play from the headphones
/// would leave the radio muted and then frozen. A paused radio closes
/// after ten minutes. Removing the app from recents always stops it,
/// whether paused, playing or tuning.
AudioServiceConfig radioServiceConfig({required String channelName}) =>
    AudioServiceConfig(
      androidNotificationChannelId: radioNotificationChannelId,
      androidNotificationChannelName: channelName,
      androidNotificationIcon: 'drawable/ic_stat_frequenza',
      androidStopForegroundOnPause: false,
      // A deliberate stop removes the notification and cannot wake playback.
      // Pause keeps the running service and its active controls available.
      androidResumeOnClick: false,
    );
