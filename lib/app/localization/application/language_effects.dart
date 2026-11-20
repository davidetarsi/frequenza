import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/analytics/application/analytics_providers.dart';
import '../../../features/radio/application/radio_providers.dart';
import '../../config/notification_config.dart';
import '../../platform/application/app_platform_provider.dart';
import 'app_language_provider.dart';
import 'notification_localization.dart';

part 'language_effects.g.dart';

/// Updates existing surfaces; neither the player nor the analytics launch ID
/// is restarted when the displayed app language changes.
@Riverpod(keepAlive: true)
void appLanguageEffects(Ref ref) {
  final session = ref.watch(radioMediaSessionProvider);
  void notification() {
    if (session == null) return;
    final labels = notificationLocalization(
      ref.read(activeAppLanguageProvider),
    );
    session.updateLocalization(labels);
    unawaited(
      ref
          .read(appPlatformProvider)
          .updateNotificationChannel(
            radioNotificationChannelId,
            labels.channelName,
          ),
    );
  }

  notification();
  ref.listen(activeAppLanguageProvider, (_, language) {
    notification();
    final details = ref.read(analyticsSessionDetailsProvider);
    if (details.isNotEmpty && details['locale'] != language.name) {
      ref.read(analyticsSessionDetailsProvider.notifier).describe({
        ...details,
        'locale': language.name,
      });
    }
  });
}
