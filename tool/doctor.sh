#!/usr/bin/env bash

set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
missing=0

ok() { printf '  ok       %s\n' "$*"; }
need() { printf '  MISSING  %s\n' "$*"; missing=$((missing + 1)); }
note() { printf '  --       %s\n' "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

required() {
  local tool="$1" why="$2"
  if has "$tool"; then ok "$tool ($why)"; else need "$tool: $why"; fi
}

optional() {
  local tool="$1" why="$2"
  if has "$tool"; then ok "$tool ($why)"; else note "$tool not found: $why"; fi
}

echo 'Required'
required git 'submodules and versioning'
required flutter 'every build and test'
required dart 'tool/ scripts'
required cargo 'the build hook compiles Concord, the Helper and rust_api, even for flutter test'
required rustup 'the toolchain pinned in concord/rust-toolchain.toml'

for module in concord plugins/prism_ui; do
  if [ -n "$(ls -A "$root/$module" 2>/dev/null)" ]; then
    ok "submodule $module"
  else
    need "submodule $module is empty: make submodules"
  fi
done

toolchain_file="$root/concord/rust-toolchain.toml"
if [ -f "$toolchain_file" ] && has rustup; then
  channel="$(sed -n 's/^channel = "\(.*\)"/\1/p' "$toolchain_file")"
  if rustup toolchain list | grep -q "^$channel"; then
    ok "Rust $channel"
    installed="$(rustup target list --installed --toolchain "$channel" 2>/dev/null)"
    absent=()
    for target in $(sed -n '/^targets/,/]/s/^ *"\(.*\)",*$/\1/p' "$toolchain_file"); do
      grep -qx "$target" <<<"$installed" || absent+=("$target")
    done
    if [ "${#absent[@]}" -gt 0 ]; then
      note "Rust targets not installed (only needed to build for them): ${absent[*]}"
    fi
  else
    need "Rust $channel: rustup toolchain install $channel"
  fi
fi

if [ -n "${all_proxy:-}${ALL_PROXY:-}" ]; then
  note 'all_proxy is set; cargo fetches through it, so unset it if the proxy is not running'
fi

echo
echo 'Android'
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [ -z "$sdk" ]; then
  case "$(uname -s)" in
    Darwin) sdk="$HOME/Library/Android/sdk" ;;
    *) sdk="$HOME/Android/Sdk" ;;
  esac
fi
ndk_version="$(sed -n 's/^ndkVersion = "\(.*\)"/\1/p' "$root/android/gradle/libs.versions.toml")"
if [ -d "$sdk/ndk/$ndk_version" ]; then
  ok "NDK $ndk_version"
else
  note "NDK $ndk_version not in $sdk/ndk: needed for package-android and Gradle builds"
fi
is_jdk17() { [ -x "$1/bin/java" ] && "$1/bin/java" -version 2>&1 | grep -q 'version "17'; }
if [ -n "${JAVA_HOME:-}" ] && is_jdk17 "$JAVA_HOME"; then
  ok "JDK 17 (JAVA_HOME)"
elif has brew && is_jdk17 "$(brew --prefix openjdk@17 2>/dev/null)/libexec/openjdk.jdk/Contents/Home"; then
  note 'JDK 17 is the Homebrew openjdk@17 keg: export JAVA_HOME to it before Gradle (see .agents/commands.md)'
else
  note 'no JDK 17 in JAVA_HOME: Gradle builds need one'
fi

echo
echo 'Optional'
optional pre-commit 'make hooks'
optional flutter_rust_bridge_codegen 'make frb'
optional rsvg-convert 'make icons, make status-icons'
optional cwebp 'make icons'
optional node 'make site'
optional gh 'release metadata in make site'
case "$(uname -s)" in
  Darwin) optional appdmg 'package-macos installs it through npm when missing' ;;
  Linux)
    for tool in rpm patchelf; do
      optional "$tool" 'package-linux installs it through apt when missing'
    done
    ;;
esac

echo
if [ "$missing" -gt 0 ]; then
  echo "$missing required item(s) missing."
  exit 1
fi
echo 'Everything required is in place.'
