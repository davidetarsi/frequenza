import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/geo_point.dart';

void main() {
  test('accepts only numeric coordinates in range', () {
    expect(GeoPoint.tryFrom('45.4', 9.2), isNull);
    expect(GeoPoint.tryFrom(0, 0), isNull);
    expect(GeoPoint.tryFrom(91, 0), isNull);
    expect(GeoPoint.tryFrom(0, 181), isNull);
    expect(GeoPoint.tryFrom(null, 9.2), isNull);
    final milan = GeoPoint.tryFrom(45.46, 9.19)!;
    expect(milan.latitude, 45.46);
    expect(milan.longitude, 9.19);
  });

  test('measures great-circle distance in kilometres', () {
    const milan = GeoPoint(45.46, 9.19);
    const paris = GeoPoint(48.86, 2.35);
    expect(milan.distanceKm(paris), closeTo(640, 5));
    expect(milan.distanceKm(milan), 0);
  });
}
