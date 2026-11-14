import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../features/radio/application/radio_providers.dart';
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
  final handler = await AudioService.init(
    builder: () => RadioAudioHandler(
      player,
      flightTitle: config.appName,
      flightSubtitle: text(LocaleKeys.notificationFlying),
    ),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'it.davidetarsi.frequenza.channel.audio',
      androidNotificationChannelName: text(LocaleKeys.audioChannelName),
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  runApp(
    ProviderScope(
      overrides: [radioAudioHandlerProvider.overrideWithValue(handler)],
      child: StarterApp(config: config),
    ),
  );
}
