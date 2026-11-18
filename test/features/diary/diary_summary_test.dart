import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/domain/diary_duration.dart';
import 'package:frequenza/features/diary/domain/diary_period.dart';
import 'package:frequenza/features/diary/domain/diary_summary.dart';
import 'package:frequenza/features/diary/domain/listen.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

RadioStation radio(
  String id,
  String code, {
  double? lat,
  double? lon,
  String? region,
}) => RadioStation(
  id: id,
  name: 'Radio $id',
  streamUrl: 'https://$id.example.com/live',
  country: code,
  countryCode: code,
  region: region,
  latitude: lat,
  longitude: lon,
);

void main() {
  final day = DateTime.utc(2026, 11, 17);
  var nextId = 0;
  Listen listen(RadioStation station, int seconds, {int minutes = 0}) => Listen(
    id: ++nextId,
    stationId: station.id,
    countryCode: station.countryCode,
    startedAt: day.add(Duration(minutes: minutes)),
    seconds: seconds,
  );
  Map<String, RadioStation> byId(List<RadioStation> stations) => {
    for (final s in stations) s.id: s,
  };
  const h = 3600;

  group('the threshold', () {
    test('five minutes, or one per cent of a long period', () {
      expect(DiaryThreshold.of(0), 300);
      expect(DiaryThreshold.of(5 * h), 300);
      expect(DiaryThreshold.of(41 * h), 1476);
    });
  });

  group('the periods', () {
    test('count back from now; always has no start', () {
      final now = DateTime.utc(2026, 11, 17, 12);
      expect(DiaryPeriod.week.since(now), DateTime.utc(2026, 11, 10, 12));
      expect(DiaryPeriod.month.since(now), DateTime.utc(2026, 10, 18, 12));
      expect(DiaryPeriod.year.since(now), DateTime.utc(2025, 11, 17, 12));
      expect(DiaryPeriod.always.since(now), isNull);
    });
  });

  group('the summary', () {
    test('no listens is empty', () {
      expect(summarize(const [], const {}), const DiarySummary.empty());
    });

    test('ten minutes in Brazil light Brazil fully', () {
      final br = radio('br', 'BR');
      final summary = summarize([listen(br, 600)], byId([br]));
      final filled = summary as DiaryFilled;
      expect(filled.countries.single.code, 'BR');
      expect(filled.countries.single.level, 4);
      expect(filled.top.station.id, 'br');
      expect(filled.totalSeconds, 600);
      expect(filled.stationCount, 1);
      expect(filled.stopped, hasLength(1));
      expect(filled.passing, isEmpty);
    });

    test('stopped countries are lit by quartiles, passing ones not', () {
      final br = radio('br', 'BR'), de = radio('de', 'DE');
      final jp = radio('jp', 'JP'), pt = radio('pt', 'PT');
      final cl = radio('cl', 'CL');
      final summary =
          summarize([
                listen(br, 9 * h),
                listen(de, 5 * h, minutes: 1),
                listen(jp, 4 * h, minutes: 2),
                listen(pt, 3 * h, minutes: 3),
                listen(cl, 180, minutes: 4),
              ], byId([br, de, jp, pt, cl]))
              as DiaryFilled;
      expect(summary.thresholdSeconds, 758, reason: "1% of 21 h 3 min");
      expect(
        [for (final c in summary.countries) (c.code, c.level)],
        [('BR', 4), ('DE', 3), ('JP', 2), ('PT', 1), ('CL', 0)],
      );
      expect(summary.stopped.map((c) => c.code), ['BR', 'DE', 'JP', 'PT']);
      expect(summary.passing.map((c) => c.code), ['CL']);
    });

    test('stations of a country, most heard first, and its last listen', () {
      final a = radio('a', 'BR'), b = radio('b', 'BR');
      final summary =
          summarize([
                listen(a, 600),
                listen(b, 1200, minutes: 30),
                listen(a, 100, minutes: 90),
              ], byId([a, b]))
              as DiaryFilled;
      final brazil = summary.countries.single;
      expect(brazil.seconds, 1900);
      expect(
        [for (final s in brazil.stations) (s.station.id, s.seconds)],
        [('b', 1200), ('a', 700)],
      );
      expect(brazil.lastListen, day.add(const Duration(minutes: 90)));
    });

    test('a station without a country counts in the totals only', () {
      final nowhere = radio('x', ''), br = radio('br', 'BR');
      final summary =
          summarize([
                listen(nowhere, 900),
                listen(br, 600, minutes: 20),
              ], byId([nowhere, br]))
              as DiaryFilled;
      expect(summary.totalSeconds, 1500);
      expect(summary.stationCount, 2);
      expect(summary.countries.map((c) => c.code), ['BR']);
    });
  });

  group('the longest trip', () {
    test('between two listens of different stations', () {
      final rome = radio('rome', 'IT', lat: 41.9, lon: 12.5);
      final rio = radio('rio', 'BR', lat: -22.9, lon: -43.2);
      final summary =
          summarize([
                listen(rome, 600),
                listen(rio, 600, minutes: 20),
              ], byId([rome, rio]))
              as DiaryFilled;
      expect(summary.longestTripKm, closeTo(9200, 100));
    });

    test('the same station twice is no trip', () {
      final rome = radio('rome', 'IT', lat: 41.9, lon: 12.5);
      final summary =
          summarize([
                listen(rome, 600),
                listen(rome, 600, minutes: 20),
              ], byId([rome]))
              as DiaryFilled;
      expect(summary.longestTripKm, isNull);
    });

    test('one listen is no trip', () {
      final rome = radio('rome', 'IT', lat: 41.9, lon: 12.5);
      final summary = summarize([listen(rome, 600)], byId([rome]));
      expect((summary as DiaryFilled).longestTripKm, isNull);
    });
  });

  group('the country card', () {
    final br = radio('br', 'BR'), cl = radio('cl', 'CL');
    final summary = summarize([
      listen(br, 9 * h),
      listen(cl, 180, minutes: 5),
    ], byId([br, cl]));

    test('stopped, passing, unvisited', () {
      expect(cardFor(summary, 'BR'), isA<StoppedCountry>());
      final passing = cardFor(summary, 'CL') as PassingCountry;
      expect(passing.country.seconds, 180);
      expect(passing.thresholdSeconds, 326);
      expect(cardFor(summary, 'MN'), const CountryCard.unvisited('MN'));
    });

    test('an empty diary knows only unvisited countries', () {
      expect(
        cardFor(const DiarySummary.empty(), 'BR'),
        const CountryCard.unvisited('BR'),
      );
    });
  });

  group('names and the top stop', () {
    test("a country carries Radio Browser's name for a fallback", () {
      const reunion = RadioStation(
        id: 'run',
        name: 'Radio Freedom',
        streamUrl: 'https://run.example.com/live',
        country: 'Réunion',
        countryCode: 'RE',
      );
      final summary =
          summarize([listen(reunion, 3600)], byId([reunion])) as DiaryFilled;
      expect(summary.countries.single.name, 'Réunion');
    });

    test('the top stop is the first country stopped in, if any', () {
      final br = radio('br', 'BR'), cl = radio('cl', 'CL');
      final passingOnly =
          summarize([listen(cl, 180)], byId([cl])) as DiaryFilled;
      expect(passingOnly.topStop, isNull);
      final both =
          summarize([listen(br, 3600), listen(cl, 180)], byId([br, cl]))
              as DiaryFilled;
      expect(both.topStop?.code, 'BR');
    });
  });

  group('durations', () {
    final cases = <(int, DiaryDuration)>[
      (0, const DiaryDuration.underAMinute()),
      (59, const DiaryDuration.underAMinute()),
      (60, const DiaryDuration.minutes(1)),
      (89, const DiaryDuration.minutes(1)),
      (90, const DiaryDuration.minutes(2)),
      (3569, const DiaryDuration.minutes(59)),
      (3570, const DiaryDuration.hours(1)),
      (5340, const DiaryDuration.hours(1)),
      (7140, const DiaryDuration.hours(2)),
      (9 * h, const DiaryDuration.hours(9)),
    ];
    for (final (seconds, expected) in cases) {
      test('$seconds s', () => expect(diaryDurationOf(seconds), expected));
    }
  });
}
