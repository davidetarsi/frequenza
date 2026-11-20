import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/widgets/app_snack_bar.dart';
import '../../radio/domain/radio_station.dart';
import '../application/favorites_controller.dart';

/// All in-app favorite hearts share the same removal feedback and undo.
Future<void> toggleFavorite(
  BuildContext context,
  WidgetRef ref,
  RadioStation station,
) async {
  final before = ref.read(favoritesProvider);
  if (before.isLoading || !before.hasValue) return;
  final index = before.requireValue.stations.indexWhere(
    (s) => s.id == station.id,
  );
  final removing = index >= 0;
  final favorites = ref.read(favoritesProvider.notifier);
  // Capture the sheet's messenger before removing its row, which may unmount.
  final messenger = ScaffoldMessenger.of(context);
  final owner = ref.context;
  final message = LocaleKeys.favoriteRemoved.tr(context: context);
  final undo = LocaleKeys.undo.tr(context: context);
  final error = LocaleKeys.favoritesError.tr(context: context);
  await favorites.toggle(station);
  if (!owner.mounted || !messenger.mounted || !removing) return;
  final after = ref.read(favoritesProvider);
  if (after.isLoading ||
      after.hasError ||
      after.valueOrNull?.contains(station.id) != false) {
    return;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      appSnackBar(
        message: message,
        action: SnackBarAction(
          label: undo,
          onPressed: () async {
            await favorites.restore(station, index);
            if (!owner.mounted || !messenger.mounted) return;
            if (ref.read(favoritesProvider).hasError) {
              messenger
                ..clearSnackBars()
                ..showSnackBar(appSnackBar(message: error));
            }
          },
        ),
      ),
    );
}
