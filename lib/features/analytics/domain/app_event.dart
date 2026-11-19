import 'package:freezed_annotation/freezed_annotation.dart';

import '../../diary/domain/diary_flight.dart';
import '../../diary/domain/diary_period.dart';
import '../../diary/domain/diary_summary.dart';
import '../../radio/domain/journey.dart';
import '../../radio/domain/radio_station.dart';
import '../../songs/domain/song_search.dart';

part 'app_event.freezed.dart';

/// One usage event. Every name and property the app sends is written
/// here, and none carries text typed or chosen by the person: only public
/// station data, known values, numbers and flags.
@freezed
class AppEvent with _$AppEvent {
  const AppEvent._();
  const factory AppEvent(
    String name, [
    @Default({}) Map<String, Object> properties,
  ]) = _AppEvent;

  factory AppEvent.appOpened({required bool firstOpen}) =>
      AppEvent('app_opened', {'first_open': firstOpen});

  factory AppEvent.welcomeCompleted() => AppEvent('welcome_completed');

  factory AppEvent.flightStarted(FlightKind kind) =>
      AppEvent('flight_started', {'kind': kind.name});

  factory AppEvent.flightLanded(
    RadioStation station, {
    required FlightKind kind,
    required int attempts,
  }) => AppEvent('flight_landed', {
    'kind': kind.name,
    ..._station(station),
    'attempts': attempts,
  });

  factory AppEvent.flightFailed({
    required FlightKind kind,
    required int attempts,
  }) => AppEvent('flight_failed', {'kind': kind.name, 'attempts': attempts});

  factory AppEvent.playbackBroken(RadioStation station) =>
      AppEvent('playback_broken', _station(station));

  factory AppEvent.favoriteAdded(RadioStation station) =>
      AppEvent('favorite_added', _place(station));

  factory AppEvent.favoriteRemoved(RadioStation station) =>
      AppEvent('favorite_removed', _place(station));

  factory AppEvent.songSaved(RadioStation station) =>
      AppEvent('song_saved', _place(station));

  factory AppEvent.songRemoved(RadioStation station) =>
      AppEvent('song_removed', _place(station));

  /// A listen saved in the diary has ended, after [seconds] on air.
  factory AppEvent.listenEnded(RadioStation station, {required int seconds}) =>
      AppEvent('listen_ended', {
        ..._place(station),
        'duration': _band(seconds),
      });

  factory AppEvent.songSearchOpened(SearchService service) =>
      AppEvent('song_search_opened', {'service': _snake(service.name)});

  factory AppEvent.songCopied() => AppEvent('song_copied');

  /// The diary always opens on the last 30 days: the period is not news.
  factory AppEvent.diaryOpened() => AppEvent('diary_opened');

  factory AppEvent.diaryPeriodChosen(DiaryPeriod period) =>
      AppEvent('diary_period_chosen', {'period': period.name});

  factory AppEvent.diaryCountryOpened(String code, CountryCard card) =>
      AppEvent('diary_country_opened', {
        'country': code,
        'kind': switch (card) {
          StoppedCountry() => 'stopped',
          PassingCountry() => 'passing',
          UnvisitedCountry() => 'unvisited',
        },
      });

  factory AppEvent.diaryFlight(DiaryFlightSource source) =>
      AppEvent('diary_flight', {'source': _snake(source.name)});

  factory AppEvent.stationRetuned() => AppEvent('station_retuned');

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

  static String _band(int seconds) => switch (seconds) {
    < 30 => '5s-30s',
    < 120 => '30s-2m',
    < 600 => '2m-10m',
    < 1800 => '10m-30m',
    _ => '30m+',
  };

  static String _snake(String name) => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '_${match[0]!.toLowerCase()}',
  );
}
