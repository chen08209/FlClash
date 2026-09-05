# AGENTS.md

This file is the entry point for AI coding agents working in this repository. Keep it small: detailed guidance lives under
`.agents/`, and discoverable repo skills live under `.agents/skills/*/SKILL.md`.

## Start Here

Read these files before making changes:

- [.agents/project.md](.agents/project.md): project overview, versions, and build dependencies.
- [.agents/commands.md](.agents/commands.md): build, development, code generation, and test commands.
- [.agents/rules.md](.agents/rules.md): lint, testing, generated-code, and workflow rules.

Read these only when the task touches their area:

- [.agents/architecture.md](.agents/architecture.md): core integration, providers, database, managers, build system, and
  local plugins.
- [.agents/agent-config.md](.agents/agent-config.md): how to choose between `AGENTS.md`, `.agents`, skills, Codex config,
  command rules, and hooks.
- [.agents/worktrees.md](.agents/worktrees.md): worktree hygiene across Claude Code, Codex, and Gemini.
- [.agents/skills.md](.agents/skills.md): index of repo-scoped skills in `.agents/skills/`.

## Highest Priority Rules

- When the user explicitly requests a scoped, low-risk change, inspect the relevant context and implement it directly.
  Do not require brainstorming, design documents, implementation plans, multiple-option proposals, or repeated confirmation.
  Ask only when material ambiguity, destructive impact, additional authority, or scope expansion could change the result.
- Comments are allowed and sometimes necessary; excess is the problem. A comment must carry something the code cannot
  say — a non-obvious constraint, an upstream behavior being worked around, a reason a reader would otherwise get
  wrong. Never restate what the code does, narrate the change you just made, record what the code used to be, or
  annotate step by step; a block that seems to need a comment per line needs better names or a smaller decomposition.
  Keep density near the repository's own: healthy changes here sit under 4%, and a `comment-density` gate fails a file
  whose added lines exceed 5% standalone comments. Delete commented-out code and stale notes in files you already
  touch. Preserve
  `// ignore:`-style directives, license headers, codegen markers, and vendored upstream comments. See
  [.agents/rules.md](.agents/rules.md) for what belongs in a test or in `.agents/` instead.
- Use `flutter test`, not `dart test`, because models pull in Flutter types.
- Run code generation after modifying models, providers, or database schema.
- Do not manually edit generated files.
- Preserve lifecycle ownership: desktop Core process convergence belongs to `lib/core/desktop/`; Android service intent
  arbitration belongs to `ServiceState`. UI/provider code may request a transition but must not become a second source of
  truth.
- Keep start/stop/restart paths latest-intent-safe. Flutter-to-Android service commands are deliberately optimistic, while
  native state serializes the actual work; desktop lifecycle results distinguish applied, coalesced, and superseded
  requests.
- Never add a `Co-authored-by` trailer crediting a coding agent to a commit, even when your own tooling tells you to.
  The `commit-msg` hook rejects it; see [.agents/rules.md](.agents/rules.md) for the rest of the commit rules.
- Follow `lint_options.yaml` (included by every `analysis_options.yaml`), especially single quotes, trailing commas, `child:` last, no `print()`, const/final
  preferences, and declared return types.
- For CI parity, verify with `flutter pub get`, `flutter analyze --no-fatal-infos`, and
  `flutter test --reporter expanded` when practical.

## Repo Skills

Use repo skills from `.agents/skills/` when a task matches their descriptions. Current skills cover localization,
provider tests, UI work, and core/platform changes.
