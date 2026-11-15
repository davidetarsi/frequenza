import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../features/radio/application/radio_notification.dart';
import '../features/radio/application/radio_providers.dart';
import '../features/radio/data/native_channel.dart';
import '../features/radio/data/radio_audio_handler.dart';

import '../l10n/app_translations.g.dart';
import '../l10n/locale_keys.g.dart';

import 'app.dart';
import 'config/app_config.dart';

Future<void> bootstrap({AppConfig config = const AppConfig()}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final player = AudioPlayer();
  final language =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'it'
      ? 'it'
      : 'en';
  String text(String key) => CodegenLoader.mapLocales[language]![key] as String;
  final fallbackArt = await _notificationArt();
  final handler = await AudioService.init(
    builder: () => RadioAudioHandler(
      player,
      flightTitle: config.appName,
      flightSubtitle: text(LocaleKeys.notificationFlying),
      saveLabel: text(LocaleKeys.notificationSave),
      removeLabel: text(LocaleKeys.notificationRemove),
      fallbackArt: fallbackArt,
    ),
    config: radioServiceConfig(channelName: text(LocaleKeys.audioChannelName)),
  );
  final container = ProviderContainer(
    overrides: [radioAudioHandlerProvider.overrideWithValue(handler)],
  );
  // The notification answers from the start, before any page is built.
  container.read(radioNotificationProvider);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: StarterApp(config: config),
    ),
  );
}

/// The service stays in the foreground, paused too: Android forbids
/// going back to it from the background, so a play from the headphones
/// would leave the radio muted and then frozen. A paused radio closes
/// after ten minutes, or when the app is swiped away from the recents.
AudioServiceConfig radioServiceConfig({required String channelName}) =>
    AudioServiceConfig(
      androidNotificationChannelId: 'it.davidetarsi.frequenza.channel.audio',
      androidNotificationChannelName: channelName,
      androidNotificationIcon: 'drawable/ic_stat_frequenza',
      androidStopForegroundOnPause: false,
    );

/// Frequenza's logo as a file in the app cache: the notification shows it
/// for stations without a logo. Null when it cannot be written.
Future<Uri?> _notificationArt() async {
  try {
    final folder = await nativeChannel.invokeMethod<String>('cacheDir');
    if (folder == null) return null;
    final art = await rootBundle.load('assets/images/notification_art.png');
    final file = File('$folder/notification_art.png');
    await file.writeAsBytes(art.buffer.asUint8List(), flush: true);
    return Uri.file(file.path);
  } catch (_) {
    // Missing asset or folder: the notification just shows no logo.
    return null;
  }
}
