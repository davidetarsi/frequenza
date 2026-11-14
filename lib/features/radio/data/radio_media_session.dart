import '../domain/radio_station.dart';

/// What the notification's keys ask of the radio.
enum RadioMediaCommand { next, previous, toggleFavorite }

/// The system media session: notification, lock screen and media buttons.
abstract interface class RadioMediaSession {
  void showStation(RadioStation station);

  /// A placeholder that never reveals the destination.
  void showFlight();

  /// The keys that depend on the journey: back only with stations left
  /// behind, the heart filled when the station is saved.
  void showControls({required bool canGoBack, required bool saved});

  /// Back, next and heart pressed in the notification.
  Stream<RadioMediaCommand> get commands;
}
