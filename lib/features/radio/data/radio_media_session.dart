import '../domain/radio_station.dart';

/// The system media session: notification, lock screen and media buttons.
abstract interface class RadioMediaSession {
  void showStation(RadioStation station);

  /// A placeholder that never reveals the destination.
  void showFlight();
}
