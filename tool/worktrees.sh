#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
usage: tool/worktrees.sh list | prune [--force]

list   Show every worktree with its owner tool and whether it has uncommitted changes.
prune  Remove worktrees that are clean, detached or locked-by-nobody, and not the main checkout.
       Dirty worktrees are listed and kept; pass --force to remove them as well.
USAGE
}

owner_of() {
  case "$1" in
    */.claude/worktrees/*) echo claude ;;
    */.codex/worktrees/*) echo codex ;;
    */.gemini/*) echo gemini ;;
    *) echo other ;;
  esac
}

root="$(git rev-parse --show-toplevel)"

each_worktree() {
  git -C "$root" worktree list --porcelain | awk '/^worktree /{print substr($0, 10)}'
}

is_locked() {
  git -C "$root" worktree list --porcelain | awk -v p="$1" '$0=="worktree " p{f=1; next} /^worktree /{f=0} f && /^locked/{found=1} END{exit !found}'
}

state_of() {
  local path="$1"
  if [ ! -d "$path" ]; then
    echo missing
  elif [ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]; then
    echo dirty
  else
    echo clean
  fi
}

cmd="${1:-list}"
force=0
[ "${2:-}" = "--force" ] && force=1

case "$cmd" in
  list)
    printf '%-8s %-8s %s\n' OWNER STATE PATH
    while IFS= read -r path; do
      printf '%-8s %-8s %s\n' "$(owner_of "$path")" "$(state_of "$path")" "$path"
    done < <(each_worktree)
    ;;
  prune)
    git -C "$root" worktree prune
    while IFS= read -r path; do
      [ "$path" = "$root" ] && continue
      if is_locked "$path"; then
        echo "keep (locked): $path"
        continue
      fi
      state="$(state_of "$path")"
      if [ "$state" = dirty ] && [ "$force" -eq 0 ]; then
        echo "keep (dirty): $path"
        continue
      fi
      git -C "$root" worktree remove --force "$path" && echo "removed: $path"
    done < <(each_worktree)
    git -C "$root" worktree prune
    ;;
  *)
    usage
    exit 1
    ;;
esac
