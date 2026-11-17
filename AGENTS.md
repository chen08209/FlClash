# AGENTS.md

This file is the entry point for AI coding agents working in this repository. Keep it small: each rule below is the
one-line form, and its explanation lives in the linked `.agents/` file.

## Start Here

Read these files before making changes:

- [.agents/project.md](.agents/project.md): project overview, versions, and build dependencies.
- [.agents/commands.md](.agents/commands.md): build, development, code generation, and test commands.
- [.agents/rules.md](.agents/rules.md): lint, testing, generated-code, and workflow rules.

Read these only when the task touches their area:

- [.agents/architecture.md](.agents/architecture.md): core integration, providers, database, managers, build system, and
  local plugins.
- [.agents/setting-changes.md](.agents/setting-changes.md): whether a changed setting is patched live, re-applies the
  profile, or asks for an Android VPN restart.
- [.agents/surfaces.md](.agents/surfaces.md): fill levels, selection and status colors, and the few borders that
  remain, for any change to how a surface is colored.
- [.agents/ios-measurements.md](.agents/ios-measurements.md): measured iOS values the iOS-style surfaces and motion
  follow, and the deliberate deviations from them.
- [.agents/agent-config.md](.agents/agent-config.md): where agent guidance belongs, the repo skills in
  `.agents/skills/`, and worktree hygiene.
- [.agents/flutter-upgrade.md](.agents/flutter-upgrade.md): SDK-pinned workarounds to recheck before changing the
  Flutter version.
- [concord/AGENTS.md](concord/AGENTS.md): the Rust core's own rules, for any change inside `concord/`.

## Highest Priority Rules

- Implement an explicitly requested, scoped, low-risk change directly. Do not require brainstorming, design documents,
  implementation plans, multiple-option proposals, or repeated confirmation; ask only when ambiguity, destructive
  impact, extra authority, or scope expansion could change the result.
- The request sets the scope: an unrequested fix, cleanup, or refactor is a follow-up in the summary. Edit surgically,
  keep scratch checks out of the repository, and commit tests only where the task or the neighbouring code keeps them.
- A comment carries only what the code cannot say; never restate, narrate the change, or keep commented-out code. The
  `comment-density` gate fails a file whose added lines exceed 5% standalone comments. See Comments in
  [rules.md](.agents/rules.md).
- Start FlClash on the host only as a safe mode build, and end only processes you started, by recorded pid; never kill
  by name. See Running the App Locally in [rules.md](.agents/rules.md).
- Use `flutter test`, not `dart test`. Run code generation after changing models, providers, or the database schema,
  and never edit generated files.
- Desktop Core process convergence belongs to `lib/core/desktop/` and Android service intent arbitration to
  `ServiceState`; UI and providers request transitions, never own them. Keep start/stop/restart latest-intent-safe.
  See Lifecycle Rules in [rules.md](.agents/rules.md).
- Commits follow Conventional Commits, carry no `Co-authored-by` trailer for a coding agent, and land follow-ups as
  regular commits. See Commit Messages in [rules.md](.agents/rules.md).
- Never write machine-local identifiers into the repository: the home directory or user name, an absolute checkout
  path, the host name, or a personal email. Use `$HOME`, a repository-relative path, or a placeholder.
- Round every corner with a superellipse from `prism_ui/lib/shape.dart`; `test/lint/superellipse_corners_test.dart`
  enforces it. See Corner Radius in [rules.md](.agents/rules.md).
- Anything that moves drops no frame while it moves and at most one as it starts (8 ms of UI work at 120 Hz). See UI
  Frame Budget in [rules.md](.agents/rules.md).
- Follow `lint_options.yaml`: single quotes, trailing commas, `child:` last, no `print()`, const/final, declared return
  types.
- Before reporting done, run `flutter pub get`, `flutter analyze --no-fatal-infos`, and the tests the change reaches;
  the full suite only after a shared-base change or in a branch's last review round. See the
  [test-scope](.agents/skills/test-scope/SKILL.md) skill. Say which check was skipped when a toolchain the build hook
  needs (`cargo`, the toolchain in `concord/rust-toolchain.toml`) is missing.

## Repo Skills

Use the skills in `.agents/skills/` when a task matches their descriptions; `.claude/skills/` symlinks expose them to
Claude Code. They cover localization, UI work, UI performance, core/platform changes, test scope, and pre-commit
structural review.
