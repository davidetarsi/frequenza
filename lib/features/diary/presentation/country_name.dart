import 'package:flutter/widgets.dart';

import '../../journey/data/world_atlas.g.dart';

/// The name of the country [code] in the app's language, from the atlas;
/// [fallback] (Radio Browser's name) when the atlas does not know it.
String countryName(BuildContext context, String code, {String? fallback}) {
  final names = countryNames[code];
  if (names == null) return fallback ?? code;
  return Localizations.localeOf(context).languageCode == 'it'
      ? names.$1
      : names.$2;
}
