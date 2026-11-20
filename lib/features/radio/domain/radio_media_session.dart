import 'radio_station.dart';
import 'radio_media_localization.dart';

/// What the notification's keys ask of the radio.
///
/// [resume] is play once the stream has closed: the radio decides how to
/// bring the station back.
enum RadioMediaCommand { next, previous, toggleFavorite, resume }

/// The system media session: notification, lock screen and media buttons.
abstract interface class RadioMediaSession {
  void updateLocalization(RadioMediaLocalization localization);
  void showStation(RadioStation station);

  /// A placeholder that never reveals the destination. Whether the radio
  /// flies is said only by [showControls].
  void showFlight();

  /// The journey as the app sees it. While [flying] the notification stays
  /// up as «connecting» and its keys do nothing; once landed it shows the
  /// station's keys, the heart filled when the station is [saved].
  void showControls({required bool flying, required bool saved});

  /// Registers the application stop operation. The service waits until the
  /// controller has cancelled flights, stopped static and closed the stream.
  /// Clear on disposal so a detached session cannot call a disposed controller.
  void setStopHandler(Future<void> Function()? stop);

  /// Back, next and heart pressed in the notification.
  Stream<RadioMediaCommand> get commands;
}
