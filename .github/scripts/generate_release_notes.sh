#!/usr/bin/env bash

set -euo pipefail

previous_tag="${1:-}"
output="${2:-release.md}"

: > "$output"

append_range() {
  local range="$1"

  git log --no-merges --pretty=format:'%B' "$range" |
    awk '!/Update changelog/ && NF {print "- " $0 "\n"}' >> "$output"
}

current_tag=""
while IFS= read -r next_tag; do
  if [[ -n "$current_tag" ]]; then
    [[ "$current_tag" == "$previous_tag" ]] && break
    append_range "$next_tag..$current_tag"
  fi
  current_tag="$next_tag"
done < <(git tag --merged HEAD --sort=-creatordate)

if [[ -n "$current_tag" && "$current_tag" != "$previous_tag" ]]; then
  append_range "$current_tag"
fi
