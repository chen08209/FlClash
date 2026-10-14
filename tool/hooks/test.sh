#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

shopt -s nullglob
tests=(*_test.sh)
shopt -u nullglob

if [[ ${#tests[@]} -eq 0 ]]; then
  echo 'no hook tests found under tool/hooks/' >&2
  exit 1
fi

failed=0

for test in "${tests[@]}"; do
  echo "==> $test"
  bash "$test" || failed=$((failed + 1))
done

if ((failed > 0)); then
  echo "$failed of ${#tests[@]} hook test file(s) failed" >&2
  exit 1
fi

echo "ran ${#tests[@]} hook test file(s)"
