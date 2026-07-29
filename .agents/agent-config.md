# Agent Configuration Model

Use the smallest durable surface that matches the job.

## Surfaces

- `AGENTS.md`: auto-loaded repository entry point. Keep it small and reserve it for always-on rules, routing, and high-priority expectations.
- `.agents/*.md`: human- and agent-readable reference docs linked from `AGENTS.md`. Use these for detailed project context, commands, architecture, and conventions.
- `.agents/skills/*/SKILL.md`: repo-scoped Codex skills. Use these for repeatable workflows that should be discoverable by name and description.
- `.codex/config.toml`: trusted project Codex settings such as MCP, hooks, sandbox, approval, or model defaults.
- `.codex/rules/*.rules`: command permission rules for running commands outside the sandbox. Do not mix these with coding conventions in `.agents/rules.md`.
- `.codex/hooks.json` or `.codex/config.toml` hooks: lifecycle automation such as prompt checks, command validation, or final verification gates.

## Placement Rules

- Put stable team conventions in `AGENTS.md` only when every task must see them without opening another file.
- Put detailed explanations in `.agents/*.md` and link them from `AGENTS.md`.
- Put reusable task workflows in `.agents/skills/<skill-name>/SKILL.md`.
- Put mechanical enforcement in linters, tests, hooks, or `.codex/rules`; do not rely on prose when tooling can enforce the rule.
- Keep user-specific preferences out of the repository. They belong in user-level Codex configuration or user-level skills.

## Skill Authoring Rules

- Use lowercase hyphenated names.
- Start descriptions with `Use when...`.
- Describe trigger conditions in the description, not the workflow.
- Keep `SKILL.md` lean; link to `.agents/*.md` for large reference material.
- Add scripts only when deterministic behavior is needed repeatedly.
