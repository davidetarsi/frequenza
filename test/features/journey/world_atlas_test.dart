import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/domain/atlas/world_atlas.g.dart';

void main() {
  test('every land cell has its country, sea cells none', () {
    expect(worldDotCountries, hasLength(worldDotRows.length));
    for (var row = 0; row < worldDotRows.length; row++) {
      final cells = worldDotRows[row];
      final countries = worldDotCountries[row];
      expect(countries.length, cells.length * 2, reason: 'row $row');
      for (var col = 0; col < cells.length; col++) {
        final code = countries.substring(col * 2, col * 2 + 2);
        expect(code == '..', cells[col] == '0', reason: 'row $row col $col');
      }
    }
  });

  test('the cell of Brasilia is Brazil', () {
    const lat = -15.8, lon = -47.9;
    final row = ((worldDotNorth - lat) / worldDotStep).floor();
    final col = ((lon + 180) / worldDotStep).floor();
    expect(worldDotCountries[row].substring(col * 2, col * 2 + 2), 'BR');
  });

  test('countries too small for a cell get a dot of their own', () {
    expect(extraCountryDots, contains('MT'));
    expect(extraCountryDots, contains('SG'));
  });

  test('countries have Italian and English names', () {
    expect(countryNames['DE'], ('Germania', 'Germany'));
    expect(countryNames['MN']?.$2, 'Mongolia');
  });

  group('overseas territories are countries of their own', () {
    String cellAt(double lat, double lon) {
      final row = ((worldDotNorth - lat) / worldDotStep).floor();
      final col = ((lon + 180) / worldDotStep).floor();
      return worldDotCountries[row].substring(col * 2, col * 2 + 2);
    }

    test('a cell of French Guiana is GF, not France', () {
      expect(cellAt(3.75, -53.75), 'GF');
    });

    test('Svalbard is SJ, not Norway', () {
      expect(cellAt(78.75, 16.25), 'SJ');
    });

    test('the small ones get their own dot', () {
      expect(
        extraCountryDots.keys,
        containsAll(['RE', 'GP', 'MQ', 'YT', 'BQ', 'CC', 'CX', 'TK']),
      );
    });

    test('they have names', () {
      expect(countryNames['GF'], ('Guyana francese', 'French Guiana'));
      expect(countryNames['RE'], ('Riunione', 'Réunion'));
      expect(countryNames['SJ']?.$1, 'Svalbard e Jan Mayen');
    });
  });
}
