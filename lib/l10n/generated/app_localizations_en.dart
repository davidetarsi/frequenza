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

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesTitle => 'Your frequencies';

  @override
  String get favoritesSubtitle => 'Places to return to.';

  @override
  String get favoritesEmpty =>
      'Tap Save on the radio to add your first station.';

  @override
  String get favoritesError =>
      'Your favorites could not be updated. Try again.';

  @override
  String get savedOnDevice => 'Saved on this device';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get tapToListen => 'Tap to listen';

  @override
  String get close => 'Close';

  @override
  String get playing => 'Listening';

  @override
  String get paused => 'Paused';

  @override
  String get ready => 'Ready to go';

  @override
  String get searching => 'Searching';

  @override
  String get connecting => 'Connecting to the station';

  @override
  String get stationError => 'Station unavailable';

  @override
  String get exploring => 'Exploring…';

  @override
  String get whereTo => 'Where shall we go?';

  @override
  String get findingPlace => 'Looking for a place';

  @override
  String get worldAwaits => 'The world awaits';

  @override
  String get tuning => 'Tuning…';

  @override
  String get powerOn => 'Power on';

  @override
  String get tune => 'Tune';

  @override
  String get tuneAccessibility => 'Tune to a new station';

  @override
  String get tagline => 'The world, on air.';

  @override
  String get nextStop => 'Next stop: anywhere';

  @override
  String get firstTrip => 'One tap to get started';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get stationErrorHint =>
      'This station is not responding. Tap the dial to try another.';

  @override
  String get pauseHint => 'Your stop is still here. Resume when you are ready.';

  @override
  String get travelHint => 'Let the next station surprise you.';

  @override
  String get footer => 'WEB RADIO · WITHOUT BORDERS';
}
