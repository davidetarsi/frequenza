import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/radio/domain/track_title.dart';

void main() {
  test('splits artist and title on a spaced dash', () {
    for (final dash in [' - ', ' – ', ' — ']) {
      final track = TrackTitle.parse('Ana Moura${dash}Desfado')!;
      expect(track.artist, 'Ana Moura');
      expect(track.title, 'Desfado');
    }
    final first = TrackTitle.parse('A - B - C')!;
    expect(first.artist, 'A');
    expect(first.title, 'B - C');
  });

  test('drops the on-air prefixes', () {
    for (final prefix in ['Now On Air:', 'now playing:', 'ON AIR:', 'NP:']) {
      final track = TrackTitle.parse('$prefix Fábio Jr. - Pai')!;
      expect(track.artist, 'Fábio Jr.');
      expect(track.title, 'Pai');
    }
  });

  test('keeps a title without artist', () {
    final track = TrackTitle.parse('Desfado')!;
    expect(track.artist, isNull);
    expect(track.title, 'Desfado');
    expect(track.display, 'Desfado');
    expect(track.query, 'Desfado');
  });

  test('rejects what is not a song', () {
    for (final raw in [
      '',
      '  ',
      '002',
      '- -',
      'Live365 - Live365 - Advertisement',
      'Commercial Break',
      'Pubblicità - Spot',
      'advertisement',
    ]) {
      expect(TrackTitle.parse(raw), isNull, reason: raw);
    }
    expect(
      TrackTitle.parse('KEXP 90.3 FM', stationName: 'KEXP 90.3 FM'),
      isNull,
    );
    expect(
      TrackTitle.parse(' kexp  90.3 fm ', stationName: 'KEXP 90.3 FM'),
      isNull,
    );
  });

  test('trims and collapses spaces', () {
    final track = TrackTitle.parse('  Ana   Moura  -  Desfado ')!;
    expect(track.display, 'Ana Moura — Desfado');
    expect(track.query, 'Ana Moura Desfado');
  });
}
