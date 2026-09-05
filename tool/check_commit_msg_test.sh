#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
checker="$script_dir/check_commit_msg.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

message_file="$temp_dir/COMMIT_EDITMSG"
failures=0

run() {
  printf '%s\n' "$@" >"$message_file"
  set +e
  bash "$checker" "$message_file" >"$temp_dir/out" 2>"$temp_dir/err"
  local status=$?
  set -e
  return $status
}

expect_pass() {
  local name="$1"
  shift
  if run "$@"; then
    return
  fi
  echo "FAIL: $name should be accepted" >&2
  cat "$temp_dir/err" >&2
  failures=$((failures + 1))
}

expect_fail() {
  local name="$1"
  local needle="$2"
  shift 2
  if run "$@"; then
    echo "FAIL: $name should be rejected" >&2
    failures=$((failures + 1))
    return
  fi
  if ! grep -q "$needle" "$temp_dir/err"; then
    echo "FAIL: $name did not explain the problem ($needle)" >&2
    cat "$temp_dir/err" >&2
    failures=$((failures + 1))
  fi
}

expect_stderr() {
  local name="$1"
  local needle="$2"
  shift 2
  expect_pass "$name" "$@"
  if ! grep -q "$needle" "$temp_dir/err"; then
    echo "FAIL: $name should have warned about $needle" >&2
    failures=$((failures + 1))
  fi
}

expect_pass 'a conventional subject' 'fix(core): keep the socket alive'
# A message left uncleaned starts with blank lines, and the subject then sits
# below line one. Cutting the body from line two would put the subject in it.
expect_fail 'a leading blank line does not hide a bad trailer' \
  'Unknown changelog trailer' \
  '' \
  'fix(core): keep the socket alive' \
  '' \
  'Changelog-de: nope'
expect_pass 'a leading blank line still finds the subject' \
  '' \
  'fix(core): keep the socket alive'
expect_pass 'a merge subject' 'Merge branch main into dev'
expect_pass 'a fixup subject' 'fixup! fix(core): keep the socket alive'
expect_pass 'a changelog trailer' \
  'feat(profiles): support override scripts' \
  '' \
  'Changelog: Per-profile override scripts'
expect_pass 'a breaking commit with its footer' \
  'feat(backup)!: new archive layout' \
  '' \
  'BREAKING CHANGE: Archives from 0.8.95 and earlier need re-import'
expect_pass 'a changelog type override' \
  'refactor(tray): replace the fork' \
  '' \
  'Changelog: Rebuilt tray' \
  'Changelog-Type: perf'

expect_fail 'an empty message' 'empty' ''
expect_fail 'a non conventional subject' 'Conventional Commits' 'Optimize core service'
expect_fail 'an upper case description' 'lower case' 'fix(core): Keep the socket alive'
expect_pass 'a camel case identifier' 'fix(ui): AppBar text is truncated'
expect_pass 'an acronym' 'fix(core): DNS leaks after wake'
expect_fail 'an upper case first word before punctuation' 'lower case' \
  'fix(core): Keep, or drop, the socket'
expect_fail 'a trailing period' 'period' 'fix(core): keep the socket alive.'
expect_fail 'a changelog translation trailer' 'Changelog-zh-CN' \
  'feat: x' '' 'Changelog-zh-CN: 新功能'
expect_fail 'an unknown changelog trailer' 'Changelog-de' \
  'feat: x' '' 'Changelog-de: Neu'
expect_fail 'a breaking translation trailer' 'Breaking-zh-CN' \
  'feat: x' '' 'Breaking-zh-CN: 变更'
expect_fail 'an unknown changelog type' 'Changelog-Type' \
  'chore: x' '' 'Changelog: X' 'Changelog-Type: docs'
expect_fail 'a breaking marker with no footer' 'BREAKING CHANGE' \
  'feat(core)!: drop the legacy socket'
expect_fail 'an agent co-author' 'coding agent' \
  'fix(core): keep the socket alive' \
  '' \
  'Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>'
expect_fail 'a bot co-author' 'coding agent' \
  'fix(core): keep the socket alive' \
  '' \
  'Co-authored-by: github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>'
expect_pass 'a human co-author' \
  'fix(core): keep the socket alive' \
  '' \
  'Co-authored-by: Feng Chen <chen08209@gmail.com>'

expect_stderr 'a user facing commit without a trailer' 'Changelog:' \
  'feat(profiles): support override scripts'

if ((failures > 0)); then
  echo "$failures check(s) failed" >&2
  exit 1
fi

echo 'check_commit_msg.sh behaves as documented.'
