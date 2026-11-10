#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != '--apk' ) ]]; then
  echo 'Usage: bash tool/check.sh [--apk]' >&2
  exit 2
fi
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
if [[ "${1:-}" == '--apk' ]]; then
  flutter build apk --release --no-pub
fi
