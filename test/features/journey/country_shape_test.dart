import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/atlas/country_outlines.g.dart';
import 'package:frequenza/features/journey/presentation/country_shape.dart';

void main() {
  test('all offline outlines decode to finite, closed rings', () {
    expect(countryOutlines.length, greaterThan(200));
    for (final code in countryOutlines.keys) {
      final shape = CountryShape.of(code)!;
      expect(shape.bounds.isFinite, isTrue, reason: code);
      expect(shape.bounds.width, greaterThan(0), reason: code);
      expect(shape.bounds.height, greaterThan(0), reason: code);
      for (final ring in shape.rings) {
        expect(ring.length, greaterThanOrEqualTo(4), reason: code);
        expect(ring.first, ring.last, reason: code);
      }
    }
  });

  test('French Guiana has its own shape, separate from France', () {
    final france = CountryShape.of('FR')!;
    final guiana = CountryShape.of('GF')!;
    expect(france.bounds.contains(const Offset(2.35, -48.86)), isTrue);
    expect(france.bounds.contains(const Offset(-52.33, -4.93)), isFalse);
    expect(guiana.bounds.contains(const Offset(-52.33, -4.93)), isTrue);
  });

  test('date-line countries do not get a full-world bounding box', () {
    expect(CountryShape.of('FJ')!.bounds.width, lessThan(30));
    expect(CountryShape.of('RU')!.bounds.width, lessThan(230));
  });

  test('small islands keep a real outline and an usable viewport', () {
    final singapore = CountryShape.of('SG')!;
    expect(singapore.rings.first.length, greaterThan(4));
    expect(singapore.viewport.width, inExclusiveRange(0, 2));
    expect(CountryShape.of('unknown'), isNull);
  });

  test('zoom interpolation has exact endpoints and no zero-sized view', () {
    const world = Rect.fromLTWH(-180, -80, 360, 140);
    final island = CountryShape.of('SG')!.viewport;
    expect(
      interpolateMapView(world, island, 0).width,
      closeTo(world.width, 1e-8),
    );
    expect(
      interpolateMapView(world, island, 1).width,
      closeTo(island.width, 1e-8),
    );
    final middle = interpolateMapView(world, island, .5);
    expect(middle.width, greaterThan(island.width));
    expect(middle.width, lessThan(world.width));
    expect(middle.isFinite, isTrue);
  });
  test('zoom keeps the destination in view throughout the approach', () {
    const world = Rect.fromLTWH(-180, -80, 360, 140);
    for (final code in ['SG', 'JP', 'BR', 'AU', 'FR']) {
      final destination = CountryShape.of(code)!.viewport;
      for (var step = 0; step <= 20; step++) {
        final view = interpolateMapView(world, destination, step / 20);
        expect(
          view.inflate(1e-8).contains(destination.topLeft),
          isTrue,
          reason: '$code at step $step loses the top of the country',
        );
        expect(
          view.inflate(1e-8).contains(destination.bottomRight),
          isTrue,
          reason: '$code at step $step loses the bottom of the country',
        );
      }
    }
  });

  test('panning at an unchanged scale stays finite and linear', () {
    const from = Rect.fromLTWH(0, 0, 20, 10);
    const to = Rect.fromLTWH(40, -20, 20, 10);
    expect(interpolateMapView(from, to, .5), Rect.lerp(from, to, .5));
  });
}
