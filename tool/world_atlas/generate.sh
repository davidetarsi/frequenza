#!/usr/bin/env bash
# Regenerates the world atlas from Natural Earth and the system tzdata.
set -euo pipefail
cd "$(dirname "$0")/../.."
data=build/world_atlas
base=https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson
mkdir -p "$data"
for name in ne_110m_land ne_50m_admin_0_countries; do
  [[ -f "$data/$name.geojson" ]] || curl -sSfL -o "$data/$name.geojson" "$base/$name.geojson"
done
out=lib/features/journey/data/world_atlas.g.dart
python3 -I tool/world_atlas/generate.py "$data/ne_110m_land.geojson" \
  "$data/ne_50m_admin_0_countries.geojson" /usr/share/zoneinfo/zone.tab "$out"
dart format "$out"
