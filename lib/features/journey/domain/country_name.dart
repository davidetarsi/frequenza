import '../../../app/localization/domain/app_language.dart';
import 'atlas/world_atlas.g.dart';

/// Names supplied by the offline atlas; unknown codes keep external names.
String localizedCountryName(
  String code,
  AppLanguage language, {
  String? fallback,
}) {
  final names = countryNames[code.trim().toUpperCase()];
  if (names == null) return (fallback?.isNotEmpty ?? false) ? fallback! : code;
  return language == AppLanguage.it ? names.$1 : names.$2;
}
