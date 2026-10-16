# Architecture

## Core Integration

The Go proxy core in `core/` operates in two modes.

Android lib mode:

- `gomobile bind` builds `core/mobile` into an AAR: a native library per ABI, shipped as `libclash.so`, and the Java
  classes gobind generates in `com.follow.clash.core.mobile`. The `:core` Gradle module builds it and takes in its
  classes and libraries (see Android Core Build).
- The Android `:core` module owns the binding: `Core.kt` is the only caller of the generated `Mobile` class. Flutter
  crosses MethodChannels through `lib/plugins/service.dart` and Android's `ServicePlugin` rather than calling the Core
  directly: `${packageName}/service` for lifecycle commands and Core events, `${packageName}/core` for Core method
  calls.
- Flutter runs the UI isolate on Android's main thread (3.47 merges the two and ignores the opt-out in release), so
  main-thread work anywhere in the process, the Core's included, costs frames. Only sending to Dart needs that thread;
  a `MethodChannel.Result` may be answered from any thread. `${packageName}/core` is handled on a serial background
  task queue and answered from the Core's goroutine, an event batch is encoded on the Core's thread and only sent on
  the main one, `ForceGC` (called from `onLowMemory`/`onTrimMemory`) collects on its own goroutine, and
  `NetworkObserveModule` refreshes DNS on its own looper.
- `lib/core/lib.dart` (`CoreLib`) implements the shared Core interface, gates method calls on its connection completer,
  initializes and synchronizes Android shared state, and closes the native service path exactly once.
- Because Core is in the application process on Android, application RSS already includes Core memory.

Desktop core mode:

- Go core runs as a separate process with `CGO_ENABLED=0`.
- `rust_api`'s `ipc` module provides the native local-IPC primitives: a Unix domain socket on macOS/Linux and a named pipe
  on Windows, served by an `IpcServer` handle. Dart owns the transport state, RPC correlation, process ownership, and
  lifecycle convergence above those primitives.
- `lib/core/service.dart` (`CoreService`) is the composition root. It wires the IPC transport, launcher selection,
  lifecycle controller, RPC client, and crash-event bridge, and holds no lifecycle logic of its own.
- `lib/core/desktop/transport.dart` binds an `IpcServer` and turns its events into ready, connected, disconnected, and
  failed transport events plus a frame stream. A connection that ends on an I/O error is a disconnect carrying that
  error; failed means the server itself is gone and is terminal for that transport. A replaceable binding keeps RPC
  subscriptions stable when a failed or stale transport must be rebuilt.
- `lib/core/desktop/rpc_client.dart` owns request IDs and pending completers, waits up to 10 seconds for a connection,
  applies a three-minute default method timeout, unwraps `CoreMethodResponse`, and fails all pending calls when transport
  disconnects or closes.
- `lib/core/desktop/lifecycle.dart` serializes process intents and owns the authoritative desktop state machine.
- `lib/core/desktop/launcher.dart` abstracts direct child-process and privileged Helper ownership through idempotent process
  leases. `lib/core/desktop/helper_client.dart` is the typed local HTTP client for the privileged Helper.

`lib/core/controller.dart` (`CoreController`) selects the implementation based on platform. `lib/core/interface.dart` defines the shared `CoreHandlerInterface`.

Key Go core files:

- `core/protocol.go`: method names, event types, and the parameter and result shapes shared with Dart.
- `core/method.go`: MethodChannel-style method-call dispatch, the handler table, and response envelopes.
- `core/lifecycle.go`, `config.go`, `proxy.go`, `delay.go`, `provider.go`, `geo.go`, `connection.go`, `log.go`: the
  handler functions, one file per area. `core/hooks.go` wires mihomo's hooks to them.
- `core/message.go`: non-blocking state/priority/bulk event queues and bounded message batching.
- `core/lib.go`: the Android library API: TUN callbacks, the event listener, and the entry points `core/mobile` binds.
- `core/mobile/`: the package gomobile binds. gobind generates Java for its exported API, so it speaks only `int32`,
  `bool`, `string`, `[]byte` and its own interfaces; a Go `int` would become a Java `long`.
- `core/cmd/core/`: the desktop entry point. `core/` itself is the library package `core`, because gomobile cannot bind
  a `main` package.
- `core/server.go`: desktop socket/named-pipe client and framed message forwarding.

## DNS, NTP and Sniffer Overrides

A URL or file profile brings its own sections; a custom profile brings none. The app's DNS page
(`PatchClashConfig.dns` with `dnsOverrideKeys`) is written over the DNS of every URL and file profile, and offers only
`DnsOverrideKey.normalProfileKeys`: keys that name nothing of a profile's own, because a subscription's groups and rule
sets change with every update. A custom profile keeps all three sections in `Profile.overrides`, a `ProfileOverrides`
stored as JSON in the `profiles.overrides` column, with every key available, and NTP and sniffer exist nowhere else.
`setupState` resolves `SetupState.overrides` by profile type, intersecting the app-wide keys with the normal set, and
`_makeRealProfileTask` merges whatever it is handed; there is no on/off toggle, a picked key is the override.

Each `*OverrideKey` names one Clash key, with `parent.field` paths for nested maps, and covers every yaml key of the
matching mihomo raw struct; `test/models/{dns,ntp,sniffer}_override_test.dart` read `core/Clash.Meta/config/config.go`
and fail when a core bump adds or drops one. `overrideJson` builds the fragment in model order and skips a key whose
value is empty, so a key left without a value writes nothing: the core refuses an empty `nameserver` outright.
`mergeDnsOverride` merges one level deep so a partial fallback filter keeps the profile's other filter keys; NTP spreads
over the profile's flat `ntp` map. For a profile whose `dns.enable` is not true, the task first fills `baselineDns` for
`baselineDnsOverrideKeys` (`enable`, `enhanced-mode: fake-ip`, `nameserver`), the one thing the core is never without:
with DNS off, mihomo answers every TUN-hijacked query with an error. The baseline stays apart from the model defaults,
which carry no preset of the app.

An added key starts from the spec's `defaults` through its `OverrideField.reset`, and those defaults are mihomo's: a key
starts at the value mihomo parses without it, presets included, such as the nameservers, fake-IP range and filter, and
NTP server of `DefaultRawConfig`. A key mihomo leaves unset, such as `listen` or a sniff protocol's ports, starts empty
and writes nothing until the user fills it in, and so does the fallback filter's GeoIP code, whose value is left for the
user to choose. mihomo sniffs a protocol listed without ports on that protocol's standard port, which the page shows as
the default. The tests above pin the defaults against `DefaultRawConfig`. A spec that mixes in `OverrideQuickEdit` gets
quick edit, which opens `overrideYaml` in an `EditorPage` and rebuilds the key set from the document through
`applyOverrideYaml`, rejecting keys outside the section and values the model cannot hold.

mihomo upper-cases sniff protocol names and ignores the deprecated `sniffing` list once `sniff` holds anything, so
`mergeSnifferOverride` drops the profile's entry for an overridden protocol in any case and first carries `sniffing`
into `sniff`. A `rule-set:` key of a custom profile's DNS policy counts as a use of that rule provider, so
`_resolveInjectedProviders` injects it like one a rule names. Safe mode forces `write-to-system` off on whatever `ntp`
section reaches the core, because setting the system clock is a host change; `loadConfig` in the Go wrapper also drops
it on Android, where the seccomp policy kills the process for `settimeofday`.

TUN is the exception to covering the raw struct. The network settings own only `Tun.coreJson` (`enable`, `device`,
`stack`, and `auto-route` always on), spread last over the profile's section and patched again on every
`updateConfig`, so `TunOverrideKey` offers only keys outside it that work in FlClash's TUN. Its keys exist app-wide
(`PatchClashConfig.tunOverride` with `tunOverrideKeys`, listed in the network page's TUN section as `OverrideEntry`
rows and added from its last row, as a custom group's options are) for every profile, and per custom profile, whose own keys `ProfileOverrides.overAppTun` lays over the app-wide ones. MTU,
congestion control, strict route and the route lists are such keys on desktop, so a profile's own values apply unless
picked; Android's TUN rows keep them in `Tun`, which its VPN service starts from, and a config saved before the move
carries values changed from their defaults into picked keys. `bypassPrivateRoute` stays a network setting: the task
appends the private ranges to whatever `route-exclude-address` results. `dns-hijack` is a key too: the task writes
`any:53` beneath the overrides, so a profile's own value never applies, a picked key replaces it, and the key starts at
that value. A key sing-tun reads on some platforms only is listed only there
(`_isRead` in `lib/views/config/tun.dart`): strict route on Linux and Windows, GSO and the interface, user ID and port
filters on Linux. `udp-timeout` reaches only the gvisor and system stacks and congestion control only mips, which their
descriptions say. Route address sets are left out: sing-tun applies them only through `auto-redirect`.
`test/models/tun_override_test.dart` fails if a key comes to overlap `Tun.coreJson`. Android starts its VPN from
`core/tun` without the section, so TUN is listed on desktop only. Being a part of the section, the page has no quick
edit; see Quick Edit.

A custom profile's overview keeps rows for rules, providers and DNS, which every custom profile runs on, and puts the
dialer proxies, NTP, sniffer and TUN behind a single "more" row, which opens a page listing them with their states.
Both lists are the same grouped rows, glyph, title and state, ending in a chevron. Another rarely changed section joins
the "more" list rather than taking a row of its own.

Every page is an `OverrideView` over an `OverrideSpec` from `lib/views/config/override.dart`. The spec supplies the
section's keys, labels and fields; its `OverrideTarget` is where the model and keys live, `PatchOverrideTarget` for the
app-wide DNS and `ProfileOverrideTarget` for a profile. Another overridable section is a spec, not a copy of a page.

A config from a release that still had the `overrideDns` toggle keeps, through `Config.fromJson`, the normal keys of
an on toggle and none of an off one. That release had no custom profiles, so its app-wide NTP override is dropped.

## Listener Exposure

`_makeRealProfileTask` in `lib/common/task.dart` writes `mixed-port`, `allow-lan`, and `external-controller` into every
generated profile. With `allow-lan` off, mihomo's `genAddr` binds each listener to `127.0.0.1`; the external controller is
`ExternalControllerStatus.close` by default and never binds anywhere but loopback. The task also clears
`external-controller-tls`, `-unix` and `-pipe` in every mode: the unix and pipe controllers answer without a secret, and
the unix one unlinks whatever file sits at its path before opening it to everyone, so a profile may not choose them.
Outside safe mode, profiles retain `listeners`, `tunnels`, `ss-config`, `vmess-config`, `tuic-server`, `iptables`,
`dns.listen` and `ntp.write-to-system`. Extra inbounds can bypass the app's LAN and authentication settings, and a TUN
listener can change routing independently of the app's TUN toggle. These network and clock effects are an accepted
boundary; they are not treated as arbitrary filesystem modification. The task disables `iptables` when its
`inbound-interface` contains a space, because mihomo interpolates it into commands and splits their arguments on spaces.
Safe mode clears these extra inbounds and iptables, closes DNS listening and disables NTP system time writes even after
local overrides. The editor omits disabled alternate controllers and keeps listener completion.

An open external controller always has a secret, because mihomo serves a controller with an empty one to every local
user and, through CORS, to any page the user visits. `PatchClashConfig.secret` is that secret and it belongs to FlClash,
as the address does: the task writes it over whatever the profile carries, and `UpdateParams.secret` hands the same value
to a running Core, which restarts the controller when it changes. `ensureControllerSecret` keeps the pair consistent
(an open controller gets a generated secret, a closed one drops it, so every opening rotates it) and runs where a
config enters the app: the settings toggle, startup, and `writeConfig` for a restored backup. `_effectivePatchConfig`
reports a controller without a secret as closed, and `_makeRealProfileTask` independently closes it without a secret
or in safe mode, so a writer that skips `ensureControllerSecret` opens nothing. The settings page shows the secret in
an editable row, which refuses an empty value.

The loopback listener takes local connections without authentication by default: mandatory credentials would lock out
every external local consumer a proxy client exists for. The binding only guarantees traffic originates on the device;
it does not isolate programs already running there, so on Android any app holding `INTERNET` can use the proxy and learn
the outbound IP (#1934). The opt-in answer is the local authentication setting (`NetworkProps.authentication`), which spans
four paths that must stay in sync: `_makeRealProfileTask` writes the credentials into `authentication` and force-clears
`skip-auth-prefixes` so a profile cannot silently exempt loopback; `UpdateParams.authentication` applies the same list
to a running core; `FlClashHttpOverrides` sends the credentials with the app's own proxied requests; and `sharedState`
withholds the Android VPN system proxy declaration because `ProxyInfo` cannot carry credentials (TUN still captures that
traffic). Desktop system proxy is deliberately not gated — dropping it would leak traffic direct, so the setting's
description tells users to supply credentials manually instead.

### Local Trust Boundary

The Windows Helper answers only a connection whose client process runs under the owner SID it was installed for;
the Linux Helper only the owner uid. A setuid Core is executable by `root:admin` (macOS) or the installing user's primary
group, so its boundary also includes every member of that group, not just the installing account. Profiles cannot choose
a controller address, a secret or alternate controllers. Another account outside those permissions, a subscription,
or a remote party reaching the privileged Core's control or filesystem APIs is a vulnerability.

A process running as the same account is not stopped. It can ask the Helper to start the Core
against a socket or pipe it owns, or run a setuid Core against a port it listens on, and so become the host that drives
a privileged Core: `initClash` chooses the home directory every path check anchors on, and `getConfig`,
`getProfileBase`, `getProfileOutbounds` and a `setupConfig` or `buildProfile` base read any path.
The Core connects to whatever address it is given and cannot tell that host from FlClash. An account check cannot
distinguish it from a same-account process that can already read FlClash's memory and files. This remains a user-to-root
or user-to-SYSTEM privilege escalation, not a complete security fix. An open external
controller is inside the same boundary: its secret is stored under the account, and `/upgrade` stays mounted (it fetches
fixed MetaCubeX release URLs, not caller-chosen code). mihomo's `IsSafePath` compares paths lexically, so a symlink inside
the home directory escapes it; that fix belongs upstream, not in the submodule.

Closing the same-account case requires limiting what a hijacked Core can do. Keeping the main Core unprivileged and
moving host changes into narrow platform helpers requires architectural work, but need not introduce repeated prompts
or remove ordinary proxy functionality. Features that require additional privileges, such as identifying other users'
processes, need platform-specific handling. Descriptor-based filesystem confinement can preserve ordinary managed
paths; intentional external symlink targets need explicit allowed roots. These changes have not been implemented.
Account authentication, a private socket directory or a symlink check at configuration time does not remove the
privileged filesystem operations available to the host. Changes must not widen access to those operations.

### Interface Name Modes

The same task also writes `interface-name` per `PatchClashConfig.interfaceNameMode`: `clear` (default) forces it empty so a
subscription's value cannot survive into the generated profile, `follow` leaves whatever the profile YAML already has, and
`custom` writes the user's `interfaceName`. mihomo ignores `interface-name` on Android whenever `dialer.DefaultSocketHook`
is installed (`core/lib.go` `installHooks`, vendored `dialer.go`), so `NetworkListView` in `lib/views/config/network.dart`
shows the mode picker and text field only on desktop.

### Network Settings

Every `Tun` field is written over the profile's `tun` section and hot-applied through `tunSchema`, and the other keys of
that section keep the profile's value; `test/models/tun_test.dart` keeps the model, `RawTun` and `tunSchema` in step.
Beyond what FlClash always managed, `Tun` carries only the keys worth tuning: `mtu`, the mips stack's
`congestion-controller`, and `strict-route` where sing-tun enforces it (Linux and Windows).

Routing is the same on every platform: `route-address` (empty routes everything), `route-exclude-address`, and
`NetworkProps.bypassPrivateRoute`, which adds `privateRouteAddress` to the exclusions in `Tun.getRealTun`. Desktop hands
both lists to sing-tun. VpnService can only add routes before Android 13, so `Tun.vpnRouteAddress` cuts the exclusions
out of the routes with `subtractCidrs` and lists every family it routes; `VpnService.addRoutes` routes everything only
for an empty list. A config saved with the old `routeMode` keeps its choice: `bypassPrivate`, which ignored the route
list, loads with the flag on and the list cleared, and `config` with the flag off. Others were left out on purpose: no stack in the vendored sing-tun reads `endpoint-independent-nat`, the
default mips stack ignores `udp-timeout`, and the rest are platform plumbing few users need. Android builds its TUN from
the VpnService descriptor in `core/tun/tun.go`, so only MTU and the congestion controller reach it, through `VpnOptions`
and the `options` argument of `startTUN`; the VpnService builder takes the same MTU.

The TUN fields start at mihomo's own defaults, and a saved zero MTU or empty congestion controller, which mihomo reads
as those defaults, decodes to them. The outbound rows are plain settings written over every profile, and changing one
re-applies the profile; keep-alive is forced off on Android, and only Linux honours `routing-mark`.

## Lifecycle Ownership And Convergence

### Shared Flutter Layer

`CoreController.start()`, `restart()`, `stop()`, and `close()` are the only shared lifecycle facade. `close()` is terminal;
callers must not try to reuse a closed platform implementation.

`CoreAction` in `lib/providers/actions/core.dart` owns the user-facing Core status and setup sequence:

- `startCore()` publishes `connecting`, starts the platform Core, publishes `connected`, then initializes Core state. A
  startup error publishes `disconnected` and displays the error.
- `restartCore()` coalesces overlapping callers behind one worker. `_requestedRestartRevision` records newer requests.
  After the lifecycle restart, the worker reapplies running state or the profile, rereading `isStartProvider` on every
  pass, until it has consumed the latest revision, so the newest start intent wins.
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

### Applying Setting Changes

A changed setting is patched live through `UpdateParams`, re-applied with the profile, or, for the Android VPN, left
to a restart the user confirms. [setting-changes.md](setting-changes.md) says which path each setting takes and how to
choose one for a new setting.

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
- `ServiceState` owns the latest `RunRequest` and the shared configuration. Identity checks discard obsolete work.
  `startPreparationLock` serializes permission/setup preparation and `transitionLock` serializes actual service
  transitions.
- `RunState` is derived, never assigned by a step: `ServiceStateMachine.publish` computes it from the transition in
  flight, the latest intent, and `ServiceController.runtime`. A service that is up under a stop intent reads `STOPPING`, a
  start still waiting on a permission reads `STOPPED`, and `STARTED` needs both a running intent and a runtime. The tile
  and `getRunTime` both read this one value, so they cannot disagree with the service.
- `ServiceController` owns exactly one `ManagedServiceBinding`, selects `VpnService` or `ProxyService` from `VpnOptions`,
  binds with a five-second connection timeout, and invokes `ManagedService.start()`/`stop()` off the main thread. The
  binding and `runtime` (which service runs, and since when) are set and cleared together, by a stop, a failed start, or
  a lost connection and by nothing else. Flutter's `shutdown` only clears the Core event listener: Android keeps an
  established `VpnService` alive through its own connection, so a binding dropped on exit left a tunnel that was
  reported as running but that neither a stop nor a revoke could reach.
- The Core listens exactly while `runtime` is set: a successful start ends in `Core.startListener()` and every path
  that clears `runtime` calls `Core.stopListener()`. Both return at once when the Core is already there, which is the
  usual case, since `startTUN`/`stopTun` and Flutter's own `startListener`/`stopListener` got there first. They matter
  when nothing else does: a proxy-only run stopped from the tile used to keep the mixed port open with nothing
  reported as running. A start closes after itself the same way: Flutter's `startListener` and the native `quickSetup`
  both open the ports before any service exists, so a start that ends without a `runtime`, refused or cancelled, stops
  the empty service once more, without passing through `STOPPING`. Flutter may be gone by then and never see the
  `stopped` report.
- A start that does not bring the service up gives its intent back and takes down whatever it left running, unless a
  newer request has claimed the service. A failed start therefore always ends in `STOPPED`, whichever step refused it.
  The one start that mints no request is a repeat on a settled run of the same kind, which Flutter sends every time it
  reattaches: a request refused at a permission prompt there would stop a service that was running fine.
- Generic service creation/destruction is lifecycle evidence, not user intent. New commands must flow through
  `ServiceState.requestStart()`/`requestStop()` or the explicit system-action handlers instead of inferring intent from a
  callback.

Quick Settings, notification, revoke, and Always-on VPN paths converge on the same owner:

- With a Flutter engine attached, `ServiceState.handleStartAction()` forwards through `TilePlugin` to `TileManager`,
  because only Flutter can apply the current profile. Without Flutter, native code claims the intent, restores
  `SharedState` from preferences, runs `quickSetup`, checks VPN permission, and runs the start; claiming first is what
  makes a second action during the setup toggle that start off instead of racing a second setup against it.
- A stop never needs Flutter. `handleStopAction()` stops the service natively whether or not an engine is attached, so
  the tile, the notification action and a revoke work even when Flutter's own idea of the state is wrong.
- Whenever the run ends without Flutter having asked for it (a start that failed, a native stop, a revoke, a lost
  service), `ServicePlugin` sends `stopped` with the revision of the last `start`/`stop` command it received.
  `Service` in `lib/plugins/service.dart` drops a report older than its newest command, or one that arrives while its
  last command was a stop (on-demand suspension stops the service while `isStartProvider` stays true), and
  `AndroidManager` answers the rest with `setRunning(false)`. The report is read on the platform thread, where the
  commands arrive, so the revision and the intent it carries describe the same instant.
- Android may create an Always-on `VpnService` through `onStartCommand()` without FlClash's bound-service path. The service
  sends the explicit, permission-protected `VPN_START_REQUESTED` broadcast to `ServiceBroadcastReceiver`, which routes it to
  `ServiceState.handleStartAction()` so Core/configuration and the normal binding are restored before TUN is treated as
  ready.
- `VpnService.onRevoke()` stops TUN/modules first, then sends `VPN_REVOKED`; the receiver only requests a stop while
  `ServiceController.runtime` is a VPN run.
- `ServiceBroadcastReceiver` uses `goAsync()` and an atomic one-shot completion. Normal completion or a nine-second
  watchdog calls `PendingResult.finish()` exactly once; the watchdog releases Android's broadcast lease and does not
  cancel or redefine the underlying lifecycle intent.

## Core Protocol And Event Delivery

The shared protocol uses `CoreMethodCall(id, method, arguments)` and `CoreMethodResponse(id, result, error)` in both
directions. The envelope is the only JSON serialization layer: keep arguments, results, and event data as structured JSON
values rather than embedding pre-encoded JSON strings. Plain domain strings, such as country codes or provider contents,
remain strings.

A response over 1 MiB goes to a file under `<home>/responses/`, and the envelope carries only its `file`
(`core/spill.go`). Sent inline, Android copies it into the Java heap three times (the gomobile `byte[]`, the codec and a
direct buffer), and desktop IPC drops a frame above `maxIPCFrameSize`. `lib/core/spill.dart` reads a spilled file only
from that directory, decodes it in an isolate and deletes it; `initClash` clears what an earlier run left.

A profile file's proxies, groups and rules never cross the bridge. `getProfileBase` returns the config without
`proxies`, `proxy-groups`, `sub-rules` and `rules`, with their counts, the profile's MATCH rules and a sha256 digest.
`SetupAction.getProfile` patches it as before and sends the result as `SetupParams.base.overlay`. `core/profile_base.go`
puts the profile's bulk sections into the overlay, appends the profile's rules after the overlay's, writes `config.yaml`
for the Android service and the controller's reload, and parses it. `config.yaml` is encoded a slice at a time, because on a
profile of 100k proxies and 2M rules one `Encode` call doubles the peak heap. The preview reads the YAML `buildProfile`
merges into the spill directory, and the extend page only the names
and types `getProfileOutbounds` lists; a script extension still needs the whole config from `getConfig`.

Go event delivery is intentionally non-blocking:

- Loaded-provider, geo-update, and route-changed events use a state queue that never evicts; the rules for it are under
  Core API Safety in `.agents/rules.md`. Every other event except the bulk kinds, delay included, uses a 256-entry
  priority queue. Desktop process crashes are generated locally by `CoreService` from lifecycle failures rather than
  sent through the Go queue.
- High-volume log, request/connection, and DNS query events use a separate 256-entry bulk queue, so bulk floods cannot
  evict state.
- A full priority or bulk queue evicts only its own oldest event and retries the newest; DNS events never evict. Core
  work never blocks on event delivery.
- The batcher flushes at 32 messages or every 16 milliseconds. Priority events are preferred, but one bulk opportunity is
  guaranteed after eight priority messages to prevent starvation.
- `sendMessage` drops an event before it is queued when `hasEventListener` is false. That only happens on Android, after
  the Flutter engine detaches while the service keeps the Core running; request and DNS events would otherwise be
  encoded per connection and per query for nobody.

DNS query events come from the Clash.Meta fork's `dns/patch.go` and are raised where mihomo writes its `[DNS]` debug
log, so the DNS page lists the same resolutions: one event per cache hit, and one per upstream exchange however many
callers singleflight merged into it, carrying the upstream whose answer was used. Fake-IP and hosts answers never reach
a resolver and are not recorded. Queries from apps arrive with the `DNSContext` that `Service.ServeMsg` created and
report `app`; other initiators come from `resolver.WithInitiator` at the call site (rule matching, DIRECT, proxy
server dialing), and unlabeled queries report `other`.

Dialer-loop events come from the fork's `component/proxydialer/patch.go`. mihomo follows a `dialer-proxy` that leads
back to its own proxy until the stack overflows, so a dial that asks the same `dialer-proxy` for an address it is
already dialing through it fails with `ErrDialerLoop`. `core/hooks.go` reports each looping name at most once every
three seconds as a priority event, which the app shows as an error notice whether or not logs are captured. The custom
profile pages flag only the loops FlClash can follow on its own, through a group's own list or an `include-all-proxies`
that no filter, exclude filter or exclude type narrows; what filters and providers pick, including provider proxies
that carry their own `dialer-proxy`, is left to this guard.

`ProxyGroup.fromJson` reads `include-all` as both `include-all-proxies` and `include-all-providers`, as the core does, so
import and quick edit keep it. They take in only what the config declares, which is what some group of the profile
names: its local proxies and the file or url profiles in a `use`. Setting one declares nothing more, so the app's other
proxies and subscriptions stay out, and the core picks from the declared ones by the group's filters. Groups saved by
v0.9.0 kept `include-all-proxies` in their stored `definition`, and it takes effect again.

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

Proxy delay testing follows the same failure-safe UI rule. `ProxiesAction._runDelayTests` marks its keys in
`pendingDelayTestsProvider` and releases them in `finally`, and a test the Core does not answer leaves the last
measurement in place; the delay-test bullets under Core API Safety in `.agents/rules.md` give the reasons. A key stays
`queued` until the `TaskPool` actually runs it, so node cards animate a loader for at most `maxConcurrentDelayTests`
nodes and show a static glyph for the rest; a loader on every queued node made fast scrolling drop frames. A group's delay
test button, the tab page's action and the list page's group header alike, spins while `delayTestingGroupsProvider`
holds the group; `delayTestPageGroup` marks it, ignores a second request for the same group, and clears it in `finally`,
so an RPC failure cannot leave the button spinning and remounting a header does not lose the state.

The dashboard's probe cards show a failure as still checking for five seconds after they see `proxied` turn true,
through `ProbeStartHold` in `lib/views/dashboard/probe_start_hold.dart`: `ServiceStatusCard` holds the check on each
tile, and `CurrentOutboundCard` holds the exit IP, whose refresh button stays inert meanwhile.
`SetupAction.setRunning` flips the run time, and with it `proxied`, before the Core has brought its listeners up, so the
probe launched on the spot often fails, and the config re-apply that follows every start probes again moments later;
without the hold a card flashes a failure and then takes it back. The hold is local display state like the connecting
hold above: the cache still records the failure, the hold arms only on an observed transition, a result that is not a
failure shows at once, a stop cancels it, and a failure still standing when it ends is shown.

## Route Consistency

A probe result on the dashboard — the exit IP, a node's exit IP, a service check — either describes the route in
force or is being asked again. The full design is `docs/plans/probe-route-consistency.md`; the mechanism has three
parts.

- The Core is the source of truth for the route. `core/route.go` keeps a structural epoch (advanced by a config
  apply, a mode or IPv6 switch, any proxy provider whose version changed, and any rule set that loaded new content,
  whether the user or its own interval updated it) and a `picks` map from each Selector, URLTest and Fallback group
  to what it resolves to right now, versioned on every change. `handleChangeProxy` re-reads the picks under
  `selectMu` and answers `ChangeProxyResult{changed}`, so the connection reset only runs when the pick moved. A
  health check moving a URLTest pick has no mihomo hook, so the picks are polled every second while the host watches
  (`watchRoute(true)`) and the listeners are up; the same poll notices a provider or rule set that updated in the
  background. Every probe answer carries the counters it started under; `routeChanged` publishes the state whenever
  it differs from the last read.
- `routeTrackerProvider` in `lib/providers/route_state.dart` merges that with the host's side: `proxied` (running and
  not suspended), a host epoch that a connectivity event moves, and `synced`, which is false until `watchRoute` has
  returned a snapshot and again after a Core disconnect. Nothing is fresh while unsynced, so a cache never judges
  answers against counters it made up. The tracker subscribes when the first target is watched and releases the Core
  when the last one goes; an answer newer than the state means an event was evicted, and the cache asks for a resync.
  It also releases the Core while the app is hidden and reads it again on return, keeping `synced`: the Core and its
  counters are the same ones, so the fresh snapshot invalidates only what moved. On Android the Core drops the watch
  itself when the event listener is cleared, because an engine that goes away never sends `watchRoute(false)`.
- `RoutedProbe` in `lib/providers/routed_probe.dart` is the one cache both `OutboundIpProbe` and `ServiceStatus` mix
  in. A widget `watch`es the target it shows and `unwatch`es on the way out; only watched targets are probed, one
  request in flight per target. An answer is stamped with the Core's counters and the host state at launch, and
  `RouteState.isFresh` walks its chain against the picks, so a selection change only invalidates results that went
  through the changed group while an epoch change invalidates everything. A stale watched entry is asked again at
  once; an unwatched one is dropped. Nothing launches while the app is hidden: what falls due waits for it to be shown.
  Failures wait for `retry`, `refresh`, or the app resuming (`markResumed`), and
  a service check that timed out is a failure that still shows its status. `refresh` is the user's own request and
  runs for unwatched targets too: the service sheet reads the cache and never watches its rows, because one service
  check is one to four full HTTPS fetches where a delay test is a single empty request.

`ipQuality(ip)` in `lib/providers/ip_quality.dart` is keyed by the outbound IP found, so a route change reaches it as
a new IP and an unchanged IP reuses the result. A lookup races its sources the way the IP check does and takes the
first one that determines a type. A success is kept for the session with `ref.keepAlive()`; a failure is not cached,
and Riverpod's automatic retry is off because a retry after an HTTP 429 spends the same per-outbound-IP quota again.

## UI Layer

`lib/ui/` holds the components and design tokens that know nothing of the app: shapes, surfaces, motion, colors, the
scaffold, sheets, popups, lists and the glyphs under `lib/ui/icons/`. `lib/widgets/` holds the components built from
them that do: settings rows, subscription and profile pieces, anything that reads a provider or a model.
`widgets/widgets.dart` re-exports `ui/ui.dart`, so app code imports either barrel.

`test/lint/ui_layering_test.dart` walks the imports of every file under `lib/ui`. Nothing they reach may leave
`lib/ui`, except `lib/common` files whose own imports stay out of the app, never the `common.dart` barrel, and none
may import Riverpod. A component that needs app state reads what the app provides above its navigator:

- `ViewScope` (`lib/ui/view_scope.dart`): the window size, whether the layout is mobile, and the window controls
  over a page. `AppViewScope` in `lib/manager/theme_manager.dart` fills it from `viewSizeProvider`,
  `isMobileViewProvider` and `versionProvider`. It is an `InheritedModel`, so a reader of one value does not rebuild
  when another changes; `context.isMobileView` reads it without listening.
- `MeasureScope` (`lib/ui/measure.dart`): the `Measure` that `ThemeManager` also assigns to `globalState.measure`.
- The `MediaQuery` text scaler that `ThemeManager` sets: the app text scale behind `.ap(context)`, `.mAp(context)` and
  the `...Of(context)` paddings in `lib/ui/metrics.dart`. Reading it there makes a widget sized by them rebuild when the
  scale changes; a global copy or a top-level final would keep the scale it was first read at.
- `UiLocalizations` (`lib/ui/l10n.dart`): the strings the components show themselves. `AppUiLocalizations.delegate`
  in `lib/common/app_localizations.dart` serves them from the ARB strings; a new one needs a getter on both.

A test that builds its own `MaterialApp` registers `AppUiLocalizations.delegate` and returns `wrapAppScopes` from
`test/helpers/test_app.dart` in its builder, as `TestApp` does.

## Icons

`lib/ui/icons/` holds every icon the app shows. Nothing in `lib/` uses the Material icon font, and
`test/lint/material_icons_test.dart` fails on any `Icons.*` or `AnimatedIcons.*`, so every icon shares one stroke and
can animate its shape.
A `Glyph` is a list of shapes on a 24-unit grid, stroked at `Glyph.strokeWidth` with round caps and joins and
superellipse corners; a curve the primitive shapes cannot draw is a `GlyphPath`, SVG path data traced along the
stroke's center. Each shape has a role that decides its filled form, the way SF Symbols and Fluent pair an
outlined icon with its filled variant:

- `body` fills;
- `detail` is cut out of the fill, and a `solid` detail such as a dot is cut as an area;
- `line` stays a stroke, for parts that belong to no body, like a handle or a link between nodes; it thickens from
  `Glyph.strokeWidth` toward 2.2 as the glyph fills, so a glyph of lines alone still carries weight in a filled button.

`GlyphPainter` paints any point between the two forms. Each body fills inward from its outline, reaching half its
shorter side, which no point of the body lies beyond, as `fill` reaches 1. Details thin away over the first half and
return as cutouts over the second, so a detail is never a stroke and a cutout at once. The glyph is painted opaque into
one layer that carries the color's alpha: a translucent color, such as a disabled one, then stays even where strokes
cross the fill, and a cutout clears only the glyph's own pixels. `GlyphIcon` shows a glyph at a fixed `fill`, taking
its size, color, and fill from `IconTheme` unless it is given its own, as `Icon` does, and mirroring it in right-to-left
text when `Glyph.matchTextDirection` is set.
`AnimatedGlyph` drives a `GlyphIcon` from its `filled` flag and pops briefly when it fills. A glyph whose shape follows
some other state, like the sidebar toggle that tracks the pane's width, is a builder in `AppGlyphs` such as
`AppGlyphs.sidebar(progress)`. A new glyph goes in `AppGlyphs` and in the list `test/icons/glyph_painter_test.dart` runs
through its checks; it is named for what it means in the app, one glyph per meaning, with SF Symbols and Fluent as the
reference for the metaphor. Tests find one with `find.byGlyph` from `test/helpers/glyph_finders.dart`.

Icons are outlined by default and filled inside a filled button: `IconButton.filled` and `.filledTonal`, and
`FilledButton` in its tonal and icon forms draw their glyph with `fill: 1`, because an outline on a tinted
container reads weaker than the container it sits in. A glyph with no body only thickens its lines and still takes
`fill: 1`, so the rule holds if the glyph later gains one. `test/lint/filled_button_glyphs_test.dart` checks every
`GlyphIcon` written inside such a button; an icon that reaches the button from elsewhere, as through a helper that picks
the button variant, gets its fill by hand or from `IconThemeData.fill`. Everywhere else fill marks state only: the
selected destination, a pinned window, a lit torch. The phone's floating navigation bar is the one exception: like an iOS
tab bar it fills every destination and marks the selected one by colour alone.

Framework widgets that draw their own icon take it from the theme: the `ActionIconThemeData` in `lib/application.dart`
supplies the back and close buttons, with `AppGlyphs.backFor` picking the platform's back glyph, and a `DropdownMenu`
is given its chevrons. A framework widget added later that paints a Material icon needs the same treatment.

Empty states draw no image assets either. `NullStatus` in `lib/ui/null_status.dart` shows the glyph for its
meaning filled on a Material 3 Expressive shape from `material_new_shapes`, with a few accent marks, and enters with
one of three choreographies picked at random: the shape spins in, morphs out of a circle, or springs in while the
accents orbit into place. The glyph takes `onPrimaryContainer`, not `primary`: the `content` scheme variant can leave
`primaryContainer` as light as `primary` in dark mode.

`CaptionIcon` is the one icon that does not follow the glyph grid: the window caption buttons keep the one pixel,
pixel-aligned stroke of Windows' 10-pixel caption glyphs on every platform.

## App Bar Actions

`CommonScaffold` keeps at most three buttons in sight in its bar, the overflow menu button included. A page hands it
what may fold as data: `primaryAction`, `iconActions`, `menuItems`, and `searchActions` while searching; custom widgets
passed through `actions` never fold. Past three, two buttons stay beside the overflow menu: the search button (the clear
button while searching) when there is one, then foldable actions, primary action first unless `foldPrimaryAction` puts
the icon actions ahead of it;
everything else goes into one overflow menu, primary action first, and a folded action that is loading shows as a
disabled item. The bar reads as one button group of two beside a single button: the overflow menu button when
something folds, otherwise the last action, so the proxies list shows a search and delay test group beside the menu.
The bar holds `primaryAction` everywhere, a phone's home page above the fixed navigation bar included, and nothing in
the app floats an action button: a secondary action such as selecting every app goes into `menuItems`. Saving or
confirming, in a page, a side sheet or a form, is a check in `confirmationAction`, never among `iconActions`: it ends
the bar and never folds, and only a form sheet moves it to its foot (Forms). Bar buttons are glyphs with tooltips,
select all included; the one text button is the custom profile's Import, a filled button whose `CommonPopupBox` opens
the import menu. Actions on a multi-selection, such as delete and select all, go into
`selectionActions` instead: the bar keeps them in sight as one button group that takes a single slot beside the search
or clear button, so they never fold. A sheet's close button leads its bar when the bar has actions, except beside a
primary action: then the two end the bar as one button group, as the proxies sheet's delay test and close do.

Actions on what the page edits as a whole, such as renaming the custom profile or viewing its final config, go into
`titleMenuItems` rather than the bar: the title shows a chevron and opens them, as an iOS document's title menu does.
The menu opens from the title's start edge (`PopupPlacement.overAnchorStart`), since the bar's own menus, which open
from their end edge, would cover the back button there.

A bar under a sheet drops its actions and keeps its title and back or close button. `CommonScaffold` fades the actions
out with the entrance of a sheet laid over its page, or over the sheet it is a page of, so none on the layer below
reads as an action of the sheet on top; `sheetCoverOf` in `lib/ui/sheet_navigator.dart` reads that entrance, which a sheet route hands
down through `SheetCoverRouteMixin`, as `SnapSheetRoute` and `ModalSideSheetRoute` do.

## Liquid Glass

`ThemeProps.liquidGlass` picks a `LiquidGlassMode`, `none` by default, and reaches widgets as `LiquidGlassScope`, on for
`standard` and `ultra` with that `LiquidGlassQuality`, from `ThemeManager`. With it on, `CommonScaffold` passes `glass`
to the bar's `TonalButtonTheme`,
which puts a `LiquidGlass` pane behind each button through `ButtonStyle.backgroundBuilder` and one behind a
`TonalButtonGroup`; the navigation dock's bar and lifted lens become panes as well, and so do a sheet's docked search,
the cards of a `CommonPopupMenu`, and a `CommonDialog`. On the dashboard only the start button is a pane: its connected
buttons and switches keep their fills, since each pane adds its area to a capture retaken whenever the dashboard
redraws, which it does often. Each still swells on its own under `ElasticPress`, and a `DashboardConnectedGroup` paints
the button pressed last over the neighbours it swells past. `lib/ui/liquid_glass.dart` holds the rest:

- A `LiquidGlassHost` over the app (`lib/ui/liquid_glass_capture.dart`, after g1455's atlas proxy) draws its panes
  without reading the backdrop. As the frame is composited, before its children, it redraws onto one small image what
  each pane under it would read: the layers painted before the pane, within its reach, shrunk as far as a sigma of the
  pane's frost still spans two of the image's pixels, twice where g1455 records its regular finish, and never past
  eight screen pixels to one, the coarsest g1455 measured, with that frost blurred in by the engine. A pane without frost, the dock's lens, keeps the screen's resolution, as g1455 keeps its clear finish.
  A pane with a `haze` takes a second slot in the same image, shrunk and blurred for its far wider `hazeBlur`, and
  mixes the two.
  Each pane paints the shader over its part of that image as an ordinary paint, one read a sample where its frost is
  even. No pane ends the frame's render pass or copies the surface, and the glass never trails the content by a frame.
  A pane outside any host draws only its tint and rim.
- `ultra` draws all of the glass below. `standard` leaves out what costs most for least: a haze becomes the whole
  frost, so the dock takes one shrunken slot in place of a sharp one at the screen's resolution, and its text no
  longer shows faintly through; a lens's rim parts no colors; the lifted lens's copy goes unwarped, tinted with the
  light its pane would add; and the dock casts no shadow, which is under 3/255. The host applies the style changes to
  every pane it draws, the dock the rest. A config saved with `standard` before `ultra` existed moves to `ultra` once
  (`Migration.upgradeVersion` 2), since that was its look. On the SwiftShader emulator, as raster time a frame over
  glass off, median of four alternating runs, the glass before the tiers, `ultra` and `standard` added 16.4, 13.5 and
  9.5 ms scrolling, 52, 40 and 17 dragging the lens, 34, 26 and 18 scrolling under an open menu, 22, 13 and 11
  opening it and 17, 9 and 5 closing it; scrolling took 18.8 render passes a frame in either tier against 23.6, and
  the lens 22 in `ultra` and 18 in `standard` against 30.
- A pane over one painted before it in the same root reads a second image, a level up, with the first drawn in as
  glass. Over means within 2.5 sigmas of its frost and as far as it bends, where a pane takes under 1% of what it
  reads, rather than the 3 sigmas and 2 dp its slot holds: the bar's buttons stand 8 dp apart, inside the slot of the
  overflow button, which went up a level and cost a second image every frame content moved under the bar. A pane's
  root is the host or its nearest ancestor that draws offscreen: as a backdrop filter would there, it
  sees only that ancestor's content, without the ancestor's own effect, and replaces what it covers. A
  `LiquidGlassFade` is no root: as Core Animation fades a layer, its panes still read what lies behind it and fade with
  the rest. A level keeps its image while what it drew, the same pictures under the same transforms, clips and
  effects, stays the same, so a still screen redraws its glass without a capture and content scrolling under glass
  captures once a frame. Within an image each band of slots that blur alike keeps its pixels the same way, copied
  from the last image rather than drawn and blurred again, and a slot without frost is a band of its own: dragging
  the lens redraws only its copy's slot, not the dock's haze or the buttons' frost. Not on Skia: an image there keeps
  what it was drawn from as long as it lives, so each capture copied from the last would hold every one before it,
  and memory grows by a capture a frame. The dark line along the rim darkens the blurred capture there rather than the
  sharp backdrop, a pixel or two wide.
- Measured on an Android emulator rendering in software (SwiftShader, 1080×2400 at density 420), as raster-thread time a
  frame counting the captures that FrameTiming's raster span leaves out, median of three runs, each capture against
  none in a run of its own: scrolling Tools takes 43 ms with none, 6 more with a sigma over one pixel of the capture and
  11 over three; scrolling the dashboard 64, 9 and 19; switching to Proxies 34, 15 and 25; opening a menu 42, 9 and 13;
  closing it 41, 1 and 3; dragging the dock's lens 39, 38 and 42. One pixel adds about half what three do while
  content scrolls, and about as much while a page switches, where the capture's size is not what costs, or while the
  lens moves, which both capture at full resolution. Three was measured before a menu's capture was held to eight
  screen pixels to one, and two, which glass uses, has not been timed. Ultra, which read the backdrop under each pane,
  added 27 to 61 ms to the same frames and was dropped. A software renderer weighs passes and texture reads unlike a
  phone's GPU, so the figures rank the captures rather than price them; no phone has measured them. A still screen
  draws no frames.
- Rendered under `flutter test --enable-impeller` at density 3, against a capture with a sigma over three pixels, one
  pixel blurs text under the dark dock into blocks that set 16% of its pixels apart side by side (CIEDE2000 above 2),
  and two sets 0.5% apart. Reading a coarse capture through a bicubic filter barely helps: the blocks are in the
  capture.
- Where a pane's frost is uneven, as along a rim that softens, the shader reads what the capture does not hold as the
  engine's Gaussian, in device pixels, on a Vogel disc of 16 taps up to a sigma of 2 pixels, 32 up to 3.5 and 64
  past it, so no taps lie further apart than 64 leave them at the widest; rendered at density 2.625 the lens moves by
  at most 12/255 on a few pixels from 64 taps throughout.
- Glass builds no pipelines ahead of use. A warm-up that rendered panes offscreen once the first frame landed was
  dropped: after an install, with no pipeline cache on disk, it compiled on the raster thread just as the app was first
  used, to spare the first menu and lens only a few pipelines.
- A pane is a rounded rectangle, each corner with its own radius, unless a `clipper` gives it a path, as the start
  button's cookie does. The shader reads that path as its reach from the pane's center in 64 directions, so it must
  meet every ray from the center once.
- Without Impeller's shader filters (Skia on the Intel macOS build, `flutter test`) a pane frosts from its capture:
  blur, saturation, brightness, tint, and a rim, with no refraction; the tint is not thickened there, as it is where a
  pane has no capture, since the capture holds the blur. `flutter test --enable-impeller` runs the shader, so `toImage`
  shows the real glass.
- A popup grows out of its anchor on a platter (`CommonPopupRoute`). On glass the platter is a `LiquidGlassPane`
  easing from the button's `regular` glass to the thicker `menu` glass, and the menu's cards stand `bare` while it
  shows, opening and returning, so one pane bends the backdrop at a time. The platter takes the `menu` glass's frost
  from the start and, as the cards do, paints with a `hold` over all it may sweep: the host captures that once and
  keeps it while the pane moves inside, its frost neither grows nor falls by a tenth, as a folding sub menu's glass
  does, and the page holds still, so a menu opening captures three times and closing twice rather than every frame.
  On the SwiftShader emulator that cut a menu's frames from 17 render passes to 12.4, against 11.1 without glass, but
  saved time only within noise: what glass still adds there, about half again a frame, is the shader over the
  growing platter. A held pane casts its shadow after itself, over its capture rather than in it, since a shadow moving with it would
  renew the capture. The anchor's snapshot is taken under `LiquidGlass.withoutPanes`: offscreen a pane has no
  backdrop and would come out a flat tint. A menu opened at a point fades out under the layer a `LiquidGlassFade`
  pushes, so its glass keeps reading the page as it goes.
- An alert on glass takes the `alert` glass, the `menu` glass frosted wider, under its `AlertDialog`'s surface, which
  it finds as the dialog's `Material` lays it out, since a dialog takes only a color. Its route fades it under a
  `LiquidGlassFade`, so the glass keeps its full blur and fades with the text, as UIKit fades an alert and its glass on
  one layer. Its plain buttons and fields fill with `glassFillOf`, black or in dark mode white at 13%: iOS 27 shifts
  them from the glass under them by about 30/255, darker or lighter, a blend Flutter has no mode for, which 13% meets
  over the glass an alert shows on a page. Its route dims by `alertScrim`, iOS's fifth in light mode and near half in
  dark mode, not Material's third, so the glass reads the backdrop iOS's reads; under Material's a light alert came
  out grey. Measured against UIKit over the same page, the title sits 21 dp down, a message 6 dp under it and a field
  16, the buttons 20 under either; plain button labels take the medium weight, and a light message takes
  `onSurfaceVariant` at 85%, as light as iOS's vibrant secondary label. UIKit sets a title with no message centred in
  the body weight, so an alert with fields (`hasFields`) does too, with room for a trailing control's width kept on
  both sides to hold the title on the alert's centre. A destructive action takes `ColorScheme.destructive`, iOS's
  systemRed: Material's `error` read dull in light mode and pink at tone 80 on dark glass.
- A press anywhere on an alert swells the whole alert, glass and content, as UIKit swells it, measured at 4 pt on its
  320 width, and a drag past its edges stretches it about 3 pt; the button under the finger does not swell, it fades
  its fill to 40%, or a dark default button's to 50%, while a dark plain button keeps its fill. `ElasticPress` takes
  the swell and the pull in dp and finds the surface through `panelOf`, since an `AlertDialog` spans the screen
  around it.
- The `menu` and `alert` glass follow iOS 27's menus and alerts as the simulator showed them over solid, striped and
  split grounds, keeping the scheme's tint: in light mode the glass passes the backdrop at 45%, doubled in saturation
  and a tenth brighter, within 2/255 of iOS; in dark mode iOS keeps each colour's hue and chroma while it compresses
  white to mid grey and lifts black to 32/255, which the shader matches over solid grounds, within 4/255 and 11 at
  worst, by thickening the scheme's highest container over a light backdrop. The dark fit weighs black and dark grey
  most, the grounds a dark page puts behind it. That `contrast` reads the whole pane's backdrop, not each pixel, so
  over half black, half white the white half shows lighter than iOS's. It reads five points, each as four taps a frost
  sigma apart so that a glyph passing under one does not flicker the tint, but once under a haze or a frost of 8 dp
  or more, which blur a glyph past flickering. iOS frosts an alert at a sigma of about 13 dp
  and a menu at 10 to 13, with no sharp share like the dock's.
- The `menu` glass leaves its rim to a `LiquidGlassRim`, which alerts, menu cards and the platter as it lands draw
  around their panes: the line on the canvas outside the pane, and the highlight in the pane's shader, band by band
  and turn by turn as the fallback draws it in nine even-odd rings, within 12/255 of those. It is shaded unlike the
  bars' rim: as iOS 27 draws it around both, measured in the simulator, the dark
  line lies just outside the glass, darkest along the sides, and the highlight is light added to the glass, brightest
  at the middle of the top and bottom, about half as bright where a corner begins, a fifth where it ends and gone
  down the sides, fading over about 5 dp inward; a menu's line is lighter than an alert's. A glass menu and a glass alert cast iOS 27's shadow as
  measured over white, a deep one under a wide one, half again as dark in dark mode, where a solid menu keeps its
  softer one.
- The optics bend with a circular bevel whose width and depth shrink to fit a small pane, so the rim shows the content
  squeezed and mirrored. The materials are iOS 27's as codenameone/CodenameOne#5906 fitted them (`pill` for the dock,
  `regular` for buttons): the backdrop passes through as `offset + scale * saturated backdrop`, the tint at
  `1 - scale` carrying the offset; a dark line takes the outermost pixels because UIKit draws it just outside the
  bounds, on the dock as faint all around as iOS draws it along the top and bottom, since the darker sides iOS draws
  read as brackets on a pale page; a highlight lights the top and bottom, fading over 1.3 dp and, as iOS 27's tab bar
  fades it around its rounded ends, with the square of the normal's upward part; the lifted lens keeps a narrower band.
  Buttons (`regular`, `tinted`) take the rim of iOS 27's glass and bar buttons, measured in the simulator: the line
  darkens toward the sides with the cube of the normal's sideways part, from nothing along a dark button's top and
  bottom, and the highlight fades over 1.2 dp with a sixth of it in a tail to 4.5 dp, dims round the ends far faster
  than the tab bar's, and is partly added as light, so it lifts a pale button as iOS does.
  The line and the highlight keep to the superellipse the pane is clipped to, which the shader traces after the
  engine's `round_superellipse_param.cc`: the circles the optics bend by lie up to half a dp outside it where a long
  side runs into its end, and a line on them breaks there. A test holds the traced curve to the engine's path.
  In dark mode the tint is
  the scheme's `surfaceContainerHighest` at iOS's alpha: iOS's mid grey lifts a dark page into a grey haze. The tint
  thickens over content much darker than it, or with a negative `contrast` much lighter.
- The `pill`'s frost, line and shadow follow iOS 27's tab bar at rest, measured in the simulator over solid fills and a
  black and white split: 28% of the backdrop shows sharp and 72% through a blur of 15.6 dp, so a stripe under the bar
  spreads over its neighbours; iOS mixes the two brighter toward white, as if it blurred in linear light, which the
  engine's blur cannot. Dark mode draws no line, as iOS draws none along a dark bar's top and bottom. Glass bars cast
  1.3% black blurred 3.8 dp and dropped 6.5 dp, shading only below and by 3/255 at most, in both modes; the solid
  dock keeps its wider shadow. The sharp part needs no blur pass of its own, so on the SwiftShader emulator the haze
  added half a render pass a frame scrolling Tools, about four on the dashboard, where it no longer shares the start
  button's blur, and no time beyond the noise of three alternating runs. Its colors are deliberately not iOS's: iOS's
  bar takes no `contrast`, its selection platter is a color matrix of the bar and its icons are vibrant, where the
  dock keeps the theme's.
- The dock and its lens follow UIKit's tab bar as codenameone/CodenameOne#5906 measured it frame by frame: 86 dp a
  destination, a resting lens 8 dp wider, a lift of 16 dp that magnifies what lies inside the lens by 16%, and springs
  taken from the capture; the lens's stretch and squash are a fit to its deformation tables. The lift stays up until it
  has risen fully and the lens has arrived, so a tap pops it all the way, and `ElasticPress` likewise finishes a tap's
  swell on the bar's press spring before it bounces back. The destinations stand on the lifted lens, as iOS draws
  them, so it bends only the bar; what lies inside it is copied, tinted and magnified, into an offscreen layer where
  a second clear pane warps it toward the rim on its own, as liquid_prism read UIKit's displacement inputs on iOS 27.
  The lens follows what iOS 27 shows of it over ramp and line backdrops in the simulator: it reads outward along its
  normal all around, by nothing at the rim and 4.3 dp a 5.5 dp bevel in, easing off toward its middle, so a band
  rings it with what lies right under its rim, drawn out; red and blue part by up to 6.5 dp along its top and bottom
  and about 3.9 dp around its ends, across the band's outer 7 dp. In dark mode both panes brighten what they show by
  a third, as iOS does, and the lens casts a soft shadow 8 dp down. A press lights the bar through `LiquidGlass.glow`:
  a wash over the whole pane, brightest at the finger, that spreads out as it fades. A `pressed` pane, as a glass
  button's or a `TonalButtonGroup`'s is, hears the pointer on what it wraps and lights from the finger the same way.

## Popup Motion

`CommonPopupRoute` follows WWDC25's account of iOS 26 menus: one that grows out of a control keeps the two continuous,
so closing returns it into the control on the same platter, its content blurring out first. Apple documents only the
opening; one opened at a point (a context menu) has no control to return into and shrinks toward the point to
`_dismissScale` as it fades, as iOS context menus do.

A sub menu is a `PopupMenuCard` laid out once at full size. One spring (`_unfold` in `lib/ui/popup.dart`) moves
its surface and clip from the item that opened it to its bounds, recedes the parent, and reveals the items, so a fold
caught mid-unfold turns back with the speed it had. The parent's item hides under the sub menu's header, which draws
it again, and the sub menu is removed only once it stands on that item.

A `CommonPopupBox` opens on its button's pointer down, as an iOS menu that is a button's primary action does, and the
press carries on into the menu. `_PopupPressRecognizer` claims the pointer then, so the button's own tap and its
tooltip's long press stand down. In a scroll view, as the settings rows are, it first waits `kPressTimeout`, as iOS
scroll views hold back a touch, so a drag from the button scrolls and a quicker tap opens the popup on its release. The
pointer's moves and release keep reaching the button, so the box hands them on (`_CarriedPress`) and lets go of the
`ElasticPress` around it. The menu follows them only once they leave the slop, since it covers the button and a press
let go where it went down would pick what now lies under it, and drives its own `ElasticPress` with them through
`ElasticPress.maybeOf`. The box tells a disabled button by the `onTap` of its first `InkResponse`, and holds the popup's
`anchorShift`, since it opens before the button's `onPressed` would run.

The menu stands in an `ElasticPress` of its own with `pullPastEdges`: it swells under a press and stretches only toward
a finger that strays past it, so sliding over the items or scrolling leaves it in place. A press on a row belongs to the
menu rather than the row's `InkWell`, which keeps only hover, focus, and keys: `_RowPressRecognizer` highlights the row
under the finger as it slides, hit testing where the menu paints (`ElasticPress.paintBoundsOf`), with a selection click
on each change, and picks the one it is let go on, or none off the rows. It claims the pointer only on release, so a
menu long enough to scroll takes a drag first and drops the press. A press that rests for `_dwellDuration` on an item
with a sub menu opens it, and one that rests on an open sub menu's header folds it back, each with a click as the
highlight moves; the finger then stands on the header or on the item it folded into, and letting go there changes
nothing. A tap that opens or folds a sub menu clicks no more than a tap on any item does, as iOS menus give selection
feedback only to a sliding press.

## Row Actions And Sort Mode

A list row or card carries no trailing more button. Its secondary actions go into a `ContextMenuRegion`, which opens
them on a right click, a touch long press, the menu key or Shift+F10 of a focused row, and, under an enabled
`RemoteFocusAdapter` (Android TV), a select key held past the long-press timeout; a short select there still presses
the row, on key up rather than key down. A tap keeps the row's main action. A row whose tap does something other than
open its page, as a profile card's tap selects the profile, may carry a trailing button to that page, as iOS's detail
button does, built as a `DetailButton` so a desktop's compact density cannot pull it off the column the indicator and
the handle share; a trailing button that repeats the row's own tap is never added. A row whose tap opens a page shows
a `DisclosureIndicator` there instead, as a script or a rule-set proxy provider does. A provider opens its content on
a tap, read-only unless it is a local text file the app owns, and keeps a second action on its trailing button: editing
for a proxy provider backed by a text file, the options dialog for an app rule provider.

A long press can mean only one thing on a row. Where rows have no context menu, as in a plain list editor, the global or
profile rules, the on-demand SSIDs or the custom proxies, a long press on the row drags it and there is no sort button.
Where they have one, the list reorders only in a sort mode. When the list is the page, `CommonScaffold` owns the mode as
it owns search and selection, and the page passes `canSort` for the toggle in its bar. Changes apply as they are made,
so nothing confirms them: while the mode is on, the bar shows only its toggle, selected, and the back or close button
fades in place rather than offer the same way out twice, as iOS hides its back button while editing; a system back still
ends the mode. A list that is one section of its page, as the custom profile's proxy groups are, keeps its own
`SortModeScope` around its rows and its toggle in its header and leaves the page bar alone, back button included; its
header keeps adding while it sorts, and a system back ends its mode before it leaves the page. Each row sits in a
`SortableItem`, which reads the scope: while it sorts `DecorationListItem` drops its tap and context menu, and
`SortableTrailing` springs a `SortHandle` in from the row's trailing edge while the trailing it replaces shrinks away.
The motion is painted, not built, and the row relayouts only while the two widths differ, since every row on screen
animates at once. A page that only reorders, such as the profiles sort sheet or a group's members, shows its
`SortHandle`s without a mode. A handle drags on press, and with focus a select key lifts its row for the up and down
keys to move through the enclosing `SliverReorderableList`'s own `onReorderItem`, which is how a remote sorts.

## Quick Edit

Quick edit, the compose button that opens what a page edits as text in an `EditorPage`, appears only where that text is
the whole of it: a full list or section, such as a custom profile's rules, its proxies as share links, or its DNS, NTP
and sniffer sections, or one isolated item, such as the definition of the proxy group or proxy a form edits. A page
that edits only part of something other settings also write offers none, since its document would show a fragment and
reject what it leaves out. The app-wide DNS page is that case, a few keys laid over the DNS of every URL and file
profile, so only the profile's DNS spec mixes in `OverrideQuickEdit`. So is the custom profile's TUN page: it picks a
few keys of a `tun` section the network settings own, so its spec does not mix in `OverrideQuickEdit`.

## Where A Route Opens

On desktop each navigation destination has its own `Navigator` (`_NavigationPage` in `lib/pages/home.dart`); on mobile
there is none, and everything goes on the root navigator, `rootNavigatorKey` in `lib/ui/navigator.dart`. A route
takes the navigator of the context it opens from: `BaseNavigator.push`, `showExtend`, `showSheet`, `showFormSheet` and
`showSnapSheet` all do, so a page or sheet opened from a destination stays beside the navigation rail, leaves the rail usable, and
stays in that destination's stack when the user switches away and back. `sheetNavigatorOf` lifts a sheet out of a
paged sheet's own `SheetPagesNavigator`, never past the destination.

The root navigator is only for what belongs to no single destination:

- dialogs, which `dialogs` in `lib/common/dialog.dart` hosts on the root unless it is given a context, and the notifier;
- a gate in front of the whole app, such as `requestDisclaimerConsent`;
- work that starts with no page behind it: a deep link, the tray, a hotkey, the update check.

Never reach for the root to open a page or sheet from a page, whether through `rootNavigatorKey`,
`globalState.navigatorKey`, `rootNavigator: true` or `useRootNavigator: true`, and never push a page from the context of
something on the root, such as a dialog: the page lands on the root too and covers the rail. The add profile sheet is
the one exception. `addProfileFormFile`, `addProfileFromLink` and `addProfilesFromLinks`, which a deep link also reaches,
close it with a root `popUntil` before switching to the profiles tab, so `showAddProfilePage` opens it on the root and
takes the caller's context as `origin`; a page the sheet leads to opens from `origin`, as `AddProfileView._toAddCustom`
does.

The mistake only shows in the desktop layout, and `TestApp` has nothing but the root navigator. A test that guards
where a route opens hosts the page in a nested `Navigator`, as the desktop case of a new custom profile in
`test/features/profile_views_test.dart` does.

## Settings Rows

`lib/widgets/config_item.dart` holds the shared settings-row vocabulary: `ConfigToggleItem`, `ConfigOptionsItem`,
`ConfigTextItem`, and `ConfigListEditItem`. Each takes a `selector` (a `ProviderListenable`, normally
`someProvider.select(...)`) and an `onChanged(ref, value)` writer, and watches its own selector so changing one setting
rebuilds one row instead of the whole section. Titles and subtitles are `ConfigLabel` callbacks that receive
`AppLocalizations`, which keeps literal labels such as `IPv6` and localized labels in the same shape.

Build settings screens from these directly, or from a file-local helper that binds one provider once — see `_networkToggle`
in `lib/views/config/network.dart` and `_appSettingToggle` in `lib/views/config/general.dart`. Declare a named
`ConsumerWidget` only when a row is genuinely reused across screens. Rows with bespoke behaviour — a custom dialog, a derived value, or a
second provider write — stay hand-written rather than growing extra parameters on the shared items.

In an inset grouped list (`generateSection`, `generateAnimatedSection`), a row's subtitle shows its value or state,
never what the setting does. As iOS settings do, the explanation goes in the group's `footer`, drawn by `ListFooter`,
one sentence per setting that names it. A section header carries its title and at most a few actions on the group, as
`IconButtonData`: `ListHeader` draws them as 36 dp tonal buttons (`TonalButtonSize.section`), the first two grouped,
centered on the title. Every header stands as tall as one with a button, 6 dp clear of the group below, so headers
match whether or not they carry actions. A group with a selection swaps them
for delete and select all, never a text button. `generateSection` is the only section builder, and a sheet lays its groups inside the 16 dp inset the pages use.

A row that opens a page, `ListItem.open` or `ListItem.next`, ends in `AppGlyphs.chevronForward` unless it passes its own
`trailing`, as iOS settings rows do. A row that opens a dialog in place, `ListItem.input`, has no chevron. A setting
that takes one of a few values is an iOS pop-up row, `ListItem.options` or `ConfigOptionsItem`: it ends in its value and
`AppGlyphs.picker`, and a tap anywhere on it opens a `CommonPopupMenu` out of that value with the current option
checked. Its items are text alone, as an iOS picker's are; glyphs belong to menus of actions. One value is never picked
from a radio dialog or a row of selectable chips; a button that picks one, as the theme's scheme variant does, opens the
same menu through a `CommonPopupBox`. A pick from a menu that returns into its control runs only once the popup has
landed, so a setting that rebuilds the app, such as the language, never does so under the returning platter; the
control shows its value with `PopupValueText`, which blurs across to the new value while the control eases to its
width. A menu opened at a point, as a context menu or the editor's is, runs its pick at once. A menu capped by
`maxVisibleItems`, such as the proxy group tabs' more menu with every group in it, builds only the rows in view and
takes its width from its labels measured as `EmojiText` lays them out.

## Forms

A form that edits more than one value opens with `showFormSheet` (`lib/ui/sheet.dart`): a bottom sheet in the mobile
layout, and elsewhere a card `FormSheetRoute` centers over the navigator, as iPad and macOS present a form sheet, moving
as an alert does. Both give the page `SheetType.bottomSheet` or `SheetType.formSheet`, compact sheets that share
`CommonScaffold`'s sheet bar, so one page serves both: `FormPage` for a plain form, or the page a `NestedPagedSheet`
pushes for the custom profile editors. Its values sit in `FormRow`s inside `generateSection` groups, each field a
`FormRowTextField`, bare and set against the end in both, so a focused field's only outline is its row's focus ring.
`RenderEditable` ends a field's text short of its end by the caret's margin, so the field ends its hint as short and
reaches as far into the row's padding: the caret follows the hint or the text, and the text ends where another row's
value does. The
save is the scaffold's `confirmationAction`: last in a bottom sheet's bar, and in a form sheet the filled default beside
Cancel, which takes the close's place, in a row of alert buttons at the first page's foot, as SwiftUI places a
confirmation action on macOS; other actions, such as quick edit, stay in the bar. A row cannot hold an error line, so a
save the form refuses marks the row `invalid` and says why in the `ErrorBanner` above the groups, which follows each
edit from then on. A prompt for one value, such as a URL import, a rename or a password, stays an alert (`CommonDialog`,
`InputDialog`), as on every Apple platform; a key with its value, as `MapEditView` adds, is two values and a form.
An alert raised while focus is in a form sheet opens on the sheet's
navigator, centered on the card rather than on the window: `Dialogs` follows the focused route when it is an
`AlertHostRoute`, which the form sheet and every alert are.

## Keyboard Insets

The soft keyboard moves `MediaQuery.viewInsets` on every frame of its animation, so whatever depends on them rebuilds
and relays out at frame rate for a few hundred milliseconds. `ThemeManager` wraps the whole app in a `LayoutBuilder`,
which runs every one of those rebuilds inside the layout phase; in a profile trace they show up there, not under
`BUILD`.

- A page the user is not typing in holds its bottom inset through `KeyboardInsetHold`
  (`lib/ui/keyboard_inset_hold.dart`). Pages under another route and inactive tabs are still laid out, offstage or
  not, and without it every page the app keeps relaid out, and rebuilt under its `LayoutBuilder`s, with each frame of a
  keyboard raised by a dialog or sheet on top. The home route, each home tab, `CommonRoute`, `CommonDesktopRoute` and
  the open-container route wrap their page in one; a new page route type does the same.
- A widget high in the tree reads the aspect it needs (`MediaQuery.paddingOf`, `viewInsetsOf`, ...), never
  `MediaQuery.of` or `MediaQuery.removePadding(context: ...)` on its own context, which subscribes it to every inset
  change. Move such a read into a small widget of its own below it, as `_AppMediaQuery` in `ThemeManager`,
  `_BodyPadding` in `lib/pages/home.dart`, `_KeyboardViewport` in `lib/ui/snap_sheet.dart` and the `SafeArea` around
  the docked search field in `CommonScaffold` do.
- A bottom sheet makes room for the keyboard itself: the keyboard raises the sheet's foot (Bottom Sheet Motion), and
  `_WithoutKeyboard` removes the bottom inset from the content's `MediaQuery`, so nothing inside a sheet,
  `CommonScaffold` included, adds keyboard space. A nested sheet must not carry the keyboard through its pages:
  `NavigatorResizable` learns a page's new size a frame late, and the sheet would trail the keyboard by a frame.
- The keyboard moves a bottom sheet as it is painted. `_RenderSheetViewport` lays the surface out as tall as the view
  whatever the keyboard, and a fit sheet keeps the limit its short content was laid out within while the keyboard
  changes the room above it, until the content reaches either (`releaseLimit`). A keyboard frame then lays out and
  paints nothing inside the sheet unless what it shows changes.
- A field without a label says `floatingLabelBehavior: FloatingLabelBehavior.never`, as `FormRowTextField` and
  `SearchField` do. `InputDecorator` animates the floating label of an empty field on focus even when there is none,
  `InputDecoration.collapsed` included, and each frame of it lays the decorator out and, inside a sheet, the whole
  form, through the first frames of the keyboard.

## Rebuild Scopes

A `LayoutBuilder` runs the rebuilds of everything under it inside its own layout, so a widget rebuilding there marks
the builder for layout, and that climbs to the nearest relayout boundary. Flutter marks every render object it lays
out for paint, so the nearest repaint boundary above that path repaints too. Under the material `Scaffold`'s body
`LayoutBuilder` (it has one with `extendBodyBehindAppBar`) that was the page and its background, and under the home
shell's `LayoutBuilder` the whole home route: a spinner turning in a page, or the dock's lens moving, relaid out and
repainted the page on every frame, and the glass over it captured every band again, the bar's included, though
nothing under the bar had changed.

So the body and the dock each take their rebuilds in a scope of their own: a `LayoutBuilder` under a repaint boundary
that is also a relayout boundary. `CommonScaffold`'s `_BodyScope` sizes itself to the most the scaffold allows, which
the scaffold never reads back, and lays the body out under it as before; `NavigationDock` sizes itself as it always
was, full width and its bar's height, and lays its boundary out tight. A rebuild inside either relays out and
repaints only that layer.

## Bottom Sheet Motion

`SnapSheetRoute` follows `UISheetPresentationController` as measured on the iOS 27 simulator (a UIKit probe app driven
by the simulator's touch injection, logging the presented view's presentation layer every frame).

- One spring moves a sheet: UIKit's mass 3, stiffness 1000, which runs critically damped (ω ≈ 18.26 rad/s, done in
  about 0.5 s). Presenting, closing, a detent change and a spring back all trace it within a point. A release thrown
  toward its target keeps its velocity and lands with UIKit's slight overshoot, about damping ratio 0.8 at full
  strength; a release away from its target loses its velocity and lands dead.
- A release lands on the detent, or the dismissal, nearest to where `UIScrollView.DecelerationRate.fast` projects it.
  With no velocity a sheet closes once it is let go past half of its shortest detent; a flick of 1000 pt/s 85 pt
  down springs back on iOS, one of 1500 pt/s closes.
- The sheet follows the finger one to one below its shortest detent and stops at its tallest, with no stretch.
- On the content, a drag up grows the sheet first and scrolls the content with what is left, in one gesture. A drag
  down moves the sheet only when it began with the content at its top; one that scrolls the content back to its top
  stops there, as iOS bounces it rather than handing it to the sheet.
- The keyboard raises the sheet's foot: a detent keeps what it shows above the keyboard, as a custom detent does on
  iOS, up to a peek below the top. iOS lifts a medium sheet to its large detent instead, which a phone's keyboard,
  about as tall as the gap between them, makes nearly the same. Since the sheet's height is a function of the inset,
  it moves with the keyboard on every frame and lands back where it was.
- Where the keyboard starts or stops carrying the sheet, that function rounds its corner (`_rounded`), so the sheet's
  speed changes smoothly. With a sharp corner a sheet stood still while the keyboard slid over the blank below short
  content and then jumped, and on the way down halted in mid-flight; the tallest detent hit the peek at the keyboard's
  full speed. Short content now eases into the rise over half its blank, which can leave the sheet up to an eighth of
  the blank higher than its content needs, and the tallest detent slows into the peek over as much keyboard again as
  it takes to get there, up to `_peakEase`.

`_SheetModel` keeps the sheet as an activity, resting at a detent, held at a height or settling toward a detent as an
offset from it, and layout resolves the detents again every frame from the view, the keyboard and the content. A
resting or settling sheet therefore follows a page transition's size or the keyboard without being told, where a
stored height would have to be patched after each change. Below the shortest detent a drag moves the route's own
animation, so the barrier, a sheet stepped back behind this one, and the page bar under it follow the finger, and the
close continues from the release on the presentation spring (`createSimulation`).

## Page Arrival

A pushed page is built, laid out and painted through every frame of its transition. Impeller has no raster cache, and
every offscreen pass is paid again each frame on a phone GPU. Even so, a page loads what it shows as it mounts: content
held back until the route settles slides in as an empty page and pops in once the motion has stopped, which reads worse
than the frames a load costs. What a transition must not carry is work that repeats on every refresh or every frame.

- Loads start as the widget mounts, never behind `whenRouteSettled`. `CommonTargetIcon` and `PackageIcon` show what is
  already in memory at once and load the rest right away; the editor reads its file and mounts CodeForge as soon as the
  content is in. An icon still loading leaves a blank slot of its size and shows its fallback only once the load ends
  without an image, so a grid of placeholders is never painted only to be replaced. `whenRouteSettled`
  (`lib/ui/navigator.dart`) is left for sequencing navigation, such as opening a page once the sheet above it is gone.
- A live feed holds its refreshes while its page moves and replays the latest once it is still, so a list does not
  re-rank, reorder or grow under a transition. `RouteMotionHoldMixin` (`lib/ui/route_motion_hold.dart`) holds them
  while `isRouteMoving`: the page's route or a sheet carrying it is pushed, popped or dragged, a page is pushed over it,
  or a sheet covers it (`sheetCoverOf`). The connections, requests, logs and DNS pages and the dashboard's live
  connections table use it. A feed's first content is no refresh and shows at once, as `ConnectionsView` applies its
  first poll, and a held poll keeps the time it was read at, which `TrackerSpeedRanker` derives speeds from. Per-frame
  work spread over frames pauses the same way: the font family page switches one name to its own family per frame and
  stops while `isRouteMoving`.
- A scroll view of image tiles takes `arrivalScrollCacheExtent(routeSettled)` from `RouteSettledMixin`: the rows past
  the viewport would otherwise be built in the same frame as the ones on screen, which for a screen of icon cards is
  most of the push. The icon grids (`IconGridScrollView`) and the access control list do this, and so does
  `ListEditorPage`, whose rows are heavy enough that only its list rebuilds as the route settles, reusing the rows
  already built.
- A page whose content waits on what it loads (lists read from the database, file sizes, the installed fonts) shows
  nothing until all of it is in, then the finished content in one step: `NullStatusSwitcher.isLoading`. A load that can
  run long also gives the switcher a `loadingStatus`, its `NullStatus` illustration with no label, which takes the
  place of a first load still running after about a route transition (400 ms); one that ends sooner goes straight to
  its content, so the illustration never flashes. The custom profile, resources and font family pages set one. Never a
  skeleton screen of placeholder rows: it has to guess how many rows are coming, fills in piece by piece, and rebuilds
  every row it stood in for. `SkeletonText` is for a single value inside a card that is already on screen, such as the
  dashboard's service status.
- `GlyphPainter` paints a translucent glyph through an offscreen layer. A placeholder repeated in every tile blends its
  color over the surface instead of carrying an alpha.
- `PagedSheetRoute` and `CommonRoute` share
  `SharedXPageTransition` (`lib/ui/page_transition.dart`) and its `pageSlide`, a quarter of the page's width as
  Android 14 slides pages, so a page moves alike in a sheet and on its own. The transition fades a page by painting the surface over it
  and needs no opacity layer: the page on top shows only on its side of the point where the two fades cross, opaque
  over the other, so neither shows through the other. A page below that does not fade with it, such as the home
  route under a `CommonRoute`, is faded by the page on top painting the surface over it. `CommonDesktopRoute` fades in
  place through a plain 200 ms `FadeTransition`.

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
  - `state/custom.dart`: custom profile validity and the staged group/rule notifiers.
- `action.dart`: business logic notifiers, setup, backup, core lifecycle, proxy selection.
- `core.dart`: `coreHandlerProvider`, the container-scoped handle on `CoreController`.
- `route_state.dart` and `routed_probe.dart`: the route tracker and the probe cache; see Route Consistency above.
- `outbound_ip.dart` and `service_status.dart`: the dashboard probes built on them.
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

`lib/models/profile.dart` does not reach Core. `Profile.saveFile` and
`Profile.update` take a `ValidateConfig` callback, and every caller passes
`(path) => _core.validateConfig(path)`, keeping the Core handle lazy so a profile
path that never validates never resolves the controller.

The UI layer must not reach a process-wide singleton directly.
`test/lint/ui_layer_singleton_test.dart` scans `lib/ui`, `lib/views`, `lib/widgets`,
`lib/pages` and `lib/features` for `globalState.container` and the bare
`coreController` global and fails the run on either. Widgets that need Core hold
`CoreController get _core => ref.read(coreHandlerProvider)`.

`globalState.measure` and `globalState.theme` stay global on purpose. Both are
context-derived caches assigned by `ThemeManager`, and tests already scope them by
assigning in the app builder (see `wrapAppScopes` in `test/helpers/test_app.dart`);
moving them into providers would touch every layout call site without changing
behaviour. `lib/ui` cannot read `globalState`, so it takes the same `Measure` from
`MeasureScope`; see UI Layer.

`globalState` in `lib/state.dart` is a singleton holding ambient app state — the
package info, the measure and theme, the container, and the start/stop flags —
plus `safeRun`/`loadingRun`. Startup orchestration is **not** on it: `init` and
`attach` live in `lib/bootstrap.dart`, above `lib/common`, because they drive the
window, the autostart entry, the tray and the permission prompts. Providers are
generated into `lib/providers/generated/`.

The root navigator key lives in `lib/ui/navigator.dart` as `rootNavigatorKey`;
`globalState.navigatorKey` is a getter onto it. `lib/common/dialog.dart` reaches
the key directly and does not import `lib/state.dart`.

### Platform Layering

`lib/common/common.dart` deliberately does not export `tray.dart`, `window.dart`,
`launch.dart`, or `system_dns.dart`. Those four modules import
`tray`, `window`, `launch_at_startup`, and `screen_retriever`;
exporting them would put those packages in the compile graph of every file that
imports the barrel for a string helper. Import the specific module instead.

`test/lint/platform_layering_test.dart` enforces four rules. Three are local: the
barrel never re-exports one of those four modules, nothing under `lib/common`,
`lib/enum` or `lib/models` other than those four imports a desktop platform
package, and `lib/common` never imports the `lib/manager/manager.dart` barrel
(import the single manager needed, as `common/context.dart` does with
`manager/status_manager.dart`). The fourth walks the barrel's whole transitive
closure and fails if *any* file in it imports one of those packages. That one is
the real invariant — the local rules only stop the shortest path, and every leak
found so far arrived through a longer one.

The shapes that keep the closure small:

- `System.back` and `System.exit` do not touch `window`; the window half of
  both lives in `SystemAction`.
- `KeyboardModifier.toHotKeyModifier()` lives in
  `lib/manager/hotkey_manager.dart`, its only consumer, not in `lib/enum/enum.dart`.
- Startup orchestration lives in `lib/bootstrap.dart`, not on `GlobalState`.
  `common/print.dart` and `common/request.dart` import `state.dart` for
  `container` and `packageInfo`/`ua`, so anything
  `GlobalState` reaches lands in the barrel's closure; the ambient state it
  holds reaches nothing platform-specific.
- `SystemAction` talks to `WindowPort` and `TrayPort` from
  `lib/common/app_ports.dart` instead of importing `common/window.dart` and
  `common/tray.dart`. `lib/bootstrap.dart` binds `windowPort` and `trayPort` to
  the real implementations; both stay null in tests, where every call through
  them is a no-op. A test that needs the real tray assigns `trayPort` itself, as
  `test/common/tray_menu_test.dart` does.
- `lib/providers/providers.dart` re-exports `action.dart`, so `lib/common` and
  `providers/app.dart` import `providers/state.dart` and `providers/config.dart`
  directly; the barrel would reach the whole action layer.
- A data type in a lower layer never holds the widget that renders it, because
  that drags the whole view tree into the barrel's closure. The route table is
  `lib/views/navigation.dart` implementing `NavigationPort`, which
  `providers/state/navigation.dart` reads through and `bootstrap.init` binds;
  unbound it yields no items, so a test that renders navigation assigns
  `navigationPort` itself, as `test/pages/home_test.dart` does. `DashboardWidget`
  is plain data, since it is persisted in the app settings; the card mapping
  lives in `lib/views/dashboard/widget_registry.dart`.

`test/lint/platform_layering_test.dart` also pins that the barrel's closure
contains no `lib/views` file. Data the provider layer needs from the UI layer
goes through a port in `lib/common/app_ports.dart` rather than an import in the
other direction.

### High-Frequency Buffers

`logsProvider`, `requestsProvider`, `dnsQueriesProvider` and `trafficsProvider` hold a `FixedList`
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

### Background Work

A proxy client runs for days with nobody looking at it, so work that only feeds the UI stops when the UI cannot be
seen. There are three levels of gating:

- `appVisibleProvider` is false while the desktop window is hidden or the Android activity is in the background
  (`hidden`, `paused`, `detached`). `AppStateManager` writes it. The one-second run-time and traffic ticker in
  `SetupAction` follows it. The macOS menu bar title is the exception: it shows the traffic while the window is
  hidden. `RouteTracker` and `RoutedProbe` follow it too, as described under Route Consistency.
- `ActivePollingMixin` is stricter for per-widget polls such as connections and memory. It polls only while the app is
  `resumed`, its home page is the current one, and no opaque route covers its page: the overlay turns tickers off on a
  covered page once the route over it has finished moving in, and the mixin follows `TickerMode`.
- `_NavigationPage` puts every page except the current one under a disabled `TickerMode`. Home pages are kept alive in
  the `PageView`, and Flutter does not mute tickers on a kept-alive page off screen. A spinner left on one would
  otherwise keep scheduling frames.

A provider's own `ref.listen` delivers nothing while no one listens to that provider. That is the usual state of an
action notifier, which is only ever read. A derived provider it listens to is never recomputed, and even a `ref.read`
of it returns a stale value. So an action that has to follow a signal listens to the keep-alive provider that holds
it, as `SetupAction` does with `appVisibleProvider`, not to a provider derived from that.

On Android the Core does not react to the screen or to Doze. Doze's firewall keeps apps without an exemption off the
network before their traffic reaches the TUN, so what still arrives is traffic Doze allows, FCM among it; suspending the
tunnel rejects exactly that and stalls push reconnects until their backoff runs out. The VPN service keeps its own
network as a foreground service (`dumpsys netpolicy` shows its `DOZE` block allowed by `FOREGROUND`), so health checks
keep producing real results: holding them blocks the re-check mihomo runs after repeated dial failures, which is how a
`url-test` group leaves a dead node, and hiding their failures hides the truth. Nothing re-probes on resume either:
every proxy group is a provider, `select` groups included, and checking one tests every node in it. Should a ROM be
shown to cut the VPN's own network while the screen is off, holding back failures measured then needs only a screen
on/off signal.

## Database

The app uses Drift/SQLite in `lib/database/`. `schemaVersion` in `lib/database/database.dart` is the migration
counter; a schema change bumps it and goes into the one step the coming release takes, as the Migrations section of
`.agents/rules.md` describes.

Tables:

- `Profiles`
- `Scripts`
- `Rules`
- `DisabledRules` (`disabled_rules`)
- `ProxyGroups` (`proxy_groups`)
- `CustomProxies` (`custom_proxies`)
- `ProxyDialers` (`proxy_dialers`)
- `IconRecords` (`icon_records`)
- `IconSets` (`icon_sets`)
- `ClashProviders` (`clash_providers`)

`Profiles.type` is `file`, `url` or `custom`, fixed when the profile is created. A rule belongs to whoever its
`profile_id` names: no profile makes it global, a file or url profile's rules are what its standard extension adds, and
a custom profile's rules are all the rules it has. `DisabledRules` lets a profile leave out a global rule. Proxy groups
and dialers exist only on custom profiles. Every one of these rows cascades with its profile. Rule and proxy-group
ordering use fractional indexing.

A custom profile has no file and no extension: `SetupAction.getProfile` builds its config from an empty map plus its
groups and rules, and `clashConfigProvider` answers an empty `ClashConfig` for it. Its groups name app-level custom
proxies directly, and the config declares only the ones some group names; they take nodes from every file or url
profile too, each a file proxy provider under its label. A custom profile is never a provider itself. App-level
`ClashProviders` rows are rule providers only, and only custom profiles are offered them.

A custom profile names groups, local proxies, provider profiles and rule sets by name, mihomo's own strings included
(a DNS server's `#proxy`, a `rule-set:` policy key, the sniffer's lists). `lib/models/references.dart` reads and
renames every such place, and renames, delete prompts, provider injection and the profile checks all go through it;
`test/models/references_test.dart` fails when `config.go` reads a name somewhere it does not. A rename is detected
where the row is written, so every path carries it. A local proxy may not share a name with any custom profile's
group, as both live in mihomo's one namespace; where older data has both, the name means the group in that profile
and a proxy rename leaves it alone. `Profiles` writes rows one at a time from the state as it then stands, so a rename
rewriting custom profiles is never written over by a put issued before it landed.

An app-level rule set's behavior and format are what the Core's `compileRuleSet` found in its source, never a user
choice. The source stays at `getProviderCachePath(fileName)`; a domain or ipcidr set also gets an `.mrs` beside it, and
that is what the config loads, while classical rules have no mrs form and load from the source. The Core downloads a
remote set too and mihomo sees it as a `file` provider, so a sync goes through `ClashProvidersAction`, not mihomo's
HTTP vehicle. `ClashProvidersAction.prepare` rebuilds a missing cache while the config is built, since backups carry
only local sources and sets saved before compiling existed have no `.mrs`.

`IconSets` and `IconRecords` only feed the proxy-group icon picker. A set is an icon gallery in the format Quantumult X
and Loon subscribe to, kept whole as one JSON column; a record is an icon the user saved on a group, written on save and
never by merely displaying it. A group stores the icon string itself, a URL or a data URI, never a reference to a set,
so renaming, syncing or deleting a set leaves every group as it was.

Generated Drift output lives in `lib/database/generated/database.g.dart`. After schema changes, run code generation and add or update focused database tests under `test/database/` when converter or migration behavior changes.

### Unreadable Stored Data

Preferences, database rows and backups can hold values this build cannot read: an enum a newer build wrote before a
downgrade, a fork sharing the data directory, a hand edit. Reading them gives up the smallest unit it can and never
fails startup or a whole restore.

- `Config.fromJson` and every `safeFromJson` decoder go through `decodeSalvaging`, which keeps each value the strict
  decoder accepts, descending into maps and lists, and leaves the rest at their defaults; a list or section none of
  whose entries can be read falls back to its default rather than to empty. Only the migration uses
  `Config.strictFromJson`, since it tells legacy data apart by the failure. A field's own `fromJson` throws on what it
  cannot read instead of restoring a default for the whole field, so the salvage around it drops just that entry.
- DAO entity queries read through `TableInfo.readable`, which skips a row it cannot map and leaves it in the table. A
  profile's JSON columns that hold selection state, subscription info or overrides fall back to empty instead, so the
  profile stays listed.
- Rules, disabled rules and proxy groups are the exception and read strictly, in the app and from a backup alike:
  skipping one would quietly change how traffic is routed, so a damaged row fails loudly instead.
- Code that deletes files or rows by comparing against what a query listed must use raw ids (`ProfilesDao.ids`,
  `ScriptsDao.ids`, `ClashProvidersDao.fileNames`), or it deletes what a skipped row owns. Startup reorders profiles
  with `Profiles.reorder`, which writes rows but never deletes them.

## Manager Stack

Managers are nested `InheritedWidget`/`StatefulWidget` components built by `buildManagerStack()` in `lib/application.dart`:

```text
AppEnvManager > LocaleManager > StatusManager > ThemeManager
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

`lib/core/controller.dart` (`CoreController`) is a singleton facade over `CoreHandlerInterface`. Public methods delegate to the platform-specific interface, either the Android service channel (`CoreLib`) or the desktop socket. It has an `@visibleForTesting` constructor and `resetInstance()` for test injection.

`lib/providers/action.dart` is the public library entry point for action
providers. The Riverpod notifier implementations are split by responsibility
under `lib/providers/actions/` and joined to the entry point with `part`
directives, so consumers continue to import the same public API:

- `CommonAction`: update check and common UI operations.
- `SetupAction`: config setup and TUN management.
- `BackupAction`: backup/restore orchestration over a per-run temp work directory; the view supplies where an archive
  goes (local save, WebDAV upload) or comes from. The archive format lives in `lib/common/backup.dart`, which stages a
  restore without touching the data directory; files, database rows and settings are applied only after the whole
  archive has been read and validated.
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

## Safe Mode

`--dart-define=SAFE_MODE=true` builds a FlClash that never changes the host network, so a development build can run
next to an installed one. It is a compile-time constant with two faces: `safeModeBuild` in `lib/common/constant.dart`
for the process-wide handles that exist before the provider container, and `safeModeProvider` in
`lib/providers/app.dart` for everything reached through Riverpod, which is also what tests override. Settings are never
rewritten; each owner reads the flag where it would otherwise act:

- Core config: `SetupAction._effectivePatchConfig` is the one place the profile path and `updateConfig` derive what
  the Core receives from the user's `PatchClashConfig`. In safe mode it reports `tun.enable: false` and
  `ExternalControllerStatus.close`, so the generated profile and every `updateConfig` carry no TUN and an empty
  `external-controller` (the Core's `route.ReCreateServer` binds no RESTful API port) while the settings keep the
  user's values and the installed app keeps `127.0.0.1:9090`. `SetupAction.requestAdmin` skips authorization.
- System clock: `_makeRealProfileTask` sets `write-to-system: false` on whatever `ntp` section the generated profile
  ends up with, so neither the user's override nor the profile's own NTP config can move the host's time.
- Profile listeners and firewall rules: `_makeRealProfileTask` clears `listeners`, `tunnels`, `ss-config`,
  `vmess-config`, `tuic-server` and `iptables`, and closes `dns.listen`, preventing profile-only changes during apply.
- System proxy: the `proxy` plugin handle in `lib/common/proxy.dart` is `null`, so `ProxyManager` and exit cleanup
  never write the OS setting, not even the `stopProxy` that would clear what the installed app configured.
- System DNS: `systemDnsCoordinator` is `null` and `shouldPatchSystemDnsProvider` is `false`, so neither the apply nor
  the restore path runs. The restore path matters because a profile or release build shares the preferences of the
  installed app (only a macOS or Android debug build has its own bundle id) and would restore from its record.
- Login item: the `autoLaunch` handle in `lib/common/launch.dart` is `null`, so neither the boot sync nor the setting
  listener registers the build's executable or removes the installed app's entry, which on Windows is the same
  `FlClash` value in the user's Run key.
- Privileged Core: `CoreService` resolves the launcher with `hasHelper: false`, which is the direct child-process path
  on every desktop platform; the Helper keeps managing the installed app's Core.
- Core listeners: `SetupAction` never calls `startListener` or `stopListener`, for a run or for an on-demand
  suspension, so the Core's `isRunning` stays false and `updateListeners` binds nothing, while `isStartProvider`
  and `applyProfile` behave as usual. The installed app keeps the mixed, DNS and other loopback ports.
- Android: `sharedStateProvider` hands the service `VpnOptions.enable: false` and `systemProxy: false`, so the
  foreground service runs without a `VpnService`.
- Wi-Fi SSID: `ConnectivityManager` never reads the SSID and `LocationPermissions.refresh` neither checks
  nor requests location authorization, so `currentSSIDProvider` stays `null` and the excluded-network suspend never
  trips. The macOS `wifi_ssid` plugin builds its `CLLocationManager` and `CWWiFiClient` lazily, so a build that
  never asks never reaches locationd or wifid.
- Global hotkeys: `HotKeyManager` neither subscribes to hotkey events nor registers the configured shortcuts with the
  OS; the in-window `Shortcuts` (close window, escape) stay.
- URL schemes and launcher shortcuts: `Window.init` skips the Windows registry and Linux desktop-entry registration
  of the `clash` schemes, and Android never calls `initShortcuts`.
- Presentation: `AppEnvManager` shows a `SAFE MODE` banner ahead of the channel banner, and `TrayState.safeMode` gives
  the tray the `status_4` bug icon, a suffixed tooltip and a menu of only show and exit. `trayStateProvider` and
  `trayTitleStateProvider` report `showTrayTitle: false`, so the macOS menu bar carries no traffic title.

A new host integration, anything that changes the OS's routes, proxy, DNS, login items, privileges or VPN state, or
that asks the OS for a permission, a global shortcut or a registration, must consult the flag at its owner in the same way and get a test that overrides `safeModeProvider`.

## Build System

`setup.dart` is the release build orchestrator: it writes `env.json` (`APP_ENV`), activates `flutter_distributor` from
the `chen08209/flutter_distributor` fork pinned to a `v<version>-flclash.<n>` tag (cut a new tag there and bump
`--git-ref` when the fork changes), and leaves the Core artifacts to the build hook.

The desktop Go core and the Rust helper are built by a Dart build hook; Android's Core is built by Gradle (see Android
Core Build). `plugins/setup/hook/build.dart` only constructs
`CoreBuilder`, a `package:hooks` `Builder` in `plugins/setup/setup_hooks/`, the same shape `rust_api` uses. Flutter
runs it for every platform build and for `flutter test`, once per target architecture. `CoreBuilder` turns the hook
input into a `BuildRequest` (repository root, `Target`) and hands it to `buildPlatform`. It lives in
`setup_hooks` so `dart test` there can cover it; a test run of `plugins/setup` itself would execute the hook. Failures
reach the runner as `BuildError` (Go or Cargo failed, no Core for the architecture) or `InfraError` (a toolchain could
not start, the package is not at `plugins/setup`).

What the hook protocol forces:

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

- Android: nothing. The hook returns without building, because it runs once per architecture while gomobile packs
  every ABI and one set of Java classes into a single AAR.
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
  effective build configuration, `setup_hooks` sources, target flags and the Go toolchain.
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

`core_version` in `build_config.yaml` is the mihomo release tag the `core/Clash.Meta` fork is based on. Upstream injects
its version only from its own CI, so the fork alone reports the placeholder `1.10.0` in `/version` and in protocol
user agents; `GoBuilder` passes the value as `-X github.com/metacubex/mihomo/constant.Version=...` for every build,
local and CI alike. Bump it whenever the submodule moves onto a new upstream release.

Architecture detection is automatic. The `--description` flag passed to `flutter_distributor` adds arch suffixes to artifact names, such as `FlClash-0.8.93-macos-arm64.dmg`.

#### Android Core Build

`android/core/build.gradle.kts` registers `bindCore`, which runs `gomobile bind` on `core/mobile`. `:core` cannot
depend on the AAR itself: `bundleAar` refuses a local AAR in a library, which would break `./gradlew assemble` and
Android Studio's Make Project. It takes the AAR apart instead, `classes.jar` as a file dependency and `jni/` through
an `unpack<Variant>CoreJniLibs` task per variant handed to `variant.sources.jniLibs.addGeneratedSourceDirectory`; the
legacy `sourceSets` DSL rejects a task-built directory. Gradle therefore runs the Go build before any task that needs
its classes or libraries, in every variant and whether or not Flutter started the build, and its up-to-date check over
`core/` (tests, `testdata` and `cmd/` left out), `build_config.yaml`, the Go version, the ABIs, the API level and the
NDK version stands in for the hook's cache.

- `gomobile` and `gobind` come from the `tool` directives in `core/go.mod` and are built into the task's temporary
  directory, so their version moves only with `go.mod`. `bindCore` finds `go` on `PATH` or in the Homebrew and Go
  installer locations that Android Studio's GUI `PATH` leaves out, and puts the JDK running Gradle first for
  gomobile's `javac`.
- The ABIs come from the `target-platform` property Flutter passes, and default to all three for a Gradle build Flutter
  did not start. `ANDROID_HOME` and `ANDROID_NDK_HOME` are AGP's SDK and its `ndkVersion` NDK, so the Core and the app
  share one NDK, and `-androidapi` is the app's `minSdk`.
- `tags`, `go_ldflags` and `core_version` come from `build_config.yaml`, the file the hook reads.
- Both Cores take their GODEBUG defaults from the `go` line of `core/go.mod`, whatever toolchain builds them. The
  desktop Core gets them from the Go command because `core` is its main module. gomobile links the library as the main
  package of a module it generates, whose `go` line is the toolchain's, so `bindCore` hands the desktop Core's
  `DefaultGODEBUG` (from `go list` on `./cmd/core`) to the Android Core through `-X=runtime.godebugDefault`. Without
  it, a toolchain newer than that line would move only Android's TLS, x509 and runtime defaults. Raising the `go`
  line therefore changes both Cores' behaviour at once; pin a setting with a `godebug` line in `core/go.mod` to hold
  it back on both.
- The TLS settings among them do nothing for proxy traffic. Every TLS connection the Core makes goes through
  `metacubex/tls` or `metacubex/utls`, ports of `crypto/tls` that hard-code their version's defaults and never read
  GODEBUG, so `tlssha1` and `tlsmlkem` cannot be held back. They still parse and verify through the standard
  `crypto/x509` and `crypto/rsa`, and both run before `skip-cert-verify` is consulted, so `core/go.mod` keeps
  `x509negativeserial=1` and `rsa1024min=0`: a server certificate with a negative serial number or an RSA key under
  1024 bits would otherwise fail the handshake even on a proxy that skips verification.
- gomobile names the library `gojni`, both as the file it builds and in the `System.loadLibrary` of the `go.Seq`
  runtime, with no option to change it. `bindCore` rewrites that string constant in `go/Seq.class` to `clash` as it
  extracts `classes.jar`, and the unpack task renames `libgojni.so` to `libclash.so`; each fails the build unless it
  finds what it rewrites, the constant exactly once. Go writes no `DT_SONAME` into a c-shared library, so the ELF
  needs no change.
- The AAR's own `proguard.txt` goes with the rest of it. `android/core/consumer-rules.pro` keeps `go.**` and
  `com.follow.clash.core.mobile.**`, the classes gobind's C glue looks up by name.
- The CI `android` job compiles `:core` without Flutter, so it passes `-Ptarget-platform=android-arm64` to build one ABI.

## Local Plugins

- `setup`: build-time harness for Go core artifacts and the Rust helper, driven by a Dart build hook; no runtime Dart API.
- `proxy`: system proxy configuration. On Windows the package installer and uninstaller kill the app, and then run
  `FlClash.exe --clear-stale-proxy`, the installer once the new files are in place; the runner hands it to the plugin
  before any engine starts, and it turns off only a proxy still set to FlClash's `127.0.0.1:<port>` with nothing
  listening on that port.
- `rust_api`: runtime Flutter Rust Bridge FFI package built through Native Assets. See below.
- `tray`: system tray for Linux, macOS and Windows. Written for FlClash; replaced the `tray_manager` fork.
- `window`: desktop window control for Linux, macOS and Windows. Written for FlClash; replaced the
  `window_manager` fork. See below.
- `wifi_ssid`: Wi-Fi SSID detection.
- `code_forge`: the text editor behind `EditorPage`, derived from upstream `code_forge`. See below.

## code_forge Plugin

`CodeForgeController` is the document: text lives in the Rust `RopeBridge`, and the controller's methods are split by
concern into `lib/code_forge/controller/` extensions. `CodeForge` builds `_CodeFieldRenderer`, whose painting, layout,
folding, caret, gutter and pointer code sit in `lib/code_forge/code_area/` part files.

- `loadText` builds a document of 128K characters or more on a Rust worker thread (`RopeBridge.createInBackground`),
  so a large file does not stall the frame it arrives in; `EditorView` loads through it, and a later `text =` or
  `loadText` supersedes one still building.
- Rust counts offsets in Unicode scalars and Flutter in UTF-16 code units. Convert at the boundary with
  `text_offsets.dart`; a mixed-up offset only shows up with astral characters such as emoji, so tests use them.
- The renderer learns what changed from `takeChange()`, whose `lines` (first line, lines removed, lines inserted) let it
  follow edits without reading the whole text; a whole-text `text =` assignment marks the change `replaced` and resets
  the renderer instead.
- The input method is handed a window of the document around the caret, at most 4096 characters, and its deltas are
  mapped through that window, so the platform has to hold the current one: a caret move that shifts the window, the
  input method's own included, sends it again. A selection can reach past the window; when the platform removes the
  selection it sees, the controller removes the rest with it, as one undo step. Gboard does that by collapsing the
  selection and deleting what it saw, then composes the typed letter before a newly sent window reaches it: deltas
  made on a window already replaced are not mapped through the new one, and only what they typed is kept. A line
  longer than the window gets one cut by character count, which stays where it is until the caret nears an end of it,
  or every key would replace it. A caret move can put a window of the very same text further along; an edit the
  platform then makes at the caret it had is mapped through the window it still holds.
- A selection the input method collapsed is still the one to replace only while the caret rests at the end it was
  left at; Gboard's spacebar caret gesture collapses to the middle and moves on, which lets it go. The platform's own
  cut (Gboard's text-editing panel) arrives as a lone deletion of the live selection and copies only the window's
  part, so the controller rewrites the clipboard with the whole selection. That panel's select-all and copy still
  reach only the window. Gboard types over a selection in two batches, the removal and then the letter: the second
  joins the undo step of the first, and undoing it gives the selection back.
- A composition is drawn over the document and written into it only when it ends, so whatever reads or rewrites the
  document from outside the input method commits it first: saving, leaving the page, accepting a suggestion, a
  snippet, find's replace, and `UndoRedoController`'s `undo`/`redo` through the `settleInput` callback the controller
  registers. Losing focus and a closing connection commit it too rather than drop it. Typing that ends a composition,
  Enter or a bracket, goes through the typing path so it still indents and pairs. Android ends one with an empty
  delta batch when the keyboard is hidden.
- A caret the input method moves has to set `selection` on the change record like any other move, or the renderer
  neither repaints nor follows it.
- A line's fold comes from the renderer's `_computeFoldRangeForLine` up to 10000 lines and from `compute_all` in
  `rust_api`'s `editor/folds.rs` past that, and the two must find the same ranges; `folding_test.dart` compares them on
  one document. A folded range, and the folded ranges inside it that it folds again when it opens, outlive an edit
  only while the text still gives that range. An edit reports the lines it changed, not where in them, so a fold
  heading a line inside an edit that changes the line count is opened rather than guessed at; `replaceText`, which
  find's replace-all uses, rewrites only the span that differs to keep that to the lines between its matches.
- The caret never rests on a line a fold hides: folding over it moves it to the heading line, the keyboard steps over
  the fold, and a caret put there any other way opens it.
- The controller reaches the mounted editor only through the `CodeForgeView` it attaches, which the editor's state
  implements by forwarding to its renderer.
- FlClash supplies the suggestion popup, context menu and scrollbar; the package has no built-in versions of them.
- Tests live in `test/plugins/code_forge/` at the repository root and need the `rust_api` library.
- `isMobile` comes from `Platform`, so host tests never reach the touch branches (selection handles, long press,
  magnifier); check those on an Android emulator.

## window Plugin

`plugins/window` exposes `desktopWindow` (`DesktopWindow`) on the `window` method channel; `plugins/window/README.md`
is the channel contract (methods, arguments, events, effects, runner hooks) and every platform implements exactly that
table. `lib/common/window.dart` and `lib/manager/window_manager.dart` are the only application callers.

- Each platform keeps one style record (title bar style and button visibility everywhere, rounded corners on
  Windows, effect, tint and brightness on Windows and macOS) and reapplies it whole from a single `apply` routine, so DWM margins
  on Windows and `isOpaque`/effect views on macOS have one writer. Add a visual setting to that record, never a second
  code path.
- Method dispatch is a table on every platform, and every handler validates its arguments; a bad call answers with a
  `bad_args` `PlatformException`, a capability the platform lacks with `unsupported`. Coordinates cross the channel in
  logical pixels; Windows converts with `GetDpiForWindow`.
- Position and size changes surface as one `geometry-changed` event that each platform coalesces natively (150 ms
  after the last `WM_WINDOWPOSCHANGED`, did-move/did-resize, or configure-event); `WindowManager` only debounces the
  capture on top of it.
- Windows: with `titleBarStyle: hidden`, `WM_NCCALCSIZE` takes the frame insets from `AdjustWindowRectExForDpi` and
  keeps the client rect at the top edge (plus the frame height when maximized, so the taskbar stays uncovered; plus
  one physical pixel on Windows 11, which draws the top border only into a non-client strip; none on Windows 10,
  where DWM draws the whole caption over any strip shorter than one). Windows 10 gets its top border the Windows
  Terminal way instead: the DWM frame is extended over the caption height, the plugin places the Flutter view one
  physical pixel lower and paints that row black, which DWM treats as alpha 0, and hit-tests it as `HTTOP`; see
  `plugins/window/README.md`.
  The plugin therefore owns the view placement on `WM_SIZE`. Fullscreen is emulated by the
  plugin, which raises `enter-full-screen` and
  `leave-full-screen` itself and mutes `WM_SIZE` while it is on. The find-running-window IPC
  (`WindowPluginFindRunningWindow`/`WindowPluginActivateWindow`) registers a window message from the executable path
  and whitelists it through UIPI so a non-elevated launcher reaches an elevated instance.
- Linux: GTK drops the placement of an unmapped window, so `hide` saves the geometry and the `map-event` handler
  applies it, then corrects the placement for 150 ms while the window manager settles (it may place the window
  after the map handler ran). `isPositionSupported` is X11-only; Wayland owns placement and re-shown windows land where the
  compositor puts them. Linux supports no effect: GTK 3 has no desktop-neutral blur protocol, so `isEffectSupported`
  is true only for `none` and the runner keeps the default visual.
- macOS: `WindowPlugin.instance` is reached from `AppDelegate` for `applicationShouldTerminate` (emits
  `should-terminate`) and `applicationShouldHandleReopen` (emits `activate`); `MainFlutterWindow` calls
  `hiddenWindowAtLaunch()` so the first `order` keeps the window hidden until Dart shows it.
- Window effects (`transparent`, `blur`, `acrylic`, `mica`) are capability-gated by `isEffectSupported`; the Flutter
  content must paint a translucent background for them to show. `ThemeProps.sidebarBlur` (on by default) drives
  them: `Window.setBlur` picks `blur` on macOS and `acrylic` (or `blur`) on Windows and caches only a successful
  probe, so a platform that answered unsupported is asked again the next time blur is turned on. `WindowManager` reapplies it
  whenever the setting or the app brightness changes and records the outcome in `windowBlurProvider`, and only the
  sidebar and the caption strip paint translucently while it is on. On macOS the sidebar paints fully transparent
  and the effect view follows the window's active state, which is the flutter_acrylic `TransparentMacOSSidebar`
  look; Windows keeps a 50% tint because the accent effects blur too little for the rail to stay readable.
- Sidebar blur is soft-disabled: `feature.sidebarBlur` (`lib/common/feature.dart`) is off unless the build passes
  `--dart-define=FEATURE_SIDEBAR_BLUR=true`. While it is off the theme page hides the toggle and
  `windowBlurRequestProvider` asks for no effect whatever `ThemeProps.sidebarBlur` holds. `WindowManager` still sends
  that request at startup: the macOS plugin installs its effect view in `ensureInitialized` and leaves it active until
  the first `setEffect`, so the `none` request is what makes the window opaque and parks the effect view.

## rust_api Crate Layout

`plugins/rust_api` has no platform folders. `hook/build.dart` is a Dart build hook: Flutter runs it for every platform
build and for `flutter test`, and `flutter_rust_bridge_hooks` (over `native_toolchain_rust`) compiles the crate with
Cargo and registers `librust_api` as a code asset that Flutter bundles and signs. The build runs
`rustup run <channel>`, so `rust/rust-toolchain.toml` must pin an exact channel and list every target the project ships;
the hook refuses `stable` and a target missing from that list. `rustup show` installs the pinned toolchain and those
targets on first use.

`flutter_rust_bridge_codegen generate` (see `.agents/commands.md`) writes `lib/src/rust/frb_generated.dart`,
`frb_generated.io.dart`, `frb_generated.web.dart`, one `lib/src/rust/api/<module>.dart` per Rust API module, and
`rust/src/frb_generated.rs`; none of them is edited by hand. A new Rust function is a public function in `rust/src/api/`,
plus `pub mod <name>;` in `api/mod.rs` and an export from `lib/rust_api.dart` when it starts a new module. `RustLib` is
the singleton entry point: `RustLib.init()` runs before any call and `RustLib.dispose()` on teardown.

`plugins/rust_api/rust/src/` separates the bridge boundary from the code behind it:

- `api/` is the only input flutter_rust_bridge parses (`rust_input: crate::api`). Every function there is a thin
  delegation, so the generated bindings stay identical on every platform.
- `ipc/` implements the desktop socket server: `frame` (length-prefixed framing), `outbox` (the byte-bounded send
  queue), `access` (socket mode, the Unix peer uid check, and the peer PID), and `server` (bind, the accept loop, and
  the read and write halves of a connection). Each `Server` runs a current-thread tokio runtime on an `ipc-server`
  thread of its own and holds no global state, so I/O is event-driven on every platform and closing or dropping the
  handle releases the socket. It serves one peer at a time; a second one waits in the backlog.
- `script/` runs profile override scripts on QuickJS through `rquickjs`.
- `editor/` backs `plugins/code_forge`: a `ropey` buffer, fold ranges and bracket matching, indent guides for the
  viewport, and completion words. `api/editor.rs` exposes the buffer as the opaque `RopeBridge`; the selection
  stays in Dart. Only the editor imports this module, through `lib/editor.dart`, so `lib/rust_api.dart` keeps its
  generic names such as `GuideBlock` out of app code.
- `hotkey/` registers desktop global shortcuts through `global-hotkey`: `keys` maps Flutter USB HID usages to key
  codes, `owner` runs every registration on the thread the platform binds it to (a dedicated message-loop thread on
  Windows, the main dispatch queue on macOS, in place on Linux), and `service` owns the registry and forwards presses
  to Dart. Linux is X11 only; a Wayland session without XWayland gets an error rather than a silent no-op.

`IpcServer.bind` resolves once the address is bound, `events()` attaches the one event stream, `send` only enqueues
and is a synchronous call so frames keep the order they were sent in, and `close` joins the thread. A bridge function
that takes a `StreamSink` must not return an error: the generated Dart code drops that call's future, so an `Err`
surfaces as an unhandled async error instead of reaching the caller. That is why binding is its own call and
everything after it is reported as an event.

What a platform does not use, it does not compile. `interprocess`, `tokio` and `global-hotkey` are declared under
`cfg(not(target_os = "android"))`, and `ipc/mod.rs` and `hotkey/mod.rs` swap in their `unsupported.rs` there, because
Android loads the Core in-process and has no global shortcuts. Adding a capability follows the same shape: implement it in its own module, gate the
dependency by target, and keep the `api/` entry point unconditional so one set of bindings still serves every platform.

`RustLib.init()` runs on every platform in `main`, because the script engine and the editor are shared; the editor
shows its unavailable state when `RustLib` is not initialized rather than loading the library itself.

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
- `rust/tests/fixtures/profile_script.js` is the compatibility regression: an extension script written for the suite that
  performs the transform real ones perform, so it exercises `Map`/`Set`, spread, destructuring, optional chaining,
  nullish coalescing, `Object.fromEntries`, named capture groups and lookbehind in one pass. Keep it first-party and
  free of external URLs — vendoring somebody's published script here carries their attribution and their links.

## Rust Helper Service

`services/helper/` is the privileged helper that starts the core elevated so TUN works. It ships on Windows and Linux
and is built by the setup build hook alongside the Core, which always compiles the Helper in Rust release mode
after calculating the SHA256 of the Core produced for the active Flutter configuration.

The helper owns its Windows Service Control Manager lifecycle through two elevated commands:

- `FlClashHelperService.exe install --owner-pid <pid>` reads the account of that process (the app, which Dart names with
  its own PID because the elevated installer may be another administrator), stops and removes any stale registration,
  creates the auto-start service for the current executable path with `--owner-sid <SID>` as its launch argument,
  starts it, and waits for the running state. A service started without an owner exits instead of serving anyone.
- `FlClashHelperService.exe uninstall` stops the service, waits for shutdown, removes its registration, and is also used
  by the Windows package uninstaller.

The Dart layer only launches the helper's `install` command through `ShellExecuteW`; it does not compose `sc.exe`,
`taskkill`, or `cmd.exe` command lines.

Linux takes the same shape with systemd in place of the Service Control Manager, and the same install timing: nothing
is registered at package install, and `Linux.registerService` asks for elevation only when TUN authorization needs it.
Elevation goes through `pkexec` so polkit raises the system prompt. When pkexec is missing, or exits 127 because no
polkit agent runs (common under tiling window managers), it falls back to `sudo`: cached credentials first, then a
password the app asks for and hands to `sudo -S` on stdin. A 126 means the user dismissed the polkit dialog and is final.

- `FlClashHelperService install`, run through `LinuxElevation` (`lib/common/linux_elevation.dart`), writes
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
  readiness is the `stat` check, and the same elevation sets the setuid bit on the bundled Core as before.

A setuid Core is a root process for whoever gives it an address to dial (`argv[1]`), so its mode never lets others
execute it: macOS runs `chown root:admin` and `chmod 4750` (and refuses an account outside the `admin` group, which
could not run the result), and a Linux host without systemd hands it to the primary group of the user that
`PKEXEC_UID` or `SUDO_UID` names. `System.isPrivilegedStatOutput` reads a Core that others can execute as unauthorized, so one that an earlier
version marked `+sx` is re-authorized on the next TUN enable.

In every Flutter build mode `/start` opens the fixed Core executable beside the Helper without write/delete sharing,
validates it against the SHA256 embedded only in the Helper, and keeps that handle open through process creation.
`/ping` only compares the requested `coreSha256` with the Helper's embedded value and checks the fixed Core path exists;
it never hashes the Core. Protocol version 6 (8 on Windows, where the owner check and the browser-origin check arrived
and an older Helper must be reinstalled) uses 32-character lowercase-hex session ownership:

- `GET /ping?coreSha256=...` returns the current Helper executable path with `x-flclash-helper-protocol` when the
  requested SHA matches.
- `POST /start` rejects unknown JSON fields and validates `{address, sessionId}` and, on Linux, the socket owner, which
  leaves a running Core alone. It then releases any previously managed Core before verifying the Core — so every
  outcome of a request that passed validation, including a rejected one, leaves the Helper owning no Core — and returns
  `{sessionId, pid}`.
- `POST /stop` validates `{sessionId}` and only stops the matching managed Core. A session mismatch is HTTP 409.
- `GET /logs` exposes the bounded recent Helper/Core stderr buffer with `no-store` caching.

`/start` and `/stop` take at most 4096 bytes and need a `Content-Length` (HTTP 413 and 411 otherwise); `HelperClient`
always sends one. All endpoints reject `Origin` headers and non-local `Host` values, preventing browser requests and DNS
rebinding through an owner-account browser, which would otherwise pass the Windows account check. The accepted
authorities are `127.0.0.1`, `localhost` and the Linux Unix-socket placeholder `FlClashHelperService`. The Helper grants
no CORS access.

Endpoints bind only to `127.0.0.1` on Windows and to `/run/flclash/helper.sock` on Linux, and do not use
request-token authentication. The Windows port is picked by the system, because Hyper-V and WinNAT reserve ranges that
can cover any fixed one, and published as the `Port` DWORD of a volatile `Runtime` key under the service's own registry
key, which only administrators can write; `HelperClient` reads it per request and falls back to 47890, where a Helper
from before listens. Who may call them is decided per connection, before any request is read: the Linux
socket drops a peer whose `SO_PEERCRED` UID is not the owner's, and the Windows listener (`service/peer.rs`) traces the
connection through the TCP table to the process holding its client end and drops it unless that process runs as the
owner SID the service was registered with. The Windows Core runs as SYSTEM and dials whatever pipe `/start` names, so
without that check any local account would host a SYSTEM Core. What no per-connection check closes is a process that
runs as the owner itself, on either platform. Lifecycle safety also comes from the fixed executable/hash, the strict
address namespace (`\\.\pipe\FlClashCore_<32 hex>` on Windows, `/tmp/FlClashSocket_<digits>.sock` on Linux), the session-scoped stop
contract, Dart-side peer-PID verification on Windows and, on Unix, the Core socket that `plugins/rust_api` sets to
mode `0600` so only the owning user (and the root-effective Core) can connect. When the Helper service itself shuts
down, it unconditionally stops the Core process it owns; under systemd the unit's control group does the same.
