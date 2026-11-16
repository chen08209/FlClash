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
required go 'the build hook compiles the Go core, even for flutter test'
required cargo 'the build hook compiles the Helper and rust_api'

for module in core/Clash.Meta plugins/prism_ui; do
  if [ -n "$(ls -A "$root/$module" 2>/dev/null)" ]; then
    ok "submodule $module"
  else
    need "submodule $module is empty: make submodules"
  fi
done

go_version="$(sed -n 's/^go //p' "$root/core/go.mod")"
if has go; then
  installed="$(go env GOVERSION 2>/dev/null | sed 's/^go//')"
  if [ "$(printf '%s\n%s\n' "$go_version" "$installed" | sort -V | head -1)" = "$go_version" ]; then
    ok "Go $installed (core/go.mod asks for $go_version)"
  else
    need "Go $go_version or newer for core/go.mod, found $installed"
  fi
fi

if [ -n "${all_proxy:-}${ALL_PROXY:-}" ]; then
  note 'all_proxy is set; cargo and go fetch through it, so unset it if the proxy is not running'
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
optional rsvg-convert 'make status-icons'
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
