# Architecture

## Core Integration

The Go proxy core in `core/` operates in two modes.

Android lib mode:

- Go core is compiled as a C shared library, `libclash.so`, through `go build -buildmode=c-shared` with CGO.
- Flutter calls it via FFI through the `service` plugin.
- Dart-side implementation: `lib/core/lib.dart` (`CoreLib`).

Desktop core mode:

- Go core runs as a separate process with `CGO_ENABLED=0`.
- Flutter communicates through the `rust_api` local IPC server, using a Unix
  domain socket on macOS/Linux and a named pipe on Windows.
- Dart-side implementation: `lib/core/service.dart` (`CoreService`).

`lib/core/controller.dart` (`CoreController`) selects the implementation based on platform. `lib/core/interface.dart` defines the shared `CoreHandlerInterface`.

Key Go core files:

- `core/hub.go`: handler functions.
- `core/method.go`: MethodChannel-style method-call dispatch and response envelopes.
- `core/lib.go`: CGO exports.
- `core/server.go`: socket server.

## State Management

Provider files in `lib/providers/`:

- `app.dart`: runtime/UI state, logs, traffic, delays, loading, navigation.
- `config.dart`: persistent config providers, app settings, theme, VPN, proxy style.
- `state.dart`: derived/computed providers, navigation, proxy, tray, color scheme.
- `action.dart`: business logic notifiers, setup, backup, core lifecycle, proxy selection.
- `database.dart`: Drift database provider wrappers.

`globalState` in `lib/state.dart` is a singleton holding app lifecycle, timers, theme, and start/stop state. Providers are generated into `lib/providers/generated/`.

## Database

The app uses Drift/SQLite in `lib/database/`. Current schema version is 2.

Tables:

- `Profiles`
- `Scripts`
- `Rules`
- `ProfileRuleLinks` (`profile_rule_mapping`)
- `ProxyGroups`
- `IconRecords` (`icon_records`)

Rule scenes distinguish global added rules, profile added rules, profile custom rules, and disabled links. Rule and proxy-group ordering use fractional indexing.

Generated Drift output lives in `lib/database/generated/database.g.dart`. After schema changes, run code generation and add or update focused database tests under `test/database/` when converter or migration behavior changes.

## Manager Stack

Managers are nested `InheritedWidget`/`StatefulWidget` components in `lib/application.dart`:

```text
AppEnvManager > StatusManager > ThemeManager
  > [Desktop: WindowManager > TrayManager > HotKeyManager > ProxyManager]
  > ConnectivityManager > CoreManager > AppStateManager
  > [Mobile: AndroidManager > VpnManager | Desktop: WindowHeaderContainer]
```

Each manager in `lib/manager/` handles a specific platform concern. Desktop-only managers are conditionally inserted.

## Core Controller and Actions

`lib/core/controller.dart` (`CoreController`) is a singleton facade over `CoreHandlerInterface`. Public methods delegate to the platform-specific interface, either Android FFI or desktop socket. It has an `@visibleForTesting` constructor and `resetInstance()` for test injection.

The shared core protocol uses `CoreMethodCall(method, arguments)` in both directions and `CoreMethodResponse(result, error)` for replies. Desktop calls include an `id` for concurrent request correlation; Android carries the same JSON envelope through its service `MethodChannel` and JNI bridge.
The envelope is the only JSON serialization layer: keep `arguments`, `result`, and event data as structured JSON values instead
of embedding pre-encoded JSON strings. Plain domain strings, such as country codes or provider file contents, remain strings.

`lib/providers/action.dart` is the public library entry point for action
providers. The Riverpod notifier implementations are split by responsibility
under `lib/providers/actions/` and joined to the entry point with `part`
directives, so consumers continue to import the same public API:

- `CommonAction`: update check and common UI operations.
- `SetupAction`: config setup and TUN management.
- `BackupAction`: backup/restore with WebDAV sync.
- `CoreAction`: core lifecycle, init, connect, restart, shutdown.
- `SystemAction`: system integration, tray, exit, brightness.
- `StoreAction`: profile storage operations.
- `ThemeAction`: theme state updates.
- `ProxiesAction`: group management and proxy selection.
- `ProfilesAction`: profile CRUD, auto-update, import.
- `GeoResourceAction`: geo resource updates and URL configuration.

## Platform Managers

Desktop:

- `WindowManager`
- `TrayManager`
- `HotKeyManager`
- `ProxyManager`

Mobile:

- `AndroidManager`
- `TileManager`
- `VpnManager`

Shared:

- `ConnectivityManager`
- `CoreManager`
- `AppStateManager`
- `StatusManager`
- `ThemeManager`

## Build System

`setup.dart` is the release build orchestrator:

1. Writes `env.json` (`APP_ENV`).
2. Activates `flutter_distributor` for packaging.
3. Relies on the platform build hook to build the required Core artifacts before
   the native application is linked.

Go core building is handled by `build_tool`, a standalone Dart CLI in `plugins/setup/buildkit/build_tool/`.

Platform build hooks inside `flutter build` trigger `build_tool` automatically:

- macOS: podspec script phase, `build_pod.sh`, `build_tool macos`.
- Linux: CMake include, `buildkit/cmake/buildkit.cmake`, `build_tool linux`.
- Windows: CMake include, `buildkit/cmake/buildkit.cmake`, `build_tool windows`. CMake forwards the active configuration through `BUILDKIT_CONFIGURATION`.
- Android: Gradle include, `buildkit/gradle/plugin.gradle`, `build_tool android`.

### Setup Build Harness Plugin

`plugins/setup/` is a build-time Flutter plugin, not a runtime Dart or FFI API. Its plugin shape exists so Flutter's native
build graphs can run the Go/Rust build harness before platform consumers need the generated artifacts. Application code
must not import or call it.

Responsibilities are deliberately split:

- CocoaPods, Gradle, and CMake hooks schedule a lightweight check on every native build. They do not decide which Go or
  Rust files are stale.
- `buildkit/build_tool/` owns target resolution, input fingerprinting, compilation, output copying, and cache validation.
- `core/` and `services/helper/` remain source owners; `libclash/` and Android `jniLibs`/header directories are generated
  output locations.
- `setup.dart` remains the release/package orchestrator and does not pre-build
  platform artifacts or pass Core integrity data into Dart.

Platform outputs remain explicit:

- Android builds the Go core as `c-shared`, then copies `libclash.so` and generated headers into the `:core` Android module.
- macOS and Linux build a standalone `FlClashCore` process used by the desktop socket integration.
- Windows builds `FlClashCore.exe` plus the Rust `FlClashHelperService.exe` privileged helper.

The hooks follow rust_api/Cargokit's phony-output scheduling pattern, but setup uses its own cache because it builds both a
Go core and, on Windows, a separate Rust helper. Per-target records live under `.dart_tool/setup_build_cache/v1/`:

- Go fingerprints cover the target-specific `go list -deps` inputs inside `core/` and `Clash.Meta`, module files, effective
  build configuration, build-tool sources, target flags, Go environment/toolchain, and Android NDK compiler details.
- Windows helper fingerprints cover its Rust sources and manifests, Cargo/Rust
  toolchains and flags, and the expected Core SHA256.
- A cache hit requires the fingerprint and every recorded output's path, size, and modification state to match. It exits
  silently without Go/Cargo compilation, output copying, or Windows `taskkill`.
- Cache records are written only after a successful build and protected by per-target process/file locks. Missing outputs,
  changed inputs, cache-schema changes, or `--force` rebuild only the affected target.
- `flutter clean` removes `.dart_tool`, so the next native build performs one full core rebuild. Manual builds can bypass
  the cache with `make core-<platform> FORCE=1`.

This differs from `rust_api`: rust_api is a runtime Flutter Rust Bridge integration whose Cargokit hooks produce its native
FFI library, while setup is only the build and packaging bridge for FlClash's external core artifacts.

Windows helper integrity/version check:

- The build tool constructs the Core first, calculates its SHA256, and always
  builds the Rust Helper with release hardening and that expected hash.
- Flutter does not embed or send the Core SHA256. Debug, Profile, and Release
  builds use the same Helper protocol and may use TUN through the same flow.
- Ping is loopback-only and requires no request token. The Helper verifies the
  fixed `FlClashCore.exe` beside it against its embedded SHA256 before reporting
  readiness, and repeats the verification before every launch.
- Flutter creates a named pipe with a 128-bit random suffix and passes only that
  address to the helper. The helper validates the address namespace, returns the
  spawned Core PID, and Flutter matches it against the named-pipe peer PID.
- The Helper path and protocol version allow Flutter to replace stale service
  registrations, while the Helper-owned Core check detects mismatched builds.

Build configuration defaults live in `build_tool/lib/src/options.dart` and can be overridden via a root `build_config.yaml`.

Architecture detection is automatic. The `--description` flag passed to `flutter_distributor` adds arch suffixes to artifact names, such as `FlClash-0.8.93-macos-arm64.dmg`.

## Local Plugins

- `setup`: build-time harness for Go core artifacts and the Windows Rust helper; no runtime Dart API.
- `proxy`: system proxy configuration.
- `rust_api`: runtime Flutter Rust Bridge FFI plugin built through Cargokit.
- `tray_manager`: system tray fork/customization.
- `wifi_ssid`: Wi-Fi SSID detection.
- `window_ext`: window extensions.
- `flutter_distributor`: app packaging/distribution.

## Rust Helper Service

`services/helper/` is a Windows-only privileged helper for starting the core as admin and managing TUN. It is built with:

```bash
make core-windows
```

The build tool always compiles the Helper in Rust release mode after calculating
the SHA256 of the Core produced for the active Flutter configuration.

The helper owns its Windows Service Control Manager lifecycle through two elevated commands:

- `FlClashHelperService.exe install` stops and removes any stale registration, creates the auto-start service for the
  current executable path, starts it, and waits for the running state.
- `FlClashHelperService.exe uninstall` stops the service, waits for shutdown, removes its registration, and is also used
  by the Windows package uninstaller.

The Dart layer only launches the helper's `install` command through `ShellExecuteW`; it does not compose `sc.exe`,
`taskkill`, or `cmd.exe` command lines.

In every Flutter build mode it opens the fixed Core executable beside the Helper
without write/delete sharing, validates it against the SHA256 embedded only in
the Helper, and keeps that handle open through process creation. `/ping`
self-validates the Core before reporting readiness; `/start`, `/stop`, and
`/logs` remain loopback-only without request-token validation. The Helper accepts
only FlClash's random Core named-pipe namespace, returns the spawned PID, and
reports its executable path and protocol version from ping so stale
registrations are replaced.
