# Flutter Upgrade Checklist

Read this before changing `FLUTTER_VERSION` in `.github/workflows/build.yaml` or `.fvmrc`. Each entry is a
workaround tied to a Flutter bug: what it does, where it lives, and what has to be true before it can go. Remove an
entry together with its workaround; add one whenever a new workaround is pinned to the SDK.

## Stable cadence

Flutter ships a stable release about once a quarter, three minor versions apart (3.44, 3.47, 3.50). The two minors in
between are beta only, so a fix that lands on `main` reaches the next stable minor, three above the current one.
Hotfix releases (3.50.x) carry only cherry-picks listed in the SDK's `CHANGELOG.md`.

The SDK checkout carries the engine sources under `engine/src/flutter`, so an entry below that names an engine file can
be checked against the new SDK with a plain `diff` of that file between the two checkouts.

## Impeller disabled on Intel macOS release builds

- **Bug:** two failures on Intel (x86_64) Macs under Impeller. On 3.47,
  [flutter/flutter#191538](https://github.com/flutter/flutter/issues/191538): the whole window flickered while
  scrolling or animating, and text could render garbled; the fix is in 3.50. On 3.50.0, #3063: on an iMac 13,2
  (GeForce GTX 675MX, macOS 12.5 installed through OpenCore Legacy Patcher) the app never shows its window. The main
  thread waits inside the engine under the first `order` of `MainFlutterWindow` (`viewWillAppear`) while Metal's
  compiler service builds Impeller's shaders and never answers; no Core starts and no crash report is written.
  `FLTEnableImpeller` set to false in the bundle's `Info.plist` brings it up. Apple Silicon is not affected.
- **Workaround:** the release job for `macos-15-intel` (`arch: amd64`) runs
  `plutil -replace FLTEnableImpeller -bool NO macos/Runner/Info.plist` before `tool/package.dart`, so only the Intel
  DMG renders with Skia. The checked-in `Info.plist` does not set the key, so local builds and the arm64 DMG keep
  Impeller. The macOS embedder reads the key at launch in `FlutterDartProject.mm` (`enableImpeller`), release builds
  included.
- **Side effect:** Skia on Intel renders blur, shadows and text slightly differently, and Liquid Glass frosts from its
  capture without refraction; judge Intel-only visual reports against Skia, not Impeller.
- **Remove when:** an Intel DMG built without the step passes both checks on real hardware. It reaches its window on a
  Mac whose GPU supports only the first macOS Metal family, such as a Kepler-era NVIDIA card on an OCLP-patched system.
  Scrolling the proxies and dashboard pages does not flicker on an Intel Mac with its integrated GPU driving the
  built-in display; an external display can switch to the discrete GPU and hide the flicker. Flutter no longer tests on
  Intel Macs from 3.50, so nothing upstream guards against either.

## Wrong-size back buffer on macOS

- **Bug:** [flutter/flutter#185394](https://github.com/flutter/flutter/issues/185394). `removeSurfaceForSize:` in
  the macOS engine's `FlutterSurfaceManager.mm` hands out the youngest idle cached surface without checking its size.
  When the window flips between sizes while the window server still holds the previous surface, which dragging a
  window edge back and forth does, a request for one size gets a surface of another. Impeller's Metal texture then
  disagrees with its descriptor, the render target drops it, and `Canvas::SetupRenderPass` dereferences a null
  texture on the raster thread. Debug builds log `The texture and its descriptor disagree about its size` and
  `Store action needs resolve but no valid resolve texture specified` first; release builds just crash.
- **Fix upstream:** [flutter/flutter#192522](https://github.com/flutter/flutter/pull/192522), still open; 3.50.1
  ships the same `FlutterSurfaceManager.mm` as 3.47.9, whose `removeSurfaceForSize:` compares only the first cached
  surface's size.
- **Workaround:** `plugins/rust_api/rust/src/window/macos/back_buffer.rs`, installed from the window module's
  `ensureInitialized`, replaces
  `-[FlutterBackBufferCache removeSurfaceForSize:]` at runtime and answers nil when the cached surface is not the
  requested size, so the engine allocates a new one. It does nothing if the engine no longer has that class or
  selector.
- **Remove when:** `FLUTTER_VERSION` moves to a stable that contains #192522 (check the SDK `CHANGELOG.md` for a
  3.50.x cherry-pick). Before dropping it, run a debug build without the guard on that SDK and drag a window edge
  back and forth for a minute; neither validation line may appear.

## Windows view visibility forwarded by the runner

- **Bug:** the Windows embedder's `WindowsLifecycleManager` counts the Flutter view as a window of its own and keeps
  it visible until the view is sized to zero. Hiding the top-level window never resizes the view, and rust_api's
  window module keeps it sized while minimized, so the app was never told `hidden`: animations kept rendering in the tray
  and `appVisibleProvider` stayed true.
- **Workaround:** `FlutterWindow::MessageHandler` in `windows/runner/flutter_window.cpp` hands the top-level
  window's `WM_SHOWWINDOW` and `WM_SIZE` to `ProcessExternalWindowMessage` for the view's HWND before
  `HandleTopLevelWindowProc`, so the view shows and hides with its window. The Flutter runner template has no such
  call, so keep it when regenerating the runner.
- **Remove when:** the engine hides the view together with its top-level window; `windows_lifecycle_manager.cc` is
  unchanged from 3.47.9 to 3.50.1. Check with the proxy running and
  the window focused: hiding it to the tray and minimizing it must each log `AppLifecycleState.hidden`.

## macOS activation resumes a hidden window

- **Bug:** `handleWillBecomeActive` in the macOS engine's `FlutterEngine.mm` resumes when any window in
  `NSApp.windows` is visible, and the tray's `NSStatusBarWindow` always is. Activating the app while its window was
  minimized or hidden, such as Cmd-Tab back to a minimized window, reported `resumed`, and the next deactivation
  `inactive`, so frames ran until the window was shown again.
- **Workaround:** rust_api's window module observes will-become-active and will-resign-active and, once the engine
  has answered, has `AppLifecycleState.hidden` sent on `flutter/lifecycle` while its window is not visible
  (`applicationActivityChanged:` in `plugins/rust_api/rust/src/window/macos/mod.rs`). A window brought back without another activation change
  would then wait on an occlusion notification macOS does not always post, keeping its last frame, so `show` and a
  deminiaturize hand the state back (`became_visible`).
- **Remove when:** the engine ignores status item windows on activation; 3.50.1's `handleWillBecomeActive` still
  resumes for any visible window. Check without the workaround: minimize the
  window, switch to another app, then Cmd-Tab back without restoring it; the log must stay at
  `AppLifecycleState.hidden`.

## Linux minimize on Wayland reads as inactive

- **Bug:** the Linux engine reports `hidden` for `GDK_WINDOW_STATE_ICONIFIED`, but xdg-shell has no minimized state,
  so GTK 3 never sets it on Wayland. A minimized window reported only its focus loss, as `inactive`, and kept
  rendering at the display rate (GNOME 46).
- **Workaround:** rust_api's Linux window module records the time of `minimize`, and a focus loss within 500 ms of it sends
  `AppLifecycleState.hidden`. Its `window-state-event` handler is connected after the engine's, so that message
  follows the engine's `inactive`; the compositor focuses the window when it restores it, which the engine reports as
  `resumed`. A minimize the compositor starts itself (Super+H, the dock) is not covered.
- **Remove when:** the Linux engine reports minimized windows on Wayland, which needs GTK 4 or xdg-shell's
  `suspended` state; 3.50.1's `fl_window_state_monitor.cc` still reads only `GDK_WINDOW_STATE_ICONIFIED`. Check in a GNOME Wayland session without the workaround: minimizing from the caption button
  must log `AppLifecycleState.hidden`.

## Linux window black after it is shown again on Wayland

- **Bug:** not filed upstream yet. GTK destroys a toplevel's Wayland surface when the window is hidden and makes a new
  one when it is shown. `FlViewRendererSubsurface` in the Linux engine moves its subsurface to the new surface from its
  `map` and `size_allocate` handlers, but `map` runs before GDK has made the surface, so a window shown again at the
  size it had gets no subsurface: the view paints its background and nothing else until the window is resized.
  Hiding to the tray and showing again left the window black (3.50.0, GNOME 46 Wayland).
- **Workaround:** the `map-event` handler of rust_api's Linux window module (`on_map_event` in
  `plugins/rust_api/rust/src/window/linux.rs`), which runs once the surface exists, queues a resize of every widget
  under the Flutter view, so the renderer is allocated again even at an unchanged size.
- **Remove when:** `fl_view_renderer_subsurface.cc` finds the new parent surface without an allocation. Check in a
  GNOME Wayland session without the workaround: close the window to the tray, show it from the tray at the same size;
  it must draw.

## Liquid glass saves around the transform of a blurring layer

- **Bug:** not filed upstream. From 3.47 Impeller scales a `saveLayer`'s image filter by a transform set inside the
  layer that is still in effect when the layer is restored. A host's capture shrinks each pane's slot inside the
  layer that blurs it, so its blur vanished at a quarter scale and spread half again as far at 1.5.
- **Workaround:** `_LiquidGlassHostLayer._snapshot` sets each slot's transform inside a `save` of its own, and each
  band's offset, restored before the layer is.
- **Remove when:** a test fails on an SDK that has the bug and passes on the new one without the `save`s. The
  frosted-pane case of `test/widgets/liquid_glass_host_test.dart` cannot decide it: under
  `flutter test --enable-impeller` it passes without the band offset's `save` on both 3.47.9 and 3.50.0. The slot's
  `save` also scopes its `clipRect`, so it stays whatever the engine does.

## Removed before their check ran

A workaround here is gone from the tree, removed by the maintainer's decision before its removal check had run, so a
report that matches its symptom points back at it. Drop an entry once the check passes or a stable release has shipped
without such a report.

### Impeller on Windows

- **Bug:** [flutter/flutter#193504](https://github.com/flutter/flutter/issues/193504), reported here as #2423. On 3.47,
  on some machines (seen on Windows 11 26200 with an Intel Arc integrated GPU), dragging a window edge froze the
  window on its last frame: the EGL context was lost, no frame of the new size was ever produced, and every later frame
  was dropped while Dart kept running. Hiding and showing the window left it white until the app restarted.
- **Removed:** on moving to 3.50.0, by turning Impeller back on in `wWinMain` (`windows/runner/main.cpp`). Upstream
  never reproduced the freeze, and a bot closed #193504 on 2026-10-29 with no fix linked, but 3.50 changed the path
  underneath it: the embedder asks for OpenGL ES 3 before falling back to ES 2
  ([#191516](https://github.com/flutter/flutter/pull/191516)) and uses offscreen MSAA where implicit MSAA is missing.
  It was not retested on a machine that reproduced it.
- **If it returns:** call `project.set_impeller_switch(flutter::ImpellerSwitch::Disabled)` in `wWinMain` before the
  window is created; release builds ignore `FLUTTER_ENGINE_SWITCHES`, so users cannot turn Impeller off themselves. The
  check: a build with Impeller survives dragging every window edge for a minute on such a machine, and the window
  keeps redrawing.
