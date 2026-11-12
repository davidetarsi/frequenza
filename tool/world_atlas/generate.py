"""Generates lib/features/journey/data/world_atlas.g.dart.

Inputs, all public domain:
- Natural Earth 1:110m land and 1:50m admin-0 countries (GeoJSON), downloaded
  by tool/world_atlas/generate.sh into build/world_atlas/;
- zone.tab and the IANA time zone rules installed with the system tzdata.

Usage: python3 -I tool/world_atlas/generate.py LAND COUNTRIES ZONE_TAB OUT
"""

import datetime as dt
import json
import sys
from collections import Counter
from zoneinfo import ZoneInfo

STEP = 2.5
NORTH, SOUTH = 80.0, -60.0
YEAR = 2027
RULES = ['none', 'eu', 'northAmerica', 'australia', 'newZealand', 'chile']
MAIN_ZONES = {
    'RU': 'Europe/Moscow',
    'BR': 'America/Sao_Paulo',
    'AU': 'Australia/Sydney',
    'CA': 'America/Toronto',
    'MX': 'America/Mexico_City',
    'ID': 'Asia/Jakarta',
    'KZ': 'Asia/Almaty',
    'CD': 'Africa/Kinshasa',
}


def rings(geometry):
    polygons = (
        [geometry['coordinates']]
        if geometry['type'] == 'Polygon'
        else geometry['coordinates']
    )
    for polygon in polygons:
        for ring in polygon:
            xs = [p[0] for p in ring]
            ys = [p[1] for p in ring]
            yield ring, (min(xs), min(ys), max(xs), max(ys))


def inside(x, y, all_rings):
    hit = False
    for ring, (x0, y0, x1, y1) in all_rings:
        if not (x0 <= x <= x1 and y0 <= y <= y1):
            continue
        j = len(ring) - 1
        for i in range(len(ring)):
            xi, yi = ring[i][0], ring[i][1]
            xj, yj = ring[j][0], ring[j][1]
            if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                hit = not hit
            j = i
    return hit


def dot_rows(land_path):
    land = json.load(open(land_path))
    all_rings = [r for f in land['features'] for r in rings(f['geometry'])]
    rows = []
    lat = NORTH - STEP / 2
    while lat > SOUTH:
        row = ''
        lon = -180 + STEP / 2
        while lon < 180:
            row += '1' if inside(lon, lat, all_rings) else '0'
            lon += STEP
        rows.append(row)
        lat -= STEP
    return rows


def parse_coordinate(text):
    sign = -1 if text[0] == '-' else 1
    digits = text[1:]
    degrees_len = 2 if len(digits) in (4, 6) else 3
    degrees = int(digits[:degrees_len])
    minutes = int(digits[degrees_len:degrees_len + 2])
    seconds = int(digits[degrees_len + 2:] or 0)
    return sign * (degrees + minutes / 60 + seconds / 3600)


def split_coordinates(text):
    for i in range(1, len(text)):
        if text[i] in '+-':
            return parse_coordinate(text[:i]), parse_coordinate(text[i:])
    raise ValueError(text)


def zone_tab(path):
    for line in open(path):
        if line.startswith('#') or not line.strip():
            continue
        code, coordinates, name = line.split('\t')[:3]
        lat, lon = split_coordinates(coordinates)
        yield code, round(lat, 2), round(lon, 2), name.strip()


def nth_sunday(year, month, n):
    day = dt.datetime(year, month, 1, tzinfo=dt.timezone.utc)
    day += dt.timedelta(days=(6 - day.weekday()) % 7)
    return day + dt.timedelta(weeks=n - 1)


def last_sunday(year, month):
    following = dt.datetime(year + (month == 12), month % 12 + 1, 1,
                            tzinfo=dt.timezone.utc)
    day = following - dt.timedelta(days=1)
    return day - dt.timedelta(days=(day.weekday() + 1) % 7)


def rule_offset(rule, std, t):
    """Mirrors lib/features/journey/domain/local_clock.dart."""
    y, hour = t.year, dt.timedelta(hours=1)
    local = dt.timedelta(minutes=std)
    if rule == 'none':
        on = False
    elif rule == 'eu':
        on = last_sunday(y, 3) + hour <= t < last_sunday(y, 10) + hour
    elif rule == 'northAmerica':
        on = (nth_sunday(y, 3, 2) + 2 * hour - local <= t <
              nth_sunday(y, 11, 1) + hour - local)
    elif rule == 'australia':
        on = not (nth_sunday(y, 4, 1) + 2 * hour - local <= t <
                  nth_sunday(y, 10, 1) + 2 * hour - local)
    elif rule == 'newZealand':
        on = not (nth_sunday(y, 4, 1) + 2 * hour - local <= t <
                  last_sunday(y, 9) + 2 * hour - local)
    elif rule == 'chile':
        on = not (nth_sunday(y, 4, 1) + 3 * hour <= t <
                  nth_sunday(y, 9, 1) + 4 * hour)
    return std + (60 if on else 0)


def classify(name):
    zone = ZoneInfo(name)
    start = dt.datetime(YEAR, 1, 1, 12, tzinfo=dt.timezone.utc)
    samples = [start + dt.timedelta(days=d) for d in range(365)]
    offsets = [int(t.astimezone(zone).utcoffset().total_seconds() // 60)
               for t in samples]
    if len(set(offsets)) == 1:
        return offsets[0], 'none', True
    std = min(offsets)
    for rule in RULES[1:]:
        misses = sum(rule_offset(rule, std, t) != o
                     for t, o in zip(samples, offsets))
        if misses <= 2:
            return std, rule, True
    return Counter(offsets).most_common(1)[0][0], 'none', False


def main(land_path, countries_path, zone_tab_path, out_path):
    rows = dot_rows(land_path)

    centroids = {}
    for feature in json.load(open(countries_path))['features']:
        p = feature['properties']
        code = p.get('ISO_A2_EH') or p.get('ISO_A2')
        if code and len(code) == 2 and code.isalpha():
            centroids.setdefault(code, (round(p['LABEL_Y'], 2),
                                        round(p['LABEL_X'], 2)))

    zones, zone_index, country_zones, unmatched = [], {}, {}, []
    for code, lat, lon, name in zone_tab(zone_tab_path):
        centroids.setdefault(code, (lat, lon))
        std, rule, matched = classify(name)
        if not matched:
            unmatched.append(name)
        key = (std, rule)
        if key not in zone_index:
            zone_index[key] = len(zones)
            zones.append(key)
        entry = (zone_index[key], lat, lon)
        entries = country_zones.setdefault(code, [])
        if MAIN_ZONES.get(code) == name:
            entries.insert(0, entry)
        else:
            entries.append(entry)

    for code, entries in country_zones.items():
        # One zone: a single entry. Several: every city, for nearest lookup.
        if len({e[0] for e in entries}) == 1:
            country_zones[code] = entries[:1]

    out = [
        '// GENERATED by tool/world_atlas/generate.py. Do not edit by hand.',
        '// Sources: Natural Earth (public domain), IANA tz database.',
        '',
        "import '../domain/dst_rule.dart';",
        '',
        f'const worldDotStep = {STEP};',
        f'const worldDotNorth = {NORTH};',
        '',
        '/// Land cells from north to south, west to east: `1` means land.',
        'const worldDotRows = <String>[',
        *[f"  '{r}'," for r in rows],
        '];',
        '',
        '/// Country label points from Natural Earth, keyed by ISO 3166 alpha-2.',
        'const countryCentroids = <String, (double, double)>{',
        *[f"  '{c}': ({la}, {lo})," for c, (la, lo) in sorted(centroids.items())],
        '};',
        '',
        '/// Standard offset in minutes and daylight saving rule.',
        'const timeZones = <(int, DstRule)>[',
        *[f'  ({std}, DstRule.{rule}),' for std, rule in zones],
        '];',
        '',
        '/// Reference cities of each country with their zone; the first is the main one.',
        'const countryZones = <String, List<(int, double, double)>>{',
        *[f"  '{c}': [{', '.join(f'({i}, {la}, {lo})' for i, la, lo in e)}],"
          for c, e in sorted(country_zones.items())],
        '};',
        '',
    ]
    open(out_path, 'w').write('\n'.join(out))
    multi = sum(len(e) > 1 for e in country_zones.values())
    print(f'rows {len(rows)}x{len(rows[0])}, land cells '
          f'{sum(r.count("1") for r in rows)}, countries {len(centroids)}, '
          f'zones {len(zones)}, multi-zone countries {multi}')
    print('unclassified (standard offset used):', ', '.join(unmatched) or '-')


if __name__ == '__main__':
    main(*sys.argv[1:5])
