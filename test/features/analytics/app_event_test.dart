import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
import 'package:frequenza/features/diary/domain/diary_flight.dart';
import 'package:frequenza/features/diary/domain/diary_period.dart';
import 'package:frequenza/features/diary/domain/diary_summary.dart';
import 'package:frequenza/features/radio/domain/journey.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:frequenza/features/songs/domain/song_search.dart';

RadioStation radio({String? codec}) => RadioStation(
  id: 'station-1',
  name: 'Radio 1',
  streamUrl: 'https://stream.test/1.mp3',
  country: 'Italy',
  countryCode: 'IT',
  codec: codec,
);

void main() {
  test('a landing carries kind, place, station, codec and attempts', () {
    expect(
      AppEvent.flightLanded(
        radio(codec: 'MP3'),
        kind: FlightKind.back,
        attempts: 2,
      ),
      const AppEvent('flight_landed', {
        'kind': 'back',
        'country': 'IT',
        'station': 'Radio 1',
        'codec': 'MP3',
        'attempts': 2,
      }),
    );
  });

  test('a missing or empty codec is unknown', () {
    for (final codec in [null, '', '  ']) {
      expect(AppEvent.playbackBroken(radio(codec: codec)).properties, {
        'country': 'IT',
        'station': 'Radio 1',
        'codec': 'unknown',
      });
    }
  });

  test('search services are named in snake case', () {
    expect(AppEvent.songSearchOpened(SearchService.amazonMusic).properties, {
      'service': 'amazon_music',
    });
    expect(
      [
        for (final service in SearchService.values)
          AppEvent.songSearchOpened(service).properties['service'],
      ],
      ['spotify', 'youtube', 'amazon_music', 'web'],
    );
  });

  test('every event has its exact name', () {
    final station = radio(codec: 'AAC');
    expect(
      [
        AppEvent.appOpened(firstOpen: true),
        AppEvent.welcomeCompleted(),
        AppEvent.flightStarted(FlightKind.forward),
        AppEvent.flightLanded(station, kind: FlightKind.forward, attempts: 1),
        AppEvent.flightFailed(kind: FlightKind.reconnect, attempts: 3),
        AppEvent.playbackBroken(station),
        AppEvent.favoriteAdded(station),
        AppEvent.favoriteRemoved(station),
        AppEvent.songSaved(station),
        AppEvent.songRemoved(station),
        AppEvent.songSearchOpened(SearchService.web),
        AppEvent.songCopied(),
        AppEvent.stationRetuned(),
      ].map((event) => event.name),
      [
        'app_opened',
        'welcome_completed',
        'flight_started',
        'flight_landed',
        'flight_failed',
        'playback_broken',
        'favorite_added',
        'favorite_removed',
        'song_saved',
        'song_removed',
        'song_search_opened',
        'song_copied',
        'station_retuned',
      ],
    );
  });

  test('no event carries free text', () {
    final station = radio(codec: 'AAC');
    final allowed = <Object>{
      'Radio 1',
      'IT',
      'AAC',
      for (final kind in FlightKind.values) kind.name,
      'spotify',
      'youtube',
      'amazon_music',
      'web',
      '2m-10m',
      'year',
      'unvisited',
      'top_station',
      'country_station',
      'random_in_country',
    };
    final events = [
      AppEvent.appOpened(firstOpen: false),
      AppEvent.flightStarted(FlightKind.back),
      AppEvent.flightLanded(station, kind: FlightKind.forward, attempts: 4),
      AppEvent.flightFailed(kind: FlightKind.forward, attempts: 2),
      AppEvent.playbackBroken(station),
      AppEvent.favoriteAdded(station),
      AppEvent.songSaved(station),
      AppEvent.listenEnded(station, seconds: 300),
      AppEvent.diaryOpened(DiaryPeriod.year),
      AppEvent.diaryCountryOpened('IT', const CountryCard.unvisited('IT')),
      for (final source in DiaryFlightSource.values)
        AppEvent.diaryFlight(source),
      for (final service in SearchService.values)
        AppEvent.songSearchOpened(service),
    ];
    for (final event in events) {
      for (final value in event.properties.values) {
        expect(
          value is int || value is bool || allowed.contains(value),
          isTrue,
          reason: '${event.name}: $value',
        );
      }
    }
  });

  test('duration bands', () {
    String band(int seconds) =>
        AppEvent.listenEnded(radio(), seconds: seconds).properties['duration']!
            as String;
    expect([5, 29, 30, 119, 120, 599, 600, 1799, 1800, 7200].map(band), [
      '5s-30s',
      '5s-30s',
      '30s-2m',
      '30s-2m',
      '2m-10m',
      '2m-10m',
      '10m-30m',
      '10m-30m',
      '30m+',
      '30m+',
    ]);
    expect(
      AppEvent.listenEnded(radio(), seconds: 60),
      const AppEvent('listen_ended', {
        'country': 'IT',
        'station': 'Radio 1',
        'duration': '30s-2m',
      }),
    );
  });
}
