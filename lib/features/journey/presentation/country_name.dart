import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../app/localization/domain/app_language.dart';
import '../../../l10n/locale_keys.g.dart';
import '../domain/country_name.dart';

String countryName(BuildContext context, String code, {String? fallback}) {
  if (code.isEmpty && (fallback?.isEmpty ?? true)) {
    return LocaleKeys.unknownCountry.tr(context: context);
  }
  return localizedCountryName(
    code,
    AppLanguage.device(context.locale.languageCode),
    fallback: fallback,
  );
}
