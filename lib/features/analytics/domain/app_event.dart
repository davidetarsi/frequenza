import '../../radio/domain/journey.dart';
import '../../radio/domain/radio_station.dart';
import '../../songs/domain/song_search.dart';

/// One anonymous event. Every name and property the app sends is written
/// here, and none carries text typed or chosen by the person: only public
/// station data, known values, numbers and flags.
final class AppEvent {
  const AppEvent(this.name, [this.properties = const {}]);

  AppEvent.appOpened({required bool firstOpen})
    : this('app_opened', {'first_open': firstOpen});

  const AppEvent.welcomeCompleted() : this('welcome_completed');

  AppEvent.flightStarted(FlightKind kind)
    : this('flight_started', {'kind': kind.name});

  AppEvent.flightLanded(
    RadioStation station, {
    required FlightKind kind,
    required int attempts,
  }) : this('flight_landed', {
         'kind': kind.name,
         ..._station(station),
         'attempts': attempts,
       });

  AppEvent.flightFailed({required FlightKind kind, required int attempts})
    : this('flight_failed', {'kind': kind.name, 'attempts': attempts});

  AppEvent.playbackBroken(RadioStation station)
    : this('playback_broken', _station(station));

  AppEvent.favoriteAdded(RadioStation station)
    : this('favorite_added', _place(station));

  AppEvent.favoriteRemoved(RadioStation station)
    : this('favorite_removed', _place(station));

  AppEvent.songSaved(RadioStation station)
    : this('song_saved', _place(station));

  AppEvent.songRemoved(RadioStation station)
    : this('song_removed', _place(station));

  AppEvent.songSearchOpened(SearchService service)
    : this('song_search_opened', {'service': _snake(service.name)});

  const AppEvent.songCopied() : this('song_copied');

  const AppEvent.stationRetuned() : this('station_retuned');

  final String name;
  final Map<String, Object> properties;

  static Map<String, Object> _place(RadioStation station) => {
    'country': station.countryCode,
    'station': station.name,
  };

  static Map<String, Object> _station(RadioStation station) => {
    ..._place(station),
    'codec': switch (station.codec?.trim()) {
      final codec? when codec.isNotEmpty => codec,
      _ => 'unknown',
    },
  };

  static String _snake(String name) => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '_${match[0]!.toLowerCase()}',
  );

  @override
  bool operator ==(Object other) =>
      other is AppEvent &&
      other.name == name &&
      _sameProperties(other.properties, properties);

  @override
  int get hashCode => Object.hash(
    name,
    Object.hashAllUnordered(
      properties.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  static bool _sameProperties(Map<String, Object> a, Map<String, Object> b) =>
      a.length == b.length &&
      a.entries.every((entry) => b[entry.key] == entry.value);

  @override
  String toString() => 'AppEvent($name, $properties)';
}
