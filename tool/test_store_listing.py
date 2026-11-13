"""Limiti della scheda del Play Store: oltre, Google rifiuta l'invio."""

import struct
import unittest
from pathlib import Path

METADATA = Path(__file__).resolve().parents[1] / 'fastlane' / 'metadata' / 'android'
LIMITS = {'title.txt': 30, 'short_description.txt': 80, 'full_description.txt': 4000}


class StoreListingTest(unittest.TestCase):
    def test_texts_within_limits(self):
        for locale in ('it-IT', 'en-US'):
            for name, limit in LIMITS.items():
                text = (METADATA / locale / name).read_text().strip()
                self.assertTrue(text, f'{locale}/{name}')
                self.assertLessEqual(len(text), limit, f'{locale}/{name}')

    def test_icon_is_512(self):
        for locale in ('it-IT', 'en-US'):
            header = (METADATA / locale / 'images' / 'icon.png').read_bytes()[:24]
            self.assertEqual(struct.unpack('>II', header[16:24]), (512, 512))


if __name__ == '__main__':
    unittest.main()
