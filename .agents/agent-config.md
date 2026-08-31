# Agent Configuration Model

Use the smallest durable surface that matches the job.

## Surfaces

- `AGENTS.md`: repository entry point. Keep it small and reserve it for always-on rules, routing, and high-priority expectations.
- `CLAUDE.md`: a one-line `@AGENTS.md` import and nothing else. Claude Code loads `CLAUDE.md` into the system prompt at startup; the import makes `AGENTS.md` arrive with it. Without it, `AGENTS.md` reaches the session only as a tool result some agent chose to fetch, which is the weakest position in context and the first thing dropped when the conversation is summarized. Do not let rules accumulate in this file.
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
- Split a rule into the part that can be counted and the part that cannot, and enforce them differently. A rule resting entirely on judgment gets decided at the keyboard, at the moment the exception looks most justified; the comment policy is the worked example, where "is this comment useful" stays prose and review while "are these comments too frequent" became a measured gate. Find the countable half before writing more prose.
- Restate a rule verbatim in every context that must obey it, and prefer a runnable check to a description of the rule. A gate an agent trips before reporting done outperforms a paragraph asking it to have been careful.
- State a gate's real force. Enforcement differs per tool, and a rule that claims uniform coverage it does not have is worse than one that names the gap.
- Keep user-specific preferences out of the repository. They belong in user-level Codex configuration or user-level skills.

## Skill Authoring Rules

- Use lowercase hyphenated names.
- Start descriptions with `Use when...`.
- Describe trigger conditions in the description, not the workflow.
- Keep `SKILL.md` lean; link to `.agents/*.md` for large reference material.
- Add scripts only when deterministic behavior is needed repeatedly.
