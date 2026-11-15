import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../favorites/application/favorites_controller.dart';
import '../data/radio_media_session.dart';
import '../domain/radio_session.dart';
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
    final radio = ref.read(radioControllerProvider);
    final favorites = ref.read(favoritesProvider).valueOrNull;
    session.showControls(
      flying: radio is Flying,
      saved: radio is OnAir && favorites?.contains(radio.station.id) == true,
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
        final radio = ref.read(radioControllerProvider);
        final favorites = ref.read(favoritesProvider);
        if (radio is OnAir && favorites.hasValue && !favorites.isLoading) {
          unawaited(ref.read(favoritesProvider.notifier).toggle(radio.station));
        }
    }
  });
  ref.onDispose(commands.cancel);
}
