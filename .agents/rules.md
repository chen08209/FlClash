# Rules

These are repository coding and testing conventions. Codex command permission rules belong in `.codex/rules/*.rules`; see `.agents/agent-config.md` before adding those.

## Dart and Flutter Style

`analysis_options.yaml` enforces these non-default rules:

- `prefer_single_quotes: true`: always use single quotes.
- `require_trailing_commas: true`: use trailing commas in multi-line argument lists.
- `sort_child_properties_last: true`: `child:` must be the last named parameter.
- `avoid_print: true`: do not use `print()` calls.
- `prefer_const_constructors: true` and `prefer_const_declarations: true`.
- `prefer_final_locals: true` and `prefer_final_in_for_each: true`.
- `always_declare_return_types: true`.

Generated directories are excluded from analysis:

- `build/**`
- `lib/l10n/intl/**`
- `lib/**/generated/**`
- `plugins/**`

## Comments

Comments are opt-in and reserved for the few places that genuinely need one. Density is the point: every comment that
restates the code devalues the comments that carry real information, until readers skim past all of them. A file with
three comments that matter is more readable than one with thirty.

### Writing Comments

- Never add a comment on your own initiative. This covers explanatory, narrative, TODO, section-divider, and
  documentation comments, in Dart, Kotlin, Swift, Go, Rust, YAML, Gradle, and any other file you touch.
- Never annotate line by line or statement by statement, and never restate in prose what the code already says. If a
  block needs a comment per step, the block needs better names or a smaller decomposition instead.
- When a change genuinely cannot be understood without a comment, do not write it silently. Explain what is unclear,
  propose the exact comment text, and wait for the user to approve it before adding it.
- Delete commented-out code, stale version notes, and comments that only restate the code, whenever you edit the file
  that contains them. This does not need approval.
- These are not comments and must be preserved: analyzer and linter directives (`// ignore:`, `// ignore_for_file:`,
  `// coverage:ignore`), license and copyright headers, code-generation markers, and comments inside vendored upstream
  code such as `lib/widgets/open_container.dart`.

### Where Knowledge Belongs

Pick the destination by where the constraint would be violated, not by how important it feels.

- **Assertable behavior goes in a test.** A test is the only form that cannot drift, because it fails when the behavior
  it describes is broken. Prefer it over both a comment and a document whenever the fact can be checked in code.
- **Repository-wide defaults, ownership, and invariants go in `.agents/*.md` or a `.agents/skills/*/SKILL.md`.** They
  are violated from many files, so they must reach every future agent at session start. A comment in one file cannot do
  that.
- **A fact that is true only at one call site, and is not visible from that call site, stays a comment there.** Its
  value is being in the reader's line of sight at the moment of the edit. `lib/common/constant.dart` is the model case:
  the delay-test concurrency cap is bound to `mBatch` in `core/common.go`, and whoever changes that number must see the
  constraint on the same screen.

Both failure directions are real. Moving a local constraint into `.agents/` hides it from the person editing the line;
leaving a repo-wide policy as a comment reaches only the reader of that one file.

Before any of the three, prefer encoding the intent in structure and naming — a named mixin, type, or method that makes
the invariant hard to break beats prose that asks the next reader not to break it.

## Core API Safety

- Do not expose direct filesystem deletion APIs through Core or helper IPC; use
  a scope-specific cleanup API instead.
- Keep the shared `CoreMethodCall`/`CoreMethodResponse` JSON envelope structurally identical across Dart, Go, JNI, and
  desktop IPC. Do not double-encode `arguments`, `result`, or event batches.
- Keep high-volume log/request events separate from state-bearing events in `core/message.go`; bulk backpressure must not
  evict delay, loaded-provider, or geo-update state.

## Lifecycle Rules

- Desktop process ownership belongs to `DesktopCoreLifecycle`; do not start/kill `FlClashCore` from providers, widgets,
  managers, or ad hoc exit callbacks. Acquire and release it through a `CoreProcessLease`.
- `CoreController.close()` and platform `close()` implementations are terminal and idempotent. Application shutdown must
  stay centralized in `SystemAction`/`SystemExitCoordinator`.
- Android start/stop MethodChannel calls are optimistic UI commands. Keep latest-wins arbitration in native
  `ServiceState`; do not add a Flutter completion callback that creates a second lifecycle owner.
- Android service callbacks are not automatically user intent. Route explicit Quick Settings, Always-on VPN, and revoke
  actions through `ServiceState` and keep `ServiceController` as the sole binding/run-time owner.
- Every `BroadcastReceiver.goAsync()` path must finish its `PendingResult` exactly once. A watchdog may release the
  broadcast lease, but must not cancel, reverse, or otherwise redefine the service operation.
- Presentation smoothing such as `CoreStatusButton`'s connecting hold must remain local display state. It must not delay or
  overwrite `coreStatusProvider`, and a real failure must bypass/cancel the hold immediately.

## Testing Rules

The `core/` directory is excluded from automated coverage accounting. Do not add coverage instrumentation or coverage
collection for code under `core/`. CI still runs `CGO_ENABLED=0 go test .` and `go vet .` to compile/check the Go wrapper;
verify cross-language protocol behavior through shared Dart contract tests under `test/core/` and native platform build
checks.

Use `CoreController.test(mock)` to inject a mocked `CoreHandlerInterface`. Call `CoreController.resetInstance()` in `tearDown` to clean up the singleton between tests.

Register fallback values for freezed params used with `any()` matchers.

Use `ProviderContainer` directly for simple Riverpod provider tests. The generated Riverpod `update()` method takes a callback:

```dart
notifier.update((state) => newValue);
```

When testing freezed models with nested objects, always round-trip through `jsonEncode` and `jsonDecode`. Direct `fromJson(toJson())` fails for nested freezed types because `toJson()` stores child objects directly instead of maps.

For async widgets, put visual cleanup in `finally` when the action may throw. Focused widget tests should cover success,
failure, disposal, and any timer boundary that changes visible state.

## Generated Code

Do not manually edit generated files under:

- `lib/l10n/l10n.dart`
- `lib/models/generated/`
- `lib/providers/generated/`
- `lib/database/generated/`
- `lib/l10n/intl/`

After schema, model, or provider changes, run build generation and include focused tests when behavior changes.
