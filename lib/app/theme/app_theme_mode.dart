import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_mode.g.dart';

@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  static const _key = 'app.themeMode';
  Object? _generation;

  @override
  Future<ThemeMode> build() async {
    _generation = Object();
    ref.onDispose(() => _generation = null);
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<bool> select(ThemeMode mode) async {
    if (state.isLoading || state.valueOrNull == mode) return true;
    final generation = _generation;
    final previous = state.valueOrNull ?? ThemeMode.system;
    state = const AsyncLoading<ThemeMode>().copyWithPrevious(
      AsyncData(previous),
    );
    final result = await AsyncValue.guard(() async {
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setString(_key, mode.name)) {
        throw StateError('Theme preference could not be saved');
      }
      return mode;
    });
    if (_generation == generation) {
      state = result.copyWithPrevious(AsyncData(previous));
    }
    return !result.hasError;
  }
}
