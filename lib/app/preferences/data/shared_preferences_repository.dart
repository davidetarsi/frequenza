import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_preferences_repository.dart';
import '../../localization/domain/app_language.dart';

class SharedPreferencesRepository implements AppPreferencesRepository {
  // Keep EasyLocalization's existing key when moving persistence behind the repository.
  static const _languageKey = 'locale';
  static const _themeKey = 'app.themeMode';
  static const _analyticsKey = 'app.analyticsOn';
  static const _legacyWelcomeKey = 'app.welcomeSeen';
  static const _welcomeRevisionKey = 'app.welcomeRevision';

  @override
  Future<AppLanguage?> loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    return AppLanguage.fromTag(preferences.getString(_languageKey));
  }

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    final preferences = await SharedPreferences.getInstance();
    _requireSaved(await preferences.setString(_languageKey, language.name));
  }

  @override
  Future<PreferredTheme> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_themeKey);
    return PreferredTheme.values.firstWhere(
      (theme) => theme.name == saved,
      orElse: () => PreferredTheme.system,
    );
  }

  @override
  Future<void> saveTheme(PreferredTheme theme) async {
    final preferences = await SharedPreferences.getInstance();
    _requireSaved(await preferences.setString(_themeKey, theme.name));
  }

  @override
  Future<bool?> loadAnalyticsConsent() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_analyticsKey);
  }

  @override
  Future<void> saveAnalyticsConsent(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    _requireSaved(await preferences.setBool(_analyticsKey, enabled));
  }

  @override
  Future<int> loadWelcomeRevision() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_welcomeRevisionKey) ?? 0;
  }

  @override
  Future<bool> hasSeenAnyGuide() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getBool(_legacyWelcomeKey) ?? false) ||
        (preferences.getInt(_welcomeRevisionKey) ?? 0) > 0;
  }

  @override
  Future<void> saveWelcomeRevision(int revision) async {
    final preferences = await SharedPreferences.getInstance();
    _requireSaved(await preferences.setInt(_welcomeRevisionKey, revision));
    _requireSaved(await preferences.setBool(_legacyWelcomeKey, true));
  }

  void _requireSaved(bool saved) {
    if (!saved) throw StateError('App preference could not be saved');
  }
}
