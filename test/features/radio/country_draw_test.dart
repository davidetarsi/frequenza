import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/country_draw.dart';

void main() {
  test('weights a country by the square root of its stations', () {
    expect(CountryDraw.weight(100), 10);
    expect(CountryDraw.weight(0), 0);
  });

  test('a country with four times the stations comes up twice as often', () {
    final random = Random(1);
    var big = 0;
    var small = 0;
    for (var i = 0; i < 10000; i++) {
      final code = CountryDraw.pick(const {
        'US': 400,
        'NG': 100,
      }, random: random);
      if (code == 'US') big++;
      if (code == 'NG') small++;
    }
    expect(big / small, inInclusiveRange(1.8, 2.2));
  });

  test('draws only among the chosen countries', () {
    final random = Random(2);
    final drawn = {
      for (var i = 0; i < 200; i++)
        CountryDraw.pick(
          const {'US': 7000, 'DE': 5000, 'IT': 1500, 'NG': 70},
          among: const {'IT', 'NG'},
          random: random,
        ),
    };
    expect(drawn, {'IT', 'NG'});
  });

  test('never draws a skipped or empty country', () {
    final random = Random(3);
    final drawn = {
      for (var i = 0; i < 200; i++)
        CountryDraw.pick(
          const {'US': 7000, 'DE': 5000, 'AQ': 0},
          skip: const {'US'},
          random: random,
        ),
    };
    expect(drawn, {'DE'});
  });

  test('returns null when nothing is left', () {
    expect(CountryDraw.pick(const {}), isNull);
    expect(CountryDraw.pick(const {'AQ': 0}), isNull);
    expect(CountryDraw.pick(const {'IT': 10}, skip: const {'IT'}), isNull);
    expect(CountryDraw.pick(const {'IT': 10}, among: const {'FR'}), isNull);
  });

  test('codes are compared in upper case and blank ones ignored', () {
    final random = Random(4);
    final drawn = {
      for (var i = 0; i < 100; i++)
        CountryDraw.pick(
          const {'it': 10, '': 500, ' ': 500},
          among: const {'IT'},
          random: random,
        ),
    };
    expect(drawn, {'IT'});
    expect(CountryDraw.pick(const {'IT': 10}, skip: const {'it'}), isNull);
  });
}
