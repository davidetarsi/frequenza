import '../domain/radio_station.dart';

/// What the notification's keys ask of the radio.
enum RadioMediaCommand { next, previous, toggleFavorite }

/// The system media session: notification, lock screen and media buttons.
abstract interface class RadioMediaSession {
  void showStation(RadioStation station);

  /// A placeholder that never reveals the destination. Whether the radio
  /// flies is said only by [showControls].
  void showFlight();

  /// The journey as the app sees it. While [flying] the notification stays
  /// up as «connecting» and its keys do nothing; once landed it shows the
  /// station's keys, the heart filled when the station is [saved].
  void showControls({required bool flying, required bool saved});

  /// Back, next and heart pressed in the notification.
  Stream<RadioMediaCommand> get commands;
}
