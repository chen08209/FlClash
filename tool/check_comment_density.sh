#!/usr/bin/env bash

set -euo pipefail

max_density="${COMMENT_DENSITY_MAX:-5}"
min_lines="${COMMENT_DENSITY_MIN_LINES:-20}"

is_checkable() {
  local file="$1"
  case "$file" in
    *.dart | *.kt | *.kts | *.swift | *.go | *.rs | *.java | *.cpp | *.cc | *.h | *.hpp | *.gradle | *.yaml | *.yml) ;;
    *) return 1 ;;
  esac
  case "$file" in
    */build/* | */generated/* | */l10n/intl/* | */l10n/l10n.dart | */Clash.Meta/* | */.dart_tool/*) return 1 ;;
    *.g.dart | *.freezed.dart | */frb_generated*.dart | */frb_generated.rs | */open_container.dart) return 1 ;;
  esac
  return 0
}

added_for() {
  local file="$1"
  [ -f "$file" ] || return 0
  is_checkable "$file" || return 0

  local repo relative
  repo="$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$repo" ] || return 0

  relative="$file"
  case "$file" in
    "$repo"/*) relative="${file#"$repo"/}" ;;
  esac

  if git -C "$repo" ls-files --error-unmatch "$relative" >/dev/null 2>&1; then
    git -C "$repo" diff HEAD -U0 -- "$relative" | grep -E '^\+' | grep -vE '^\+\+\+' |
      sed "s|^+|$relative\t|" || true
  else
    sed "s|^|$relative\t|" "$file" || true
  fi
}

comment_lines() {
  local body="$1"
  printf '%s\n' "$body" |
    grep -E "$(printf '\t')[[:space:]]*(//|/\*|#|\*([[:space:]]|/|$))" |
    grep -vE 'ignore:|ignore_for_file:|coverage:ignore|Copyright|SPDX-|Licensed under|GENERATED|dart format off|yaml-language-server|[[:space:]]#!$|[[:space:]]#!/|#!?\[|#(include|define|undef|ifdef|ifndef|if|elif|else|endif|pragma|error)\b' || true
}

changed_files() {
  local repo="$1"
  {
    git -C "$repo" diff HEAD --name-only -z 2>/dev/null || true
    git -C "$repo" ls-files --others --exclude-standard -z 2>/dev/null || true
  }
}

evaluate() {
  local file="$1" added total hits count density
  added="$(added_for "$file")"
  [ -n "$added" ] || return 0

  total="$(printf '%s\n' "$added" | grep -c . || true)"
  [ "$total" -ge "$min_lines" ] || return 0

  hits="$(comment_lines "$added")"
  count="$(printf '%s' "$hits" | grep -c . || true)"
  [ "$count" -gt 0 ] || return 0

  density="$(awk -v c="$count" -v t="$total" 'BEGIN { printf "%.1f", c * 100 / t }')"
  [ "$(awk -v d="$density" -v m="$max_density" 'BEGIN { print (d > m) ? 1 : 0 }')" -eq 1 ] || return 0

  printf '%s: %s of %s added lines are standalone comments (%s%%)\n\n' \
    "$(printf '%s\n' "$added" | head -1 | cut -f1)" "$count" "$total" "$density"
  printf '%s\n\n' "$(printf '%s\n' "$hits" | sed 's/\t/: /')"
}

collect() {
  local file
  for file in "$@"; do
    case "$file" in
      /*) ;;
      *) file="$PWD/$file" ;;
    esac
    evaluate "$file"
  done
}

collect_changed() {
  local repo file
  repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$repo" ] || return 0

  while IFS= read -r -d '' file; do
    evaluate "$repo/$file"
  done < <(changed_files "$repo")
}

if [ "$#" -gt 0 ]; then
  mode='argv'
  findings="$(collect "$@")"
else
  mode='hook'
  payload="$(cat)"
  file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null || true)"
  if [ -n "$file" ]; then
    findings="$(collect "$file")"
  else
    findings="$(collect_changed)"
  fi
fi

[ -n "$findings" ] || exit 0

cat >&2 <<REPORT
These files are over the ${max_density}% comment cap this repository holds to. Healthy changes
here sit under 4%; the outlier that prompted this gate ran 22%.

$findings
Comments are welcome when they carry something the code cannot say. Trim the ones that
restate what the code already does, narrate the change you just made, or annotate step by
step - a block needing a comment per line needs better names or a smaller decomposition
instead. Keep the few that record a non-obvious constraint, and prefer a test or an
.agents/ entry when the fact belongs there. See the Comments section of .agents/rules.md.
Set COMMENT_DENSITY_MAX to adjust this gate when a change genuinely warrants it.
REPORT

if [ "$mode" = 'argv' ]; then
  exit 1
fi
exit 2
