#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart run easy_localization:generate -S assets/translations -O lib/l10n -o app_translations.g.dart
dart run easy_localization:generate -S assets/translations -O lib/l10n -o locale_keys.g.dart -f keys
dart format lib/l10n
