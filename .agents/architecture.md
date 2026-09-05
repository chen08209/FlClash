# Architecture

## Core Integration

The Go proxy core in `core/` operates in two modes.

Android lib mode:

- Go core is compiled as a C shared library, `libclash.so`, through `go build -buildmode=c-shared` with CGO.
- The Android `:core` module owns JNI access to the in-process library. Flutter crosses the `${packageName}/service`
  MethodChannel through `lib/plugins/service.dart` and Android's `ServicePlugin` rather than talking to JNI directly.
- `lib/core/lib.dart` (`CoreLib`) implements the shared Core interface, gates method calls on its connection completer,
  initializes and synchronizes Android shared state, and closes the native service path exactly once.
- Because Core is in the application process on Android, application RSS already includes Core memory.

Desktop core mode:

- Go core runs as a separate process with `CGO_ENABLED=0`.
- `rust_api`'s `ipc` module provides the native local-IPC primitives: a Unix domain socket on macOS/Linux and a named pipe
  on Windows.
  Dart now owns the transport state, RPC correlation, process ownership, and lifecycle convergence above those primitives.
- `lib/core/service.dart` (`CoreService`) is the composition root. It wires the IPC transport, launcher selection,
  lifecycle controller, RPC client, and crash-event bridge; it is no longer the whole desktop implementation by itself.
- `lib/core/desktop/transport.dart` converts native IPC frames into ready, connected, disconnected, failed, and data
  events. A replaceable binding keeps RPC subscriptions stable when a failed or stale transport must be rebuilt.
- `lib/core/desktop/rpc_client.dart` owns request IDs and pending completers, waits up to 10 seconds for a connection,
  applies a three-minute default method timeout, unwraps `CoreMethodResponse`, and fails all pending calls when transport
  disconnects or closes.
- `lib/core/desktop/lifecycle.dart` serializes process intents and owns the authoritative desktop state machine.
- `lib/core/desktop/launcher.dart` abstracts direct child-process and privileged Helper ownership through idempotent process
  leases. `lib/core/desktop/helper_client.dart` is the typed local HTTP client for the privileged Helper.

`lib/core/controller.dart` (`CoreController`) selects the implementation based on platform. `lib/core/interface.dart` defines the shared `CoreHandlerInterface`.

Key Go core files:

- `core/hub.go`: handler functions.
- `core/method.go`: MethodChannel-style method-call dispatch and response envelopes.
- `core/message.go`: non-blocking priority/bulk event queues and bounded message batching.
- `core/lib.go`: CGO exports.
- `core/server.go`: desktop socket/named-pipe client and framed message forwarding.

## Listener Exposure

`_makeRealProfileTask` in `lib/common/task.dart` writes `mixed-port`, `allow-lan`, and `external-controller` into every
generated profile. With `allow-lan` off, mihomo's `genAddr` binds each listener to `127.0.0.1`; the external controller is
`ExternalControllerStatus.close` by default and never binds anywhere but loopback.

The loopback listener takes local connections without authentication by default: mandatory credentials would lock out
every external local consumer a proxy client exists for. The binding only guarantees traffic originates on the device;
it does not isolate programs already running there, so on Android any app holding `INTERNET` can use the proxy and learn
the outbound IP (#1934). The opt-in answer is the local authentication setting (`NetworkProps.localAuth`), which spans
four paths that must stay in sync: `_makeRealProfileTask` writes the credentials into `authentication` and force-clears
`skip-auth-prefixes` so a profile cannot silently exempt loopback; `UpdateParams.authentication` applies the same list
to a running core; `FlClashHttpOverrides` sends the credentials with the app's own proxied requests; and `sharedState`
withholds the Android VPN system proxy declaration because `ProxyInfo` cannot carry credentials (TUN still captures that
traffic). Desktop system proxy is deliberately not gated — dropping it would leak traffic direct, so the setting's
description tells users to supply credentials manually instead.

### Interface Name Modes

The same task also writes `interface-name` per `PatchClashConfig.interfaceNameMode`: `clear` (default) forces it empty so a
subscription's value cannot survive into the generated profile, `follow` leaves whatever the profile YAML already has, and
`custom` writes the user's `interfaceName`. mihomo ignores `interface-name` on Android whenever `dialer.DefaultSocketHook`
is installed (`core/lib.go` `installHooks`, vendored `dialer.go`), so `NetworkListView` in `lib/views/config/network.dart`
shows the mode picker and text field only on desktop.

## Lifecycle Ownership And Convergence

### Shared Flutter Layer

`CoreController.start()`, `restart()`, `stop()`, and `close()` are the only shared lifecycle facade. `close()` is terminal;
callers must not try to reuse a closed platform implementation.

`CoreAction` in `lib/providers/actions/core.dart` owns the user-facing Core status and setup sequence:

- `startCore()` publishes `connecting`, starts the platform Core, publishes `connected`, then initializes Core state. A
  startup error publishes `disconnected` and displays the error.
- `restartCore()` coalesces overlapping callers behind one worker. `_requestedRestartRevision` records newer requests,
  while `_latestExplicitStart` retains the newest requested post-restart running intent. After the lifecycle restart and
  `initCore()`, the worker reapplies profile/running state until it has consumed the latest revision.
- The provider is an orchestration and presentation layer, not a process owner. Platform lifecycle code remains responsible
  for determining whether a Core process/service is actually running.

Application exit is centralized in `SystemAction` and `SystemExitCoordinator`:

1. Optionally save config and clean up DNS, system proxy, and tray resources in parallel.
2. Close the desktop window.
3. Call terminal `CoreController.close()`.
4. Exit the application exactly once.

The coordinator is idempotent, continues later cleanup steps after an earlier error, preserves the first error for the
caller, and uses a three-second watchdog as an emergency application-exit path. `Application.dispose()` and
`CoreManager.onCrash()` do not independently destroy Core; this avoids competing shutdown owners.

### Desktop Lifecycle

`DesktopCoreLifecycle` is a latest-desired-intent reconciler, not a queue that blindly executes every request:

- Public intents receive monotonically increasing revisions and target running, restarted, stopped, or closed.
- Observable phases are `idle`, `starting`, `running`, `stopping`, `failed`, and `closed`.
- A completed command reports `applied`, `coalesced`, or `superseded`, allowing callers and tests to distinguish a command
  that won from one satisfied or replaced by a newer compatible intent.
- Startup opens or replaces the IPC transport, resolves a launcher, generates a 128-bit lowercase hexadecimal session ID,
  launches Core, and waits for the matching connection. Windows additionally verifies that the named-pipe peer PID equals
  the process PID returned by the Helper lease.
- Each running session retains its process owner, lease, PID, session ID, and transport connection generation. Stop waits
  for both process-exit confirmation and the matching disconnect generation; a missing disconnect replaces the transport
  before later starts.
- An unconfirmed process exit is retained as an unconfirmed lease. New start/restart intents fail until ownership can be
  cleaned up, preventing two Core instances from being treated as the active session. Terminal close may continue on a
  best-effort basis because the application is exiting.
- An unexpected disconnect or transport failure while running is converted to `DesktopCoreFailure`, the owned process is
  cleaned up, and `CoreService` emits a Core crash event for the normal UI recovery path.

Direct launch is used on macOS, inside an AppImage, and as the Windows/Linux fallback when the privileged Helper is not
ready. When the Helper is ready, it owns the Core child and Dart owns it through a session-scoped lease.

### Android Service Lifecycle

Android deliberately keeps Flutter requests optimistic and the native layer authoritative:

- `ServicePlugin.start()` and `stop()` acknowledge immediately after submitting intent. They do not wait for service
  creation, VPN permission, binding, TUN establishment, or teardown.
- `ServiceState` owns the latest `RunRequest`, shared configuration, run time, and `STOPPED`/`STARTING`/`STARTED`/`STOPPING`
  state. Identity checks discard obsolete work. `startPreparationLock` serializes permission/setup preparation and
  `transitionLock` serializes actual service transitions.
- `ServiceController` owns exactly one `ManagedServiceBinding`, selects `VpnService` or `ProxyService` from `VpnOptions`,
  binds with a five-second connection timeout, invokes `ManagedService.start()`/`stop()` off the main thread, and clears
  binding/run-time state on failure or disconnection.
- Generic service creation/destruction is lifecycle evidence, not user intent. New commands must flow through
  `ServiceState.requestStart()`/`requestStop()` or the explicit system-action handlers instead of inferring intent from a
  callback.

Quick Settings, notification, revoke, and Always-on VPN paths converge on the same owner:

- With a Flutter engine attached, `ServiceState.handleStartAction()`/`handleStopAction()` forward through `TilePlugin` to
  `TileManager`, which updates normal Flutter setup state. Without Flutter, native code restores `SharedState` from
  preferences, runs `quickSetup`, checks VPN permission, and submits the native request directly.
- Android may create an Always-on `VpnService` through `onStartCommand()` without FlClash's bound-service path. The service
  sends the explicit, permission-protected `VPN_START_REQUESTED` broadcast to `ServiceBroadcastReceiver`, which routes it to
  `ServiceState.handleStartAction()` so Core/configuration and the normal binding are restored before TUN is treated as
  ready.
- `VpnService.onRevoke()` stops TUN/modules first, then sends `VPN_REVOKED`; the receiver only requests a stop when
  `ServiceController` still owns an active VPN binding.
- `ServiceBroadcastReceiver` uses `goAsync()` and an atomic one-shot completion. Normal completion or a nine-second
  watchdog calls `PendingResult.finish()` exactly once; the watchdog releases Android's broadcast lease and does not
  cancel or redefine the underlying lifecycle intent.

## Core Protocol And Event Delivery

The shared protocol uses `CoreMethodCall(id, method, arguments)` and `CoreMethodResponse(id, result, error)` in both
directions. The envelope is the only JSON serialization layer: keep arguments, results, and event data as structured JSON
values rather than embedding pre-encoded JSON strings. Plain domain strings, such as country codes or provider contents,
remain strings.

Go event delivery is intentionally non-blocking:

- State-bearing events such as delay, loaded-provider, and geo-update use a 256-entry priority queue. Desktop process
  crashes are generated locally by `CoreService` from lifecycle failures rather than sent through the Go queue.
- High-volume log and request/connection events use a separate 256-entry bulk queue, so bulk floods cannot evict state.
- A full queue evicts only its own oldest event and retries the newest event; Core work never blocks on event delivery.
- The batcher flushes at 32 messages or every 16 milliseconds. Priority events are preferred, but one bulk opportunity is
  guaranteed after eight priority messages to prevent starvation.

Desktop RPC accepts both a single event object and batched event lists. Android and desktop listener dispatch isolate
listener exceptions so one faulty observer does not prevent the remaining events/listeners from running.

## User-Facing Core And Delay Feedback

`CoreStatusButton` in `lib/views/dashboard/widgets/core_status_button.dart` is the desktop dashboard's status/restart
surface. It is shown only outside dashboard edit mode and only when `coreLib == null`:

- Provider state remains authoritative. The widget keeps a separate display-only status so a fast
  `connecting -> connected` transition still shows at least 600 milliseconds of progress instead of flashing.
- The hold arms only after an observed transition to `connecting`; mounting while already connecting does not invent a new
  delay. A real `disconnected` transition cancels the hold immediately so failure is never hidden, while a long-running
  connecting state remains visible after the timer expires.
- Taps during the display hold or while the provider is genuinely connecting are inert. Connected/disconnected taps show
  the appropriate confirmation and delegate restart to `CoreAction`; the widget never starts Core directly.

Proxy delay testing follows the same failure-safe UI rule. `proxyDelayTest()` records an in-progress zero delay, writes the
real result on success, and logs plus records `-1` on exceptions. `DelayTestButton` reverses its animation in `finally`, so
an RPC failure cannot leave the control permanently spinning.

## Settings Rows

`lib/widgets/config_item.dart` holds the shared settings-row vocabulary: `ConfigToggleItem`, `ConfigOptionsItem`,
`ConfigTextItem`, and `ConfigListInputItem`. Each takes a `selector` (a `ProviderListenable`, normally
`someProvider.select(...)`) and an `onChanged(ref, value)` writer, and watches its own selector so changing one setting
rebuilds one row instead of the whole section. Titles and subtitles are `ConfigLabel` callbacks that receive
`AppLocalizations`, which keeps literal labels such as `IPv6` and localized labels in the same shape.

Build settings screens from these directly, or from a file-local helper that binds one provider once — see `_dnsToggle`
in `lib/views/config/dns.dart` and `_appSettingToggle` in `lib/views/application_setting.dart`. Declare a named
`ConsumerWidget` only when a row is genuinely reused across screens, as `lib/views/config/network.dart` rows are by
`lib/views/dashboard/widgets/quick_options.dart`. Rows with bespoke behaviour — a custom dialog, a derived value, or a
second provider write — stay hand-written rather than growing extra parameters on the shared items.

## State Management

Provider files in `lib/providers/`:

- `app.dart`: runtime/UI state, logs, traffic, delays, loading, navigation.
- `config.dart`: persistent config providers, app settings, theme, VPN, proxy style.
- `state.dart`: derived/computed providers, navigation, proxy, tray, color scheme.
  Like `action.dart`, this is an entry point only: the providers live under
  `lib/providers/state/` and are joined with `part` directives, so importing
  `state.dart` still reaches all of them.
  - `state/proxies.dart`: group and proxy lists, filter/sort, delay, selection.
  - `state/navigation.dart`: navigation items, current page, dashboard, more tools.
  - `state/system.dart`: tray, VPN params, access control, hot keys, shared state.
  - `state/theme.dart`: dynamic color, color scheme, brightness.
  - `state/profile.dart`: profiles, current profile, clash config, setup state.
  - `state/overwrite.dart`: custom overwrite validity and the staged group/rule notifiers.
- `action.dart`: business logic notifiers, setup, backup, core lifecycle, proxy selection.
- `core.dart`: `coreHandlerProvider`, the container-scoped handle on `CoreController`.
- `database.dart`: Drift database provider wrappers.

### Reaching Singletons

`lib/common/` and `lib/core/` publish process-wide singletons (`coreController`,
`system`, `preferences`, `appPath`, `request`, and others). Code that already has a
`Ref` or a `WidgetRef` reads them through a provider instead, so a test can scope a
fake to one `ProviderContainer` rather than swapping a global and relying on a
tearDown to put it back.

`coreHandlerProvider` is the established case. Every call site under
`lib/providers/`, `lib/manager/` and `lib/views/` goes through it; notifiers and
`ConsumerState` classes that touch Core repeatedly hold it as
`CoreController get _core => ref.read(coreHandlerProvider)`.

Tests override it with `coreHandlerProvider.overrideWithValue(CoreController.scoped(fake))`,
which does not claim the singleton. `CoreController.test` does claim it, and is
only for tests that have not moved yet. Prefer the scoped override even when a
test passes either way: a test that claims the singleton makes the global and the
provider resolve to the same fake, so it cannot tell a provider read from a
leftover global read, and a half-migrated call site stays green.

One deliberate exception: `globalState` owns the `ProviderContainer`, so it cannot
itself live in one. Code without a `Ref` reaches providers through
`globalState.container.read(...)`. The remaining call sites are `lib/core/lib.dart`,
`lib/common/print.dart`, and the tray `read` callback in
`lib/providers/actions/system.dart` — all singletons or platform callbacks with no
`Ref` in scope.

`lib/models/profile.dart` no longer reaches Core. `Profile.saveFile` and
`Profile.update` take a `ValidateConfig` callback, and every caller passes
`(path) => _core.validateConfig(path)`, keeping the Core handle lazy so a profile
path that never validates never resolves the controller.

The UI layer must not reach a process-wide singleton directly.
`test/lint/ui_layer_singleton_test.dart` scans `lib/views`, `lib/widgets`,
`lib/pages` and `lib/features` for `globalState.container` and the bare
`coreController` global and fails the run on either. Widgets that need Core hold
`CoreController get _core => ref.read(coreHandlerProvider)`.

`globalState.measure` and `globalState.theme` stay global on purpose. Both are
context-derived caches assigned by `ThemeManager`, and tests already scope them by
assigning in the app builder (see `test/helpers/test_app.dart`); moving them into
providers would touch every layout call site without changing behaviour.

`globalState` in `lib/state.dart` is a singleton holding ambient app state — the
package info, the measure and theme, the container, and the start/stop flags —
plus `safeRun`/`loadingRun`. Startup orchestration is **not** on it: `init` and
`attach` live in `lib/bootstrap.dart`, above `lib/common`, because they drive the
window, the autostart entry, the tray and the permission prompts. Providers are
generated into `lib/providers/generated/`.

The root navigator key lives in `lib/common/navigator.dart` as `rootNavigatorKey`;
`globalState.navigatorKey` is a getter onto it. `lib/common/dialog.dart` reaches
the key directly, so the dialog helpers no longer import `lib/state.dart`.

### Platform Layering

`lib/common/common.dart` deliberately does not export `tray.dart`, `window.dart`,
`launch.dart`, `system_dns.dart`, or `permission.dart`. Those five modules import
`tray_manager`, `window_manager`, `launch_at_startup`, and `screen_retriever`;
exporting them put those packages in the compile graph of all 132 files that
import the barrel for a string helper. Import the specific module instead.

`test/lint/platform_layering_test.dart` enforces four rules. Three are local: the
barrel never re-exports one of those five modules, nothing under `lib/common`,
`lib/enum` or `lib/models` other than those five imports a desktop platform
package, and `lib/common` never imports the `lib/manager/manager.dart` barrel
(import the single manager needed, as `common/context.dart` does with
`manager/status_manager.dart`). The fourth walks the barrel's whole transitive
closure and fails if *any* file in it imports one of those packages. That one is
the real invariant — the local rules only stop the shortest path, and every leak
found so far arrived through a longer one.

Four consequences are already in the tree:

- `System.back` and `System.exit` no longer touch `window`; the window half of
  both lives in `SystemAction`.
- `KeyboardModifier.toHotKeyModifier()` moved from `lib/enum/enum.dart` to
  `lib/manager/hotkey_manager.dart`, its only consumer.
- Startup orchestration moved off `GlobalState` into `lib/bootstrap.dart`.
  `common/num.dart`, `common/print.dart` and `common/request.dart` import
  `state.dart` for `theme`, `container` and `packageInfo`/`ua`, so anything
  `GlobalState` reaches lands in the barrel's closure; the ambient state it now
  holds reaches nothing platform-specific.
- `SystemAction` talks to `WindowPort` and `TrayPort` from
  `lib/common/app_ports.dart` instead of importing `common/window.dart` and
  `common/tray.dart`. `lib/bootstrap.dart` binds `windowPort` and `trayPort` to
  the real implementations; both stay null in tests, where every call through
  them is a no-op. A test that needs the real tray assigns `trayPort` itself, as
  `test/common/tray_menu_test.dart` does.

Narrow the barrel imports too: `lib/providers/providers.dart` re-exports
`action.dart`, so importing the providers barrel from `lib/common` or from
`providers/app.dart` reaches the whole action layer. Those three now import
`providers/state.dart` and `providers/config.dart` directly.

The same shape appeared twice more, without a platform package involved: a data
type in a lower layer holding the widget that renders it, which drags the whole
view tree into the barrel's closure.

- `lib/common/navigation.dart` was a route table building view widgets. It is
  now `lib/views/navigation.dart` implementing `NavigationPort`, which
  `providers/state/navigation.dart` reads through and `bootstrap.init` binds.
  Unbound it yields no items, so a test that renders navigation assigns
  `navigationPort` itself, as `test/pages/home_test.dart` does.
- `DashboardWidget` carried a `GridItem` per value, so `lib/enum/enum.dart`
  imported the dashboard cards — and `lib/widgets/widgets.dart` with them. The
  enum is persisted in the app settings, so it is back to plain data; the
  mapping lives in `lib/views/dashboard/widget_registry.dart`, the reverse
  lookup relying on the branches returning canonical consts.

Together those took the closure from 258 files to 187, with nothing under
`lib/views` left in it. `test/lint/platform_layering_test.dart` pins that
directly: the barrel's closure must contain no `lib/views` file. Data the
provider layer needs from the UI layer goes through a port in
`lib/common/app_ports.dart` rather than an import in the other direction.

### High-Frequency Buffers

`logsProvider`, `requestsProvider` and `trafficsProvider` hold a `FixedList`
(`lib/common/fixed.dart`), which trades a normal copy-on-write for a shared
buffer tagged with a generation counter:

- `append` mutates the buffer in place and returns a new wrapper one generation
  ahead. That is what providers publish, so `updateShouldNotify` still fires.
- `list` returns an immutable copy, cached until the next mutation. It must stay
  eager: an older wrapper shares the buffer, so its contents move on. Anything
  that needs a stable view has to read `list` at the moment it is notified, not
  hold the wrapper and read later.
- Consumers that only need to know *that* the buffer changed watch `revision`,
  not `list` — selecting on the list snapshots and deep-compares the whole
  buffer on every arrival, which is what this design exists to avoid. See
  `lib/views/logs.dart` for the pattern: watch the generation, snapshot inside
  the throttled callback.

`add`/`clear` mutate in place without advancing the generation; use them only on
a buffer you own outright (seeding, resets, tests), never on published state.

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

Managers are nested `InheritedWidget`/`StatefulWidget` components built by `buildManagerStack()` in `lib/application.dart`:

```text
AppEnvManager > StatusManager > ThemeManager
  > [Desktop: WindowManager > TrayManager > HotKeyManager > ProxyManager]
    [Mobile:  AndroidManager > TileManager]
  > AppStateManager > CoreManager > ConnectivityManager
  > [Desktop: WindowHeaderContainer] [Mobile: VpnManager]
  > app content
```

Each manager in `lib/manager/` handles a specific platform concern. The
platform slots are exclusive: no desktop manager appears on mobile and no mobile
manager appears on desktop.

The order is an ownership contract, not a layout detail. `ConnectivityManager`
sits below `CoreManager` because its `onConnectivityChanged` callback reads
Core-backed state, so Core must already be mounted when it fires. `StatusManager`
and `ThemeManager` sit above the platform managers so a platform manager can
surface a message or read the theme.

`buildManagerStack()` is a pure function of `isDesktop`, the connectivity
callback, and the app content, so `test/application_test.dart` asserts the whole
order by constructing the stack without mounting it. Changing the nesting means
updating both this diagram and that test.

## Core Controller and Actions

`lib/core/controller.dart` (`CoreController`) is a singleton facade over `CoreHandlerInterface`. Public methods delegate to the platform-specific interface, either Android FFI or desktop socket. It has an `@visibleForTesting` constructor and `resetInstance()` for test injection.

`lib/providers/action.dart` is the public library entry point for action
providers. The Riverpod notifier implementations are split by responsibility
under `lib/providers/actions/` and joined to the entry point with `part`
directives, so consumers continue to import the same public API:

- `CommonAction`: update check and common UI operations.
- `SetupAction`: config setup and TUN management.
- `BackupAction`: backup/restore with WebDAV sync.
- `CoreAction`: core lifecycle, initialization, coalesced restart, and post-restart profile/running-state application.
- `SystemAction`: system integration, tray, coordinated resource cleanup, terminal Core close, exit, and brightness.
- `StoreAction`: profile storage operations.
- `ThemeAction`: theme state updates.
- `ProxiesAction`: group management and proxy selection.
- `ProfilesAction`: profile CRUD, auto-update, import.
- `GeoResourceAction`: geo resource updates and URL configuration.
- `UpdatingAction`: stale sweep over `UpdatingKeys`.

`UpdatingKeys` in `lib/providers/app.dart` owns every per-entity updating flag; `isUpdatingProvider(key)` is the
read-only view widgets watch. Callers pair `start(key, scope: ...)` with `stop(key, operation)` using the returned
token, so overlapping operations on one key are reference counted and a late `stop` from a superseded operation
cannot clear a newer one. Keys started with `UpdatingScope.core` depend on the Core to make progress, so
`UpdatingKeys` discards them itself when `coreStatusProvider` leaves `connected` — that is the state's own
invariant, not a policy, and it must stay inside the notifier where no warm-up ordering can miss it.
`UpdatingScope.local` keys (profile updates run entirely in Dart) survive a Core restart. `UpdatingAction` holds
only the policy half: the periodic sweep that discards a key stuck past `updatingStaleTimeout`. Do not move the
timeout back into `UpdatingKeys`, and do not widen the disconnect reset to every scope.

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

`setup.dart` is the release build orchestrator: it writes `env.json` (`APP_ENV`), activates `flutter_distributor` from
the `chen08209/flutter_distributor` fork pinned to a `v<version>-flclash.<n>` tag (cut a new tag there and bump
`--git-ref` when the fork changes), and leaves the Core artifacts to the build hook.

The Go core and the Rust helper are built by a Dart build hook. `plugins/setup/hook/build.dart` only constructs
`CoreBuilder`, a `package:hooks` `Builder` in `plugins/setup/setup_hooks/`, the same shape `rust_api` uses. Flutter
runs it for every platform build and for `flutter test`, once per target architecture. `CoreBuilder` turns the hook
input into a `BuildRequest` (repository root, `Target`, Android toolchain) and hands it to `buildPlatform`. It lives in
`setup_hooks` so `dart test` there can cover it; a test run of `plugins/setup` itself would execute the hook. Failures
reach the runner as `BuildError` (Go or Cargo failed, no Core for the architecture) or `InfraError` (a toolchain could
not start, Flutter passed no NDK compiler, the package is not at `plugins/setup`).

What the hook protocol forces:

- Android derives the per-ABI clang wrapper from the C compiler and `targetNdkApi` (the app's `minSdk`) Flutter
  passes; `hooks_runner` filters the environment, so `ANDROID_NDK` is not read.
- `PATH` arrives unextended, so `runCommand` appends the Homebrew, Go and rustup locations that Xcode's and Gradle's
  stripped `PATH` hides.
- The hook does not know the build mode: the protocol carries none and `linkingEnabled` only says whether link hooks
  run, so nothing in the hook branches on debug versus release. It cannot tell `flutter test` from a build either; the
  `build_assets: false` user-define in the root `pubspec.yaml` is the one switch (see `.agents/commands.md`), and
  `setup.dart` refuses to package while it is set.
- The hook declares the files it read but the *directories* it wrote: `hooks_runner` hashes a file by content and a
  directory by child names, so `libclash/macos/` catches a deleted artifact without MD5-ing a 55 MB Core on every
  build. A rebuild touches those directories after the runner's cutoff, so the next build runs the hook once more and
  setup's cache answers it; that extra run is expected.
- The runner discards hook output on success, even under `-v`, so the hook mirrors it into
  `.dart_tool/setup_build_cache/hook.log` (rotated at 512 KB), one `===` header per invocation.

Platform projects copy the artifacts out of `libclash/`; application code must not import `plugins/setup`:

- Android: the Go core is built `c-shared`, and `libclash.so` with its headers lands in the `:core` module (see Android
  Native Task Ordering).
- macOS: a standalone `FlClashCore`. `Release.xcconfig` pins release and profile `ARCHS` to the host because
  flutter_tools otherwise builds a universal binary and every artifact ships one slice; the hook skips a non-host slice
  for the same reason. The `Stage Core` phase copies the Core after the hook may have rewritten it and fails when it is
  missing or lacks a slice for `ARCHS`, so a skipped hook cannot stage a stale Core silently.
- Linux and Windows: `FlClashCore`, the Rust `FlClashHelperService`, and a `manifest.json` holding `coreSha256`; the
  Core builds first because the Helper embeds its hash. The CMake `install` rules copy them, and the Windows bundle
  places `manifest.json` beside the executable. A Helper running from a Debug build keeps its exe open and the install
  fails behind an opaque `MSB3073`, so `windows/CMakeLists.txt` stops it from an `install(CODE)` step for the `Debug`
  configuration only, and only when the staged Helper differs from the installed one; that step is where the
  configuration is known, and a Release install never stops a registered service. The step matches the process by
  executable path rather than image name, so a Helper registered from an installed release keeps running.

Setup keeps its own cache under `.dart_tool/setup_build_cache/v1/` because it builds a Go core and, on Windows and
Linux, a Rust helper:

- Go fingerprints cover the target-specific `go list -deps` inputs in `core/` and `Clash.Meta`, module files, the
  effective build configuration, `setup_hooks` sources, target flags, the Go toolchain and the Android clang version.
  Helper fingerprints cover its Rust sources and manifests, Cargo/Rust toolchains and flags, and the expected Core
  SHA256.
- A hit requires the fingerprint and every recorded output's path, size and modification state to match, and skips
  compilation and copying.
- Records are written only after a successful build, under per-target locks. Compilation happens in a staging
  directory and moves into place on success, so a failed build never destroys the previous artifacts.
- `flutter clean` removes `.dart_tool` and forces one full rebuild; deleting `.dart_tool/setup_build_cache/` does the
  same without a clean.

Windows helper integrity/version check:

- `setup_hooks` constructs the Core first, calculates its SHA256, and always
  builds the Rust Helper with release hardening and that expected hash.
- Flutter reads the Core SHA256 from the bundled `manifest.json` and sends it with `/ping`. Debug, Profile, and Release
  builds use the same Helper protocol and may use TUN through the same flow.
- `/ping` is loopback-only and requires no request token. The Helper compares the requested SHA256 with its embedded value
  and checks that the fixed `FlClashCore.exe` beside it exists; `/start` performs the actual Core SHA256 verification before
  every launch. The response includes the running Helper path and protocol header; Dart checks both against the current
  installation. The launcher selects the Helper only when `/ping` reports ready; any other readiness (missing manifest,
  unavailable Helper, or a Helper built for a different Core) falls back to the direct Core without requesting elevation.
  If `/start` reports a pre-spawn failure — `coreVerificationFailed` (the on-disk Core no longer matches the SHA the
  Helper and manifest agree on) or `processLaunchFailed` (the Core process could not be spawned) — the launcher degrades
  to the direct Core rather than failing the launch. `/start` releases the previously managed Core before it verifies,
  so the Helper owns no Core when either code is reported and the direct retry cannot race a Helper-managed Core.
  A mismatched Helper is reinstalled through the explicit TUN authorization flow, not at startup.
- TUN is not a required run condition. A direct Core runs unelevated and cannot bring up TUN, so any degrade to the
  direct Core — an unready Helper at resolve time, or a pre-spawn `/start` failure — silently drops TUN and keeps the
  Core running. Degrading is preferred over failing the launch: an unverified Core carries no privilege the direct
  launch path did not already have. `manifestMissing` is the one readiness that is surfaced to the user, because it
  means the installation itself is incomplete.
- Flutter creates a 128-bit lowercase-hex session ID and uses it as the random named-pipe suffix. `/start` receives only
  that address and session ID, validates the fixed `FlClashCore_<session>` namespace, starts the fixed Core beside the
  Helper, and returns the same session ID plus the spawned PID. Flutter verifies both the session and named-pipe peer PID.
- `/stop` requires the same session ID. A missing process returns `notRunning`; a different owner returns
  `sessionMismatch` without terminating that process. Session IDs are ownership tokens for lifecycle safety, not a claim
  that the loopback HTTP endpoints are authenticated.
- The Core must not outlive the Helper. On Linux the systemd unit's cgroup and `Restart=on-failure` cover that; on
  Windows the Helper puts the Core in a Job Object with `KILL_ON_JOB_CLOSE`, so the kernel kills the Core when the Helper
  process ends for any reason, and the `install` subcommand configures SCM failure actions (three restarts, 5 s apart,
  reset after 24 h). Stopping a Core sends SIGTERM first on Linux, because only a shutdown removes the policy routes
  sing-tun installed; the Core runs the same teardown itself when its IPC host disconnects or it receives a termination
  signal. `HelperClient.stopTimeout` must stay above the Helper's graceful-plus-kill budget.
- Never take `MANAGED_CORE` or `LOGS` with `lock().unwrap()`. The Helper is a long-lived service running as SYSTEM, so a
  single panic while a lock is held would poison it and turn every later request into another panic — the service stays
  dead until Windows restarts it. `lock_surviving_poison` recovers the guard through `PoisonError::into_inner` instead.
  `hub.rs` uses it at every lock site, tests included, and two tests in that file pin the behaviour.

Build configuration defaults live in `plugins/setup/setup_hooks/lib/src/options.dart` and can be overridden via the root
`build_config.yaml`.

Architecture detection is automatic. The `--description` flag passed to `flutter_distributor` adds arch suffixes to artifact names, such as `FlClash-0.8.93-macos-arm64.dmg`.

#### Android Native Task Ordering

`:core` consumes `libclash.so` and its headers as files the setup build hook writes into `android/core/src/main`, not
as an asset the hook hands back, so nothing in Gradle's model links the two. AGP's configure fingerprint tracks only
`CMakeLists.txt` and its own generated files, which makes a wrong ordering *sticky*: a configure that ran before the
hook stays cached and every later build reuses it. `CMakeLists.txt` therefore links `clash` unconditionally, and
`android/core/build.gradle.kts` fails before any native task runs when those files are absent — both push the failure
out of the configure step, where it would be cached, and into a place that re-evaluates every build. Three details
there are easy to get wrong:

- `defaultConfig.ndk.abiFilters` is derived from the `target-platform` property Flutter passes to Gradle, mapped
  through the same ABI table as `Target.forPlatform('android')` in `setup_hooks`; keep the two tables equal. The hook
  builds a Core only for the platforms of the current build, so a `:core` ABI outside that set has no `libclash.so` to
  link, and without any filter AGP would configure the NDK's full default ABI set.
- Match task names by **prefix**. AGP puts the ABI in the names of the tasks that do the work
  (`configureCMakeDebug[arm64-v8a]`). The bare `configureCMakeDebug`, `buildCMakeDebug`, and `externalNativeBuildDebug`
  that an exact-name match catches are grouping tasks that never enter an app build's execution graph.
- Use `mustRunAfter`, not `dependsOn`. `:core` declares only `debug` and `release` variants, so a **profile** app
  consumes `:core`'s `debug` variant; no `:core` variant name maps onto the right `:app` task, and `dependsOn` would
  drag a second, wrong-mode Flutter build into the graph.

A standalone `./gradlew :core:assembleDebug` stays legal once the hook has run at least once; it only warns that the
artifacts under `src/main` are whatever the last hook run left behind, which is the one failure mode this guard cannot
detect. Verify a change here with `./gradlew ":core:buildCMakeDebug[arm64-v8a]" :app:compileFlutterBuildDebug
--dry-run`: the Flutter task must be listed first even though the CMake task was requested first.

## Local Plugins

- `setup`: build-time harness for Go core artifacts and the Rust helper, driven by a Dart build hook; no runtime Dart API.
- `proxy`: system proxy configuration.
- `rust_api`: runtime Flutter Rust Bridge FFI package built through Native Assets. See below.
- `tray`: system tray for Linux, macOS and Windows. Written for FlClash; replaced the `tray_manager` fork.
- `wifi_ssid`: Wi-Fi SSID detection.
- `flutter_distributor`: app packaging/distribution.

## rust_api Crate Layout

`plugins/rust_api` has no platform folders. `hook/build.dart` is a Dart build hook: Flutter runs it for every platform
build and for `flutter test`, and `flutter_rust_bridge_hooks` (over `native_toolchain_rust`) compiles the crate with
Cargo and registers `librust_api` as a code asset that Flutter bundles and signs. The build runs
`rustup run <channel>`, so `rust/rust-toolchain.toml` must pin an exact channel and list every target the project ships;
the hook refuses `stable` and a target missing from that list. `rustup show` installs the pinned toolchain and those
targets on first use.

`plugins/rust_api/rust/src/` separates the bridge boundary from the code behind it:

- `api/` is the only input flutter_rust_bridge parses (`rust_input: crate::api`). Every function there is a thin
  delegation, so the generated bindings stay identical on every platform.
- `ipc/` implements the desktop socket server: `frame` (length-prefixed framing and the write backoff), `queue` (the
  bounded send queue), `platform` (socket cleanup, Windows peer credentials and the non-blocking pipe reader), and
  `server` (lifecycle, accept loop, and the `RUNNING`/`STATE` globals).
- `script/` runs profile override scripts on QuickJS through `rquickjs`.
- `hotkey/` registers desktop global shortcuts through `global-hotkey`: `keys` maps Flutter USB HID usages to key
  codes, `owner` runs every registration on the thread the platform binds it to (a dedicated message-loop thread on
  Windows, the main dispatch queue on macOS, in place on Linux), and `service` owns the registry and forwards presses
  to Dart. Linux is X11 only; a Wayland session without XWayland gets an error rather than a silent no-op.

What a platform does not use, it does not compile. `interprocess` and `global-hotkey` are declared under
`cfg(not(target_os = "android"))`, and `ipc/mod.rs` and `hotkey/mod.rs` swap in their `unsupported.rs` there, because
Android loads the Core in-process and has no global shortcuts. Adding a capability follows the same shape: implement it in its own module, gate the
dependency by target, and keep the `api/` entry point unconditional so one set of bindings still serves every platform.

`RustLib.init()` runs on every platform now, not only desktop — the script engine is shared.

## Profile Script Engine

`lib/common/javascript.dart` sends the profile as JSON to `evaluate_script`, which runs `main(config)` on QuickJS and
returns the JSON the script produced. Nothing about the script runs in Dart.

- QuickJS is compiled from source for the target being built, which is what removed the prebuilt `quickjs-c-bridge`
  binaries: `flutter_js` shipped x64 Windows and desktop-only libraries, so Windows ARM64 could not start (#2361).
- `rquickjs` carries pre-generated bindings for every target this project builds except the Android ones, so Android
  builds enable its `bindgen` feature. That needs the NDK's own libclang and sysroot: `native_toolchain_rust` exports
  the sysroot through `BINDGEN_EXTRA_CLANG_ARGS_<target>`, and `hook/build.dart` adds `LIBCLANG_PATH` from the NDK
  toolchain Flutter hands the hook, because bindgen otherwise loads whatever libclang the host has, or none.
- Evaluation is bounded: a 10-second interrupt deadline and a memory ceiling, because a script that never returns would
  otherwise hold the profile forever. `console` is installed before the script runs, since scripts written for other
  clients log as they work.
- `rust/tests/fixtures/profile_script.js` is the compatibility regression: an overwrite written for the suite that
  performs the transform real ones perform, so it exercises `Map`/`Set`, spread, destructuring, optional chaining,
  nullish coalescing, `Object.fromEntries`, named capture groups and lookbehind in one pass. Keep it first-party and
  free of external URLs — vendoring somebody's published script here carries their attribution and their links.

## Rust Helper Service

`services/helper/` is the privileged helper that starts the core elevated so TUN works. It ships on Windows and Linux
and is built by the setup build hook alongside the Core, which always compiles the Helper in Rust release mode
after calculating the SHA256 of the Core produced for the active Flutter configuration.

The helper owns its Windows Service Control Manager lifecycle through two elevated commands:

- `FlClashHelperService.exe install` stops and removes any stale registration, creates the auto-start service for the
  current executable path, starts it, and waits for the running state.
- `FlClashHelperService.exe uninstall` stops the service, waits for shutdown, removes its registration, and is also used
  by the Windows package uninstaller.

The Dart layer only launches the helper's `install` command through `ShellExecuteW`; it does not compose `sc.exe`,
`taskkill`, or `cmd.exe` command lines.

Linux takes the same shape with systemd in place of the Service Control Manager, and the same install timing: nothing
is registered at package install, and `Linux.registerService` asks for elevation only when TUN authorization needs it.

- `FlClashHelperService install`, run through `pkexec` so polkit raises the system prompt, writes
  `/etc/systemd/system/flclash-helper.service` for the current executable path and enables and restarts it. It reads
  `PKEXEC_UID`/`SUDO_UID` to learn who asked, and refuses to install without one — there would be no account to grant
  the socket to. It also refuses a Helper whose binary or directory is not root-owned and non-writable (a unit runs it
  as root at every boot, so an unpacked bundle would be a standing escalation), and refuses to replace a unit already
  installed for a different UID rather than restart the service out from under that account.
- That ownership check is why the `flutter_distributor` fork normalizes the packaging tree to 0755/0644 before
  `dpkg-deb`, `rpmbuild` and `appimagetool` run: they record modes verbatim, and Ubuntu's per-user default umask
  of 002 would otherwise ship `/opt/FlClash` as 0775, which the installer rejects as group-writable.
- The rpm spec sets `debug_package` and `__os_install_post` to nil for the same reason: rpmbuild's find-debuginfo and
  brp-strip rewrite `FlClashCore`, and a Core whose SHA256 no longer matches the Helper's embedded value is refused at
  `/start`, which silently degrades every launch to the direct Core.
- `FlClashHelperService uninstall` disables the unit, removes it and reloads systemd.
- The unit carries `Group=` (the owner's primary GID), `RuntimeDirectory=flclash`, the owner's UID/GID in
  `FLCLASH_HELPER_OWNER_UID`/`_GID`, a double-quoted `ExecStart=` with `%` escaped, and `Restart=on-failure` under a
  start limit so a broken unit ends up failed instead of restarting forever. The helper serves
  `/run/flclash/helper.sock` at mode `0660`, additionally drops any connection whose `SO_PEERCRED` UID is not the
  owner's, logs and retries an `accept` failure instead of letting hyper end the server, and handles SIGTERM so
  `systemctl stop` still runs its own Core teardown.
- `/start` additionally requires the Core address to be a socket owned by the owner UID before spawning, since the
  Core connects to it as root.
- The Core is spawned with the owner's real UID and an effective UID of 0, which is what a setuid Core would have had.
  It is the signal `core/ownership_unix.go` uses to hand the files it created back to the user; without it a root
  service would leave a root-owned config tree in the owner's home.
- An AppImage has neither a stable executable path nor a writable Core, and its FUSE mount is `nosuid`, so
  `system.isAppImage` reports TUN authorization as unavailable instead of prompting for a password that cannot help.
- A Linux host without systemd (`/run/systemd/system` absent) has no Helper: `system.hasHelperService` is false there,
  readiness is the `stat` check, and `pkexec` sets the setuid bit on the bundled Core as before.

In every Flutter build mode `/start` opens the fixed Core executable beside the Helper without write/delete sharing,
validates it against the SHA256 embedded only in the Helper, and keeps that handle open through process creation.
`/ping` only compares the requested `coreSha256` with the Helper's embedded value and checks the fixed Core path exists;
it never hashes the Core. Protocol version 6 uses 32-character lowercase-hex session ownership:

- `GET /ping?coreSha256=...` returns the current Helper executable path with `x-flclash-helper-protocol` when the
  requested SHA matches.
- `POST /start` rejects unknown JSON fields, validates `{address, sessionId}`, then releases any previously managed Core
  before verifying the Core — so every outcome, including a rejected one, leaves the Helper owning no Core — and returns
  `{sessionId, pid}`.
- `POST /stop` validates `{sessionId}` and only stops the matching managed Core. A session mismatch is HTTP 409.
- `GET /logs` exposes the bounded recent Helper/Core stderr buffer with `no-store` caching.

Endpoints bind only to `127.0.0.1:47890` on Windows and to `/run/flclash/helper.sock` on Linux, and do not use
request-token authentication. Lifecycle safety comes from the fixed executable/hash, the strict address namespace
(`\\.\pipe\FlClashCore_<32 hex>` on Windows, `/tmp/FlClashSocket_<digits>.sock` on Linux), the session-scoped stop
contract, Dart-side peer-PID verification on Windows and, on Unix, the Core socket that `plugins/rust_api` sets to
mode `0600` so only the owning user (and the root-effective Core) can connect. When the Helper service itself shuts
down, it unconditionally stops the Core process it owns; under systemd the unit's control group does the same.
