import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/preferences/application/app_preferences_provider.dart';
import 'package:frequenza/features/analytics/application/analytics_providers.dart';
import 'package:frequenza/features/radio/application/radio_controller.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_session.dart';
import 'package:frequenza/features/welcome/application/welcome_controller.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:frequenza/features/welcome/domain/welcome_session.dart';

import '../../support/memory_app_preferences.dart';
import '../analytics/recording_analytics.dart';

class TourRadio extends RadioController {
  int tunes = 0;
  @override
  RadioSession build() => const RadioSession.off(Journey());
  @override
  Future<void> tuneRandom({Set<String>? countries}) async {
    tunes++;
  }
}

Future<void> flushEffects() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late MemoryAppPreferences preferences;
  late RecordingAnalytics analytics;
  late ProviderContainer container;
  late ProviderSubscription<WelcomeSession> subscription;

  setUp(() async {
    preferences = MemoryAppPreferences();
    analytics = RecordingAnalytics();
    container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(preferences),
        analyticsProvider.overrideWithValue(analytics),
        radioControllerProvider.overrideWith(TourRadio.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(welcomeSeenProvider.future);
    subscription = container.listen(welcomeControllerProvider, (_, _) {});
  });

  WelcomeController controller() =>
      container.read(welcomeControllerProvider.notifier);
  WelcomeSession session() => container.read(welcomeControllerProvider);

  test('only the first advance starts a flight', () async {
    controller().advance();
    controller().advance();
    expect(session(), const WelcomeSession.diary());
    expect(
      (container.read(radioControllerProvider.notifier) as TourRadio).tunes,
      1,
    );
    expect(preferences.welcomeWrites, 0);
    expect(analytics.events, isEmpty);
  });

  test(
    'repeated taps and back during persistence complete only once',
    () async {
      preferences.pendingWelcome = Completer<void>();
      controller().advance();
      controller().advance();
      controller().advance();
      controller().advance();
      controller().dismiss();
      expect(session(), const WelcomeSession.closing(WelcomeStep.diary));
      expect(preferences.welcomeWrites, 1);
      expect(container.read(welcomeSeenProvider).isLoading, isTrue);
      expect(container.read(welcomeSeenProvider).valueOrNull, isTrue);
      preferences.pendingWelcome!.complete();
      await flushEffects();
      expect(session(), const WelcomeSession.completed(WelcomeStep.diary));
      expect(preferences.revision, WelcomeSeen.currentRevision);
      expect(analytics.names, ['welcome_completed']);
      controller().advance();
      controller().dismiss();
      expect(preferences.welcomeWrites, 1);
    },
  );

  test('back completes without starting audio', () async {
    controller().dismiss();
    await flushEffects();
    expect(session(), const WelcomeSession.completed(WelcomeStep.radio));
    expect(
      (container.read(radioControllerProvider.notifier) as TourRadio).tunes,
      0,
    );
  });

  test('failed persistence still allows leaving the guide', () async {
    preferences.failWrites = true;
    controller().dismiss();
    await flushEffects();
    expect(session(), const WelcomeSession.completed(WelcomeStep.radio));
    expect(container.read(welcomeSeenProvider).hasError, isTrue);
    expect(container.read(welcomeSeenProvider).valueOrNull, isTrue);
    expect(preferences.revision, 0);
  });

  test('a disposed guide does not receive late completion', () async {
    preferences.pendingWelcome = Completer<void>();
    controller().dismiss();
    subscription.close();
    await flushEffects();
    // A fresh presentation must start a fresh guide, not inherit a late exit.
    subscription = container.listen(welcomeControllerProvider, (_, _) {});
    expect(session(), const WelcomeSession.radio());
    preferences.pendingWelcome!.complete();
    await flushEffects();
    expect(session(), const WelcomeSession.radio());
    expect(preferences.welcomeWrites, 1);
  });
}
