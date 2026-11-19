import '../../../features/radio/domain/radio_media_localization.dart';
import '../../../l10n/app_translations.g.dart';
import '../../../l10n/locale_keys.g.dart';
import '../domain/app_language.dart';

RadioMediaLocalization notificationLocalization(AppLanguage language) {
  String text(String key) =>
      CodegenLoader.mapLocales[language.name]![key] as String;
  return RadioMediaLocalization(
    language: language,
    flying: text(LocaleKeys.notificationFlying),
    save: text(LocaleKeys.notificationSave),
    remove: text(LocaleKeys.notificationRemove),
    play: text(LocaleKeys.resume),
    pause: text(LocaleKeys.pause),
    next: text(LocaleKeys.notificationNext),
    previous: text(LocaleKeys.notificationPrevious),
    unknownCountry: text(LocaleKeys.unknownCountry),
    channelName: text(LocaleKeys.audioChannelName),
  );
}
