import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/just_audio_service.dart';
import '../data/radio_browser_repository.dart';
import '../domain/radio_player_state.dart';
import '../domain/radio_repository.dart';
import 'radio_audio_service.dart';
import 'radio_controller.dart';

final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioBrowserRepository();
});

final radioAudioServiceProvider = Provider<RadioAudioService>((ref) {
  final service = JustAudioService();
  ref.onDispose(service.dispose);
  return service;
});

final radioControllerProvider =
    StateNotifierProvider<RadioController, RadioPlayerState>((ref) {
      final repository = ref.watch(radioRepositoryProvider);
      final audioService = ref.watch(radioAudioServiceProvider);

      return RadioController(
        repository: repository,
        audioService: audioService,
      );
    });
