#!/usr/bin/env bash
set -euo pipefail

mode="${1:-minor}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pubspec_file="${PUBSPEC_FILE:-"$script_dir/../pubspec.yaml"}"

usage() {
  cat <<'EOF'
Usage: tool/bump_version.sh [major|minor|all]

major  Bump app version patch: 0.8.94 -> 0.8.95
minor  Bump build number: YYYYMMDDNN, NN is today's build count from 01 to 99 (default)
all    Bump both app version patch and build number
EOF
}

if [[ "$mode" != "major" && "$mode" != "minor" && "$mode" != "all" ]]; then
  usage >&2
  exit 64
fi

version_line="$(grep -E '^version: [0-9]+\.[0-9]+\.[0-9]+\+[0-9]{10}$' "$pubspec_file" || true)"
if [[ -z "$version_line" ]]; then
  echo "No valid version line found in $pubspec_file" >&2
  exit 1
fi

version="${version_line#version: }"
app_version="${version%%+*}"
build_number="${version##*+}"

if [[ "$mode" == "major" || "$mode" == "all" ]]; then
  IFS='.' read -r major minor patch <<<"$app_version"
  patch=$((patch + 1))
  app_version="$major.$minor.$patch"
fi

if [[ "$mode" == "minor" || "$mode" == "all" ]]; then
  today="$(date +%Y%m%d)"
  build_date="${build_number:0:8}"
  build_count="${build_number:8:2}"
  if [[ "$build_date" == "$today" ]]; then
    count=$((10#$build_count + 1))
    if ((count > 99)); then
      echo "Build count for $today exceeds 99" >&2
      exit 1
    fi
  else
    count=1
  fi
  build_number="$today$(printf '%02d' "$count")"
fi

new_version="$app_version+$build_number"
tmp_file="$(mktemp)"
sed "s/^version: .*/version: $new_version/" "$pubspec_file" >"$tmp_file"
mv "$tmp_file" "$pubspec_file"

echo "$version -> $new_version"
