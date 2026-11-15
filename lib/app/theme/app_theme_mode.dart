import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/latest_save.dart';

part 'app_theme_mode.g.dart';

@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  static const _key = 'app.themeMode';
  final _save = LatestSave();

  @override
  Future<ThemeMode> build() async {
    _save.start(ref);
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<bool> select(ThemeMode mode) async {
    if (state.isLoading || state.valueOrNull == mode) return true;
    final previous = state.valueOrNull ?? ThemeMode.system;
    final result = await _save.run(
      shown: AsyncData(previous),
      emit: (value) => state = value,
      action: () async {
        final preferences = await SharedPreferences.getInstance();
        if (!await preferences.setString(_key, mode.name)) {
          throw StateError('Theme preference could not be saved');
        }
        return mode;
      },
    );
    return !result.hasError;
  }
}
