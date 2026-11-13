import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/data/world_atlas.g.dart';
import 'package:frequenza/features/journey/domain/geo_point.dart';
import 'package:frequenza/features/journey/domain/station_place.dart';
import 'package:frequenza/features/journey/domain/travel_leg.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

RadioStation station(String code, {double? lat, double? lon}) => RadioStation(
  id: '$code-$lat',
  name: 'Radio $code',
  streamUrl: 'https://example.com/$code',
  country: code,
  countryCode: code,
  latitude: lat,
  longitude: lon,
);

void main() {
  test('places a station at its own coordinates', () {
    final place = placeOf(station('IT', lat: 45.46, lon: 9.19))!;
    expect(place.point, const GeoPoint(45.46, 9.19));
    expect(place.approximate, isFalse);
    expect(place.countryCode, 'IT');
  });

  test('falls back to the country centre, or to nothing', () {
    final france = placeOf(station('FR'))!;
    final (lat, lon) = countryCentroids['FR']!;
    expect(france.point, GeoPoint(lat, lon));
    expect(france.approximate, isTrue);
    expect(placeOf(station('')), isNull);
    expect(placeOf(station('XX')), isNull);
  });

  test('home is the approximate centre of Italy', () {
    final (lat, lon) = countryCentroids['IT']!;
    expect(homePlace.point, GeoPoint(lat, lon));
    expect(homePlace.approximate, isTrue);
    expect(homePlace.countryCode, 'IT');
  });

  test('leg distance follows the approximation rules', () {
    final milan = placeOf(station('IT', lat: 45.46, lon: 9.19))!;
    final paris = placeOf(station('FR', lat: 48.86, lon: 2.35))!;
    final exact = TravelLeg(from: milan, to: paris).distance!;
    expect(exact.km, closeTo(640, 5));
    expect(exact.approximate, isFalse);

    expect(
      TravelLeg(from: homePlace, to: placeOf(station('IT'))).distance,
      isNull,
    );
    expect(TravelLeg(from: homePlace, to: milan).distance, isNull);
    final japan = TravelLeg(from: homePlace, to: placeOf(station('JP')));
    expect(japan.distance!.approximate, isTrue);
    expect(TravelLeg(from: homePlace, to: null).distance, isNull);
  });

  test('the dot map has land in the Alps and sea in the Atlantic', () {
    bool land(double lat, double lon) {
      final row = ((worldDotNorth - lat) / worldDotStep).floor();
      final col = ((lon + 180) / worldDotStep).floor();
      return worldDotRows[row][col] == '1';
    }

    expect(worldDotRows.first.length, 144);
    expect(land(46, 9), isTrue);
    expect(land(0, -30), isFalse);
  });
}
