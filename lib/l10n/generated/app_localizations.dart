import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('it'),
    Locale('en'),
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Una nuova partenza'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In it, this message translates to:
  /// **'Una piccola base, pronta per la tua prossima idea.'**
  String get welcomeBody;

  /// No description provided for @loading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa non ha funzionato'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile caricare i contenuti. Puoi riprovare.'**
  String get errorBody;

  /// No description provided for @emptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Ancora nessun elemento'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In it, this message translates to:
  /// **'Quando ci saranno contenuti, li troverai qui.'**
  String get emptyBody;

  /// No description provided for @reload.
  ///
  /// In it, this message translates to:
  /// **'Ricarica'**
  String get reload;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @favorites.
  ///
  /// In it, this message translates to:
  /// **'Preferiti'**
  String get favorites;

  /// No description provided for @favoritesTitle.
  ///
  /// In it, this message translates to:
  /// **'Le tue frequenze'**
  String get favoritesTitle;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Posti in cui tornare.'**
  String get favoritesSubtitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Tocca Salva sulla radio per aggiungere la tua prima frequenza.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesError.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile aggiornare i preferiti. Riprova.'**
  String get favoritesError;

  /// No description provided for @savedOnDevice.
  ///
  /// In it, this message translates to:
  /// **'Salvate su questo dispositivo'**
  String get savedOnDevice;

  /// No description provided for @removeFavorite.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dai preferiti'**
  String get removeFavorite;

  /// No description provided for @tapToListen.
  ///
  /// In it, this message translates to:
  /// **'Tocca per ascoltare'**
  String get tapToListen;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @playing.
  ///
  /// In it, this message translates to:
  /// **'In ascolto'**
  String get playing;

  /// No description provided for @paused.
  ///
  /// In it, this message translates to:
  /// **'In pausa'**
  String get paused;

  /// No description provided for @ready.
  ///
  /// In it, this message translates to:
  /// **'Pronta a partire'**
  String get ready;

  /// No description provided for @searching.
  ///
  /// In it, this message translates to:
  /// **'Ricerca'**
  String get searching;

  /// No description provided for @connecting.
  ///
  /// In it, this message translates to:
  /// **'Connessione alla radio'**
  String get connecting;

  /// No description provided for @stationError.
  ///
  /// In it, this message translates to:
  /// **'Stazione non raggiungibile'**
  String get stationError;

  /// No description provided for @exploring.
  ///
  /// In it, this message translates to:
  /// **'Esplorando…'**
  String get exploring;

  /// No description provided for @whereTo.
  ///
  /// In it, this message translates to:
  /// **'Dove andiamo?'**
  String get whereTo;

  /// No description provided for @findingPlace.
  ///
  /// In it, this message translates to:
  /// **'Alla ricerca di un luogo'**
  String get findingPlace;

  /// No description provided for @worldAwaits.
  ///
  /// In it, this message translates to:
  /// **'Il mondo ti aspetta'**
  String get worldAwaits;

  /// No description provided for @tuning.
  ///
  /// In it, this message translates to:
  /// **'Sintonizzazione…'**
  String get tuning;

  /// No description provided for @powerOn.
  ///
  /// In it, this message translates to:
  /// **'Accendi'**
  String get powerOn;

  /// No description provided for @tune.
  ///
  /// In it, this message translates to:
  /// **'Sintonizza'**
  String get tune;

  /// No description provided for @tuneAccessibility.
  ///
  /// In it, this message translates to:
  /// **'Sintonizza una nuova stazione'**
  String get tuneAccessibility;

  /// No description provided for @tagline.
  ///
  /// In it, this message translates to:
  /// **'Il mondo, in ascolto.'**
  String get tagline;

  /// No description provided for @nextStop.
  ///
  /// In it, this message translates to:
  /// **'Prossima fermata: ovunque'**
  String get nextStop;

  /// No description provided for @firstTrip.
  ///
  /// In it, this message translates to:
  /// **'Un tocco per partire'**
  String get firstTrip;

  /// No description provided for @knobHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca la manopola per cambiare radio'**
  String get knobHint;

  /// No description provided for @pause.
  ///
  /// In it, this message translates to:
  /// **'Pausa'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In it, this message translates to:
  /// **'Riprendi'**
  String get resume;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In it, this message translates to:
  /// **'Salvata'**
  String get saved;

  /// No description provided for @stationErrorHint.
  ///
  /// In it, this message translates to:
  /// **'Questa frequenza non risponde. Tocca la manopola per provarne un’altra.'**
  String get stationErrorHint;

  /// No description provided for @pauseHint.
  ///
  /// In it, this message translates to:
  /// **'La tua fermata è ancora qui. Riprendi quando vuoi.'**
  String get pauseHint;

  /// No description provided for @travelHint.
  ///
  /// In it, this message translates to:
  /// **'Lasciati sorprendere dalla prossima radio.'**
  String get travelHint;

  /// No description provided for @footer.
  ///
  /// In it, this message translates to:
  /// **'WEB RADIO · SENZA CONFINI'**
  String get footer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
