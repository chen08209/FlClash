#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
checker="$script_dir/check_comment_density.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

repo="$temp_dir/repo"
mkdir -p "$repo"
git -C "$repo" init --quiet
git -C "$repo" config user.email 'test@example.com'
git -C "$repo" config user.name 'Test'
printf 'void main() {}\n' >"$repo/tracked.dart"
git -C "$repo" add tracked.dart
git -C "$repo" commit --quiet -m 'seed'

failures=0
status=0

dense() {
  local comments="$1" code="$2" i
  echo 'void main() {'
  for i in $(seq 1 "$comments"); do echo "  // step $i explained"; done
  for i in $(seq 1 "$code"); do echo "  step$i();"; done
  echo '}'
}

run_stdin() {
  local target="${1:-}"
  local payload='{"tool_name":"apply_patch","tool_input":{}}'
  if [ -n "$target" ]; then
    payload="$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$target")"
  fi
  set +e
  printf '%s' "$payload" | (cd "$repo" && bash "$checker") >"$temp_dir/out" 2>"$temp_dir/err"
  status=$?
  set -e
}

run_argv() {
  set +e
  bash "$checker" "$@" >"$temp_dir/out" 2>"$temp_dir/err"
  status=$?
  set -e
}

expect_over() {
  local name="$1" path="$2"
  shift 2
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
  run_stdin "$path"
  if [ "$status" -ne 2 ]; then
    echo "FAIL: $name should exit 2, got $status" >&2
    failures=$((failures + 1))
  elif ! grep -q 'added lines are standalone comments' "$temp_dir/err"; then
    echo "FAIL: $name should report the density" >&2
    failures=$((failures + 1))
  fi
}

expect_under() {
  local name="$1" path="$2"
  shift 2
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
  run_stdin "$path"
  if [ "$status" -ne 0 ] || [ -s "$temp_dir/err" ]; then
    echo "FAIL: $name should pass, got $status" >&2
    cat "$temp_dir/err" >&2
    failures=$((failures + 1))
  fi
}

expect_over 'a diff that is a quarter comments' "$repo/dense.dart" "$(dense 8 24)"
expect_over 'block comment bodies count as comments' "$repo/block.kt" \
  '/**' \
  ' * first constraint' \
  ' * second constraint' \
  ' * third constraint' \
  ' * fourth constraint' \
  ' * fifth constraint' \
  ' * sixth constraint' \
  ' * seventh constraint' \
  ' */' \
  "$(dense 0 24)"
expect_over 'first-party plugin source is checked' \
  "$repo/plugins/proxy/lib/dense.dart" "$(dense 8 24)"
expect_under 'a diff with a few real comments' "$repo/sparse.dart" "$(dense 2 40)"
expect_under 'a small diff below the line floor' "$repo/tiny.dart" \
  'void main() {' '  // why this retries' '}'
expect_under 'code with no comments at all' "$repo/clean.dart" "$(dense 0 40)"

expect_under 'analyzer directives do not count' "$repo/directives.dart" \
  "$(
    echo 'void main() {'
    for i in $(seq 1 8); do echo '  // ignore: avoid_print'; done
    for i in $(seq 1 24); do echo "  step$i();"; done
    echo '}'
  )"
expect_under 'a license header does not count' "$repo/license.dart" \
  "$(
    for i in $(seq 1 8); do echo '// Copyright 2026 The FlClash Authors.'; done
    for i in $(seq 1 24); do echo "final v$i = $i;"; done
  )"
expect_under 'go pointer dereferences are not comments' "$repo/deref.go" \
  "$(
    echo 'package main'
    echo 'func f(p *int) {'
    for i in $(seq 1 30); do echo '	*p = 1'; done
    echo '}'
  )"
expect_under 'a generated file is skipped' "$repo/model.g.dart" "$(dense 20 4)"
expect_under 'generated plugin bindings are skipped' \
  "$repo/plugins/rust_api/lib/src/rust/frb_generated.io.dart" "$(dense 20 4)"
expect_under 'the intl_utils localization class is skipped' "$repo/lib/l10n/l10n.dart" "$(dense 20 4)"
expect_under 'a vendored upstream file is skipped' "$repo/Clash.Meta/hub.go" "$(dense 20 4)"
expect_under 'a markdown file is skipped' "$repo/notes.md" "$(dense 20 4)"

expect_over 'a dense change to a tracked file' "$repo/tracked.dart" "$(dense 8 24)"
git -C "$repo" checkout --quiet -- tracked.dart

printf '%s\n' "$(dense 8 24)" >"$repo/argv.dart"
run_argv "$repo/argv.dart"
if [ "$status" -ne 1 ]; then
  echo "FAIL: argv mode should exit 1 when over the cap, got $status" >&2
  failures=$((failures + 1))
fi

run_argv "$repo/sparse.dart"
if [ "$status" -ne 0 ]; then
  echo "FAIL: argv mode should exit 0 under the cap, got $status" >&2
  cat "$temp_dir/err" >&2
  failures=$((failures + 1))
fi

set +e
COMMENT_DENSITY_MAX=50 bash "$checker" "$repo/argv.dart" >"$temp_dir/out" 2>"$temp_dir/err"
status=$?
set -e
if [ "$status" -ne 0 ]; then
  echo 'FAIL: COMMENT_DENSITY_MAX should raise the cap' >&2
  failures=$((failures + 1))
fi

set +e
COMMENT_DENSITY_MAX=1 bash "$checker" "$repo/sparse.dart" >"$temp_dir/out" 2>"$temp_dir/err"
status=$?
set -e
if [ "$status" -ne 1 ]; then
  echo 'FAIL: COMMENT_DENSITY_MAX should lower the cap' >&2
  failures=$((failures + 1))
fi

# Codex apply_patch payloads carry no file path, so the whole working tree is scanned.
run_stdin
if [ "$status" -ne 2 ]; then
  echo "FAIL: a payload without a file path should scan the working tree, got $status" >&2
  failures=$((failures + 1))
fi

rm -f \
  "$repo/dense.dart" \
  "$repo/block.kt" \
  "$repo/argv.dart" \
  "$repo/plugins/proxy/lib/dense.dart"
run_stdin
if [ "$status" -ne 0 ] || [ -s "$temp_dir/err" ]; then
  echo "FAIL: a tree under the cap should pass silently, got $status" >&2
  cat "$temp_dir/err" >&2
  failures=$((failures + 1))
fi

space_path="$repo/path with space/dense.dart"
mkdir -p "$(dirname "$space_path")"
printf '%s\n' "$(dense 8 24)" >"$space_path"
run_stdin
if [ "$status" -ne 2 ]; then
  echo "FAIL: fallback scanning should handle paths with spaces, got $status" >&2
  failures=$((failures + 1))
fi
rm -f "$space_path"

if ((failures > 0)); then
  echo "$failures check(s) failed" >&2
  exit 1
fi

echo 'check_comment_density.sh behaves as documented.'
