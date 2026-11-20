import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/links/app_version.dart';
import '../data/just_audio_service.dart';
import '../data/radio_browser_repository.dart';
import '../domain/radio_audio_service.dart';
import '../domain/radio_media_session.dart';
import '../domain/radio_repository.dart';
import 'flight_timing.dart';

part 'radio_providers.g.dart';

@Riverpod(keepAlive: true)
RadioRepository radioRepository(Ref ref) {
  final identity = ref
      .read(appVersionProvider.future)
      .then((version) {
        final valid = RegExp(r'^[a-zA-Z0-9.+_-]{1,80}$').hasMatch(version);
        return valid
            ? 'Frequenza/$version (it.davidetarsi.frequenza)'
            : 'Frequenza (it.davidetarsi.frequenza)';
      })
      .catchError((Object _) => 'Frequenza (it.davidetarsi.frequenza)');
  final repository = RadioBrowserRepository(resolvedUserAgent: identity);
  ref.onDispose(repository.close);
  return repository;
}

@Riverpod(keepAlive: true)
FlightTiming flightTiming(Ref ref) => const FlightTiming();

/// The system media session, overridden at startup by `bootstrap`.
@Riverpod(keepAlive: true)
RadioMediaSession? radioMediaSession(Ref ref) => null;

@Riverpod(keepAlive: true)
RadioAudioService radioAudioService(Ref ref) {
  final session = ref.watch(radioMediaSessionProvider);
  final service = JustAudioService(mediaSession: session);
  ref.onDispose(service.dispose);
  return service;
}
