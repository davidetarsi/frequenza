"""Genera l'icona di Frequenza, la manopola, in tutti i formati Android.

Le forme sono quelle della tavola dei loghi (viewBox 108):
  rect rx26 #203C33; anello tratteggiato r36 #E4EBC5 al 70%, tratto 3;
  disco r27 #354B3F con bordo #8E9A80 da 2; cerchio r13 #203C33 da 2;
  tacca x51.5 y30 w5 h14 rx2.5 #AD4823.

Uso: python3 tool/icon/generate.py  (solo libreria standard).
"""

import math
import struct
import sys
import zlib
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
RES = Path('android/app/src/main/res')

BACKGROUND = (0x20, 0x3C, 0x33)
RING = (0xE4, 0xEB, 0xC5)
RING_ALPHA = 0.7
KNOB = (0x35, 0x4B, 0x3F)
KNOB_EDGE = (0x8E, 0x9A, 0x80)
MARKER = (0xAD, 0x48, 0x23)

CENTER = 54.0
DASHES = 32
DASH_LENGTH = 1.6
RING_RADIUS = 36.0
RING_WIDTH = 3.0
# Le icone adattive mostrano con certezza solo il cerchio di raggio 33:
# la manopola dei vettori si rimpicciolisce finché l'anello ci sta dentro.
SAFE_RADIUS = 32.9
ADAPTIVE_SCALE = SAFE_RADIUS / math.hypot(RING_RADIUS + RING_WIDTH / 2, DASH_LENGTH / 2)

LEGACY_SIZES = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}


def _dash_angles():
    step = 2 * math.pi / DASHES
    return [i * step for i in range(DASHES)]


# --- PNG ---------------------------------------------------------------------

def _box(px, py, hx, hy):
    qx, qy = abs(px) - hx, abs(py) - hy
    outside = math.hypot(max(qx, 0), max(qy, 0))
    return outside + min(max(qx, qy), 0)


def _rounded_square(x, y, radius):
    half = CENTER - radius
    return _box(x - CENTER, y - CENTER, half, half) - radius


def _capsule(x, y):
    dy = min(max(y, 32.5), 41.5)
    return math.hypot(x - CENTER, y - dy) - 2.5


def _ring_dashes(x, y):
    dx, dy = x - CENTER, y - CENTER
    radius = math.hypot(dx, dy)
    if abs(radius - RING_RADIUS) > RING_WIDTH:
        return abs(radius - RING_RADIUS) - RING_WIDTH / 2
    # Basta il trattino più vicino: gli altri distano almeno un intervallo.
    step = 2 * math.pi / DASHES
    angle = round(math.atan2(dy, dx) / step) * step
    c, s = math.cos(angle), math.sin(angle)
    radial = dx * c + dy * s - RING_RADIUS
    tangent = -dx * s + dy * c
    return _box(radial, tangent, RING_WIDTH / 2, DASH_LENGTH / 2)


def _layers(rounded):
    """(colore, alfa, distanza con segno) dal fondo verso l'alto."""
    corner = 26.0 if rounded else 0.0
    return [
        (BACKGROUND, 1.0, lambda x, y: _rounded_square(x, y, corner)),
        (RING, RING_ALPHA, _ring_dashes),
        (KNOB, 1.0, lambda x, y: math.hypot(x - CENTER, y - CENTER) - 27),
        (KNOB_EDGE, 1.0, lambda x, y: abs(math.hypot(x - CENTER, y - CENTER) - 27) - 1),
        (BACKGROUND, 1.0, lambda x, y: abs(math.hypot(x - CENTER, y - CENTER) - 13) - 1),
        (MARKER, 1.0, _capsule),
    ]


def _pixel(x, y, half_pixel, layers):
    red = green = blue = alpha = 0.0
    for color, opacity, distance in layers:
        coverage = min(max(0.5 - distance(x, y) / (2 * half_pixel), 0.0), 1.0)
        a = coverage * opacity
        if a == 0:
            continue
        keep = 1 - a
        red = color[0] * a + red * keep
        green = color[1] * a + green * keep
        blue = color[2] * a + blue * keep
        alpha = a + alpha * keep
    if alpha == 0:
        return b'\0\0\0\0'
    return bytes(round(c / alpha) for c in (red, green, blue)) + bytes([round(alpha * 255)])


def render_png(size, rounded=True):
    """PNG RGBA della manopola; `rounded=False` per l'icona del Play Store,
    che Google ritaglia da sé."""
    unit = 108 / size
    layers = _layers(rounded)
    raw = bytearray()
    for row in range(size):
        raw.append(0)
        y = (row + 0.5) * unit
        for column in range(size):
            raw += _pixel((column + 0.5) * unit, y, unit / 2, layers)

    def chunk(kind, data):
        body = kind + data
        return struct.pack('>I', len(data)) + body + struct.pack('>I', zlib.crc32(body))

    header = struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', header)
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


# --- Vettori adattivi ---------------------------------------------------------

def _n(value):
    text = f'{value:.3f}'.rstrip('0').rstrip('.')
    return '0' if text == '-0' else text


def _point(x, y):
    s = ADAPTIVE_SCALE
    return CENTER + (x - CENTER) * s, CENTER + (y - CENTER) * s


def _circle(radius):
    """Cerchio in quattro quarti, così i punti estremi sono vertici del path."""
    r = radius * ADAPTIVE_SCALE
    top = (CENTER, CENTER - r)
    corners = [(CENTER + r, CENTER), (CENTER, CENTER + r), (CENTER - r, CENTER), top]
    data = f'M{_n(top[0])},{_n(top[1])}'
    for x, y in corners:
        data += f'A{_n(r)},{_n(r)},0,0,1,{_n(x)},{_n(y)}'
    return data + 'Z'


def _dash(angle):
    c, s = math.cos(angle), math.sin(angle)
    corners = []
    for radial, tangent in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
        r = RING_RADIUS + radial * RING_WIDTH / 2
        t = tangent * DASH_LENGTH / 2
        corners.append(_point(CENTER + r * c - t * s, CENTER + r * s + t * c))
    data = 'M' + 'L'.join(f'{_n(x)},{_n(y)}' for x, y in corners)
    return data + 'Z'


def _marker():
    r = 2.5 * ADAPTIVE_SCALE
    (left, top), (right, bottom) = _point(51.5, 32.5), _point(56.5, 41.5)
    middle = CENTER
    cap_top = top - r
    cap_bottom = bottom + r
    return (f'M{_n(left)},{_n(top)}'
            f'A{_n(r)},{_n(r)},0,0,1,{_n(middle)},{_n(cap_top)}'
            f'A{_n(r)},{_n(r)},0,0,1,{_n(right)},{_n(top)}'
            f'L{_n(right)},{_n(bottom)}'
            f'A{_n(r)},{_n(r)},0,0,1,{_n(middle)},{_n(cap_bottom)}'
            f'A{_n(r)},{_n(r)},0,0,1,{_n(left)},{_n(bottom)}Z')


def _hex(color, alpha=1.0):
    return '#' + f'{round(alpha * 255):02X}' + ''.join(f'{c:02X}' for c in color)


def _fill(data, color, alpha=1.0):
    return f'    <path android:fillColor="{_hex(color, alpha)}" android:pathData="{data}"/>\n'


def _stroke(data, color, width):
    return (f'    <path android:fillColor="#00000000" android:strokeColor="{_hex(color)}" '
            f'android:strokeWidth="{_n(width * ADAPTIVE_SCALE)}" android:pathData="{data}"/>\n')


def _vector(paths):
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<!-- Generato da tool/icon/generate.py: non modificare a mano. -->\n'
            '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
            '    android:width="108dp"\n    android:height="108dp"\n'
            '    android:viewportWidth="108"\n    android:viewportHeight="108">\n'
            + ''.join(paths) + '</vector>\n')


def foreground_xml():
    dashes = ''.join(_dash(angle) for angle in _dash_angles())
    return _vector([
        _fill(dashes, RING, RING_ALPHA),
        _fill(_circle(27), KNOB),
        _stroke(_circle(27), KNOB_EDGE, 2),
        _stroke(_circle(13), BACKGROUND, 2),
        _fill(_marker(), MARKER),
    ])


def monochrome_xml():
    white = (0xFF, 0xFF, 0xFF)
    dashes = ''.join(_dash(angle) for angle in _dash_angles())
    return _vector([
        _fill(dashes, white),
        _stroke(_circle(27), white, 2),
        _stroke(_circle(13), white, 2),
        _fill(_marker(), white),
    ])


ADAPTIVE = '''<?xml version="1.0" encoding="utf-8"?>
<!-- Generato da tool/icon/generate.py: non modificare a mano. -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
    <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>
</adaptive-icon>
'''

BACKGROUND_COLOR = f'''<?xml version="1.0" encoding="utf-8"?>
<!-- Generato da tool/icon/generate.py: non modificare a mano. -->
<resources>
    <color name="ic_launcher_background">#{''.join(f'{c:02X}' for c in BACKGROUND)}</color>
</resources>
'''


def write_all(root):
    """Scrive tutti i file sotto `root` e restituisce i percorsi relativi."""
    files = {
        RES / 'mipmap-anydpi-v26/ic_launcher.xml': ADAPTIVE.encode(),
        RES / 'values/ic_launcher_background.xml': BACKGROUND_COLOR.encode(),
        RES / 'drawable/ic_launcher_foreground.xml': foreground_xml().encode(),
        RES / 'drawable/ic_launcher_monochrome.xml': monochrome_xml().encode(),
    }
    for density, size in LEGACY_SIZES.items():
        files[RES / f'mipmap-{density}/ic_launcher.png'] = render_png(size)
    store = render_png(512, rounded=False)
    for locale in ('it-IT', 'en-US'):
        files[Path(f'fastlane/metadata/android/{locale}/images/icon.png')] = store
    for relative, content in files.items():
        target = Path(root) / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)
    return list(files)


if __name__ == '__main__':
    for path in write_all(Path(sys.argv[1]) if len(sys.argv) > 1 else REPO):
        print(path)
