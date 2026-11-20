import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/app/localization/application/app_language_provider.dart';
import 'package:frequenza/app/localization/domain/app_language.dart';
import 'package:frequenza/app/preferences/application/app_preferences_provider.dart';
import 'package:frequenza/app/preferences/data/shared_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/memory_app_preferences.dart';

class HeldLanguage extends MemoryAppPreferences {
  final started = Completer<void>();
  final release = Completer<void>();
  @override
  Future<void> saveLanguage(AppLanguage language) async {
    if (!started.isCompleted) {
      started.complete();
      await release.future;
    }
    await super.saveLanguage(language);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final tag in ['it', 'it_IT', 'it-IT']) {
    test(
      'existing saved locale $tag takes priority over device English',
      () async {
        SharedPreferences.setMockInitialValues({
          'locale': tag,
          'app.welcomeRevision': 2,
        });
        final repository = SharedPreferencesRepository();
        expect(await resolveInitialLanguage(repository, 'en'), AppLanguage.it);
        await repository.saveLanguage(AppLanguage.en);
        expect(
          await SharedPreferencesRepository().loadLanguage(),
          AppLanguage.en,
        );
        expect(
          (await SharedPreferences.getInstance()).getInt('app.welcomeRevision'),
          2,
        );
      },
    );
  }
  test(
    'missing, unsupported and unreadable language use the device fallback',
    () async {
      SharedPreferences.setMockInitialValues({'locale': 'fr'});
      expect(
        await resolveInitialLanguage(SharedPreferencesRepository(), 'it'),
        AppLanguage.it,
      );
      expect(
        await resolveInitialLanguage(MemoryAppPreferences(), 'fr'),
        AppLanguage.en,
      );
      expect(
        await resolveInitialLanguage(
          MemoryAppPreferences()..failReads = true,
          'it',
        ),
        AppLanguage.it,
      );
    },
  );
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
    'rapid choices are persisted in order, keeping the last choice',
    () async {
      final repository = HeldLanguage();
      final container = open(repository);
      await container.read(languagePreferenceProvider.future);
      final controller = container.read(languagePreferenceProvider.notifier);
      final first = controller.select(AppLanguage.it);
      await repository.started.future;
      final last = controller.select(AppLanguage.en);
      repository.release.complete();
      expect(await first, isTrue);
      expect(await last, isTrue);
      expect(repository.language, AppLanguage.en);
      expect(
        container.read(languagePreferenceProvider).requireValue,
        AppLanguage.en,
      );
    },
  );
  test(
    'failed persistence keeps the previous language and allows retry',
    () async {
      final repository = MemoryAppPreferences()..language = AppLanguage.en;
      final container = open(repository);
      await container.read(languagePreferenceProvider.future);
      repository.failWrites = true;
      expect(
        await container
            .read(languagePreferenceProvider.notifier)
            .select(AppLanguage.it),
        isFalse,
      );
      expect(container.read(languagePreferenceProvider).hasError, isTrue);
      expect(
        container.read(languagePreferenceProvider).valueOrNull,
        AppLanguage.en,
      );
      repository.failWrites = false;
      expect(
        await container
            .read(languagePreferenceProvider.notifier)
            .select(AppLanguage.it),
        isTrue,
      );
      expect(repository.language, AppLanguage.it);
    },
  );
}
