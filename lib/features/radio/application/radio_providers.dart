import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/just_audio_service.dart';
import '../data/radio_audio_handler.dart';
import '../data/radio_browser_repository.dart';
import '../domain/radio_audio_service.dart';
import '../domain/radio_repository.dart';

part 'radio_providers.g.dart';

@Riverpod(keepAlive: true)
RadioRepository radioRepository(Ref ref) => RadioBrowserRepository();

/// The system media session, overridden at startup by `bootstrap`.
@Riverpod(keepAlive: true)
RadioAudioHandler? radioAudioHandler(Ref ref) => null;

@Riverpod(keepAlive: true)
RadioAudioService radioAudioService(Ref ref) {
  final handler = ref.watch(radioAudioHandlerProvider);
  final service = JustAudioService(
    player: handler?.player,
    mediaSession: handler,
  );
  ref.onDispose(service.dispose);
  return service;
}
