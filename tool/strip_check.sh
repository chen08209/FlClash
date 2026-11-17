#!/usr/bin/env bash
# Strips the rsFeature checks in a scratch copy of the working tree and
# analyzes the result, so dev keeps what the rs line builds on compiling.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

rsync -a --exclude .dart_tool/build --exclude build --exclude core/Clash.Meta \
  "$root/" "$scratch/"
mkdir -p "$scratch/core/Clash.Meta/component/ca"
cp "$root/core/Clash.Meta/component/ca/ca-certificates.crt" \
  "$scratch/core/Clash.Meta/component/ca/" 2>/dev/null || true

cd "$scratch"
# `dart run` runs the build hooks, and the Go core they build is left out above.
perl -pi -e 's/build_assets: true/build_assets: false/' pubspec.yaml
flutter pub get
dart run tool/strip_rs_feature.dart
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
