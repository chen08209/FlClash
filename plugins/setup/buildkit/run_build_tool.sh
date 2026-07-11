#!/usr/bin/env bash

set -e

BASEDIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

if [ ! -f "$PROJECT_DIR/pubspec.yaml" ] || [ ! -d "$PROJECT_DIR/core" ]; then
  echo "Error: Could not find project root at $PROJECT_DIR" >&2
  exit 1
fi

BUILD_TOOL_PKG_DIR="$BASEDIR/build_tool"
BUILD_TOOL_TEMP_DIR="$PROJECT_DIR/build/setup_build_tool"

mkdir -p "$BUILD_TOOL_TEMP_DIR"
cd "$BUILD_TOOL_TEMP_DIR"

if [[ -z ${FLUTTER_ROOT:-} ]]; then
  DART=dart
else
  DART="$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart"
fi

cat << EOF > "pubspec.yaml"
name: setup_build_tool_runner
version: 1.0.0
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  build_tool:
    path: "$BUILD_TOOL_PKG_DIR"
EOF

mkdir -p "bin"

cat << EOF > "bin/build_tool_runner.dart"
import 'package:build_tool/build_tool.dart' as build_tool;
void main(List<String> args) {
  build_tool.runMain(args);
}
EOF

if ! [ -x "$(command -v shasum)" ] && [ -x "$(command -v sha1sum)" ]; then
  shopt -s expand_aliases
  alias shasum="sha1sum"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  PACKAGE_HASH=$(ls -lTR "$BUILD_TOOL_PKG_DIR" | shasum)
else
  PACKAGE_HASH=$(ls -lR --full-time "$BUILD_TOOL_PKG_DIR" | shasum)
fi

PACKAGE_HASH_FILE=".package_hash"

if [ -f "$PACKAGE_HASH_FILE" ]; then
    EXISTING_HASH=$(cat "$PACKAGE_HASH_FILE")
    if [ "$PACKAGE_HASH" != "$EXISTING_HASH" ]; then
        rm "$PACKAGE_HASH_FILE"
    fi
fi

if [ ! -f "$PACKAGE_HASH_FILE" ]; then
    "$DART" pub get --no-precompile
    "$DART" compile kernel bin/build_tool_runner.dart
    echo "$PACKAGE_HASH" > "$PACKAGE_HASH_FILE"
fi

if [ ! -f "bin/build_tool_runner.dill" ]; then
  "$DART" compile kernel bin/build_tool_runner.dart
fi

set +e

"$DART" bin/build_tool_runner.dill "$@" --root-dir "$PROJECT_DIR"

exit_code=$?

if [ $exit_code == 253 ]; then
  "$DART" pub get --no-precompile
  "$DART" compile kernel bin/build_tool_runner.dart
  "$DART" bin/build_tool_runner.dill "$@" --root-dir "$PROJECT_DIR"
  exit_code=$?
fi

exit $exit_code
