# Worktrees

Claude Code, Codex, and Gemini each create git worktrees. `tool/worktrees.sh list` shows every worktree with its
owning tool and whether it holds uncommitted work; `tool/worktrees.sh prune` removes the clean ones and keeps
dirty ones unless `--force` is passed. `.claude/worktrees/` is ignored by git; `.claude/settings.json` is tracked.
