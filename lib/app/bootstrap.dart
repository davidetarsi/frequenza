import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../l10n/app_translations.g.dart';
import '../l10n/locale_keys.g.dart';

import 'app.dart';
import 'config/app_config.dart';

Future<void> bootstrap({AppConfig config = const AppConfig()}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'dev.davidetarsi.frequenza.channel.audio',
    androidNotificationChannelName:
        WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'it'
        ? CodegenLoader.mapLocales['it']![LocaleKeys.audioChannelName] as String
        : CodegenLoader.mapLocales['en']![LocaleKeys.audioChannelName]
              as String,
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );
  runApp(ProviderScope(child: StarterApp(config: config)));
}
