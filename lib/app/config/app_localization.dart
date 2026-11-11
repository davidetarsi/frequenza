import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_translations.g.dart';

class AppLocalization extends StatelessWidget {
  const AppLocalization({super.key, required this.child, this.startLocale});

  static const english = Locale('en');
  static const italian = Locale('it');
  static const locales = [english, italian];

  final Widget child;
  final Locale? startLocale;

  @override
  Widget build(BuildContext context) => EasyLocalization(
    supportedLocales: locales,
    fallbackLocale: english,
    startLocale: startLocale,
    saveLocale: startLocale == null,
    path: 'assets/translations',
    assetLoader: const CodegenLoader(),
    child: child,
  );
}
