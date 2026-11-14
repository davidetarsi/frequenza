import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/radio_browser_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('RadioBrowserRepository', () {
    test('filters out non-HTTPS streams and parses valid stations', () async {
      final mockData = [
        {
          'stationuuid': 'uuid-1',
          'name': 'HTTP Station (discard)',
          'url_resolved': 'http://stream.example.com/live',
          'country': 'Italy',
          'countrycode': 'IT',
          'codec': 'MP3',
        },
        {
          'stationuuid': 'uuid-2',
          'name': 'HTTPS Station (keep)',
          'url_resolved': 'https://stream.example.com/live.mp3',
          'country': 'Italy',
          'countrycode': 'IT',
          'codec': 'MP3',
          'bitrate': 128,
          'tags': 'jazz, chillout',
        },
      ];

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockData), 200);
      });

      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://mirror1.test'],
      );

      final candidates = await repository.getCandidates(countryCode: 'IT');

      expect(candidates.length, 1);
      final station = candidates.first;
      expect(station.id, 'uuid-2');
      expect(station.name, 'HTTPS Station (keep)');
      expect(station.streamUrl, 'https://stream.example.com/live.mp3');
      expect(station.countryCode, 'IT');
      expect(station.codec, 'MP3');
      expect(station.bitrate, 128);
      expect(station.tags, ['jazz', 'chillout']);
    });

    test('falls back to secondary mirror when primary fails', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (request.url.host == 'failing-mirror.test') {
          return http.Response('Server Error', 500);
        }
        return http.Response(
          jsonEncode([
            {
              'stationuuid': 'uuid-fallback',
              'name': 'Fallback Radio',
              'url_resolved': 'https://fallback.example.com/stream',
              'country': 'France',
              'countrycode': 'FR',
            },
          ]),
          200,
        );
      });

      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://failing-mirror.test', 'https://working-mirror.test'],
      );

      final candidates = await repository.getCandidates(countryCode: 'FR');

      expect(candidates.length, 1);
      expect(candidates.first.name, 'Fallback Radio');
      expect(callCount, 2);
    });

    test('throws when all mirrors fail', () async {
      final client = MockClient((request) async {
        return http.Response('Error', 503);
      });

      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://m1.test', 'https://m2.test'],
      );

      expect(() => repository.getCandidates(), throwsA(isA<Exception>()));
    });
    test('reads valid station coordinates only', () async {
      Map<String, Object?> raw(String id, Object? lat, Object? lon) => {
        'stationuuid': id,
        'name': 'Radio $id',
        'url_resolved': 'https://stream.example.com/$id',
        'country': 'Japan',
        'countrycode': 'JP',
        'geo_lat': lat,
        'geo_long': lon,
      };
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode([
            raw('tokyo', 35.68, 139.76),
            raw('missing', null, null),
            raw('zero', 0, 0),
            raw('range', 120, 10),
          ]),
          200,
        ),
      );
      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://mirror1.test'],
      );

      final stations = await repository.getCandidates();

      expect(stations.first.point?.latitude, 35.68);
      expect(stations.first.point?.longitude, 139.76);
      expect(stations.skip(1).map((s) => s.point), everyElement(isNull));
      expect(stations.skip(1).map((s) => s.latitude), everyElement(isNull));
    });
  });
}
