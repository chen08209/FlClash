---
name: core-platform
description: Use when changing FlClash Core integration, lifecycle/process ownership, Go event delivery, Android services, desktop IPC, platform managers, build hooks, system proxy, tray, VPN/TUN, or the Windows or Linux Helper.
---

# Core And Platform

## When To Use

Use this for changes touching `lib/core/`, `lib/manager/`, `core/`, `services/helper/`, Android app/service modules,
build hooks, system proxy, tray, VPN, TUN, or platform-specific desktop/mobile behavior.

## Read First

- `.agents/rules.md`: Core API Safety and Lifecycle Rules are binding. They carry the mihomo-fork patch budget, the
  JSON envelope and `core/message.go` queue rules, JNI ownership, `BootGuard`, tray, and SSID rules, and every
  lifecycle invariant (latest intent wins, desktop ownership through a `CoreProcessLease`, terminal `close()`,
  optimistic Android commands arbitrated by `ServiceState`, callbacks are not user intent, `goAsync()` finishes once).
- `.agents/architecture.md`: Core Integration, Lifecycle Ownership And Convergence, Core Protocol And Event Delivery,
  Safe Mode, Build System, and Rust Helper Service describe the current mechanisms, including the Helper protocol,
  the applied/coalesced/superseded outcomes, and the unconfirmed-exit lease.

## Owners

Every behavior here has one authoritative owner, and a change lands there:

- Shared facade/protocol: `lib/core/controller.dart`, `lib/core/interface.dart`, and `lib/core/method.dart`.
- Android Core connection: `lib/core/lib.dart`, `lib/plugins/service.dart`, and Android `ServicePlugin`.
- Android start/stop intent: `ServiceState`; binding/process-time bookkeeping: `ServiceController`.
- Desktop composition: `lib/core/service.dart`; lifecycle/process ownership: `lib/core/desktop/lifecycle.dart`.
- Desktop IPC/RPC: `lib/core/desktop/transport.dart` and `lib/core/desktop/rpc_client.dart`.
- Desktop launch ownership: `lib/core/desktop/launcher.dart`; Windows and Linux Helper HTTP contract:
  `lib/core/desktop/helper_client.dart` and `services/helper/`.
- Flutter orchestration: `lib/providers/actions/core.dart` and `system.dart`; application exit:
  `SystemExitCoordinator`; UI/event observation: `lib/manager/`.

An owner has more entry paths than the UI: provider calls, Quick Settings, notification actions, Always-on VPN, revoke
callbacks, application exit, and crash/disconnect recovery all reach it. Always-on startup is explicit through
`VPN_START_REQUESTED` and revoke through `VPN_REVOKED`; service creation or destruction is never read as intent.

## Verification

Focused tests live at the narrowest layer, and the matching commands are in `.agents/commands.md`:

- Desktop lifecycle/transport/RPC: `test/core/desktop/` plus `test/core/service_test.dart`.
- Cross-language envelopes/events: `test/core/protocol_contract_test.dart` and `CGO_ENABLED=0 go test .`.
- Provider/exit convergence: `test/providers/action_test.dart` and `test/providers/system_action_test.dart`.
- Android Kotlin: compile each touched Gradle module with JDK 17.
- Helper: `cargo fmt --check` and `cargo test`; the `windows-service` feature only builds on Windows.

State host gaps explicitly. Always-on VPN, VPN permission, system revoke, named-pipe peer identity, polkit and systemd
on Linux, and Windows Service Control Manager behavior need their real platform even when portable tests pass.

## Pitfalls

- A `200` from Helper `/stop` means the Core is gone. When termination cannot be confirmed the Helper keeps the child
  and answers `coreStopFailed`, and `/start` reports the same code instead of spawning a replacement. Keep that code
  out of the Dart pre-spawn fallback set in `helper_client.dart`, or the direct launch races a Core the Helper still
  owns.
- The Helper owns executable integrity: Core SHA256 validation and the protocol stay identical across Flutter build
  modes, so a debug build is not exempt.
- `plugins/setup/` is a build harness, not a Dart API plugin, and its hooks can trigger Go or Rust compilation
  indirectly through Flutter platform builds; a missing toolchain fails `flutter test`, not only `flutter build`.
