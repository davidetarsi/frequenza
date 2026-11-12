import '../domain/radio_station.dart';

/// The system media session: notification, lock screen and media buttons.
abstract interface class RadioMediaSession {
  void showStation(RadioStation station);
}
