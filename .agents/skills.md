# Agent Skills

Repo-scoped Codex skills live under `.agents/skills/*/SKILL.md`. Codex can discover these by skill `name` and `description`, then load the full instructions only when a task matches.

## Available Repo Skills

- `localization`: hardcoded UI text scans, ARB updates, locale generation, and localization verification.
- `provider-tests`: Riverpod provider, notifier, and state-management tests.
- `ui-work`: Flutter UI, widgets, Material You styling, navigation surfaces, and user-facing interactions.
- `core-platform`: core integration, platform managers, Go core communication, desktop/mobile behavior, and Windows helper flow.

## Authoring Notes

- Add new repeatable workflows as `.agents/skills/<skill-name>/SKILL.md`.
- Keep skill descriptions trigger-focused and start them with `Use when...`.
- Keep long reference material in `.agents/*.md`; skills should link to it instead of duplicating it.
- Put command permission rules in `.codex/rules/*.rules`, not in this file.
