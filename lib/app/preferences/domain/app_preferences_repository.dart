import '../../localization/domain/app_language.dart';

/// The persisted appearance, independent of Flutter's ThemeMode.
enum PreferredTheme { system, light, dark }

/// App-level preferences. Implementations preserve stored keys and throw when
/// a write fails; application controllers decide the fallback policy.
abstract interface class AppPreferencesRepository {
  Future<AppLanguage?> loadLanguage();
  Future<void> saveLanguage(AppLanguage language);
  Future<PreferredTheme> loadTheme();
  Future<void> saveTheme(PreferredTheme theme);
  Future<bool?> loadAnalyticsConsent();
  Future<void> saveAnalyticsConsent(bool enabled);
  Future<int> loadWelcomeRevision();
  Future<bool> hasSeenAnyGuide();
  Future<void> saveWelcomeRevision(int revision);
}
