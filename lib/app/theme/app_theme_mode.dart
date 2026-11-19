import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../preferences/application/app_preferences_provider.dart';
import '../preferences/domain/app_preferences_repository.dart';
import '../state/latest_save.dart';

part 'app_theme_mode.g.dart';

@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  final _save = LatestSave();

  @override
  Future<ThemeMode> build() async {
    _save.start(ref);
    final repository = ref.watch(appPreferencesRepositoryProvider);
    return switch (await repository.loadTheme()) {
      PreferredTheme.system => ThemeMode.system,
      PreferredTheme.light => ThemeMode.light,
      PreferredTheme.dark => ThemeMode.dark,
    };
  }

  Future<bool> select(ThemeMode mode) async {
    if (state.isLoading || state.valueOrNull == mode) return true;
    final previous = state.valueOrNull ?? ThemeMode.system;
    final repository = ref.read(appPreferencesRepositoryProvider);
    final result = await _save.run(
      shown: AsyncData(previous),
      emit: (value) => state = value,
      action: () async {
        await repository.saveTheme(switch (mode) {
          ThemeMode.system => PreferredTheme.system,
          ThemeMode.light => PreferredTheme.light,
          ThemeMode.dark => PreferredTheme.dark,
        });
        return mode;
      },
    );
    return !result.hasError;
  }
}
