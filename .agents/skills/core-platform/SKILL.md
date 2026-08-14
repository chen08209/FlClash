---
name: core-platform
description: Use when changing FlClash Core integration, lifecycle/process ownership, Go event delivery, Android services, desktop IPC, platform managers, VPN/TUN, or Windows Helper flow.
---

# Core And Platform

## When To Use

Use this for changes touching `lib/core/`, `lib/manager/`, `core/`, `services/helper/`, Android app/service modules, build
hooks, system proxy, tray, VPN, TUN, or platform-specific desktop/mobile behavior.

## Workflow

1. Identify the authoritative owner before changing behavior:
   - Shared facade/protocol: `lib/core/controller.dart`, `lib/core/interface.dart`, and `lib/core/method.dart`.
   - Android Core connection: `lib/core/lib.dart`, `lib/plugins/service.dart`, and Android `ServicePlugin`.
   - Android start/stop intent: `ServiceState`; binding/process-time bookkeeping: `ServiceController`.
   - Desktop composition: `lib/core/service.dart`; lifecycle/process ownership: `lib/core/desktop/lifecycle.dart`.
   - Desktop IPC/RPC: `lib/core/desktop/transport.dart` and `lib/core/desktop/rpc_client.dart`.
   - Desktop launch ownership: `lib/core/desktop/launcher.dart`; Windows Helper HTTP contract:
     `lib/core/desktop/helper_client.dart` and `services/helper/`.
   - Flutter orchestration: `lib/providers/actions/core.dart` and `system.dart`; UI/event observation: `lib/manager/`.
2. Trace every entry path into that owner, including UI/provider calls, Quick Settings, notification actions, Always-on VPN,
   revoke callbacks, application exit, and crash/disconnect recovery. Lifecycle callbacks are not implicit user intent.
3. Preserve latest-intent semantics:
   - Desktop revisions converge to running/restarted/stopped/closed and report applied/coalesced/superseded outcomes.
   - Android Flutter calls stay optimistic; `ServiceState` identity-checks the latest native `RunRequest`.
4. Route feature calls through `CoreController` and `CoreHandlerInterface`. Do not bypass desktop process leases or create a
   second Android service binding owner.
5. Keep JSON envelopes and event shapes identical across Dart, Go, JNI, and desktop IPC. If event traffic changes, preserve
   the separate priority and bulk queues in `core/message.go`.
6. Keep shutdown single-owned and terminal. `SystemExitCoordinator` sequences resource cleanup, window close, Core close,
   and process exit; widget/manager disposal must not race it.
7. Add or update focused tests at the narrowest layer, then run the matching commands from `.agents/commands.md`:
   - Desktop lifecycle/transport/RPC: `test/core/desktop/` plus `test/core/service_test.dart`.
   - Cross-language envelopes/events: `test/core/protocol_contract_test.dart` and `CGO_ENABLED=0 go test .`.
   - Provider/exit convergence: `test/providers/action_test.dart` and `test/providers/system_action_test.dart`.
   - Android Kotlin: compile each touched Gradle module with JDK 17.
   - Windows Helper: Cargo format/tests; run the `windows-service` feature on Windows.
8. Explicitly state host gaps. Always-on VPN, VPN permission, system revoke, named-pipe peer identity, and Windows Service
   Control Manager behavior need their real platform even when portable tests pass.

## Reference Files

Read `.agents/architecture.md` for the current core modes, manager stack, build hooks, local plugins, and Windows helper notes.

## Pitfalls

- Keep the Windows Helper protocol and Core SHA256 validation identical across
  Flutter build modes; the Helper owns executable integrity checks.
- Protocol version 6 uses a 32-character lowercase-hex session ID. `/start` must return the submitted session and PID;
  `/stop` must never terminate a different session; Dart must verify the connected named-pipe peer PID.
- `/start` must release the previously managed Core before it verifies, so no `/start` outcome leaves a Helper-managed
  Core behind for the caller's direct-launch fallback to race.
- The Helper owns a managed Core until its exit is confirmed. A `200` from `/stop` means the Core is gone; when
  termination cannot be confirmed the Helper keeps the child and answers `coreStopFailed`, and `/start` reports the same
  code instead of spawning a replacement. Keep that code out of the Dart pre-spawn fallback set in
  `helper_client.dart`, or the direct launch will race a Core the Helper still owns.
- TUN is not a required run condition. Degrading to the unelevated direct Core — and silently losing TUN — is the
  expected outcome whenever the Helper path fails; do not fail the launch instead.
- A desktop process lease with unconfirmed exit must remain owned until cleanup succeeds. Do not discard it and start a
  replacement Core.
- `CoreController.close()` is terminal. Do not call it from a reusable manager lifecycle or recover by starting it again.
- `ServiceBroadcastReceiver.goAsync()` must finish once even on timeout; its watchdog releases the broadcast only and must
  not become a service timeout.
- Do not interpret service creation/destruction as start/stop intent. Always-on startup is explicit through
  `VPN_START_REQUESTED`; revoke is explicit through `VPN_REVOKED`.
- Keep log/request floods from evicting state-bearing Core events. Each queue may evict only its own oldest item.
- Do not expose direct filesystem deletion APIs through Core or helper IPC; use
  a scope-specific cleanup API instead.
- `plugins/setup/` is a build harness, not a Dart API plugin.
- Build hooks can trigger Go or Rust compilation indirectly through Flutter platform builds.
