// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get welcomeTitle => 'Una nuova partenza';

  @override
  String get welcomeBody =>
      'Una piccola base, pronta per la tua prossima idea.';

  @override
  String get loading => 'Caricamento';

  @override
  String get errorTitle => 'Qualcosa non ha funzionato';

  @override
  String get errorBody =>
      'Non è stato possibile caricare i contenuti. Puoi riprovare.';

  @override
  String get emptyTitle => 'Ancora nessun elemento';

  @override
  String get emptyBody => 'Quando ci saranno contenuti, li troverai qui.';

  @override
  String get reload => 'Ricarica';

  @override
  String get retry => 'Riprova';
}
