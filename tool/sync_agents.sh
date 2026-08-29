#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
usage: tool/sync_agents.sh [--check]

Generate .codex/agents/<name>.toml from .claude/agents/<name>.md. With --check, exit 1 instead of writing when any
generated file differs from the tracked one or a toml has no matching markdown.
USAGE
}

root="$(git rev-parse --show-toplevel)"
src="$root/.claude/agents"
dst="$root/.codex/agents"
check=0
[ "${1:-}" = "--check" ] && check=1
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { usage; exit 0; }

frontmatter() {
  awk 'NR==1 && $0=="---"{f=1; next} f && $0=="---"{exit} f{print}' "$1"
}

field() {
  frontmatter "$1" | awk -v key="$2" -F': ' '$1==key{sub(/^[^:]*: */, ""); print; exit}'
}

body() {
  awk 'NR==1 && $0=="---"{f=1; next} f && $0=="---"{f=0; b=1; next} b{print}' "$1" |
    sed -e '1{/^$/d;}' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
}

codex_model() {
  case "$1" in
    implementer | test-generator) echo gpt-5.6-sol ;;
    *) echo gpt-5.6-luna ;;
  esac
}

render() {
  local md="$1" name tools
  name="$(field "$md" name)"
  tools="$(field "$md" tools)"
  local sandbox=read-only
  case ",${tools// /}," in *,Edit,* | *,Write,*) sandbox=workspace-write ;; esac
  printf 'name = "%s"\n' "$name"
  printf 'description = "%s"\n' "$(field "$md" description | sed 's/"/\\"/g')"
  printf 'model = "%s"\n' "$(codex_model "$name")"
  local effort
  effort="$(field "$md" effort)"
  [ -n "$effort" ] && printf 'model_reasoning_effort = "%s"\n' "$effort"
  printf 'sandbox_mode = "%s"\n' "$sandbox"
  printf 'developer_instructions = """\n%s\n"""\n' "$(body "$md")"
}

status=0
for md in "$src"/*.md; do
  name="$(field "$md" name)"
  toml="$dst/$name.toml"
  if [ "$check" -eq 1 ]; then
    if ! diff -u "$toml" <(render "$md") >/dev/null 2>&1; then
      echo "out of date: ${toml#"$root"/} (run tool/sync_agents.sh)" >&2
      status=1
    fi
  else
    mkdir -p "$dst"
    render "$md" >"$toml"
    echo "wrote ${toml#"$root"/}"
  fi
done

for toml in "$dst"/*.toml; do
  name="$(basename "$toml" .toml)"
  if [ ! -f "$src/$name.md" ]; then
    echo "no markdown source for ${toml#"$root"/}" >&2
    status=1
  fi
done

exit "$status"
