import '../domain/radio_station.dart';

/// What the notification's keys ask of the radio.
enum RadioMediaCommand { next, previous, toggleFavorite }

/// The system media session: notification, lock screen and media buttons.
abstract interface class RadioMediaSession {
  void showStation(RadioStation station);

  /// A placeholder that never reveals the destination.
  void showFlight();

  /// The keys of a landed station, with the heart filled when it is saved.
  /// After [showStation] they wait for this call, so they never show the
  /// flight's stale state.
  void showControls({required bool saved});

  /// Back, next and heart pressed in the notification.
  Stream<RadioMediaCommand> get commands;
}
