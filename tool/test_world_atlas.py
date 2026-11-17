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


if __name__ == '__main__':
    unittest.main()
