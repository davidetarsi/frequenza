"""Le funzioni pure del generatore dell'atlante, senza scaricare nulla.

python3 -m unittest discover -s tool -p 'test_world_atlas.py'
"""

import importlib.util
import unittest
from pathlib import Path

# Loaded under its own name: tool/tuning_sound has a generate.py too.
_spec = importlib.util.spec_from_file_location(
    'world_atlas_generate',
    Path(__file__).resolve().parent / 'world_atlas' / 'generate.py')
generate = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(generate)


def square(code, west, south, east, north, **names):
    ring = [[west, south], [east, south], [east, north], [west, north],
            [west, south]]
    return {
        'properties': {'ISO_A2': code, 'ISO_A2_EH': code, **names},
        'geometry': {'type': 'Polygon', 'coordinates': [ring]},
    }


class DotCountryTest(unittest.TestCase):
    countries = generate.country_rings([
        square('BR', -74, -34, -34, 5),
        square('DE', 5, 47, 15, 55),
    ])

    def test_a_point_in_brasilia_is_brazil(self):
        self.assertEqual(generate.dot_country(-47.9, -15.8, self.countries),
                         'BR')

    def test_a_point_at_sea_is_nobody(self):
        self.assertIsNone(generate.dot_country(-30.0, 0.0, self.countries))


class CodeTest(unittest.TestCase):
    def test_the_eh_code_covers_minus_99(self):
        self.assertEqual(
            generate.code_of({'ISO_A2': '-99', 'ISO_A2_EH': 'FR'}), 'FR')

    def test_no_code_is_none(self):
        self.assertIsNone(generate.code_of({'ISO_A2': '-99',
                                            'ISO_A2_EH': '-99'}))


class NamesTest(unittest.TestCase):
    def test_italian_and_english(self):
        feature = square('DE', 5, 47, 15, 55, NAME_IT='Germania',
                         NAME_EN='Germany')
        self.assertEqual(generate.names(feature), ('Germania', 'Germany'))

    def test_dart_strings_are_escaped(self):
        self.assertEqual(generate.dart_string("Costa d'Avorio $"),
                         '"Costa d\'Avorio \\$"')



def multi(code, *boxes):
    return {
        'properties': {'ISO_A2': code, 'ISO_A2_EH': code},
        'geometry': {'type': 'MultiPolygon', 'coordinates': [
            [[[w, s], [e, s], [e, n], [w, n], [w, s]]]
            for w, s, e, n in boxes]},
    }


class NearestTest(unittest.TestCase):
    def test_across_the_date_line(self):
        centroids = {'RU': (65.0, 175.0), 'US': (64.0, -150.0)}
        self.assertEqual(generate.nearest(65.0, -178.0, centroids), 'RU')

    def test_the_closest_label(self):
        centroids = {'BR': (-10.0, -52.0), 'AR': (-35.0, -65.0)}
        self.assertEqual(generate.nearest(-20.0, -50.0, centroids), 'BR')


class PiecesTest(unittest.TestCase):
    # France with Corsica and French Guiana; Cayenne is the city of GF.
    france = multi('FR', (-5, 42, 8, 51), (8.5, 41.3, 9.6, 43),
                   (-54.5, 2, -51.5, 5.8), (-53, 6.2, -52.8, 6.4))
    cities = {'GF': (4.93, -52.33)}

    def pieces(self):
        return generate.country_pieces([self.france], self.cities)

    def test_a_territory_takes_the_piece_holding_its_city(self):
        self.assertEqual(
            generate.dot_country(-53.75, 3.75, self.pieces()), 'GF')

    def test_its_islands_nearby_follow_it(self):
        self.assertEqual(
            generate.dot_country(-52.9, 6.3, self.pieces()), 'GF')

    def test_a_city_on_the_coast_finds_its_island(self):
        # Fort-de-France just off the simplified outline of Martinique.
        france = multi('FR', (-5, 42, 8, 51), (-61.2, 14.4, -60.8, 14.9))
        pieces = generate.country_pieces([france], {'MQ': (14.6, -61.3)})
        self.assertEqual(generate.dot_country(-61.0, 14.6, pieces), 'MQ')
        self.assertEqual(generate.dot_country(2.0, 47.0, pieces), 'FR')

    def test_islands_follow_the_nearest_territory(self):
        # Marie-Galante belongs with Guadeloupe, not with Martinique.
        france = multi('FR', (-5, 42, 8, 51), (-61.2, 14.4, -60.8, 14.9),
                       (-61.8, 15.9, -61.2, 16.5), (-61.35, 15.8, -61.2, 15.88))
        pieces = generate.country_pieces(
            [france], {'MQ': (14.6, -61.0), 'GP': (16.2, -61.5)})
        self.assertEqual(generate.dot_country(-61.27, 15.84, pieces), "GP")

    def test_the_rest_stays_with_the_country(self):
        pieces = self.pieces()
        self.assertEqual(generate.dot_country(2.0, 47.0, pieces), 'FR')
        self.assertEqual(generate.dot_country(9.0, 42.0, pieces), 'FR')

    def test_a_country_without_territories_is_one_piece_set(self):
        brazil = square('BR', -74, -34, -34, 2)  # south of Cayenne
        self.assertEqual(
            generate.country_pieces([brazil], self.cities),
            generate.country_rings([brazil]))


class DotCountriesTest(unittest.TestCase):
    def test_cells_take_their_country_or_the_nearest_holder(self):
        rows = ['0' * 72 + '11' + '0' * 70]
        countries = generate.country_rings([square('XX', 0, 77, 2.5, 80)])
        dots = generate.dot_countries(
            rows, countries, {'XX': (78.75, 1.25), 'YY': (0.0, 100.0)})
        self.assertEqual(dots[0][144:148], 'XXXX')


if __name__ == '__main__':
    unittest.main()
