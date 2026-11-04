#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FLUTTER_ROOT=${FLUTTER_ROOT:-"$ROOT_DIR/.toolchains/flutter-3.47.6"}
CARGO_HOME=${CARGO_HOME:-"$ROOT_DIR/.toolchains/cargo"}
RUSTUP_HOME=${RUSTUP_HOME:-"$ROOT_DIR/.toolchains/rustup"}
PUB_CACHE=${PUB_CACHE:-"$HOME/.pub-cache"}
export CARGO_HOME RUSTUP_HOME PUB_CACHE
export RUSTUP_TOOLCHAIN=1.99.0
export PATH="$ROOT_DIR/.toolchains/bin:$FLUTTER_ROOT/bin:$CARGO_HOME/bin:$PUB_CACHE/bin:$PATH"
export APP_TRAFFIC_CUSTOM_BUILD=true
export APP_UPDATE_REPOSITORY=${APP_UPDATE_REPOSITORY:-"$(gh api user --jq .login)/FlClash"}

cd "$ROOT_DIR"
exec dart setup.dart macos --env stable "$@"
