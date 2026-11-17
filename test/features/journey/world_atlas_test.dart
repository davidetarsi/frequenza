import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/journey/data/world_atlas.g.dart';

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
}
