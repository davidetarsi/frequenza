import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/local_clock.dart';
import 'package:frequenza/features/radio/domain/radio_station.dart';

RadioStation station(String code, {double? lat, double? lon}) => RadioStation(
  id: code,
  name: 'Radio $code',
  streamUrl: 'https://example.com/$code',
  country: code,
  countryCode: code,
  latitude: lat,
  longitude: lon,
);

void main() {
  final july = DateTime.utc(2027, 7, 1, 10);
  final january = DateTime.utc(2027, 1, 15, 10);

  test('single-zone countries follow their daylight saving rule', () {
    expect(localTimeOf(station('IT'), july), (
      hhmm: '12:00',
      approximate: false,
    ));
    expect(localTimeOf(station('IT'), january)?.hhmm, '11:00');
    expect(localTimeOf(station('JP'), july)?.hhmm, '19:00');
  });

  test('multi-zone countries use the nearest reference city', () {
    final evening = DateTime.utc(2027, 7, 1, 20);
    expect(localTimeOf(station('US', lat: 34.05, lon: -118.24), evening), (
      hhmm: '13:00',
      approximate: false,
    ));
    expect(localTimeOf(station('US'), evening), (
      hhmm: '16:00',
      approximate: true,
    ));
    expect(
      localTimeOf(station('AU', lat: -33.87, lon: 151.21), january)?.hhmm,
      '21:00',
    );
    expect(
      localTimeOf(station('AU', lat: -27.47, lon: 153.03), january)?.hhmm,
      '20:00',
    );
  });

  test('daylight saving changes on the expected days', () {
    // Europe: last Sunday of March 2027 is the 28th, 01:00 UTC.
    expect(
      localTimeOf(station('DE'), DateTime.utc(2027, 3, 28, 0, 59))?.hhmm,
      '01:59',
    );
    expect(
      localTimeOf(station('DE'), DateTime.utc(2027, 3, 28, 1))?.hhmm,
      '03:00',
    );
    // New York: second Sunday of March 2027 is the 14th, 07:00 UTC.
    final ny = station('US', lat: 40.71, lon: -74.01);
    expect(localTimeOf(ny, DateTime.utc(2027, 3, 14, 6, 59))?.hhmm, '01:59');
    expect(localTimeOf(ny, DateTime.utc(2027, 3, 14, 7))?.hhmm, '03:00');
  });

  test('unknown countries have no local time', () {
    expect(localTimeOf(station('XX'), july), isNull);
    expect(localTimeOf(station(''), july), isNull);
  });
}
