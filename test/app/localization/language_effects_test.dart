import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/localization/application/app_language_provider.dart';
import 'package:frequenza/app/localization/application/language_effects.dart';
import 'package:frequenza/app/localization/application/notification_localization.dart';
import 'package:frequenza/app/localization/domain/app_language.dart';
import 'package:frequenza/features/analytics/application/analytics_consent.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/radio/data/radio_audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgram_analytics/tgram_analytics.dart';

import '../../features/radio/radio_audio_handler_test.dart' show EventPlayer;
import '../../features/songs/saved_songs_test.dart' show fip;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(TGA.reset);

  test(
    'language changes update analytics metadata without changing the launch ID',
    () async {
      final requests = <http.Request>[];
      final container = ProviderContainer(
        overrides: [
          analyticsKeysProvider.overrideWithValue((
            apiKey: 'proj_test',
            serverUrl: 'https://analytics.test',
          )),
          analyticsHttpClientProvider.overrideWithValue(
            MockClient((request) async {
              requests.add(request);
              return http.Response('{}', 202);
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(analyticsConsentProvider.future);
      container.read(analyticsSessionDetailsProvider.notifier).describe({
        'locale': 'en',
        'app_version': '0.4.1+6',
      });
      container.read(appLanguageEffectsProvider);
      container.read(analyticsProvider).track(AppEvent.songCopied());
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      container
          .read(activeAppLanguageProvider.notifier)
          .activate(AppLanguage.it);
      container.read(analyticsProvider).track(AppEvent.songCopied());
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(requests, hasLength(2));
      final first = jsonDecode(requests[0].body) as Map;
      final second = jsonDecode(requests[1].body) as Map;
      expect(first['properties']['locale'], 'en');
      expect(second['properties']['locale'], 'it');
      expect(first['session_id'], isA<String>());
      expect(first['session_id'], second['session_id']);
      expect(
        container.read(analyticsSessionDetailsProvider)['app_version'],
        '0.4.1+6',
      );
    },
  );

  test(
    'notification language changes preserve playback and refresh names and actions',
    () async {
      final player = EventPlayer()
        ..playing = true
        ..processingState = ProcessingState.ready;
      final handler = RadioAudioHandler(
        player,
        flightTitle: 'Frequenza',
        flightSubtitle: 'In flight…',
        saveLabel: 'Save',
        removeLabel: 'Remove',
      );
      addTearDown(() async {
        await handler.dispose();
        await player.events.close();
        if (!player.playback.isCompleted) player.playback.complete();
      });
      player.events.add(PlaybackEvent(processingState: ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);
      handler.showStation(fip);
      handler.showControls(flying: false, saved: false);
      handler.updateLocalization(notificationLocalization(AppLanguage.it));
      expect(handler.mediaItem.value!.title, fip.name);
      expect(handler.mediaItem.value!.artist, 'Francia');
      expect(handler.playbackState.value.controls.map((c) => c.label), [
        'Radio precedente',
        'Pausa',
        'Prossima radio',
        'Salva nei preferiti',
      ]);
      expect(handler.playbackState.value.controls[1].action, MediaAction.pause);
      handler.showFlight();
      handler.updateLocalization(notificationLocalization(AppLanguage.en));
      expect(handler.mediaItem.value!.id, 'flight');
      expect(
        handler.mediaItem.value!.artist,
        notificationLocalization(AppLanguage.en).flying,
      );
      expect(player.plays, 0);
      expect(player.stops, 0);
      expect(player.pauses, 0);
    },
  );
}
