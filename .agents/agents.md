# Subagents

`.claude/agents/*.md` is the single source of truth. `.codex/agents/*.toml` is generated from it by
`tool/sync_agents.sh`; edit the Markdown, run the script, and commit both. `tool/sync_agents.sh --check` runs in
pre-commit and fails on drift.

Definitions follow the structure Claude Code's documentation recommends: one focused purpose each, a `description`
that says when to use it (with "use proactively" where automatic delegation is wanted), a system prompt with
approach, checklist, constraints, and output format, and the smallest tool set that does the job. Subagents do not
inherit `CLAUDE.md` or `AGENTS.md`, so the always-on repository rules are restated inside each definition's
constraints. Model choice follows the documented fit: Sonnet for exploration and
implementation, Opus for review that needs deep reasoning.

## Roles

| Role             | Purpose                                                       | Tools                                | Model  | Memory  |
|------------------|---------------------------------------------------------------|--------------------------------------|--------|---------|
| `code-explorer`  | Map symbols, owners, boundaries, and tests before a change    | Read, Glob, Grep, codegraph          | sonnet | project |
| `implementer`    | Make one scoped change and run focused verification           | Read, Glob, Grep, Bash, Edit, Write  | sonnet | —       |
| `test-generator` | Cover changed behavior with tests at the narrowest layer      | Read, Glob, Grep, Bash, Edit, Write  | sonnet | —       |
| `code-reviewer`  | Find defects, contract breaks, and coverage gaps in a diff    | Read, Glob, Grep, Bash, codegraph    | opus   | project |

`memory: project` stores what an agent learns under `.claude/agent-memory/<name>/`, which is tracked so the
knowledge is shared. `.claude/agent-memory-local/` is ignored.

`tool/sync_agents.sh` maps models to Codex (`implementer` and `test-generator` → `gpt-5.6-sol`, the rest →
`gpt-5.6-luna`) and derives the sandbox from whether the role has `Edit`/`Write`.

## Orchestration

The main conversation coordinates; it does not do the steps itself. The sequence for a code change is in
`.agents/skills/change-workflow/SKILL.md`: `code-explorer` → `implementer` → `test-generator` when coverage is
missing → `code-reviewer` → `implementer` on the Critical and High findings → `code-reviewer` re-checks those.
Independent areas can be explored by several `code-explorer` runs in parallel and synthesized afterwards.

`/code-review` (Claude Code's bundled skill) is the independent second opinion before a merge; `code-reviewer`
carries the repository's lifecycle and IPC knowledge and runs on every change.

## Worktrees

Claude Code, Codex, and Gemini each create git worktrees. `tool/worktrees.sh list` shows every worktree with its
owning tool and whether it holds uncommitted work; `tool/worktrees.sh prune` removes the clean ones and keeps
dirty ones unless `--force` is passed. `.claude/worktrees/` is ignored by git; `.claude/agents/`,
`.claude/settings.json`, and `.codex/agents/` are tracked. Give a subagent `isolation: worktree` only for
experimental changes that should be reviewed before landing in the checkout.
