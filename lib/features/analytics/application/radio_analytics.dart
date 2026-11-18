import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../radio/application/radio_controller.dart';
import '../domain/radio_events.dart';
import 'analytics_providers.dart';

part 'radio_analytics.g.dart';

/// Watches the radio from outside: the radio does not know about the
/// statistics.
@Riverpod(keepAlive: true)
void radioAnalytics(Ref ref) {
  ref.listen(radioControllerProvider, (before, after) {
    if (before == null) return;
    final analytics = ref.read(analyticsProvider);
    for (final event in radioEvents(before, after)) {
      analytics.track(event);
    }
  });
}
