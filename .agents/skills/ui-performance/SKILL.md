---
name: ui-performance
description: Use when a FlClash page, sheet, list, menu, or transition drops frames or feels slow, when asked to lower UI-thread, raster, or idle load, or when deciding whether work belongs in an isolate.
---

# UI Performance

## Read First

- `.agents/rules.md`: UI Frame Budget and UI Isolate Work are binding; they name the usual causes and the components
  that fix each one.
- `.agents/architecture.md`: Rebuild Scopes, Page Arrival, Background Work, and Liquid Glass for glass costs.

## Workflow

1. Name the moment: opening a page, a frame during a push or pop, dragging a sheet, scrolling, switching tabs,
   editing one item, or idling while the Core runs. Each has its own probe below.
2. Seed the largest data the app expects, not a demo profile: 40 to 150 groups of 300 proxies, 300 groups of 50
   members, 20,000 rules, 2,000 local proxies, 60 rule sets, 20,000 connections, a 7.7 MB profile of 200,000 lines.
3. Count before timing. Rebuilds, repaints, provider recomputes, SELECTs, glass captures, and render passes are
   deterministic; a count that grows with the data or with the screen when one item changed is the defect. Time only to
   rank variants.
4. Fix by cause with the components the rules name. Change an algorithm, then compare it against the old one copied
   into the probe under an `old_` prefix on random data, which catches more than the existing tests.
5. Measure the same probe on the base and on the change. Pin a count that matters in a widget test; never pin a time.
6. Stop where the numbers do. A change that moves timings only within noise, or saves under a millisecond at the
   largest data, is reported and left out.

## Probes

A probe is scratch: write it in the scratchpad, copy it under `test/` to reach `package:fl_clash` and
`test/helpers/`, and run and delete it in one command so a crash leaves nothing in the checkout. Compare against the
base by writing `git show HEAD:<file>` over the file and restoring your version afterwards, never with `git stash`:
another session may share the checkout.

### `flutter test` counts

- Rebuilds: `debugOnRebuildDirtyWidget`. It also reports first builds, and its `builtOnce` argument stays false unless
  `debugPrintRebuildDirtyWidgets` is on, so track built elements in an `Expando<bool>`. Print a rebuild's cause from
  `element.toDiagnosticsNode().getProperties()` (`dependencies`); find the root of a rebuild as the element whose
  nearest `ComponentElement` ancestor did not rebuild this frame, skipping `RenderObjectElement` ancestors.
- Paints: `debugProfilePaintsEnabled` with `debugOnProfilePaint`, skipping `ro.isRepaintBoundary && !ro.debugNeedsPaint`,
  which are only composited; or `RenderRepaintBoundary.debugSymmetricPaintCount` on one boundary, as the repaint tests
  do. Trace where a layout or paint mark comes from with `debugPrintMarkNeedsLayoutStacks` and
  `debugPrintMarkNeedsPaintStacks` for one frame (import `package:flutter/rendering.dart`).
- Provider recomputes: `ProviderObserver` misses a recompute that produced an equal value, so override the provider
  with a counting wrapper around the generated function. A riverpod 3 observer subclass is a `final class`.
- Queries: a real drift database on `NativeDatabase.memory().interceptWith(...)` or `createInBackground` over a temp
  file, counting `QueryInterceptor.runSelect` per table. Seed inside `tester.runAsync`.
- Glass: `flutter test --enable-impeller` and `LiquidGlassHost.debugLastCapture`, reset to null before every pump, since
  a retained frame keeps the last record.
- Frames: pump 16 ms at a time and record each frame's rebuilds and a `Stopwatch`; the frame index maps to the
  transition's first frame, first visible paint, end of motion, and settle. `getCpuSamples` through `vm_service` with
  `--enable-vmservice` attributes a slow frame to a stack.

Pitfalls: `find.byType` skips offstage elements unless `skipOffstage: false`; the first test of a file carries JIT
compilation, so warm up with a throwaway test; a single long `pump` advances one frame and leaves running animations
inside the counted window, so pump frame by frame past them first; `pumpAndSettle` never returns on a page with a
running indicator; a fling needs `createGesture` with `moveBy` and timestamps to carry velocity; the test host is
not mobile, so a touch drag on the editor selects text, and scrolling there takes a trackpad `panZoom` gesture; Timer creation under FakeAsync samples a stack, so
Timer cost in a profile is an artifact.

### Device numbers

`flutter test` is JIT on the host. A case near the budget, raster cost, and anything glass-related are settled on a
profile build:

- Android: `flutter build apk --profile` keeps the release package name, so install it on an emulator or a device
  without the user's release build, or give it a suffix temporarily and restore the build file at once. Read frames
  from `Flutter.Frame` on the `Extension` stream through the VM service. On an emulator, compare render passes and
  `Canvas::saveLayer` per frame from the `Embedder` timeline; SwiftShader timings change with host load and weigh
  texture reads unlike a phone GPU. On a real device, missed vsyncs between SurfaceFlinger `latchBuffer` events in
  `atrace gfx view input` are closer to what the user sees than `Flutter.Frame` times.
- Android, base against change: build release APKs of both with ascending `--build-number`s, since a phone refuses a
  downgrade, and install them in turn (base, change, base, change), running eight to ten pushes and pops on each, so
  a drift in the phone's state falls on both. Note where in the burst a gap falls against the bar in UI Frame
  Budget: one before the page moves is the one its start may miss, any after it is a defect. To find a cause, a
  profile build with `Flutter.Frame` and the `Dart`/`Embedder` timeline shows each frame's UI and raster time, and
  `ext.flutter.profileWidgetBuilds` with `ext.flutter.profileRenderObjectLayouts` names the widgets inside a heavy
  one, at a cost to its time. `adb` needs `ANDROID_SERIAL` when another session runs an emulator.
- macOS: a probe app made with `flutter create` that holds only the `prism_ui` or `lib/ui` files under test builds a
  profile in about half a minute and starts no Core. A profile build of FlClash itself shares the installed app's data
  and single-instance lock, so give it another bundle id and drop its URL scheme first, and run it under Running the
  App Locally in `.agents/rules.md`. On Apple silicon `FrameTiming` raster excludes GPU time; use Metal System Trace for that. Compare
  variants inside one binary, alternating several rounds and taking the median, under enough load (many popups at
  once, a long fling) that the difference exceeds the noise.

## Reporting

Report counts and times as base and change at the same data, say which numbers are JIT, name the device and backend
for the rest, and list what was measured and left alone with the reason.
