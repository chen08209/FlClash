#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generator="$script_dir/generate_release_notes.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

repo="$temp_dir/repo"
git init --quiet --initial-branch=main "$repo"
git -C "$repo" config user.email "release-notes-test@example.com"
git -C "$repo" config user.name "Release notes test"

commit() {
  local message="$1"
  local date="$2"

  GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
    git -C "$repo" commit --allow-empty --quiet --message "$message"
}

commit "Initial release" "2025-01-01T00:00:00Z"
git -C "$repo" tag v1.0.0

commit "First release change" "2025-01-02T00:00:00Z"
commit "Update changelog" "2025-01-03T00:00:00Z"
git -C "$repo" tag v1.1.0

git -C "$repo" branch feature
git -C "$repo" checkout --quiet feature
commit $'Feature branch change\n\nFeature detail' "2025-01-04T00:00:00Z"
git -C "$repo" checkout --quiet main
GIT_AUTHOR_DATE="2025-01-05T00:00:00Z" \
  GIT_COMMITTER_DATE="2025-01-05T00:00:00Z" \
  git -C "$repo" merge --no-ff --quiet --message "Merge feature" feature
git -C "$repo" tag v1.2.0

expected="$temp_dir/expected.md"
actual="$temp_dir/actual.md"
printf '%s\n' \
  "- Feature branch change" \
  "" \
  "- Feature detail" \
  "" \
  "- First release change" \
  "" > "$expected"

(
  cd "$repo"
  bash "$generator" v1.0.0 "$actual"
)
diff -u "$expected" "$actual"

printf '%s\n' "stale content" > "$actual"
(
  cd "$repo"
  bash "$generator" v1.2.0 "$actual"
)
[[ ! -s "$actual" ]]

(
  cd "$repo"
  bash "$generator" "" "$actual"
)
grep -q -- "- Initial release" "$actual"
