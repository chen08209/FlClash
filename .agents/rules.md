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
message, which is what `globalState.safeRun` surfaces in the dialog, and the
throw stays catchable as an `Exception` and carries a stack trace. Assert on it
with `isA<MessageException>().having((e) => e.message, 'message', ...)`, not on a
raw string.

### Corner Radius

Rounded corners are superellipses (continuous corners) everywhere, never circular arcs; when a component offers
both, pick the superellipse. `test/lint/superellipse_corners_test.dart` fails on the circular APIs below in `lib/`. Use
the superellipse API at each layer:

- Shapes: `RoundedSuperellipseBorder` instead of `RoundedRectangleBorder`.
- Clips: `ClipRSuperellipse` instead of `ClipRRect`.
- Container decorations: `ShapeDecoration(shape: RoundedSuperellipseBorder(...))` instead of
  `BoxDecoration(borderRadius: ...)`; borders move to the shape's `side`, and a `Container` with
  `clipBehavior` still clips to the shape path.
- Canvas: `canvas.drawRSuperellipse(RSuperellipse.fromRectAndRadius(...))` instead of `drawRRect`.

Passing `BorderRadius.circular(x)` as the `borderRadius` argument of these APIs is expected — it only
carries the corner magnitude; the rendered geometry stays a superellipse.

Pills are no exception. `StadiumBorder` joins its round caps to the straight sides with a curvature jump, while
`AppShape.full`, a superellipse at full radius, blends them, and on a square it renders the exact circle, so it serves
circles too. The buttons of `prism_ui/lib/common_button.dart` default to `AppShape.full`, and `ButtonTheme.merge`
keeps what the ambient theme sets. `CircleBorder` and `BoxShape.circle` are fine for something that is always square.

APIs that accept only a `Radius` keep circular corners; supply the superellipse with an enclosing clip or shape where it
shows.

### Typography

Text sizes follow Apple's iOS Dynamic Type scale at its default size, on every platform. `AppTextStyle` in
`prism_ui/lib/typography.dart` holds its eleven styles, `largeTitle` to `caption2`, with Apple's leading and weights, plus two
steps the scale lacks: `display` for a dashboard figure and `pageTitle` for an app bar. Take one with
`AppTextStyle.body.of(context)`, pass `emphasized: true` for the scale's emphasized weight (bold for the titles,
semibold for the rest), and change color or family with `copyWith`; a weight is either regular or emphasized. Text
sized to the shape it marks, such as a letter scaled to its icon, comes from `AppTextStyle.custom`. The dashboard's
roles (`DashboardText` in `lib/views/dashboard/style.dart`) are built on the same types.

App bar titles sit at the leading edge in `pageTitle` on a root page and on any desktop page, at the leading edge in
`headline` on a pushed page in the mobile view, and in the bar's centre in `headline` on a bottom sheet. A title widget,
such as the editor's name field, stays at the leading edge. Past a back button a title keeps the bar's action inset
clear of the button on either side.

`test/lint/typography_test.dart` fails on `textTheme` anywhere in `lib/` or `prism_ui` but `typography.dart`, and on `fontSize:` or
`fontWeight:` in the app, except in the code editor, whose text follows the editor font-size setting.

### Text Field Suggestions

On Android, Flutter maps `enableSuggestions: false` to the visible-password input type, not only to "no suggestions"
(`TextInputPlugin.inputTypeFromTextInputType` in the engine). Input methods then treat the field as a password: no
clipboard panel, no Chinese layouts, and on some systems a secure keyboard. With the app's clipboard permission denied,
that leaves no way to paste a link at all. Only the secret fields, `SecretTextFormField` and `FormRowSecretTextField`,
ask for a password keyboard; a link, key, rule or regex field that should not be corrected sets `autocorrect: false`
alone. `test/lint/text_field_suggestions_test.dart` fails on `enableSuggestions: false` or
`TextInputType.visiblePassword` anywhere else in `lib/`.

### Text Selection Menu

Selected text opens `TextSelectionMenu`, never the toolbar Flutter draws per platform; `TextField`, `TextFormField`,
`SelectableText` and `SelectionArea` default to it (`prism_ui/lib/text_selection_menu.dart`). By touch that is
`EditMenuRoute` (`prism_ui/lib/edit_menu.dart`), iOS 27's capsule of labels beside the selection, unfolding from
a chevron into a card when they do not fit; by pointer it is a `PopupMenu`. The editor opens the same two. The menu
keeps to cut, copy, paste, select and select all, and offers select all whenever some text is left unselected, which
iOS drops. Handles, selection color, caret and `TextLoupe` follow the same measurements. Gestures stay each platform's
own: a long press on Android selects a word.

### Length Units

Flutter lengths are logical pixels, the unit Android calls dp. Comments, test names, docs and reports give them in dp,
as in `48 dp`, never px: a reader takes px for physical pixels and misjudges the size by the device pixel ratio. Write
"physical pixel" in full where the code really works in them, as the hairline snapping in
`prism_ui/lib/list_row_separator.dart` and the Win32 frame metrics in `plugins/window` do; raster image sizes in
`tool/` and CSS under `site/` keep px. `test/lint/length_unit_test.dart` fails on a number followed by px in `lib/`
and `test/`.

CI gates formatting: `dart format --output=none --set-exit-if-changed lib test
tool plugins setup.dart` runs before `flutter analyze`.

These directories are excluded from analysis:

- `build/**`
- `lib/l10n/intl/**`
- `lib/**/generated/**`
- `plugins/**`
- the platform runner directories: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`

## Comments

Comments are part of the code and some of them are load-bearing. What this repository limits is the useless and the
frequent. Every comment that restates the code devalues the ones carrying real information, until readers skim past all
of them — a file with three comments that matter is more readable than one with thirty.

The two halves are enforced differently, because only one of them can be counted. Whether a comment is useless is a
judgment, and it lives in the rules below and in review. Whether comments are too frequent is arithmetic, and
`comment-density` measures it.

### What a Comment Must Earn

- Write one when it carries something the code cannot: a non-obvious constraint, an upstream or platform behavior being
  worked around, a reason the next reader would otherwise get wrong, a coupling to a value defined somewhere else.
- Never restate what the code already says. If the comment and the line below it convey the same thing, the comment is
  noise.
- Never narrate. Not what this diff changed, not what the code used to be, not the order you did things in. Version
  history belongs in git and change rationale belongs in the commit message.
- Never annotate line by line or statement by statement. A block that seems to need a comment per step needs better
  names or a smaller decomposition instead — reach for structure before prose.
- Prefer encoding the intent in structure and naming. A named mixin, type, or method that makes the invariant hard to
  break beats a paragraph asking the next reader not to break it.
- Delete commented-out code, stale version notes, and comments that only restate the code, whenever you edit the file
  that contains them. This does not need approval.
- These are not comments and are exempt from every rule here, including the density count: analyzer and linter
  directives (`// ignore:`, `// ignore_for_file:`, `// coverage:ignore`), license and copyright headers,
  code-generation markers, and comments inside vendored upstream code such as `prism_ui/lib/open_container.dart`.

### Density

`tool/hooks/comment_density.sh` fails a file whose added lines are more than 5% standalone comment lines, ignoring
diffs under 20 added lines so small edits are never caught. The number is calibrated on this repository's own history:
healthy changes sit at or under 3.6%, while the core fix that prompted the gate ran 22.4%.

It is a ceiling on frequency, not a target to fill. Do not read `core/`'s inherited mihomo density as a quota either —
it is forked upstream code, not a house style.

Three gates run the same script, and they do not have equal force. The `PostToolUse` hooks in `.claude/settings.json`
and `.codex/config.toml` run after the tool and hand offending lines back as feedback; neither can undo the completed
write. The `comment-density` pre-commit hook fails the commit, and it is the only hard gate that covers every tool.
Behavior is pinned by `tool/hooks/comment_density_test.sh`, which CI runs through `tool/hooks/test.sh`.

When a change genuinely warrants more, raise the ceiling for that run rather than working around it:
`COMMENT_DENSITY_MAX=20 git commit`, or `SKIP=comment-density git commit` to step past it entirely.

### Where Knowledge Belongs

A comment is one of three destinations, and often the weakest. Pick by where the constraint would be violated, not by
how important it feels.

- **Assertable behavior goes in a test.** A test is the only form that cannot drift, because it fails when the behavior
  it describes is broken. Prefer it over both a comment and a document whenever the fact can be checked in code.
- **Repository-wide defaults, ownership, and invariants go in `.agents/*.md` or a `.agents/skills/*/SKILL.md`.** They
  are violated from many files, so they must reach every future agent at session start. A comment in one file cannot do
  that.
- **A fact that is true only at one call site, and is not visible from that call site, is the one thing a comment does
  better than a test or a document.** Its value is being in the reader's line of sight at the moment of the edit.
  `lib/common/constant.dart` carries one: the delay-test concurrency cap is bound to `delayTestConcurrency` in
  `core/delay.go`, and whoever changes that number must see the constraint on the same screen. This is the case a
  comment is for; the bar is that no test and no `.agents/` entry could hold the fact instead.

Both failure directions are real. Moving a local constraint into `.agents/` hides it from the person editing the line;
leaving a repo-wide policy as a comment reaches only the reader of that one file.

## Core API Safety

- `core/Clash.Meta` is a fork of mihomo, and changes to it are budgeted for features, not repairs. Fixing a bug there is
  low priority even when the bug is real and the fix is small: every patch is one more thing to carry across an upstream
  rebase. Solve it on the FlClash side of the boundary and note the mihomo behaviour you are working around. Reach into
  the submodule only for a feature that has nowhere else to live, or when the problem is one the FlClash patches
  themselves introduced — and say which of the two it is in the commit message.
- Do not expose direct filesystem deletion APIs through Core or helper IPC; use
  a scope-specific cleanup API instead.
- The desktop IPC socket in `plugins/rust_api` admits a Unix peer only when its effective uid is the app's own or root:
  the socket lives in `/tmp`, and the Core connects as root whenever it runs setuid for TUN or under the Linux Helper.
  A launch mode that runs the Core as any other user has to widen `admit` in `ipc/access.rs`, and Windows
  keeps its identity check on the Dart side, which compares the named-pipe peer PID with the Core it launched.
- Keep the shared `CoreMethodCall`/`CoreMethodResponse` JSON envelope structurally identical across Dart, Go, the
  gomobile binding, and desktop IPC. Do not double-encode `arguments`, `result`, or event batches. A response whose
  `file` is set was spilled to disk; a transport resolves it with `resolveSpilledResponse` before reading `result`.
- `core/message.go` carries three event queues, and the split is load-bearing: state (loaded, geo-update,
  route-changed), priority (every other event), and bulk (log, request, DNS). Priority and bulk evict their own oldest
  entry under backpressure, except DNS, which enters the bulk queue through `enqueueState` so a lookup burst cannot push
  out the request events the connection list is built from; state uses `enqueueState`, which never evicts, because a dropped `geoUpdate{updating:false}` leaves `isUpdatingProvider` stuck at true in the UI until
  `UpdatingAction` sweeps it as stale minutes later. Do not merge the tiers or give state eviction semantics. `enqueueState` drops silently on a full
  queue and must stay that way: reaching it means the host stopped reading, which `logDeliveryError` already reports,
  and reporting it from the message layer feeds the same batcher.
- Every method of the callback interfaces in `core/mobile` (`TunHandler`, `ResultHandler`) returns an `error`. gobind
  clears a Java exception and hands it to Go only for a method that declares one; otherwise the exception stays pending
  and the next JNI call on that thread aborts the process, so a throw in `protect`/`resolveUid`/`resolvePackage`/
  `onResult` would crash unrelated code. `core/mobile` turns the error into the answer the system gives when it will not
  help: `false`, `-1`, or an empty package name.
- `TunHandler`'s hooks in `core/lib.go` check `callbacks` under `th.mu` before every call. `clear` drops the callbacks
  while connections may still be resolving, and a call through the nil interface panics on a mihomo goroutine, outside
  every recovery.
- The Android bridge resolves an owner in two steps — `ResolveUid` then `ResolvePackage` — because mihomo fills
  `metadata.Uid` from a procfs lookup that Android Q closed off. Collapsing them back into one call that returns only a
  package name is what left every connection reporting uid 0, so `UID` rules matched nothing.
- The desktop delivery path in `core/server.go` must not report failures through `logError`. A log event is published to
  the log subscriber, batched, and handed back to `send`, so a send failure reported that way feeds itself; use
  `logDeliveryError`, which writes to stderr and latches until a frame gets through or the next connection is installed.
  A write that fails without putting a byte on the wire — host backpressure hitting `ipcWriteTimeout`, or a payload above
  `maxIPCFrameSize` — drops that one frame and keeps the connection: the stream is still framed correctly, and tearing it
  down here ends the read loop, and with it the Core process. A half-written frame whose write merely timed out is
  resumed for as long as the stall lasts: Windows Modern Standby suspends the app while the Helper's Core keeps running,
  so the host can stop draining for hours and still come back, and go-winio reports the expiry as its own `ErrTimeout`
  rather than `os.ErrDeadlineExceeded`, which is why `send` checks `Timeout()`. The wait has no cap on purpose, and
  `send` holds `writeMu` throughout, so every other frame — method responses and the single batcher goroutine behind
  the event queues — waits behind the stalled one. Memory is bounded by the queues; what gives is delivery: the state
  queue fills and `enqueueState` starts dropping, which is the case the `UpdatingAction` sweep above exists for. Nothing
  on the Dart side restarts the Core over a stall: `CoreRpcClient` times each pending request out on its own and hands
  the caller `null` (a `no_response` exception for message methods), and the sweep clears core-scope updating state
  minutes later. Only a half-written frame that fails outright desynchronizes the stream, and that is the one case
  `send` closes on.
- Core method handlers are plain functions that return their answer, registered in the `methodHandlers` table in
  `core/method.go` through the adapter matching their shape. `dispatchMethodCall` already runs every call on its own
  goroutine and `handleMethodCall` turns a panic into an `internal_error` answer, so a handler blocks for as long as its
  work takes and never spawns a goroutine just to answer. Work that outlives the answer goes through `safeGo`, which
  recovers; a bare `go` puts a panic outside every recovery and kills the process, which on Android is the whole
  application. The exported Android entry points in `core/lib.go` do not reach `handleMethodCall`, so each one carries
  its own recovery.
- A handler fails by returning an `error`: a `*MethodError` travels as it is and anything else under `core_error`. The
  exception is `withMessage`, for the methods whose result the host reads as a message that is empty on success
  (`_invokeMessage` in `lib/core/interface.dart`): there a plain error becomes that message and only a `*MethodError`
  fails the call. Moving a method between the two changes what Dart receives.
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
- Queueing for the delay-test semaphore and probing the node each get the full timeout in `handleTestDelay`. With one
  shared deadline, a node that waited behind a saturated semaphore reached `URLTest` with almost nothing left, so a bulk
  test of a large subscription reported whatever sat at the back of the queue as unreachable.
- A delay test that the Core does not answer is a fault of the Core or the channel, never a verdict on the proxy:
  `handleTestDelay` returns within its two timeouts on every path. `testDelay` therefore throws instead of answering a
  `-1` delay, and `ProxiesAction` leaves the last measurement in place and abandons the rest of the run. Writing a
  timeout there is what made a reachable node read as unreachable whenever the host deadline beat the Core's.
- Delay-test progress lives in `pendingDelayTestsProvider`, not as a sentinel value in `DelayDataSource`. A delay of 0
  used to mean "testing", which let a result and the state of a test overwrite each other and left cards spinning
  forever when the Core restarted. The run owns its keys and releases them in a `finally`, so nothing depends on a
  reply arriving; core status leaving `connected` cancels every run in flight.
- Some constants in `lib/common/constant.dart` mirror the Core and move with it. `delayTimedOutValue` is the `-1` that
  `core/delay.go` reports for a delay test that ran out of time; any other negative value failed outright.
  `downloadTimeoutDuration` matches mihomo's `resource.DefaultHttpTimeout`, which bounds the Core's provider downloads
  end to end. `shareLinkSchemes` are the schemes mihomo's `ConvertsV2Ray` reads, less http(s), which is a subscription.
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
- No file in `core/` uses cgo: the only C in the Android library is the glue gobind generates during `gomobile bind`.
  Android-only files take `//go:build android` and desktop-only ones `!android`, so `GOOS=android CGO_ENABLED=0 go vet`
  checks the Android side without an NDK. Keep it that way; cgo in `core/` puts the NDK back in front of that vet and of
  `go build ./...` on every developer machine.

## Lifecycle Rules

- Crash recovery is owned by `BootGuard` (`lib/common/boot_guard.dart`), and the signal it acts on is the persisted
  `BootRecord`, never a crash reporter. The record is stamped `starting` before `startCore` and `running` once
  `_initApp` finishes, so only a launch that died before reaching `running` is a failed launch — a crash after hours of
  runtime, or a process the system reclaimed in the background, is not one. `ApplicationExitInfo` can only veto a
  failure (user stop, low memory, signal, package change), never create one, and its timestamp is consumed through
  `handledExitAt` so the same exit cannot be counted twice.
- `BootGuard` is an Android-only mechanism and gates itself: on every other platform `evaluate`, `markRunning` and
  `markClosed` return without touching preferences. The desktop has no `ApplicationExitInfo` equivalent to attribute an
  exit, so a bare sentinel there would read a window closed on the disclaimer dialog, or a session ended by shutdown,
  as a failed launch. Keep the platform check inside the guard; callers in `bootstrap.dart` and `SystemAction` stay
  unconditional.
- Recovery is graded: the first failed launch only skips `initStatus`, and `currentProfileId` is cleared only from
  `crashRecoveryClearThreshold` consecutive failures on. Do not let a single interrupted launch write to the config.
- Desktop process ownership belongs to `DesktopCoreLifecycle`; do not start/kill `FlClashCore` from providers, widgets,
  managers, or ad hoc exit callbacks. Acquire and release it through a `CoreProcessLease`.
- `CoreController.close()` and platform `close()` implementations are terminal and idempotent. Application shutdown must
  stay centralized in `SystemAction`/`SystemExitCoordinator`.
- Android start/stop MethodChannel calls are optimistic UI commands. Keep latest-wins arbitration in native
  `ServiceState`; do not add a Flutter completion callback that creates a second lifecycle owner. What flows back is
  the revision-stamped `stopped` report, which Flutter mirrors with `setRunning(false)` and never answers with a
  decision of its own.
- Android `RunState` is derived in `ServiceStateMachine.publish`; do not assign it from a transition step, and do not
  add a second "is it running" field beside `ServiceController.runtime`. Every divergence between the tile and the
  service so far came from a copy that one path forgot to update.
- Android service callbacks are not automatically user intent. Route explicit Quick Settings, Always-on VPN, and revoke
  actions through `ServiceState` and keep `ServiceController` as the sole binding/run-time owner.
- Every `BroadcastReceiver.goAsync()` path must finish its `PendingResult` exactly once. A watchdog may release the
  broadcast lease, but must not cancel, reverse, or otherwise redefine the service operation.
- Anything that probes through the outbound route is a `RoutedProbe` judged against `routeTrackerProvider` (Route
  Consistency in `.agents/architecture.md`); the Core stamps every answer with its counters and hits and checks the
  hits again on a move, so do not add a change signal, a trigger counter, or a `coreStatusProvider` watch of your
  own.
- Presentation smoothing such as `CoreStatusButton`'s connecting hold must remain local display state. It must not delay or
  overwrite `coreStatusProvider`, and a real failure must bypass/cancel the hold immediately.
- Safe mode (`SAFE_MODE` define, see the safe mode section of `.agents/architecture.md`) is consulted by each host
  integration at its owner, never by rewriting the user's settings. `safeModeBuild` is for handles created before the
  container exists; everything else reads `safeModeProvider` so a test can override it.
- `Tray.hide()` is idempotent on all three desktop platforms and returns native state to "`show` was never called".
  `AppTray.shutdown()` latches, so no later `update()`/`updateTitle()` can resurrect the icon once shutdown begins.
  Keep it that way; a resurrected icon outlives `exit(0)` as a Windows ghost icon, because `setPreventClose(true)`
  means `WM_DESTROY` never runs.
- The `tray` plugin owns call ordering, idempotency, serialization, and unchanged-payload suppression. Application code
  declares desired state through one `Tray.show(TraySpec)` call and must not add platform branches to work around
  ordering. Platform branches in `lib/common/tray.dart` are only for deliberate product differences (macOS speed title
  and group submenus); query `Tray.instance.capabilities` for ability differences.
- Every native `show` returns whether the tray accepted the payload, and reports `false` instead of showing a broken
  icon. `Tray` caches the payload signature only on `true`, so a rejected `show` is retried by the next update rather
  than suppressed until restart. Windows accepts a payload the shell refused, as at sign-in, and retries the icon
  natively until it lands, so `Tray` still treats it as visible and `hide` reaches native to delete an add that may
  have landed. Any test that mocks the `tray` channel must return `true` from `show`.
- Reading the Wi-Fi SSID is opt-in work, not ambient state. `ConnectivityManager` reads it only while `excludeSSIDs` is
  non-empty, because that list is its only consumer through `suspendProvider`, and the read costs a blocking platform
  call plus a location permission on Android and macOS. A second consumer must widen that gate, not drop it.
- On Android the `wifi_ssid` permission is only `granted` once `ACCESS_BACKGROUND_LOCATION` is held too (Q+). Fine
  location alone reads the SSID in the foreground but returns `UNKNOWN_SSID` once the app is backgrounded, which is
  where on-demand spends most of its time. `getSsid` itself only needs fine location, so the split stays inside the
  plugin.
- No `wifi_ssid` implementation may answer `getSsid` on the platform thread. Android resolves through a network callback
  with a timeout, Linux through `g_task_run_in_thread`, and macOS through `ssidQueue` after checking the location
  authorization, because CoreWLAN reaches `wifid` over XPC and a wedged daemon would freeze the window. Windows is the
  outstanding exception: `WlanQueryInterface` still runs inline, since replying off-thread there needs a window-message
  hop that the plugin API does not provide.
- Android's `system` nameserver resolves only through the DNS `NetworkObserver` reports; mihomo builds it with no
  fallback, so with no list every lookup through it fails at once. The Core tests delays and updates providers with no
  service running, so the observer lives for the process from the first `init` or native `quickSetup` and never sends
  an empty list on a service stop.
- The delayed DNS re-check `NetworkObserver.onLosing` posts is deliberately left un-deduplicated. The runnable
  re-reads `networkInfos` and does nothing when `onLost` already dropped the network, and `updateDns` calls into the
  Core only when the resolved list or the preferred network changed, so a network that reports `onLosing` repeatedly
  costs two comparisons per event. Holding the pending `Runnable` to `removeCallbacks` it changes no behaviour and adds
  state that has to stay in sync with the map.

## UI Frame Budget

A frame is 16 ms at 60 Hz and 8 ms at 120 Hz, and on Android the UI isolate runs on the platform's main thread. The
bar for a push, a pop, a sheet, a menu or a tab switch is no dropped frame while it moves and at most one as it
starts. From the press to the first frame that moves, one vsync may be missed: that is where a page's first build and
the snapshot of the page it covers land, and a frame late there delays the motion rather than breaking it, provided
the still frames are split so that only one runs over. From the first moving frame until the last bar item has faded
in after the route settles, every frame stays within 8 ms, since one over shows as a skipped step at the spring's
fastest; that holds for whatever else moves meanwhile, such as the menu a push was opened from closing. Most
frames this app has dropped were not spent computing: a page built every row it had, rebuilt the whole screen for
one edited item, repainted a route for one spinner, blurred offscreen per tile, or received its data halfway
through its push. Check a UI change against these before moving anything to an isolate:

- Build what is on screen. A list that grows with the user's data is a lazy sliver (`SliverPrismList`,
  `generateSliverSection` in `prism_ui/lib/list.dart`, `ListView.custom` with an `itemExtentBuilder` for a
  strip of chips), never `ListView(children:)`, a `Column`, `generateSection`, or a `SliverMainAxisGroup` whose
  children all build at once. A settings page of a fixed 15 to 30 rows is bounded and stays eager.
- Lazy lists go through `prism_ui/lib/prism_list.dart` (`PrismListView`, `SliverPrismList`, and the
  reorderable pair): Flutter's `ListView.builder` and `SliverList` lay out every row a scrollbar drag passes, about
  250 rows a frame on a 5000-row list, where these place the skipped rows at `estimatedItemExtent`. Give rows of one
  fixed height `itemExtent`, and a gap between rows `gap`, not a separator. `test/lint/prism_list_test.dart` holds
  the few short lists allowed to stay on Flutter's.
- Rebuild what changed. Editing one item rebuilds that row: a row whose inputs are equal returns its last subtree
  through `MemoBuilder` (`prism_ui/lib/builder.dart`), with everything its builder reads from outside its own
  context in `inputs`. A value one widget shows, such as the current group or a test in progress, is watched by that
  widget through a narrower provider or a `ValueNotifier`, not by the page. Content laid out inside a sheet takes
  `WidthBuilder`, not `LayoutBuilder`, since a dragged sheet lays it out at every height.
- Repaint what moved. A rebuild under a `LayoutBuilder` repaints the nearest repaint boundary (Rebuild Scopes in
  `.agents/architecture.md`), so anything that animates for long, such as a spinner, a live value, or a card in a grid
  where any card animates, sits in a `RepaintBoundary` of its own.
- Keep the raster cheap. Impeller pays each offscreen pass again every frame and has no raster cache. A shadow is drawn
  with `drawRSuperellipse` (`.agents/surfaces.md`); a blur repeated per tile is a `MaskFilter.blur` on the shape, not an
  `ImageFilter.blur` layer; `Opacity` over a subtree, a translucent glyph, and an `SvgPicture` with a `colorFilter` each
  cost a layer. A page that scales as a whole is drawn from a `SnapshotWidget` while it scales,
  since Impeller rasterizes text again at every step of a scale.
- Keep transitions clear. Page Arrival in `.agents/architecture.md` is binding: a page holds its push until its first
  content is in (`NullStatusSwitcher`, `ArrivalHold`), a feed holds its refreshes while its route moves, and the editor
  mounts once its route settles. A route's transition wrapper keeps one structure for every state: switching it moves
  the page under a `GlobalKey`, which rebuilds every element with an inherited dependency.
- Split a first screen that overruns a frame. The frames a push holds still are frames too: a first screen that takes
  more than 8 ms to build and lay out is built in parts across them, each part one frame, and the push holds for the
  last (`ArrivalHold`). `CustomProfileView` builds its proxy groups a frame after its overview this way; one frame of
  both took 9 to 15 ms on a phone while the menu it was opened from closed.
- Build no rows ahead while anything moves. A list on a page coming in takes its cache extent from
  `ArrivalCacheExtentMixin` or `ArrivalCacheExtentBuilder`: none until its route settles and no ticker runs, since the
  rows built ahead at the moment the route settles overran a frame of the bar items still fading in.
- Put work off until nothing animates with `whenNothingAnimates` (`prism_ui/lib/route_motion_hold.dart`), never
  with `scheduleTask(..., Priority.idle)`: while a ticker runs, the scheduler posts that task again on every turn of
  the event loop and spins the UI isolate.
- Stop what nobody sees. Polls and tickers follow Background Work in `.agents/architecture.md`.
- Decide on measurements taken at the largest data the app expects, with the `ui-performance` skill. Rebuild, repaint,
  query and capture counts are deterministic and can be pinned in a widget test, as
  `test/widgets/scaffold_repaint_test.dart` and `test/widgets/route_transition_repaint_test.dart` do; `flutter test`
  timings are JIT and only rank variants against each other, so a case near the budget is settled on a 120 Hz phone:
  missed vsyncs from `atrace`, release builds of the base and the change installed in turn, and frame times from a
  profile build to find the cause. A missed vsync before the page moves counts against the one allowed at the start,
  and any after it fails the bar. Accessibility services, which many users run, make every frame that changes a
  route spend 5 to 7 ms on semantics; measure with the phone as it is used. A change that leaves missed vsyncs within
  noise is reverted, however sound its reasoning. No gate checks this section.

### UI Isolate Work

Everything the UI isolate runs synchronously shares a frame with build, layout and paint. Computation may take as long
as it needs anywhere else, so this part is about where work runs, not how much of it there is.

- Work that grows with the user's data (profiles, rules, proxies, groups, dialers, icons, connections) and can take
  more than about 8 ms on the largest data the app expects runs in an isolate, through `compute` or `Isolate.run`.
  Thousands of rules or proxies and hundreds of groups are in that range. `makeRealProfileTask` in
  `lib/common/task.dart` and the backup tasks in `lib/common/backup.dart` are the existing shape.
- Make the algorithm linear or cached first. Work superlinear in that data, such as a walk of the whole graph per
  item, a scan of every group per group, or a list copy per inserted element, is a defect on any isolate; moving it
  only hides the cost until the data outgrows the move.
- Sending data to an isolate copies it on the sending isolate, so hand the task the smallest input it reads. A value
  the UI reads synchronously, such as a sync provider watched in `build`, becomes an async provider with a loading
  state rather than a blocking call.
- drift runs SQL on its own isolate but maps rows into models on the caller's, so a watched query over a large table
  costs the UI isolate on every emission, and any write to that table makes it emit again.
- Bounded work stays where it is: a provider recompute that reuses a cache, a single-item update, a search filter over
  a list sized for scrolling. Moving it costs more than it saves: an isolate is spawned and its input copied on the
  UI isolate, and drift's `computeWithDatabase` over 20,000 rules blocked the UI isolate as long as mapping them in place.
- Reach for Rust when Dart is measurably not enough. If a computation is still too slow for its use once it is linear
  and off the UI isolate, costs too much to copy across isolates, or needs a codec or parser Dart has no solid package
  for, reuse `plugins/rust_api` (`rust/src/api/`, regenerated as `.agents/commands.md` says, tested with `cargo test`)
  before adding a Dart port or a pub package that wraps native code of its own: the library already ships on every
  platform. A Dart version that meets its budget at the largest data stays in Dart, since a bridge call and a crate
  have a cost of their own, and `flutter test` needs the Rust library built to reach it. Data the Core produces and
  already transforms, such as decompressing a captured body, stays in Go.
- An editor document stays in the Rust rope. Open a file for `EditorPage` with `openEditorFile` rather than reading it
  into a string, and read an edited one through `EditorContent`; a profile can be tens of megabytes.

## Testing Rules

The `core/` directory is excluded from automated coverage accounting. Do not add coverage instrumentation or coverage
collection for code under `core/`. CI still runs `CGO_ENABLED=0 go test .` and `go vet .` to compile/check the Go wrapper,
plus a `GOOS=android` vet that covers the `android` files the first two exclude; verify cross-language
protocol behavior through shared Dart contract tests under `test/core/` and native platform build checks.

A Go test in `core/` that reaches `sendMessage` — directly, or through `handleStartLog` or `updater.GeoUpdateHook` —
leaves events in the process-wide batcher, which flushes them up to `messageBatchInterval` later into whichever
connection `captureFrames` has installed by then. Either keep the event out of the batcher or end the test with
`settleMessageBatcher`. That batcher runs for the whole test binary and reads `conn` under `connMu`, so install a test
connection with `swapConn`; a bare assignment races every event it happens to be delivering, and `go test -race` catches
it in an unrelated test.

Register fallback values for freezed params used with `any()` matchers.

`tool/check_coverage.dart` enforces a total floor passed by CI plus per-group floors declared in `_groupFloors`. Raise a
group's floor when new tests lift it; do not lower one to make a run pass.

Every measured group needs a floor. A group the report measures but `_groupFloors` does not declare fails the run, so
adding a top-level directory under `lib/` means adding its floor in the same change. Set a new floor at or just below
the coverage the directory actually has; the point is to stop a slide, not to backfill tests before the directory can
land.

Prefer `coreHandlerProvider.overrideWithValue(CoreController.scoped(fake))` over `CoreController.test(fake)` in new and
touched tests. `CoreController.test` claims the process-wide singleton, which makes a global read and a provider read
resolve to the same fake, so it cannot fail on a call site that still reaches for the global. A test that does claim
the singleton calls `CoreController.resetInstance()` in `tearDown`. It also only reaches the global `coreController`
when nothing has read it yet: that is a top-level `final`, bound to whichever instance existed at the first read, which
in a shared isolate is another file's.

### Shared Test Isolate

`tool/test.dart` imports many test files into one entrypoint, so process-wide state outlives the file that set it, and
every file's `main()` runs before any test of the entrypoint does. Keep `main()` to declarations and
`TestWidgetsFlutterBinding.ensureInitialized()`: a mock installed there is replaced by the next file's before a test
sees it. Set up what the tests need in `setUp` or `setUpAll` instead, from the helpers that rebind the singletons:

- `appPath` resolves its directories once per process. Point them at a test's directory with `await useAppPaths(dir)`
  from `test/helpers/app_paths.dart`, not with a `PathProviderPlatform` fake, which only works while nothing has asked
  `appPath` yet.
- `preferences` opens its store once per process. Use `await mockPreferences(values)` from
  `test/helpers/preferences.dart` rather than `SharedPreferences.setMockInitialValues` alone, which leaves `preferences`
  on the store it already opened.

Both cache the resolved value, not the future that produced it. A future completed in one test's fake-async zone runs
its listeners in that zone, so a later test that awaits it never resumes. Await the helpers outside `testWidgets`
bodies for the same reason.

A test that only passes in a fresh isolate is leaning on a global it did not set up: `database_test.dart` once caught
its write failures only because `currentAppLocalizations` threw before anything had loaded them. The script reruns such
a file alone so it cannot fail the run, and lists it; fix it where it reads the global.

Construct the Android lib handler with `CoreLib.scoped(fakeService)`. The `service` global is gated on `Platform.isAndroid`
and is therefore null on every test host, so a `CoreLib()` built from it silently takes the null-service fallback on every
path. `CoreLib.scoped` binds an explicit `Service` instead; reset the singleton with `CoreLib.resetInstance()` in `tearDown`.

Three globals in `lib/common` reach real host state and carry a `@visibleForTesting` seam to stand in front of it:
`AutoLaunch.launcher`, `listNetworkInterfaces` and `LinkManager.uriLinkStream`. Replace the launcher in particular — every
`enable`/`disable`/`isEnabled` writes the actual autostart entry (a LaunchAgents plist, a `.desktop` file or a registry
key), so a test that skips the seam registers the test binary on the machine that ran it. `updateStatus` returns early
under `kDebugMode`, which is always true beneath `flutter test`, so its remaining branches cannot be reached from a test
at all; `test/common/launch_test.dart` pins the early return instead.

`pumpAndSettle` never returns on a page holding `EditorView` (what `EditorPage` embeds): the code editor blinks its
caret forever, so frames keep being scheduled. Pump explicitly instead. `encodeYamlTask` and its neighbours in
`common/task.dart` hand work to a real isolate through `compute`, which only runs outside the fake-async zone, so a test
awaiting one needs `tester.runAsync(...)` between the pumps.

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
non-macOS host, so a test mounting it needs `TestApp` for `AppLocalizations` and a `window` channel mock that
answers `isMaximized`/`isAlwaysOnTop` with a bool.

Auto-dispose providers need a container-level hold before a test reads them back. `proxyGroupProvider`, `ruleProvider`,
`itemsProvider` and friends mix in `AutoDisposeNotifierMixin`, so a `container.read` that no widget is currently watching
rebuilds the provider from its override and silently discards whatever the code under test wrote. Add
`container.listen(theProvider, (_, _) {})` in the harness, as `test/providers/action_test.dart` does for `scriptsProvider`.

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
Everything `buildManagerStack` wraps around `PrismApp.builder`'s child sits *above* the app Navigator and therefore
above the only Overlay in the tree. A manager that renders a tooltip — `WindowHeaderLayout` and its caption buttons are
the case that broke Windows while macOS, which renders a bare title there, stayed clean — hosts its own with
`Overlay.wrap`, spanning the window so the tooltip is not clipped to the widget that owns it. A test only reproduces this
by mirroring that topology: build the widget from the app's `builder`, never from `home:`.

A public top-level declaration that nothing outside its own file references is dead, and no lint catches it:
`unused_element` covers only private ones, and a barrel `export` keeps a dead file compiling and off every
"unused import" report. `test/lint/dead_file_test.dart` scans `lib/` for files whose declared names — types plus the
`final appPath = AppPath()` singletons next to them — appear nowhere else, counting generated code as a consumer (a
riverpod notifier is reached through its generated provider) and barrels as neither. Files publishing only extensions or
typedefs are skipped: those are reached through the types they attach to, never by name.

`Scaffold` runs its body under the system bar at the foot of the window, as Android's edge-to-edge guidance
asks, and only the end of the content clears it. A three-button bar is no exception: `ThemeManager` leaves it
Android's translucent scrim (`systemNavigationBarContrastEnforced`). Telling the two apart by the side back-swipe
zones Flutter reports reserved a gesture handle again on a real phone, so no page asks which bar it has. A scroll view
ends, and anything fixed at the foot of a body stands, `context.bottomInset` above the edge: `BottomInsetScope` (the
home dock, a docked search) plus the system bar `MediaQuery` still carries. The home shell takes the system bar out of
`MediaQuery` for its tabs because the dock's inset already counts it. A bare `BottomInsetScope.of` leaves the system
bar out, so code outside `prism_ui` never reads it. The scaffold adds its docked search to the scope around its body, so a page with a `searchState` reads
`context.bottomInset` below the scaffold, inside `body: Builder(builder: (context) => ...)`; read with the context the
scaffold is built from, it leaves the end of the content under the search field.
`test/lint/scaffold_bottom_inset_test.dart` enforces both by scanning `lib/`.

Every reorderable list builds its drag proxy with `commonProxyDecorator`, which tells `DecorationListItem` it is lifted:
the row drops its separator and rounds from its corners in the run to a card of its own as it lifts, and back as it
drops. A list without it lifts a middle row with square edges. `test/lint/reorder_proxy_decorator_test.dart` enforces
this by scanning `lib/`.

A `State.dispose()` override must not await before `super.dispose()`. `StatefulElement.unmount` calls `dispose()` and then
immediately asserts that `super.dispose()` already ran, so an `await` defers the call past the assert and every teardown
throws "`…State.dispose failed to call super.dispose.`" in debug and profile builds. Declare the override as `void
dispose()` and hand async teardown to `unawaited(...)`; `Future<void> dispose() async` compiles and is the shape that
invites the bug.

Use `ProviderContainer` directly for simple Riverpod provider tests, released with `addTearDown(container.dispose)`.
Assert against the provider's generated public API, not its implementation, re-read source defaults before asserting
them, and wait on provider futures or state changes rather than fixed sleeps. The generated Riverpod `update()` method
takes a callback:

```dart
notifier.update((state) => newValue);
```

When testing freezed models with nested objects, always round-trip through `jsonEncode` and `jsonDecode`. Direct `fromJson(toJson())` fails for nested freezed types because `toJson()` stores child objects directly instead of maps.

For async widgets, put visual cleanup in `finally` when the action may throw. Focused widget tests should cover success,
failure, disposal, and any timer boundary that changes visible state.

## Running the App Locally

- An agent starts FlClash on the host only as a safe mode build (`--dart-define=SAFE_MODE=true`, see
  `.agents/commands.md`). A normal build takes over the host network, so the user runs it, never the agent.
- Never end a FlClash process the agent did not start, and never kill by name (`pkill`, `killall`, a pattern on the
  executable path): the user's own instance matches too. Record the pid of every process you launch, check with
  `ps -o pid,command -p <pid>` that its executable is your own build output, and end only that pid.
- Only a macOS or Android debug build has its own data directory; every other build shares the installed app's data
  directory and single-instance lock, so it cannot start while the user's instance runs. `.agents/commands.md` lists
  which builds are kept apart.

## Commit Messages

Subjects follow Conventional Commits and are enforced by the `commit-msg` hook in `.pre-commit-config.yaml`, which runs
`tool/hooks/commit_msg.sh`:

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

### Fixup Commits

A follow-up to a change that has not shipped in a stable release goes in as `git commit --fixup=<target>`, aimed at the
commit that introduced what it amends.

- Only stable tags (`vX.Y.Z`) close a commit. A target reached only by pre-release tags (`vX.Y.Z-pre.N`) is still open
  for fixups, so do not steer away from it or flag it.
- A commit a stable tag contains takes no fixup; land the follow-up as a regular commit. Check with
  `git tag --contains <target> | grep -v -- '-pre'`, which must print nothing.
- Asking for a fixup means creating the `fixup!` commit only. Do not run `git rebase --autosquash` or otherwise fold it
  into its target unless the user asks for the squash.

### Changelog Trailers

`tool/changelog.dart` builds the user facing changelog from the commit history, so the trailers below are the copy that
ships to users. The subject stays the developer facing summary and is only the fallback.

```text
feat(profiles): support per-profile override script

Changelog: Per-profile override scripts
```

- `Changelog:` is the English entry. `Changelog: skip` drops the commit from the changelog entirely.
- The changelog is English only. A `Changelog-<locale>:` or `Breaking-<locale>:` trailer fails the hook, because
  translated release copy does not belong in the commit history. Translate after the fact if ever needed, not in the
  commit message.
- `Changelog-Type:` moves an entry into another group, for example to promote a `refactor` that users will notice. Valid
  values are `breaking`, `feat`, `fix`, `perf`, `revert`.
- `BREAKING CHANGE:` is required whenever the subject carries `!`, and its text becomes the breaking entry. A `!` commit
  therefore needs two lines of copy: the footer for the breaking entry and `Changelog:` for the normal one.

`feat`, `fix`, `perf`, `revert` and breaking commits are collected by default; every other type is dropped unless it
carries a `Changelog:` trailer. Commits missing a trailer reuse their subject; for `feat`, `fix` and `perf` the hook
says so without blocking.

## Migrations

An upgrade starts from the last release, not from the previous development build. Before writing a legacy reader, a
data move, or a test for one, check that the state it reads shipped: `git tag --contains <commit>` on the commit that
introduced it, or `git show <tag>:<path>` for the file as the release had it. A state that only ever existed between
two releases gets no migration; a development install holding it may lose that setting or fall back to its default.

A release that resets or rewrites settings, instead of reading their old shape, adds a step to `_upgrades` in
`lib/common/migration.dart` under the next `upgradeVersion`. A step takes and returns the `Config`, runs once on an
install that already had settings, and never on a new one. Leave `currentVersion` for changes to the stored format:
backups carry it, and an older app refuses a backup stamped newer than its own, so bumping it for a reset would strand
backups between devices on different releases.

The database takes one migration step per release. The newest step in `lib/database/database.dart` has not shipped
while `schemaVersion` at the last release tag is below its number; a schema change then goes into that step, raising
`schemaVersion` and the step's condition together so a development install runs the step again, instead of adding a
step of its own. Every operation in it checks the shape it finds, a missing table or column or a column under its old
name, so it can run again on a database that went through part of it. Its tests start from the released shape.

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
l10n paths for that reason. It only needs what `package:flutter/widgets.dart` exports.

The project has no design library: `material_ui`, `cupertino_ui` and the SDK's
`material.dart` and `cupertino.dart` are banned by the same test, and the lock file holds
neither package. Widgets come from `package:flutter/widgets.dart` and components, the
`ThemeData` and the `ColorScheme` from `prism_ui`.

Strings live in `arb/intl_{en,zh_CN,ja,ru,fr,es,ko}.arb` — flat JSON, no `@` metadata. Add a key to all seven, then regenerate with
`dart run intl_utils:generate`, which rewrites `lib/l10n/`. A key present in only some locales silently falls back to
English at runtime, so add the translation rather than leaving it out.

Labels for enum values go through the exhaustive switches in `lib/common/l10n_labels.dart`, never
`Intl.message(<runtime string>)`. A key built from an enum name or a stored string is invisible to the analyzer, and a
failed lookup returns the key itself, so a stale key ships as `routeMode_config` in the UI rather than throwing.
`test/lint/dynamic_message_key_test.dart` fails on any `Intl.message(` in `lib` outside the generated code, and checks
that every locale carries the same keys and has a display name.
