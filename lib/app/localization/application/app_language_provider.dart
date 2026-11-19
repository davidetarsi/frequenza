import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../preferences/application/app_preferences_provider.dart';
import '../../preferences/domain/app_preferences_repository.dart';
import '../../state/latest_save.dart';
import '../../state/serial_tasks.dart';
import '../domain/app_language.dart';

part 'app_language_provider.g.dart';

@Riverpod(keepAlive: true)
AppLanguage initialAppLanguage(Ref ref) => AppLanguage.en;

/// The language actually displayed, also used by non-widget surfaces.
@Riverpod(keepAlive: true)
class ActiveAppLanguage extends _$ActiveAppLanguage {
  @override
  AppLanguage build() => ref.watch(initialAppLanguageProvider);

  void activate(AppLanguage language) {
    if (state != language) state = language;
  }
}

/// The explicit choice; null means the initial device language is used.
@Riverpod(keepAlive: true)
class LanguagePreference extends _$LanguagePreference {
  final _tasks = SerialTasks();
  final _save = LatestSave();

  @override
  Future<AppLanguage?> build() {
    final repository = ref.watch(appPreferencesRepositoryProvider);
    _tasks.start(ref);
    _save.start(ref);
    return _tasks.settled.then((_) async {
      try {
        return await repository.loadLanguage();
      } catch (_) {
        return null;
      }
    });
  }

  Future<bool> select(AppLanguage language) async {
    // An intent arriving before the initial read must not race that read.
    try {
      if (!state.hasValue) await future;
    } catch (_) {
      return false;
    }
    return await _tasks.run<bool>((current) async {
          if (!state.hasError && state.valueOrNull == language) return true;
          final repository = ref.read(appPreferencesRepositoryProvider);
          final result = await _save.run<AppLanguage?>(
            shown: state,
            emit: (value) => state = value,
            action: () async {
              await repository.saveLanguage(language);
              return language;
            },
          );
          return current() && !result.hasError;
        }) ??
        false;
  }
}

/// Same startup policy for the UI, notification and analytics context.
Future<AppLanguage> resolveInitialLanguage(
  AppPreferencesRepository repository,
  String deviceCode,
) async {
  try {
    return await repository.loadLanguage() ?? AppLanguage.device(deviceCode);
  } catch (_) {
    return AppLanguage.device(deviceCode);
  }
}
