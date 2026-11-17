import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/analytics/domain/app_event.dart';
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
    };
    final events = [
      AppEvent.appOpened(firstOpen: false),
      AppEvent.flightStarted(FlightKind.back),
      AppEvent.flightLanded(station, kind: FlightKind.forward, attempts: 4),
      AppEvent.flightFailed(kind: FlightKind.forward, attempts: 2),
      AppEvent.playbackBroken(station),
      AppEvent.favoriteAdded(station),
      AppEvent.songSaved(station),
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
}
