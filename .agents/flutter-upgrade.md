# Flutter Upgrade Checklist

Read this before changing `FLUTTER_VERSION` in `.github/workflows/build.yaml` or `.fvmrc`. Each entry is a
workaround tied to a Flutter bug: what it does, where it lives, and what has to be true before it can go. Remove an
entry together with its workaround; add one whenever a new workaround is pinned to the SDK.

## Stable cadence

Flutter ships a stable release about once a quarter, three minor versions apart (3.41 in February, 3.44 in May, 3.47
in August 2026). The two minors in between (3.48, 3.49) are beta only, so a fix that lands on `main` reaches stable
in the next multiple, 3.50, expected around mid-November 2026. Hotfix releases (3.47.x) carry only cherry-picks
listed in the SDK's `CHANGELOG.md`.

## Impeller disabled on Intel macOS release builds

- **Bug:** [flutter/flutter#191538](https://github.com/flutter/flutter/issues/191538). From 3.47, when Impeller
  became the default desktop renderer, Intel (x86_64) Macs flicker across the whole window while scrolling or
  animating, and text can render garbled. Apple Silicon is not affected.
- **Fix upstream:** landed on `main` before 2026-08-25 and verified on `3.48.0-1.0.pre-404`; it is not in any
  3.47.x hotfix (checked through 3.47.5).
- **Workaround:** the release job for `macos-15-intel` (`arch: amd64`) runs
  `plutil -replace FLTEnableImpeller -bool NO macos/Runner/Info.plist` before `dart setup.dart`, so only the Intel
  DMG falls back to Skia. The checked-in `Info.plist` does not set the key, so local builds and the arm64 DMG keep
  Impeller. The macOS embedder reads the key at launch in `FlutterDartProject.mm` (`enableImpeller`), release
  builds included.
- **Side effect:** Skia on Intel renders blur, shadows and text slightly differently; judge Intel-only visual reports
  against Skia, not Impeller.
- **Remove when:** `FLUTTER_VERSION` moves to a stable that contains the fix (3.50 or later, or a 3.47.x whose
  changelog lists #191538). Before dropping the step, build the Intel DMG without it and scroll the proxies and
  dashboard pages on an Intel Mac with its integrated GPU driving the built-in display; an external display can
  switch to the discrete GPU and hide the flicker.

## Windows view visibility forwarded by the runner

- **Bug:** the Windows embedder's `WindowsLifecycleManager` counts the Flutter view as a window of its own and keeps
  it visible until the view is sized to zero. Hiding the top-level window never resizes the view, and the `window`
  plugin keeps it sized while minimized, so the app was never told `hidden`: animations kept rendering in the tray
  and `appVisibleProvider` stayed true.
- **Workaround:** `WindowPluginForwardVisibility` in the `window` plugin's
  `windows/include/window/window_plugin_runner.h` hands the top-level window's `WM_SHOWWINDOW` and `WM_SIZE` to
  `ProcessExternalWindowMessage` for the view's HWND, so the view shows and hides with its window.
  `FlutterWindow::MessageHandler` in `windows/runner/flutter_window.cpp` calls it before `HandleTopLevelWindowProc`;
  the Flutter runner template has no such call, so keep it when regenerating the runner.
- **Remove when:** the engine hides the view together with its top-level window. Check with the proxy running and
  the window focused: hiding it to the tray and minimizing it must each log `AppLifecycleState.hidden`.

## macOS activation resumes a hidden window

- **Bug:** `handleWillBecomeActive` in the macOS engine's `FlutterEngine.mm` resumes when any window in
  `NSApp.windows` is visible, and the tray's `NSStatusBarWindow` always is. Activating the app while its window was
  minimized or hidden, such as Cmd-Tab back to a minimized window, reported `resumed`, and the next deactivation
  `inactive`, so frames ran until the window was shown again.
- **Workaround:** the `window` plugin observes will-become-active and will-resign-active and, once the engine has
  answered, sends `AppLifecycleState.hidden` on `flutter/lifecycle` while its window is not visible
  (`applicationActivityChanged` in `WindowPlugin.swift`).
- **Remove when:** the engine ignores status item windows on activation. Check without the workaround: minimize the
  window, switch to another app, then Cmd-Tab back without restoring it; the log must stay at
  `AppLifecycleState.hidden`.

## Linux minimize on Wayland reads as inactive

- **Bug:** the Linux engine reports `hidden` for `GDK_WINDOW_STATE_ICONIFIED`, but xdg-shell has no minimized state,
  so GTK 3 never sets it on Wayland. A minimized window reported only its focus loss, as `inactive`, and kept
  rendering at the display rate (GNOME 46).
- **Workaround:** the `window` plugin's Linux `minimize` records the time, and a focus loss within 500 ms of it sends
  `AppLifecycleState.hidden`. Its `window-state-event` handler is connected after the engine's, so that message
  follows the engine's `inactive`; the compositor focuses the window when it restores it, which the engine reports as
  `resumed`. A minimize the compositor starts itself (Super+H, the dock) is not covered.
- **Remove when:** the Linux engine reports minimized windows on Wayland, which needs GTK 4 or xdg-shell's
  `suspended` state. Check in a GNOME Wayland session without the workaround: minimizing from the caption button
  must log `AppLifecycleState.hidden`.
