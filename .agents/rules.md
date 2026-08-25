# Rules

These are repository coding and testing conventions. Codex command permission rules belong in `.codex/rules/*.rules`; see `.agents/agent-config.md` before adding those.

## Dart and Flutter Style

The lint set lives in `lint_options.yaml` at the repo root. The root `analysis_options.yaml` and every local plugin under
`plugins/*` include it, so application and plugin code are held to the same rules. Add or change a rule there, not in an
individual `analysis_options.yaml`; those files carry only their own `analyzer.exclude` entries.

`lint_options.yaml` enforces these non-default rules:

- `prefer_single_quotes: true`: always use single quotes.
- `require_trailing_commas: true`: use trailing commas in multi-line argument lists.
- `sort_child_properties_last: true`: `child:` must be the last named parameter.
- `avoid_print: true`: do not use `print()` calls.
- `prefer_const_constructors: true` and `prefer_const_declarations: true`.
- `prefer_final_locals: true` and `prefer_final_in_for_each: true`.
- `always_declare_return_types: true`.
- `only_throw_errors: true`: throw an `Exception` or `Error`, never a bare `String`.

Failures whose whole content is a message meant for the user throw
`MessageException` from `lib/common/exception.dart`. Its `toString()` is the bare
message, which is what `globalState.safeRun` surfaces in the dialog, so the
user-facing text is unchanged from the older `throw someMessage` idiom while the
throw stays catchable as an `Exception` and carries a stack trace. Assert on it
with `isA<MessageException>().having((e) => e.message, 'message', ...)`, not on a
raw string.

### Corner Radius

Rounded corners are superellipses everywhere, not circular arcs. Use the superellipse API at each layer:

- Shapes: `RoundedSuperellipseBorder` instead of `RoundedRectangleBorder`.
- Clips: `ClipRSuperellipse` instead of `ClipRRect`.
- Container decorations: `ShapeDecoration(shape: RoundedSuperellipseBorder(...))` instead of
  `BoxDecoration(borderRadius: ...)`; borders move to the shape's `side`, and a `Container` with
  `clipBehavior` still clips to the shape path.
- Canvas: `canvas.drawRSuperellipse(RSuperellipse.fromRectAndRadius(...))` instead of `drawRRect`.

Passing `BorderRadius.circular(x)` as the `borderRadius` argument of these APIs is expected — it only
carries the corner magnitude; the rendered geometry stays a superellipse.

APIs that accept only `BorderRadius` keep circular corners, with the superellipse supplied by an
enclosing clip or shape where one is needed: `InkWell.borderRadius`, `OutlineInputBorder`,
`ScrollbarThemeData.radius`, and `smooth_sheets`' `MaterialSheetDecoration`. Fully round pills
(`BorderRadius.circular(999)` or half the shortest side) may stay circular — both geometries coincide
there.

CI gates formatting: `dart format --output=none --set-exit-if-changed lib test
tool plugins setup.dart` runs before `flutter analyze`.

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
  the delay-test concurrency cap is bound to `delayTestConcurrency` in `core/common.go`, and whoever changes that number must see the
  constraint on the same screen.

Both failure directions are real. Moving a local constraint into `.agents/` hides it from the person editing the line;
leaving a repo-wide policy as a comment reaches only the reader of that one file.

Before any of the three, prefer encoding the intent in structure and naming — a named mixin, type, or method that makes
the invariant hard to break beats prose that asks the next reader not to break it.

## Core API Safety

- `core/Clash.Meta` is a fork of mihomo, and changes to it are budgeted for features, not repairs. Fixing a bug there is
  low priority even when the bug is real and the fix is small: every patch is one more thing to carry across an upstream
  rebase. Solve it on the FlClash side of the boundary and note the mihomo behaviour you are working around. Reach into
  the submodule only for a feature that has nowhere else to live, or when the problem is one the FlClash patches
  themselves introduced — and say which of the two it is in the commit message.
- Do not expose direct filesystem deletion APIs through Core or helper IPC; use
  a scope-specific cleanup API instead.
- Keep the shared `CoreMethodCall`/`CoreMethodResponse` JSON envelope structurally identical across Dart, Go, JNI, and
  desktop IPC. Do not double-encode `arguments`, `result`, or event batches.
- `core/message.go` carries three event queues, and the split is load-bearing: state (loaded, geo-update), delay, and
  bulk (log, request). Delay and bulk evict their own oldest entry under backpressure; state uses `enqueueState`, which
  never evicts, because a dropped `geoUpdate{updating:false}` leaves `isUpdatingProvider` stuck at true in the UI until
  `UpdatingAction` sweeps it as stale minutes later. Do not merge the tiers or give state eviction semantics. `enqueueState` drops silently on a full
  queue and must stay that way: reaching it means the host stopped reading, which `logDeliveryError` already reports,
  and reporting it from the message layer feeds the same batcher.
- `jni_get_string` in `android/core/src/main/cpp/jni_helper.cpp` `malloc`s and hands ownership to Go, which frees through
  `free_string_func`. `quickSetup` relies on that: it reads its `*C.char` arguments inside a goroutine, after the JNI
  wrapper has already returned. Switching the wrapper to `GetStringUTFChars`/`ReleaseStringUTFChars`, or freeing on the
  C side, turns that read into a use-after-free.
- Go goroutines reach Java through `ATTACH_JNI()`, which attaches once with `AttachCurrentThreadAsDaemon` and detaches
  from a `pthread_key` destructor at thread death. Do not restore a detach-per-call: `protect` runs once per outbound
  socket and `onResult` once per event batch, and attach/detach takes ART's thread-list lock each time.
- Every JNI call into Kotlin must be followed by `jni_clear_exception`. A pending exception left in place aborts the
  process on the next JNI call on that thread, so a throw in `protect`/`resolverProcess`/`onResult` becomes a crash in
  unrelated code.
- The desktop delivery path in `core/server.go` must not report failures through `logError`. A log event is published to
  the log subscriber, batched, and handed back to `send`, so a send failure reported that way feeds itself; use
  `logDeliveryError`, which writes to stderr and latches until a frame gets through or the next connection is installed.
  A write that fails without putting a byte on the wire — host backpressure hitting `ipcWriteTimeout`, or a payload above
  `maxIPCFrameSize` — drops that one frame and keeps the connection: the stream is still framed correctly, and tearing it
  down here ends the read loop, and with it the Core process. Only a half-written frame desynchronizes the stream, and
  that is the one case `send` closes on.
- Core method handlers in `core/hub.go` are synchronous. Anything that must not block the dispatcher is spawned by
  `safeGo`/`safeGoDetached` in `core/method.go`, which recover; a bare `go` in a handler puts a panic outside every
  recovery and kills the process, which on Android is the whole application. The `//export` entry points in
  `core/lib.go` do not reach `handleMethodCall`, so each one carries its own recovery.
- `dialer.DefaultSocketHook` and `process.DefaultPackageNameResolver` are installed exactly once, by `installHooks` in
  `core/lib.go`, and never cleared. mihomo checks `DefaultSocketHook` for nil once and dereferences it again when the
  socket is created (`component/dialer/socket_hook.go`), so clearing it while a dial is in flight calls a nil func
  value. Stopping the TUN swaps `activeTunHandler` instead.
- `tunnel.AllProxies()` returns a shared, cached map — never modify it. The cache is invalidated by
  `invalidateAllProxies` on `tunnel.UpdateProxies` and validated against each provider's `Version()`, so a rebuild
  costs one read per provider rather than one per proxy. Anything else added to `tunnel/patch.go` that derives from the
  proxy set needs both signals: the external controller can reload the config through `hub/route/configs.go` without
  going through FlClash's `applyConfig`, so a hook on the FlClash side alone would miss a profile switch.
- Core state that mirrors mihomo state goes stale at the next `applyConfig`, which replaces every proxy, provider and
  rule. Read the tunnel instead of caching a snapshot of it: `lookupExternalProvider` kept one that was rebuilt only
  when the host asked for the provider list, and the host asks after a successful setup and not after a failed one, so
  an update ran against a provider the tunnel no longer held — downloading, writing to disk and reporting success
  against nothing.
- Selection writes take `selectMu`, not `configMu`. mihomo's `Selector.Set` has no lock of its own, so the writes need
  mutual exclusion against each other and against `patchSelectGroup` — but not against a whole config apply, which is
  what `configMu` made a proxy switch wait for, provider downloads included. `patchSelectGroup` takes `selectMu` under
  `configMu`, fixing the order as `configMu` → `selectMu`.
- The delay-test semaphore is acquired with a slice of the caller's budget (`budget/delayTestQueueShare`), not
  unconditionally and not with the whole deadline. Queueing and probing come out of one budget, so a test handed all of
  it can spend it waiting and reach `URLTest` with nothing left, reporting a proxy it never contacted as unreachable.
  The probe keeps the caller's original deadline, so whatever the queue did not use is still its own.
- A delay test that the Core does not answer is a fault of the Core or the channel, never a verdict on the proxy:
  `handleTestDelay` returns inside its own budget on every path. `asyncTestDelay` therefore returns null instead of a
  `-1` delay, and `ProxiesAction` leaves the last measurement in place and abandons the rest of the run. Writing a
  timeout there is what made a reachable node read as unreachable whenever the host deadline beat the Core's.
- Delay-test progress lives in `pendingDelayTestsProvider`, not as a sentinel value in `DelayDataSource`. A delay of 0
  used to mean "testing", which let a result and the state of a test overwrite each other and left cards spinning
  forever when the Core restarted. The run owns its keys and releases them in a `finally`, so nothing depends on a
  reply arriving; core status leaving `connected` cancels every run in flight.
- Anything on the mihomo side that is reached from both a user-triggered core method and mihomo's own background
  scheduler needs its in-flight guard on the FlClash side. `updater.UpdateMMDB` and its siblings have none — only the
  batch `UpdateGeoDatabases` does — and two concurrent runs close the mmap'd database twice, so `handleUpdateGeoData`
  claims per resource and `updater.GeoUpdateHook` releases.
- A failed `applyConfig` rolls the tunnel back to the default config, and that rollback is the whole recovery:
  `handleSetupConfig` returns the error and stops there. Do not add a teardown on top of it — stopping the listeners
  takes the app offline over a profile the user can still switch away from, and the error already reaches the host,
  which is what surfaces the failure (`MessageException` on the Flutter side, the config-error toast on Android). Keep
  an empty `config.yaml` out of the failure path — it is how the app says "no profile selected", and `loadConfig`
  resolves it to the defaults.
- Package `init` in the Android library runs while the `.so` is being loaded, so a panic there takes the application
  down before it can report anything. `platform/limit.go` arms an fd-pressure probe and degrades to never blocking when
  it cannot; keep that shape for anything else `init` sets up that correctness does not depend on.
- Every `android && cgo` file in `core/` is compiled only by the NDK-backed CI step in the `test` job. Keep the build
  constraints as `android && cgo` / `!(android && cgo)`: a bare `cgo` constraint makes `go build ./...` fail in `core/`
  on any developer machine, because the files it pulls in need the NDK.

## Lifecycle Rules

- Crash recovery is owned by `BootGuard` (`lib/common/boot_guard.dart`), and the signal it acts on is the persisted
  `BootRecord`, never a crash reporter. The record is stamped `starting` before `startCore` and `running` once
  `_initApp` finishes, so only a launch that died before reaching `running` is a failed launch — a crash after hours of
  runtime, or a process the system reclaimed in the background, is not one. `ApplicationExitInfo` can only veto a
  failure (user stop, low memory, signal, package change), never create one, and its timestamp is consumed through
  `handledExitAt` so the same exit cannot be counted twice.
- `BootGuard` is an Android-only mechanism and gates itself: on every other platform `evaluate`, `markRunning` and
  `markClosed` return without touching preferences. The desktop has neither of the two attribution sources — no
  `ApplicationExitInfo` equivalent and no Crashlytics toggle — so a bare sentinel there would read a window closed on
  the disclaimer dialog, or a session ended by shutdown, as a failed launch. Keep the platform check inside the guard;
  callers in `bootstrap.dart` and `SystemAction` stay unconditional.
- `FirebaseCrashlytics.didCrashOnPreviousExecution()` corroborates a failure and must not trigger one. Its marker file is
  cleared by a background initialization that `dataCollectionArbiter` blocks while collection is disabled, which is the
  default here, so one real crash makes it return true on every later launch. That latch is what made the app clear the
  selected profile on every cold start; it is also why the probe is only read when `crashlytics` is enabled, keeping
  Firebase uninitialized until the user consents.
- Recovery is graded: the first failed launch only skips `initStatus`, and `currentProfileId` is cleared only from
  `crashRecoveryClearThreshold` consecutive failures on. Do not let a single interrupted launch write to the config.
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
- `Tray.hide()` is idempotent on all three desktop platforms and returns native state to "`show` was never called".
  `AppTray.shutdown()` latches, so no later `update()`/`updateTitle()` can resurrect the icon once shutdown begins.
  Keep it that way; a resurrected icon outlives `exit(0)` as a Windows ghost icon, because `setPreventClose(true)`
  means `WM_DESTROY` never runs.
- The `tray` plugin owns call ordering, idempotency, serialization, and unchanged-payload suppression. Application code
  declares desired state through one `Tray.show(TraySpec)` call and must not add platform branches to work around
  ordering. Platform branches in `lib/common/tray.dart` are only for deliberate product differences (macOS speed title
  and group submenus); query `Tray.instance.capabilities` for ability differences.
- Every native `show` returns whether the tray now reflects the payload, and reports `false` instead of showing a broken
  icon. `Tray` caches the payload signature only on `true`, so a rejected `show` is retried by the next update rather
  than suppressed until restart. Any test that mocks the `tray` channel must return `true` from `show`.
- The delayed DNS re-check `NetworkObserveModule.onLosing` posts is deliberately left un-deduplicated. The runnable
  re-reads `networkInfos` and does nothing when `onLost` already dropped the network, `updateDns` returns early when the
  resolved list is unchanged, and `stop()` clears the handler queue, so a network that reports `onLosing` repeatedly
  costs one comparison per event. Holding the pending `Runnable` to `removeCallbacks` it changes no behaviour and adds
  state that has to stay in sync with the map.

## Testing Rules

The `core/` directory is excluded from automated coverage accounting. Do not add coverage instrumentation or coverage
collection for code under `core/`. CI still runs `CGO_ENABLED=0 go test .` and `go vet .` to compile/check the Go wrapper,
plus an NDK-backed `GOOS=android` vet that covers the `android && cgo` files the first two exclude; verify cross-language
protocol behavior through shared Dart contract tests under `test/core/` and native platform build checks.

A Go test in `core/` that reaches `sendMessage` — directly, or through `handleStartLog` or `updater.GeoUpdateHook` —
leaves events in the process-wide batcher, which flushes them up to `messageBatchInterval` later into whichever
connection `captureFrames` has installed by then. Either keep the event out of the batcher or end the test with
`settleMessageBatcher`. That batcher runs for the whole test binary and reads `conn` under `connMu`, so install a test
connection with `swapConn`; a bare assignment races every event it happens to be delivering, and `go test -race` catches
it in an unrelated test.

Use `CoreController.test(mock)` to inject a mocked `CoreHandlerInterface`. Call `CoreController.resetInstance()` in `tearDown` to clean up the singleton between tests.

Register fallback values for freezed params used with `any()` matchers.

`tool/check_coverage.dart` enforces a total floor passed by CI plus per-group floors declared in `_groupFloors`. Raise a
group's floor when new tests lift it; do not lower one to make a run pass.

Every measured group needs a floor. A group the report measures but `_groupFloors` does not declare fails the run, so
adding a top-level directory under `lib/` means adding its floor in the same change. Set a new floor at or just below
the coverage the directory actually has; the point is to stop a slide, not to backfill tests before the directory can
land.

Prefer `coreHandlerProvider.overrideWithValue(CoreController.scoped(fake))` over `CoreController.test(fake)` in new and
touched tests. `CoreController.test` claims the process-wide singleton, which makes a global read and a provider read
resolve to the same fake, so it cannot fail on a call site that still reaches for the global.

Construct the Android lib handler with `CoreLib.scoped(fakeService)`. The `service` global is gated on `Platform.isAndroid`
and is therefore null on every test host, so a `CoreLib()` built from it silently takes the null-service fallback on every
path. `CoreLib.scoped` binds an explicit `Service` instead; reset the singleton with `CoreLib.resetInstance()` in `tearDown`.

Three globals in `lib/common` reach real host state and carry a `@visibleForTesting` seam to stand in front of it:
`AutoLaunch.launcher`, `listNetworkInterfaces` and `LinkManager.uriLinkStream`. Replace the launcher in particular — every
`enable`/`disable`/`isEnabled` writes the actual autostart entry (a LaunchAgents plist, a `.desktop` file or a registry
key), so a test that skips the seam registers the test binary on the machine that ran it. `updateStatus` returns early
under `kDebugMode`, which is always true beneath `flutter test`, so its remaining branches cannot be reached from a test
at all; `test/common/launch_test.dart` pins the early return instead.

`pumpAndSettle` never returns on a page holding `EditorPage`: the code editor blinks its caret forever, so frames keep
being scheduled. Pump explicitly instead. `encodeYamlTask` and its neighbours in `common/task.dart` hand work to a real
isolate through `compute`, which only runs outside the fake-async zone, so a test awaiting one needs
`tester.runAsync(...)` between the pumps — see `test/views/profile_preview_test.dart`.

The `@visibleForTesting` `database` setter in `lib/database/database.dart` deliberately does not close the instance it
replaces. Tests inject `NativeDatabase.memory()`, which holds no file handle, and `Database.close()` is async while the
setter is not, so closing there would either be unawaited or force the seam to become async for no gain. A test that
does open a file-backed database owns closing it.

`system.isAndroid` / `isMacOS` / `isWindows` / `isLinux` read `dart:io` `Platform` and cannot be overridden, unlike
`debugDefaultTargetPlatformOverride`. A branch behind one of them is only ever exercised on a host that matches it, so CI
(`ubuntu-latest`) and a macOS working copy measure different coverage for the same test. Assert host-agnostic behavior,
and leave headroom under a group floor that covers such a branch.

A platform decision that drives layout takes `isDesktop`/`isMacOS` as parameters and reads `system` only at the call site,
so every platform's outcome is reachable from one host. `getWindowHeaderHeight` and `showsWindowHeader` in
`lib/common/layout.dart` own the window header rule for both `WindowHeaderContainer` and `overlayTopOffset` — they must
agree, or the content is offset by a header that is not there. `WindowHeaderBar` takes its height and slots as arguments,
which is what lets `test/manager/window_header_test.dart` measure the Windows caption bar on a macOS host.

A `Stack` under loose constraints sizes to its non-positioned children, and falls back to `constraints.biggest` only when
it has none — so a bar that fills the window must keep every slot positioned. One non-positioned child is enough to
collapse `WindowHeaderBar` to that child's width: the macOS title did exactly that, leaving the app name over the traffic
lights and the raw window painted black beside it, while Windows, whose slots are all positioned, stayed correct.
`WindowHeaderLayout` positions the header across the top for the same reason, and the macOS group asserts the bar's
width, not just its height — a height-only assertion cannot see this.

The same seam carries the two other places a platform decision changed what was built: `AppTray` holds `isMacOS`/
`isWindows` as state — `AppTray()` fills them from `system`, `AppTray.forPlatform` is the test seam — and `OnDemandView`
takes nullable `isAndroid`/`isMacOS` that fall back to the host. Every test names the platform it means, because
`debugDefaultTargetPlatformOverride` does not move `system` and a suite that leaves it to the host asserts the macOS
shape on a developer machine and the Linux one on CI. `WindowHeaderContainer` builds the caption buttons on every
non-macOS host, so a test mounting it needs `TestApp` for `AppLocalizations` and a `window_manager` channel mock that
answers `isMaximized`/`isAlwaysOnTop` with a bool.

Auto-dispose providers need a container-level hold before a test reads them back. `proxyGroupProvider`, `ruleProvider`,
`itemsProvider` and friends mix in `AutoDisposeNotifierMixin`, so a `container.read` that no widget is currently watching
rebuilds the provider from its override and silently discards whatever the code under test wrote. Add
`container.listen(theProvider, (_, _) {})` in the harness, as `overwrite_stage_flow_test.dart` does. The staging flow also
re-arms its debounce when it clears the stage, so drain it (`pump` past the duration, then unmount) or the binding fails
the test on a pending timer.

A field that constructs its own `ValueNotifier`, `TextEditingController`, `ScrollController`, `FocusNode`, `TabController`,
`PageController`, `AnimationController` or `StreamController` must be released in the same file.
`test/lint/disposable_field_test.dart` enforces this by scanning `lib/`, because no lint covers it: `close_sinks` only sees
sinks, and nothing in the standard set tracks `ChangeNotifier` disposal. A field that genuinely outlives its owner goes in
that test's `_allowed` set with the reason, not left bare. Controllers received as widget parameters belong to the caller
and are out of scope.

An `IconButton` whose icon is an icon needs a `tooltip`. It is the button's only accessible name — without it TalkBack and
VoiceOver announce nothing and the desktop build shows no hover hint. `test/lint/icon_button_tooltip_test.dart` enforces
it and skips exactly two shapes: an `icon:` holding a `Text`, which is already a visible label, and
`views/dashboard/widgets/core_status_button.dart`, which takes its label from an enclosing `Tooltip` (a second test fails
if that wrapper disappears). Reuse an existing string before adding one; a label that depends on state goes on the button
inside the `ValueListenableBuilder`, not outside it, or the tooltip cannot follow the icon. A row of window buttons hidden
behind `system.isMacOS` is unreachable from a macOS test host, so extract it — `WindowHeaderActions` is the pattern.

A tooltip needs an `Overlay` ancestor at build time, not at hover time: `RawTooltip` builds an `OverlayPortal`, so a
button whose `tooltip` has nowhere to go throws "No Overlay widget found" and takes its whole subtree down with it.
Everything `buildManagerStack` wraps around `MaterialApp.builder`'s child sits *above* the app Navigator and therefore
above the only Overlay in the tree. A manager that renders a tooltip — `WindowHeaderLayout` and its caption buttons are
the case that broke Windows while macOS, which renders a bare title there, stayed clean — hosts its own with
`Overlay.wrap`, spanning the window so the tooltip is not clipped to the widget that owns it. A test only reproduces this
by mirroring that topology: build the widget from `MaterialApp.builder`, never from `home:`.

A public top-level declaration that nothing outside its own file references is dead, and no lint catches it:
`unused_element` covers only private ones, and a barrel `export` keeps a dead file compiling and off every
"unused import" report. `test/lint/dead_file_test.dart` scans `lib/` for files whose declared names — types plus the
`final appPath = AppPath()` singletons next to them — appear nowhere else, counting generated code as a consumer (a
riverpod notifier is reached through its generated provider) and barrels as neither. Files publishing only extensions or
typedefs are skipped: those are reached through the types they attach to, never by name.

A `State.dispose()` override must not await before `super.dispose()`. `StatefulElement.unmount` calls `dispose()` and then
immediately asserts that `super.dispose()` already ran, so an `await` defers the call past the assert and every teardown
throws "`…State.dispose failed to call super.dispose.`" in debug and profile builds. Declare the override as `void
dispose()` and hand async teardown to `unawaited(...)`; `Future<void> dispose() async` compiles and is the shape that
invites the bug.

Use `ProviderContainer` directly for simple Riverpod provider tests. The generated Riverpod `update()` method takes a callback:

```dart
notifier.update((state) => newValue);
```

When testing freezed models with nested objects, always round-trip through `jsonEncode` and `jsonDecode`. Direct `fromJson(toJson())` fails for nested freezed types because `toJson()` stores child objects directly instead of maps.

For async widgets, put visual cleanup in `finally` when the action may throw. Focused widget tests should cover success,
failure, disposal, and any timer boundary that changes visible state.

## Commit Messages

Subjects follow Conventional Commits and are enforced by the `commit-msg` hook in `.pre-commit-config.yaml`, which runs
`tool/check_commit_msg.sh`:

```text
<type>[(scope)][!]: <description>
```

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Scope is optional and lower case; use a comma to list several, as in `fix(core,android)`.
- `!` before the colon marks a breaking change.
- Descriptions start in lower case, omit the trailing period, and keep the whole subject within 100 characters.
  Identifiers and acronyms keep their own casing, as in `fix(ui): AppBar text is truncated`.
- `Merge`/`Revert` subjects and `fixup!`/`squash!` commits are exempt.
- No `Co-authored-by` trailer crediting a coding agent, whatever that tool's own convention says. The history
  records who owns the change, not which tool typed it; human co-authors are still fine. The hook rejects the
  known agent identities.

Write what the change does, not that something changed: `perf(views): stop redoing per-frame work in build`, not
`Optimize more details`.

Install the hooks once with `pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg`.

### Changelog Trailers

`tool/changelog.dart` builds the user facing changelog from the commit history, so the trailers below are the copy that
ships to users. The subject stays the developer facing summary and is only the fallback.

```text
feat(profiles): support per-profile override script

Changelog: Per-profile override scripts
```

- `Changelog:` is the English entry. `Changelog: skip` drops the commit from the changelog entirely.
- The changelog is English only. Translation trailers were removed on purpose: they pushed release copy into the commit
  history, so any `Changelog-<locale>:` or `Breaking-<locale>:` now fails the hook. Translate after the fact if ever
  needed, not in the commit message.
- `Changelog-Type:` moves an entry into another group, for example to promote a `refactor` that users will notice. Valid
  values are `breaking`, `feat`, `fix`, `perf`, `revert`.
- `BREAKING CHANGE:` is required whenever the subject carries `!`, and its text becomes the breaking entry. A `!` commit
  therefore needs two lines of copy: the footer for the breaking entry and `Changelog:` for the normal one.

`feat`, `fix`, `perf`, `revert` and breaking commits are collected by default; every other type is dropped unless it
carries a `Changelog:` trailer. Commits missing a trailer reuse their subject, and the hook says so without blocking.

## Generated Code

Do not manually edit generated files under:

- `lib/l10n/l10n.dart`
- `lib/models/generated/`
- `lib/providers/generated/`
- `lib/database/generated/`
- `lib/l10n/intl/`

After schema, model, or provider changes, run build generation and include focused tests when behavior changes.

`lib/l10n/l10n.dart` is the one file that still imports `package:flutter/material.dart`.
`intl_utils` hardcodes that import in its own template, so regenerating rewrites it and
there is nothing to fix here; `test/lint/design_package_test.dart` exempts the generated
l10n paths for that reason. It is harmless because the file only needs `Locale`,
`BuildContext`, `Localizations` and `LocalizationsDelegate`, which the legacy library and
`material_ui` both re-export from the same `package:flutter/widgets.dart`. Everything a
human writes takes Material from `material_ui`; `cupertino_ui` is banned outright and
survives only as a transitive dependency of `material_ui`.

Strings live in `arb/intl_{en,zh_CN,ja,ru}.arb` — flat JSON, no `@` metadata. Add a key to all four, then regenerate with
`dart run intl_utils:generate`, which rewrites `lib/l10n/`. A key present in only some locales silently falls back to
English at runtime, so add the translation rather than leaving it out.

Some labels are not reached through the generated `AppLocalizations` getters at all. `Intl.message(<runtime string>)`
builds the key from an enum name or a stored string — `action_${HotAction.name}`, `${DynamicSchemeVariant.name}Scheme`,
`NavigationItem.description`. The analyzer sees nothing, and a failed lookup returns the key itself, so a stale key ships
as `routeMode_config` in the UI rather than throwing. `test/lint/dynamic_message_key_test.dart` expands those families
from the real enums and fails when a derived key is missing from any locale; every `Intl.message` site in `lib` must be
registered there, so a new dynamic key cannot be added without also declaring what builds it.
