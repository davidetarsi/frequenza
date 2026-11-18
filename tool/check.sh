#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != '--apk' ) ]]; then
  echo 'Usage: bash tool/check.sh [--apk]' >&2
  exit 2
fi
flutter pub get
bash tool/generate_l10n.sh
dart run build_runner build --delete-conflicting-outputs
# The diary's schema in the repo must match the code: migrations are
# tested against it.
schema_dir="$(mktemp -d)"
trap 'rm -rf "$schema_dir"' EXIT
dart run drift_dev schema dump lib/features/diary/data/diary_database.dart "$schema_dir/" >/dev/null
for dump in "$schema_dir"/*.json; do
  if ! cmp -s "$dump" "drift_schemas/diary/$(basename "$dump")"; then
    echo "drift_schemas/diary/$(basename "$dump") is out of date: run" >&2
    echo "  dart run drift_dev schema dump lib/features/diary/data/diary_database.dart drift_schemas/diary/" >&2
    exit 1
  fi
done
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze --no-pub
node --test .github/scripts/version.test.cjs
python3 -m unittest discover -s tool -p 'test_*.py'
flutter test --no-pub --reporter expanded
if [[ "${1:-}" == '--apk' ]]; then
  flutter build apk --release --no-pub
fi
