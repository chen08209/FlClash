#!/usr/bin/env bash
# Fetches the SQLite amalgamation into third_party/sqlite3/ so the sqlite3
# Dart package can compile libsqlite3 from source (see hooks.user_defines.sqlite3
# in pubspec.yaml). The prebuilt binary the package downloads by default is
# linked against glibc 2.33 and won't load on the Ubuntu 20.04 (glibc 2.31)
# target, so Linux builds compile from this source instead.
set -euo pipefail

version=3460000
year=2024
src_dir="third_party/sqlite3"
zip="/tmp/sqlite-amalgamation-${version}.zip"
url="https://www.sqlite.org/${year}/sqlite-amalgamation-${version}.zip"

mkdir -p "$src_dir"
curl -fsSL "$url" -o "$zip"
unzip -o "$zip" -d /tmp/sqlite > /dev/null
mv -f "/tmp/sqlite/sqlite-amalgamation-${version}/sqlite3.c" "$src_dir/sqlite3.c"
mv -f "/tmp/sqlite/sqlite-amalgamation-${version}/sqlite3.h" "$src_dir/sqlite3.h"
rm -rf /tmp/sqlite "$zip"
echo "Fetched SQLite amalgamation $version into $src_dir"
