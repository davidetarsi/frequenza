"""Country outline generation: small countries, topology and compact encoding."""
import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    'country_outline_generator', Path(__file__).parent / 'world_atlas/outlines.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class OutlineTest(unittest.TestCase):
    def test_simplification_keeps_the_corners_of_a_closed_border(self):
        ring = [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2], [1, 2], [0, 2], [0, 0]]
        reduced = module.simplify(ring, .05)
        self.assertEqual(reduced[0], reduced[-1])
        self.assertEqual(module.area(reduced), 4)
        self.assertLess(len(reduced), len(ring))

    def test_delta_encoding_preserves_negative_and_small_coordinates(self):
        ring = [[-179.999, -.012], [-179.995, -.009], [-179.999, -.012]]
        x, y = 0, 0
        decoded = []
        for pair in module.encode(ring).split(';'):
            dx, dy = [int(value, 36) for value in pair.split(',')]
            x, y = x + dx, y + dy
            decoded.append([x / 1000, y / 1000])
        self.assertEqual(decoded, ring)


if __name__ == '__main__':
    unittest.main()
