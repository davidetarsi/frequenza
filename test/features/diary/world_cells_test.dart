import 'package:flutter_test/flutter_test.dart';
import 'package:frequenza/features/diary/domain/world_cells.dart';

void main() {
  test('a point in Brasilia is Brazil', () {
    expect(countryNear(-15.8, -47.9), 'BR');
  });

  test('the open ocean is nobody', () {
    expect(countryNear(-30, -20), isNull);
  });

  test('a point just off a coast finds the nearest dot', () {
    // Off Rio de Janeiro, inside one cell and a half.
    expect(countryNear(-24.5, -41.5), 'BR');
  });

  test('a tiny country is found at its own dot', () {
    expect(countryNear(35.9, 14.4), 'MT');
  });

  test('every country dot has a place', () {
    final dots = countryDots();
    expect(dots.where((d) => d.code == 'BR'), isNotEmpty);
    expect(dots.where((d) => d.code == 'SG'), hasLength(1));
  });
}
