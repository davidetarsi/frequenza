import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/preferences/application/app_preferences_provider.dart';
import 'package:frequenza/app/preferences/data/shared_preferences_repository.dart';
import 'package:frequenza/app/preferences/domain/app_preferences_repository.dart';
import 'package:frequenza/app/theme/app_theme_mode.dart';
import 'package:frequenza/features/analytics/application/analytics_consent.dart';
import 'package:frequenza/features/welcome/application/welcome_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../features/analytics/analytics_test.dart' show FlakyStore;
import '../../support/memory_app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'the repository reads existing values and preserves unrelated data',
    () async {
      SharedPreferences.setMockInitialValues({
        'app.themeMode': 'dark',
        'app.analyticsOn': false,
        'app.welcomeSeen': true,
        'app.welcomeRevision': 2,
        'app.language': 'it',
        'frequenza.favorites.v1': '[]',
      });
      final repository = SharedPreferencesRepository();
      expect(await repository.loadTheme(), PreferredTheme.dark);
      expect(await repository.loadAnalyticsConsent(), isFalse);
      expect(await repository.loadWelcomeRevision(), 2);
      expect(await repository.hasSeenAnyGuide(), isTrue);
      await repository.saveTheme(PreferredTheme.light);
      await repository.saveAnalyticsConsent(true);
      await repository.saveWelcomeRevision(2);
      final restarted = SharedPreferencesRepository();
      expect(await restarted.loadTheme(), PreferredTheme.light);
      expect(await restarted.loadAnalyticsConsent(), isTrue);
      expect(await restarted.loadWelcomeRevision(), 2);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('app.language'), 'it');
      expect(preferences.getString('frequenza.favorites.v1'), '[]');
    },
  );

  test(
    'unknown appearance and absent values have compatible defaults',
    () async {
      SharedPreferences.setMockInitialValues({'app.themeMode': 'future-theme'});
      final repository = SharedPreferencesRepository();
      expect(await repository.loadTheme(), PreferredTheme.system);
      expect(await repository.loadAnalyticsConsent(), isNull);
      expect(await repository.loadWelcomeRevision(), 0);
      expect(await repository.hasSeenAnyGuide(), isFalse);
    },
  );

  test('all preference writes reject a false storage result', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = FlakyStore();
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    final repository = SharedPreferencesRepository();
    await expectLater(
      repository.saveTheme(PreferredTheme.dark),
      throwsStateError,
    );
    await expectLater(repository.saveAnalyticsConsent(false), throwsStateError);
    await expectLater(repository.saveWelcomeRevision(2), throwsStateError);
  });

  ProviderContainer open(MemoryAppPreferences repository) {
    final container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'controllers use the injected repository for reads and writes',
    () async {
      final repository = MemoryAppPreferences()
        ..theme = PreferredTheme.dark
        ..consent = false
        ..legacySeen = true;
      final container = open(repository);
      expect(await container.read(appThemeModeProvider.future), ThemeMode.dark);
      expect(await container.read(analyticsConsentProvider.future), isFalse);
      expect(await container.read(welcomeSeenProvider.future), isFalse);
      expect(
        await container.read(welcomeSeenProvider.notifier).hasSeenAnyGuide(),
        isTrue,
      );
      await container
          .read(appThemeModeProvider.notifier)
          .select(ThemeMode.light);
      await container.read(analyticsConsentProvider.notifier).select(true);
      await container.read(welcomeSeenProvider.notifier).markSeen();
      expect(repository.theme, PreferredTheme.light);
      expect(repository.consent, isTrue);
      expect(repository.revision, WelcomeSeen.currentRevision);
    },
  );

  test('read failures keep statistics off and the radio reachable', () async {
    final container = open(MemoryAppPreferences()..failReads = true);
    await expectLater(
      container.read(appThemeModeProvider.future),
      throwsStateError,
    );
    expect(await container.read(analyticsConsentProvider.future), isFalse);
    expect(await container.read(welcomeSeenProvider.future), isTrue);
    expect(
      await container.read(welcomeSeenProvider.notifier).hasSeenAnyGuide(),
      isTrue,
    );
  });

  test(
    'write failures remain visible and consent stays off until a successful retry',
    () async {
      final repository = MemoryAppPreferences();
      final container = open(repository);
      await container.read(appThemeModeProvider.future);
      await container.read(analyticsConsentProvider.future);
      await container.read(welcomeSeenProvider.future);
      repository.failWrites = true;
      expect(
        await container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.dark),
        isFalse,
      );
      expect(container.read(appThemeModeProvider).hasError, isTrue);
      expect(
        container.read(appThemeModeProvider).valueOrNull,
        ThemeMode.system,
      );
      final savingConsent = container
          .read(analyticsConsentProvider.notifier)
          .select(false);
      expect(analyticsOn(container.read(analyticsConsentProvider)), isFalse);
      expect(await savingConsent, isFalse);
      expect(analyticsOn(container.read(analyticsConsentProvider)), isFalse);
      await container.read(welcomeSeenProvider.notifier).markSeen();
      expect(container.read(welcomeSeenProvider).valueOrNull, isTrue);
      expect(container.read(welcomeSeenProvider).hasError, isTrue);
      repository.failWrites = false;
      expect(
        await container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.dark),
        isTrue,
      );
      expect(
        await container.read(analyticsConsentProvider.notifier).select(true),
        isTrue,
      );
      expect(analyticsOn(container.read(analyticsConsentProvider)), isTrue);
      expect(repository.theme, PreferredTheme.dark);
      expect(repository.consent, isTrue);
    },
  );
}
