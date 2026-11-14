import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../favorites/application/favorites_controller.dart';
import '../data/radio_media_session.dart';
import 'radio_controller.dart';
import 'radio_providers.dart';

part 'radio_notification.g.dart';

/// Joins the notification to the app: its keys drive the radio and the
/// favorites, and its heart follows what the app shows.
@Riverpod(keepAlive: true)
void radioNotification(Ref ref) {
  final RadioMediaSession? session = ref.watch(radioAudioHandlerProvider);
  if (session == null) return;

  void publish() {
    final station = ref.read(radioControllerProvider).station;
    final favorites = ref.read(favoritesProvider).valueOrNull;
    session.showControls(
      saved: station != null && favorites?.contains(station.id) == true,
    );
  }

  ref.listen(radioControllerProvider, (_, _) => publish());
  ref.listen(favoritesProvider, (_, _) => publish());
  publish();

  final commands = session.commands.listen((command) {
    final radio = ref.read(radioControllerProvider.notifier);
    switch (command) {
      case RadioMediaCommand.next:
        unawaited(radio.tuneRandom());
      case RadioMediaCommand.previous:
        unawaited(radio.tuneBack());
      case RadioMediaCommand.toggleFavorite:
        final station = ref.read(radioControllerProvider).station;
        final favorites = ref.read(favoritesProvider);
        if (station != null && favorites.hasValue && !favorites.isLoading) {
          unawaited(ref.read(favoritesProvider.notifier).toggle(station));
        }
    }
  });
  ref.onDispose(commands.cancel);
}
