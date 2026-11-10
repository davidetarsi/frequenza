import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'config/app_config.dart';

Future<void> bootstrap({AppConfig config = const AppConfig()}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'dev.davidetarsi.frequenza.channel.audio',
    androidNotificationChannelName: 'Frequenza Radio Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );
  runApp(ProviderScope(child: StarterApp(config: config)));
}
