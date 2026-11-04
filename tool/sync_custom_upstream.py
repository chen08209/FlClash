import json
import subprocess
import sys
from pathlib import Path


def git(*args, check=True):
    return subprocess.run(
        ["git", *args], check=check, text=True, capture_output=True
    )


def resolve_messages(path):
    versions = []
    for stage in (1, 2, 3):
        result = git("show", f":{stage}:{path}", check=False)
        versions.append(json.loads(result.stdout) if result.returncode == 0 else {})
    base, ours, theirs = versions
    missing = object()
    merged = {}
    for key in dict.fromkeys([*theirs, *ours]):
        original = base.get(key, missing)
        local = ours.get(key, missing)
        remote = theirs.get(key, missing)
        if local == remote or remote == original:
            selected = local
        elif local == original:
            selected = remote
        else:
            raise RuntimeError(f"Conflicting translation: {path}:{key}")
        if selected is not missing:
            merged[key] = selected
    Path(path).write_text(
        json.dumps(merged, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    git("add", path)


def main():
    upstream = sys.argv[1]
    result = git("merge", "--no-commit", "--no-ff", upstream, check=False)
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr)
    conflicts = git("diff", "--name-only", "--diff-filter=U").stdout.splitlines()
    try:
        for path in conflicts:
            if path.startswith(".github/workflows/"):
                git("restore", "--source=HEAD", "--staged", "--worktree", "--", path)
            elif path.startswith("arb/") and path.endswith(".arb"):
                resolve_messages(path)
            elif "/generated/" in path or path.startswith("lib/l10n/") or path == "pubspec.lock":
                git("checkout", "--theirs", "--", path)
                git("add", path)
            else:
                raise RuntimeError(f"Manual source integration required: {path}")
        git("restore", "--source=HEAD", "--staged", "--worktree", "--", ".github/workflows")
        if git("diff", "--name-only", "--diff-filter=U").stdout.strip():
            raise RuntimeError("Unresolved source conflicts")
    except Exception:
        git("merge", "--abort", check=False)
        raise


if __name__ == "__main__":
    main()
