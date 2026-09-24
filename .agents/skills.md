# Agent Skills

Repo skills live under `.agents/skills/*/SKILL.md`, where Codex discovers them directly. Claude Code discovers them
through the symlinks in `.claude/skills/`, one per skill, pointing back at the `.agents/skills/` directory. Both tools
match a task against the skill `name` and `description`, then load the full instructions only when it matches.

## Available Repo Skills

- `localization`: hardcoded UI text scans, ARB updates, locale generation, and localization verification.
- `ui-work`: Flutter UI, widgets, Material You styling, navigation surfaces, async feedback, and user-facing interactions.
- `core-platform`: Core lifecycle/process ownership, Android services, Go event delivery, desktop IPC, platform managers,
  VPN/TUN, and Windows Helper flow.
- `pre-commit-quality-review`: lightweight triage before commits, with scoped structural review and user decisions on concrete regressions.

## Authoring Notes

- Add new repeatable workflows as `.agents/skills/<skill-name>/SKILL.md`, and add the matching
  `.claude/skills/<skill-name>` symlink so Claude Code sees it too; remove both when retiring a skill.
- Git stores the symlinks as links only where the checkout supports them. A Windows checkout needs
  `core.symlinks=true` and Developer Mode, otherwise the links become plain files and Claude Code loads no repo
  skill there; Codex is unaffected because it reads `.agents/skills/` directly.
- Keep skill descriptions trigger-focused and start them with `Use when...`.
- Keep long reference material in `.agents/*.md`; skills should link to it instead of duplicating it.
- Put command permission rules in `.codex/rules/*.rules`, not in this file.
