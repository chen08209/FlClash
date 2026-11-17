# Agent Configuration Model

Use the smallest durable surface that matches the job.

## Surfaces

- `AGENTS.md`: repository entry point. Keep it small and reserve it for always-on rules, routing, and high-priority expectations.
- No `CLAUDE.md`: Claude Code v2.1.277+ loads `AGENTS.md` at startup only while no `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` sits in the working directory or above it, so adding one silently replaces `AGENTS.md` for Claude. Sessions that cannot load `AGENTS.md` directly (third-party providers, telemetry disabled) need an uncommitted `CLAUDE.local.md` containing `@AGENTS.md`. The one nested `CLAUDE.md`, in `plugins/rust_api/`, imports the root `AGENTS.md` for the same reason.
- `.agents/*.md`: human- and agent-readable reference docs linked from `AGENTS.md`. Use these for detailed project context, commands, architecture, and conventions.
- `.agents/skills/*/SKILL.md`: repo skills shared by Codex and Claude Code. Use these for repeatable workflows that should be discoverable by name and description; `.claude/skills/` holds one symlink per skill so Claude Code finds the same files.
- `.codex/config.toml`: trusted project Codex settings such as MCP, hooks, sandbox, approval, or model defaults.
- `.codex/rules/*.rules`: command permission rules for running commands outside the sandbox. None exist yet. Do not mix these with coding conventions in `.agents/rules.md`.
- `.codex/hooks.json` or `.codex/config.toml` hooks: lifecycle automation such as prompt checks, command validation, or final verification gates.

## Placement Rules

- Put stable team conventions in `AGENTS.md` only when every task must see them without opening another file.
- Put detailed explanations in `.agents/*.md` and link them from `AGENTS.md`.
- Put reusable task workflows in `.agents/skills/<skill-name>/SKILL.md`.
- Put mechanical enforcement in linters, tests, hooks, or `.codex/rules`; do not rely on prose when tooling can enforce the rule.
- Split a rule into the part that can be counted and the part that cannot, and enforce them differently. A rule resting entirely on judgment gets decided at the keyboard, at the moment the exception looks most justified; the comment policy is the worked example, where "is this comment useful" stays prose and review while "are these comments too frequent" became a measured gate. Find the countable half before writing more prose.
- Restate the one-line form of a rule in every context that must obey it, and keep its explanation in one `.agents/*.md` file that the others link to. Prefer a runnable check to either: a gate an agent trips before reporting done outperforms a paragraph asking it to have been careful.
- State a gate's real force. Enforcement differs per tool, and a rule that claims uniform coverage it does not have is worse than one that names the gap.
- Keep user-specific preferences out of the repository. They belong in user-level Codex configuration or user-level skills.

## Repo Skills

Repo skills live under `.agents/skills/*/SKILL.md`, where Codex discovers them directly. Claude Code discovers them
through the symlinks in `.claude/skills/`, one per skill, pointing back at the `.agents/skills/` directory. Both tools
match a task against the skill `name` and `description`, then load the full instructions only when it matches.

- `localization`: hardcoded UI text scans, ARB updates, locale generation, and localization verification.
- `ui-work`: Flutter UI, widgets, color and surface styling, icons and glyphs, shapes and corner radii, navigation
  surfaces, async feedback, and user-facing interactions.
- `core-platform`: Core lifecycle/process ownership, Android services, Core event delivery, desktop IPC, platform
  managers, build hooks, system proxy, tray, VPN/TUN, and the Windows and Linux Helper.
- `ui-performance`: dropped frames, slow pages and transitions, UI-thread and raster load, isolate decisions, and the
  probes that measure them.
- `test-scope`: which checks a change runs and on which machine, across Dart, Concord, Rust, Android, desktop and CI
  files; reading a `tool/test.dart` run, and Dart-only runs without the Concord build.
- `pre-commit-quality-review`: lightweight triage before every commit, with scoped structural review and decisions on
  concrete regressions by whoever authorized the commit.

## Skill Authoring Rules

- Use lowercase hyphenated names.
- Add a new skill as `.agents/skills/<skill-name>/SKILL.md` plus the matching `.claude/skills/<skill-name>` symlink;
  remove both when retiring a skill.
- Git stores the symlinks as links only where the checkout supports them. A Windows checkout needs
  `core.symlinks=true` and Developer Mode, otherwise the links become plain files and Claude Code loads no repo
  skill there; Codex is unaffected because it reads `.agents/skills/` directly.
- Start descriptions with `Use when...`.
- Describe trigger conditions in the description, not the workflow.
- Keep `SKILL.md` lean; link to `.agents/*.md` for large reference material.
- Add scripts only when deterministic behavior is needed repeatedly.

## Worktrees

Claude Code, Codex, and Gemini each create git worktrees. `tool/worktrees.sh` lists them with their owning tool and
prunes the clean ones (see Worktree Tooling in `.agents/commands.md`). `.claude/worktrees/` is ignored by git;
`.claude/settings.json` is tracked.
