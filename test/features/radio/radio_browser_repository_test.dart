import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/data/radio_browser_repository.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> rawStation(
  String id,
  String country, {
  String scheme = 'https',
}) => {
  'stationuuid': id,
  'name': 'Radio $id',
  'url_resolved': '$scheme://stream.example.com/$id',
  'country': country,
  'countrycode': country,
};

/// A fake Radio Browser: [countries] answers `/json/countries`, [stations]
/// answers a search by country code (or 'world' without one). Every request
/// is kept in [requests].
class FakeRadioBrowser {
  FakeRadioBrowser({
    this.countries = const {},
    this.stations = const {},
    this.countriesFail = false,
  });

  final Map<String, int> countries;
  final Map<String, List<Map<String, Object?>>> stations;
  bool countriesFail;
  final requests = <Uri>[];

  late final client = MockClient((request) async {
    requests.add(request.url);
    if (request.url.path == '/json/countries') {
      if (countriesFail) return http.Response('Error', 503);
      return http.Response(
        jsonEncode([
          for (final MapEntry(:key, :value) in countries.entries)
            {'name': key, 'iso_3166_1': key, 'stationcount': value},
        ]),
        200,
      );
    }
    final code = request.url.queryParameters['countrycode'] ?? 'world';
    return http.Response(jsonEncode(stations[code] ?? const []), 200);
  });

  Iterable<Uri> get searches =>
      requests.where((uri) => uri.path == '/json/stations/search');

  RadioBrowserRepository repository({int seed = 1}) => RadioBrowserRepository(
    client: client,
    mirrors: ['https://mirror1.test'],
    random: Random(seed),
  );
}

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
    test('a station without a country keeps it empty', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode([
            {
              'stationuuid': 'blank',
              'name': 'Radio Blank',
              'url_resolved': 'https://stream.example.com/blank',
              'countrycode': 'JP',
            },
          ]),
          200,
        ),
      );
      final repository = RadioBrowserRepository(
        client: client,
        mirrors: ['https://mirror1.test'],
      );

      final stations = await repository.getCandidates();

      expect(stations.single.country, isEmpty);
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

  group('drawing a station', () {
    test(
      'asks for stations of the drawn country, with a fresh seed each time',
      () async {
        final browser = FakeRadioBrowser(
          countries: {'NG': 70},
          stations: {
            'NG': [rawStation('lagos', 'NG')],
          },
        );
        final repository = browser.repository();

        final first = await repository.getRandomStation();
        final second = await repository.getRandomStation();

        expect(first?.id, 'lagos');
        expect(second?.id, 'lagos');
        final searches = browser.searches.toList();
        expect(searches, hasLength(2));
        for (final uri in searches) {
          expect(uri.queryParameters, containsPair('countrycode', 'NG'));
          expect(uri.queryParameters, containsPair('order', 'random'));
          expect(uri.queryParameters, containsPair('hidebroken', 'true'));
          expect(uri.queryParameters, containsPair('limit', '30'));
          // An HTTP-only sample must not pass for a country with no stations.
          expect(uri.queryParameters, containsPair('is_https', 'true'));
        }
        expect(
          searches[0].queryParameters['seed'],
          isNot(searches[1].queryParameters['seed']),
        );
      },
    );

    test('loads the countries once per session', () async {
      final browser = FakeRadioBrowser(
        countries: {'NG': 70},
        stations: {
          'NG': [rawStation('lagos', 'NG')],
        },
      );
      final repository = browser.repository();

      for (var i = 0; i < 3; i++) {
        await repository.getRandomStation();
      }

      expect(
        browser.requests.where((uri) => uri.path == '/json/countries'),
        hasLength(1),
      );
    });

    test('skips stations to avoid and HTTP streams', () async {
      final browser = FakeRadioBrowser(
        countries: {'IT': 1500},
        stations: {
          'IT': [
            rawStation('heard', 'IT'),
            rawStation('plain', 'IT', scheme: 'http'),
            rawStation('new', 'IT'),
          ],
        },
      );

      final station = await browser.repository().getRandomStation(
        avoid: {'heard'},
      );

      expect(station?.id, 'new');
    });

    test(
      'moves to another country when one has nothing, and remembers it',
      () async {
        final browser = FakeRadioBrowser(
          countries: {'AA': 100, 'BB': 100},
          stations: {
            'BB': [rawStation('found', 'BB')],
          },
        );
        final repository = browser.repository();

        for (var i = 0; i < 5; i++) {
          expect((await repository.getRandomStation())?.id, 'found');
        }

        final asked = browser.searches
            .map((uri) => uri.queryParameters['countrycode'])
            .toList();
        expect(asked.where((code) => code == 'AA').length, equals(1));
      },
    );

    test(
      'falls back to the whole world when the countries do not load',
      () async {
        final browser = FakeRadioBrowser(
          countriesFail: true,
          stations: {
            'world': [rawStation('anywhere', 'FR')],
          },
        );

        final station = await browser.repository().getRandomStation();

        expect(station?.id, 'anywhere');
        final search = browser.searches.single;
        expect(search.queryParameters.containsKey('countrycode'), isFalse);
        expect(search.queryParameters, contains('seed'));
      },
    );

    test('falls back to the whole world after four empty countries', () async {
      final browser = FakeRadioBrowser(
        countries: {'AA': 1, 'BB': 1, 'CC': 1, 'DD': 1, 'EE': 1},
        stations: {
          'world': [rawStation('anywhere', 'FR')],
        },
      );

      final station = await browser.repository().getRandomStation();

      expect(station?.id, 'anywhere');
      expect(browser.searches, hasLength(5));
    });

    test('with chosen countries it never leaves them', () async {
      final browser = FakeRadioBrowser(
        countries: {'IT': 1500, 'US': 7000},
        stations: {
          'US': [rawStation('nyc', 'US')],
          'world': [rawStation('anywhere', 'US')],
        },
      );

      final RadioStation? station = await browser.repository().getRandomStation(
        countries: {'IT'},
      );

      expect(station, isNull);
      expect(
        browser.searches.map((uri) => uri.queryParameters['countrycode']),
        everyElement('IT'),
      );
    });

    test('lands on a station already heard rather than on nothing', () async {
      final browser = FakeRadioBrowser(
        countries: {'IT': 1},
        stations: {
          'IT': [rawStation('heard', 'IT')],
        },
      );

      final station = await browser.repository().getRandomStation(
        countries: {'IT'},
        avoid: {'heard'},
      );

      expect(station?.id, 'heard');
    });

    test('uses all.api first, then de1', () async {
      final hosts = <String>[];
      final repository = RadioBrowserRepository(
        client: MockClient((request) async {
          hosts.add(request.url.host);
          return http.Response('Error', 503);
        }),
      );

      await expectLater(repository.getCandidates(), throwsA(isA<Exception>()));

      expect(hosts, [
        'all.api.radio-browser.info',
        'de1.api.radio-browser.info',
      ]);
    });
  });
}
