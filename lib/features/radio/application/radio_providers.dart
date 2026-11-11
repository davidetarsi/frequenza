import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/just_audio_service.dart';
import '../data/radio_browser_repository.dart';
import '../domain/radio_audio_service.dart';
import '../domain/radio_repository.dart';

part 'radio_providers.g.dart';

@Riverpod(keepAlive: true)
RadioRepository radioRepository(Ref ref) => RadioBrowserRepository();

@Riverpod(keepAlive: true)
RadioAudioService radioAudioService(Ref ref) {
  final service = JustAudioService();
  ref.onDispose(service.dispose);
  return service;
}
