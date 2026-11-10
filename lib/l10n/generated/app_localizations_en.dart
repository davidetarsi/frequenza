// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'A fresh start';

  @override
  String get welcomeBody => 'A small foundation, ready for your next idea.';

  @override
  String get loading => 'Loading';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorBody => 'The content could not be loaded. You can try again.';

  @override
  String get emptyTitle => 'No items yet';

  @override
  String get emptyBody => 'Your content will appear here when it is available.';

  @override
  String get reload => 'Reload';

  @override
  String get retry => 'Try again';
}
