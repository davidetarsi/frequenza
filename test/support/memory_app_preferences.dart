import 'package:frequenza/app/localization/domain/app_language.dart';
import 'dart:async';

import 'package:frequenza/app/preferences/domain/app_preferences_repository.dart';

class MemoryAppPreferences implements AppPreferencesRepository {
  AppLanguage? language;
  PreferredTheme theme = PreferredTheme.system;
  bool? consent;
  int revision = 0;
  bool legacySeen = false;
  bool failReads = false;
  bool failWrites = false;
  int welcomeWrites = 0;
  Completer<void>? pendingWelcome;

  void _read() {
    if (failReads) throw StateError('Storage unreadable');
  }

  void _write() {
    if (failWrites) throw StateError('Storage unwritable');
  }

  @override
  Future<AppLanguage?> loadLanguage() async {
    _read();
    return language;
  }

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    _write();
    this.language = language;
  }

  @override
  Future<PreferredTheme> loadTheme() async {
    _read();
    return theme;
  }

  @override
  Future<void> saveTheme(PreferredTheme theme) async {
    _write();
    this.theme = theme;
  }

  @override
  Future<bool?> loadAnalyticsConsent() async {
    _read();
    return consent;
  }

  @override
  Future<void> saveAnalyticsConsent(bool enabled) async {
    _write();
    consent = enabled;
  }

  @override
  Future<int> loadWelcomeRevision() async {
    _read();
    return revision;
  }

  @override
  Future<bool> hasSeenAnyGuide() async {
    _read();
    return legacySeen || revision > 0;
  }

  @override
  Future<void> saveWelcomeRevision(int revision) async {
    welcomeWrites++;
    await pendingWelcome?.future;
    _write();
    this.revision = revision;
    legacySeen = true;
  }
}
