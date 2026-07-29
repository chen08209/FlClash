---
name: core-platform
description: Use when changing FlClash core integration, platform managers, Go core communication, desktop/mobile platform behavior, or Windows helper flow.
---

# Core And Platform

## When To Use

Use this for changes touching `lib/core/`, `lib/manager/`, `core/`, `services/helper/`, build hooks, system proxy, tray, VPN, TUN, or platform-specific desktop/mobile behavior.

## Workflow

1. Identify which boundary owns the behavior:
   - Android lib mode: `lib/core/lib.dart`.
   - Desktop process/socket mode: `lib/core/service.dart`.
   - Shared facade: `lib/core/controller.dart` and `lib/core/interface.dart`.
   - Platform lifecycle: `lib/manager/`.
2. Route feature code through `CoreController` and `CoreHandlerInterface`; avoid direct calls to platform implementations outside their boundary.
3. Keep desktop and mobile paths explicit.
4. For action-layer behavior, inspect `lib/providers/action.dart` and relevant generated providers.
5. Add or update shared Dart tests for logic that can be isolated.
6. Manually verify native behavior when automated coverage is not practical.

## Reference Files

Read `.agents/architecture.md` for the current core modes, manager stack, build hooks, local plugins, and Windows helper notes.

## Pitfalls

- Debug Windows helper auth differs from release token verification.
- `plugins/setup/` is a build harness, not a Dart API plugin.
- Build hooks can trigger Go or Rust compilation indirectly through Flutter platform builds.
