# window

Desktop window control for FlClash on Linux, macOS and Windows. Written for
FlClash; it replaced the `window_manager` fork, and its platform code derives
from that plugin (see `LICENSE`).

## Dart API

`desktopWindow` is the singleton `DesktopWindow`. Every call is a method on the
`window` method channel; events arrive on the same channel as `onEvent` with a
`name` argument and are delivered to `WindowListener`s as `WindowEvent`s.

Coordinates and sizes cross the channel in logical pixels on every platform.
Windows converts with the window's own DPI.

Every native handler validates its arguments and answers a missing or mistyped
argument with a `PlatformException` whose code is `bad_args`. A call the
platform cannot honor answers with code `unsupported`. Native code never
crashes on channel input.

## Method channel contract

Arguments are a `Map<String, Object?>`; `-` means no arguments. Void methods
return `null`.

| Method | Arguments | Returns | Notes |
| --- | --- | --- | --- |
| `ensureInitialized` | - | null | Binds the plugin to the Flutter view's window and leaves it hidden. Every other method requires it. |
| `show` | `inactive: bool` | null | `inactive` shows without taking focus. |
| `hide` | - | null | |
| `isVisible` | - | bool | |
| `focus` | - | null | |
| `close` | - | null | Runs the close path; with `preventClose` set only the `close` event fires. |
| `setPreventClose` | `value: bool` | null | |
| `isMaximized` | - | bool | |
| `maximize` | - | null | |
| `unmaximize` | - | null | |
| `isMinimized` | - | bool | |
| `minimize` | - | null | |
| `restore` | - | null | |
| `isFullScreen` | - | bool | |
| `setFullScreen` | `value: bool` | null | |
| `getBounds` | - | `{x, y, width, height}` doubles | Logical pixels, top-left origin on every platform. |
| `setBounds` | `x?, y?, width?, height?: double` | null | Absent `x`/`y` keeps the position, absent size keeps the size. Never changes z-order or focus. |
| `isPositionSupported` | - | bool | false on Wayland, where the compositor owns placement. |
| `setMinimumSize` | `width, height: double` | null | |
| `isAlwaysOnTop` / `setAlwaysOnTop` | `value: bool` | bool / null | |
| `setTitleBarStyle` | `style: "normal" \| "hidden", windowButtonVisibility: bool` | null | Hidden keeps the system frame, border and resize edges; only the caption goes. |
| `setSkipTaskbar` | `value: bool` | null | macOS switches the activation policy. |
| `setRoundedCorners` | `value: bool` | null | Windows 11 corner preference; no-op elsewhere. |
| `isEffectSupported` | `effect: String` | bool | See effects below. False for anything `setEffect` would silently not draw. |
| `setEffect` | `effect: String, tint: int?` ARGB`, brightness: "light" \| "dark" \| null` | null | `unsupported` error when `isEffectSupported` is false. `brightness` picks the light or dark material; null follows the system. |
| `startDragging` | - | null | Begins a window move from the current pointer press. |

### Events

`onEvent` carries `name`, one of:

`close`, `focus`, `blur`, `show`, `hide`, `maximize`, `unmaximize`,
`minimize`, `restore`, `geometry-changed`, `enter-full-screen`,
`leave-full-screen`, `should-terminate`, `activate`.

- `geometry-changed` fires once the window's position or size has settled,
  whether the user or `setBounds` changed it. Each platform coalesces the raw
  notifications for 150 ms (Windows `WM_WINDOWPOSCHANGED`, macOS did-move and
  did-resize, Linux configure-event) and reports the final geometry. It is
  not suppressed while maximized or full screen; Dart decides what to keep.
- `show` and `hide` follow the window's visibility changes: Windows reports
  `WM_SHOWWINDOW`, Linux the GTK `show`/`hide` signals, and macOS a `show` or
  `hide` call that changed `isVisible`.
- `close` fires when the user or `close` asks to close; with `preventClose`
  the window stays open and Dart decides.
- `enter-full-screen` and `leave-full-screen` are raised by the platform's
  full-screen transition; on Windows the plugin emulates full screen and
  raises them itself from `setFullScreen`.
- `should-terminate` (macOS) is forwarded by the application delegate from
  `applicationShouldTerminate`.
- `activate` is raised by the runner when another launch, or a Dock reopen,
  asks the running instance to show its window. Nothing is shown natively.

### Window style

Each platform keeps one style record and reapplies it as a whole whenever any
part changes, so the settings never fight each other:

- `titleBarStyle`, `windowButtonVisibility`
- `roundedCorners` (Windows)
- `effect`, `effectTint`, `effectBrightness` (Windows, macOS)

On Windows that record owns `DwmExtendFrameIntoClientArea`, the DWM window
attributes (including immersive dark mode, which the system backdrops and the
frame border follow) and `SetWindowCompositionAttribute`; on macOS it owns
`isOpaque`, `backgroundColor`, `titlebarAppearsTransparent` and the effect
view, whose `appearance` is the requested brightness; on Linux the header bar
and decoration state.

### Effects

`effect` is one of `none`, `transparent`, `blur`, `acrylic`, `mica`. Linux
supports only `none`: no desktop-neutral blur protocol exists for GTK 3, and a
transparent window without blur is not a useful effect.

| Effect | Windows | macOS |
| --- | --- | --- |
| `none` | default frame | opaque window |
| `transparent` | transparent gradient accent | clear window |
| `blur` | `ACCENT_ENABLE_BLURBEHIND` | `NSVisualEffectView` `.sidebar`, behind-window blending, follows the window's active state |
| `acrylic` | `ACCENT_ENABLE_ACRYLICBLURBEHIND` (Windows 10 1803+) | `NSVisualEffectView` `.fullScreenUI` |
| `mica` | `DWMSBT_MAINWINDOW` on Windows 11 | unsupported |

The accent effects leave the DWM frame margins at zero: Windows fills a frame
extended into the client area with an opaque material that covers them. `mica`
extends the whole frame, which the system backdrop needs, and the Windows 10
top border below extends the top. The accent effects go through
`SetWindowCompositionAttribute`, so `isEffectSupported` is false for them on a
user32 without it rather than reporting an effect that draws nothing.

With `titleBarStyle: hidden` on Windows, `WM_NCCALCSIZE` takes the frame
insets from `AdjustWindowRectExForDpi` and keeps the client rect at the
window's top edge, plus the frame height when maximized so the taskbar stays
uncovered. Windows 11 draws the top border into a 1 px non-client strip left
there. Windows 10 draws the whole caption over any strip shorter than one
(Windows Terminal's `NonClientIslandWindow` records the same), so it gets no
strip. Instead, while no accent effect is on, `WindowStyle::Apply` extends the
DWM frame over the whole caption height and `WindowController` keeps a 1 px
row of client area above the Flutter view, paints it black in `WM_PAINT`
(alpha 0 to DWM, which shows the frame's border through it) and answers
`WM_NCHITTEST` with `HTTOP` for it. The plugin therefore positions the view
itself on `WM_SIZE` and after every frame change; the runner's own placement
only runs before `ensureInitialized`. The row is gone while maximized or full
screen, where there is no border to show, and while an accent effect is on.

The Flutter content must paint a translucent background for anything but
`none` to be visible.

On macOS the plugin follows macos_window_utils, which flutter_acrylic uses:
`ensureInitialized` installs a host view controller whose view is the
`NSVisualEffectView` and hosts the Flutter view controller as a child, so the
effect view is the Flutter view's superview for the life of the window.
Placing the effect view beneath the Flutter view as a sibling breaks input:
AppKit hands an unhandled `mouseDown` from a non-opaque view to the sibling
below it before the view controller, so Flutter never receives clicks. `none`
and `transparent` mask the material out with an empty `maskImage` and leave
the view inactive instead of swapping view controllers.

## Lifecycle

The engine reports `AppLifecycleState` from its own view of the window. Where
that view keeps an unseen window rendering, the plugin sends `hidden` on
`flutter/lifecycle` itself:

- Linux: Wayland has no minimized state, so GTK never sets `ICONIFIED` after
  `minimize` and the engine reports only the focus loss, as `inactive`. When
  the window loses focus within 500 ms of `minimize`, the plugin sends
  `hidden` from a `window-state-event` handler connected after the engine's.
  A compositor that ignores the request, such as sway, leaves the focus where
  it is, and a restore from the compositor focuses the window, which the
  engine reports as `resumed`. A minimize the compositor starts itself, such
  as Super+H, still reads as `inactive`.
- macOS: on activation the engine resumes if any window in `NSApp.windows` is
  visible, and the status item's window always is. After every activation
  change the plugin sends `hidden` while its own window is not visible.

On Windows the engine counts the Flutter view as a window of its own that hides
only once it is sized to zero. Hiding the top-level window never resizes the
view, and neither does minimizing it, because the plugin consumes that
`WM_SIZE`. The plugin has no handle to the engine, so the runner passes the
top-level window's `WM_SHOWWINDOW` and `WM_SIZE` to the engine for the view
through `WindowPluginForwardVisibility` (see Runner hooks).

## Unused contract surface

The application drives only `none`, `blur` and `acrylic`, always passes
`windowButtonVisibility: true`, and calls `setRoundedCorners` for Windows
alone. `transparent`, `mica`, hidden caption buttons and the macOS
`setRoundedCorners` no-op stay in the contract so every platform answers the
same table; they have no application caller today.

## Runner hooks

- Windows: `WindowPluginFindRunningWindow()` and
  `WindowPluginActivateWindow(HWND)` from `window/window_plugin_c_api.h`, and
  `WindowPluginForwardVisibility(controller, message, wparam, lparam)` from
  `window/window_plugin_runner.h`, which the top-level window procedure calls
  before `HandleTopLevelWindowProc`. That header is inline because it calls
  `flutter::FlutterEngine`, which only the app's C++ wrapper implements; the
  plugin DLL cannot use it.
- Linux: `window_plugin_activate()` from `window/window_plugin.h`.
- macOS: `WindowPlugin.instance?.handleShouldTerminate()`,
  `WindowPlugin.instance?.handleReopen()`, and `NSWindow.hiddenWindowAtLaunch()`
  for `MainFlutterWindow.order(_:relativeTo:)`.
