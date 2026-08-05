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
