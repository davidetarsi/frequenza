/// Languages supported by the app, independent of Flutter's Locale.
enum AppLanguage {
  en,
  it;

  static AppLanguage? fromTag(String? tag) =>
      switch (tag?.toLowerCase().split(RegExp('[-_]')).first) {
        'it' => AppLanguage.it,
        'en' => AppLanguage.en,
        _ => null,
      };

  static AppLanguage device(String tag) => fromTag(tag) ?? AppLanguage.en;
}
