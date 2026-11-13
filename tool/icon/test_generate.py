"""Test dell'icona manopola: python3 -m unittest discover -s tool -p 'test_*.py'."""

import math
import re
import struct
import sys
import tempfile
import unittest
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate  # noqa: E402

REPO = Path(__file__).resolve().parents[2]


def decode_png(data):
    """Legge un PNG RGBA a 8 bit senza filtri, come quelli dello script."""
    assert data[:8] == b'\x89PNG\r\n\x1a\n'
    pos, chunks = 8, {}
    while pos < len(data):
        length, kind = struct.unpack('>I4s', data[pos:pos + 8])
        chunks.setdefault(kind, b'')
        chunks[kind] += data[pos + 8:pos + 8 + length]
        pos += 12 + length
    width, height, depth, color = struct.unpack('>IIBB', chunks[b'IHDR'][:10])
    assert depth == 8 and color in (2, 6)
    channels = 4 if color == 6 else 3
    raw = zlib.decompress(chunks[b'IDAT'])
    stride = width * channels + 1
    rows = [raw[y * stride + 1:(y + 1) * stride] for y in range(height)]
    return width, height, rows, color


def pixel(png, x, y):
    width, _, rows, _ = png
    index = int(x / 108 * width)
    row = rows[int(y / 108 * width)]
    return tuple(row[index * 4:index * 4 + 4])


def path_points(xml):
    """Estremi dei segmenti (M, L e fine degli archi A) con il mezzo tratto."""
    points = []
    for match in re.finditer(r'<path([^>]*)/>', xml):
        attrs = match.group(1)
        stroke = re.search(r'strokeWidth="([\d.]+)"', attrs)
        half = float(stroke.group(1)) / 2 if stroke else 0
        data = re.search(r'pathData="([^"]+)"', attrs).group(1)
        for command, args in re.findall(r'([MLAZ])([^MLAZ]*)', data):
            numbers = [float(n) for n in re.findall(r'-?[\d.]+', args)]
            if command in 'ML':
                points.append((numbers[0], numbers[1], half))
            elif command == 'A':
                points.append((numbers[5], numbers[6], half))
    return points


class IconTest(unittest.TestCase):
    def test_png_sizes(self):
        for size in (48, 192, 512):
            width, height, _, _ = decode_png(generate.render_png(size))
            self.assertEqual((width, height), (size, size))

    def test_png_colors(self):
        png = decode_png(generate.render_png(512))
        self.assertEqual(pixel(png, 54, 37), (0xAD, 0x48, 0x23, 255))
        self.assertEqual(pixel(png, 54, 72), (0x35, 0x4B, 0x3F, 255))
        self.assertEqual(pixel(png, 1, 1)[3], 0)

    def test_store_icon_is_full_bleed(self):
        png = decode_png(generate.render_png(512, rounded=False))
        self.assertEqual(pixel(png, 1, 1), (0x20, 0x3C, 0x33, 255))

    def test_feature_graphic_has_no_alpha(self):
        # Google vuole la grafica in primo piano 1024×500, PNG a 24 bit.
        width, height, rows, color = decode_png(generate.render_feature_graphic())
        self.assertEqual((width, height, color), (1024, 500, 2))
        self.assertEqual(tuple(rows[0][:3]), (0x20, 0x3C, 0x33))
        # Al centro c'è la manopola: la tacca arancione sopra il centro.
        marker_y = 250 + round((37 - 54) * generate.FEATURE_SCALE)
        self.assertEqual(tuple(rows[marker_y][512 * 3:512 * 3 + 3]), (0xAD, 0x48, 0x23))

    def test_adaptive_fits_safe_zone(self):
        for xml in (generate.foreground_xml(), generate.monochrome_xml()):
            points = path_points(xml)
            self.assertGreater(len(points), 32)
            for x, y, half in points:
                self.assertLessEqual(math.hypot(x - 54, y - 54) + half, 33.0)

    def test_generated_files_up_to_date(self):
        with tempfile.TemporaryDirectory() as tmp:
            written = generate.write_all(Path(tmp))
            self.assertTrue(written)
            for relative in written:
                committed = REPO / relative
                self.assertTrue(committed.exists(), relative)
                self.assertEqual(
                    (Path(tmp) / relative).read_bytes(), committed.read_bytes(),
                    f'{relative} non aggiornato: python3 tool/icon/generate.py')


if __name__ == '__main__':
    unittest.main()
