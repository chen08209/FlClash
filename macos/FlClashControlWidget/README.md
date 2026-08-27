# macOS Widgets

FlClash includes macOS 26+ WidgetKit surfaces named `FlClash`:

- A Control Center control for quickly starting or stopping the current
  connection.
- A small desktop/Notification Center widget showing the current profile with
  connection and refresh buttons.

Both surfaces are implemented in the same widget extension and use an App Group
`UserDefaults` store to communicate with the Flutter app.

## Build Notes

1. Open `macos/Runner.xcworkspace` in Xcode 16 or newer.
2. Select the `Runner` target and confirm the App Group capability contains
   the value from `FLCLASH_APP_GROUP_IDENTIFIER`.
3. Select the `FlClashControlWidget` target and confirm it uses the same App
   Group.
4. If your Apple Developer Team cannot provision `group.com.follow.clash`, pick
   a team-owned group identifier and update `FLCLASH_APP_GROUP_IDENTIFIER`
   consistently for the Runner and widget extension targets.
5. Build and run the `Runner` scheme on macOS 26 or newer.
6. If macOS shows stale controls or icons after a local build, quit FlClash and
   restart `chronod`, `ControlCenter`, and `FlClashControlWidget`.

## Manual QA

1. Launch FlClash and start a connection from the normal in-app start button.
2. Open Control Center, choose Edit Controls, and add the `FlClash` control.
3. Verify the control shows the enabled state after the app starts a connection.
4. Turn the control off and verify FlClash stops the current connection.
5. Turn the control on and verify FlClash starts the current connection.
6. Quit FlClash, turn the control on, and verify macOS opens FlClash and the
   pending start request is consumed after launch.
7. Toggle rapidly a few times and verify the final app state matches the final
   Control Center state.
8. Open Notification Center or Desktop widget editing and add the small
   `FlClash` widget.
9. Verify the widget shows the current profile name and connection state.
10. Click the main connection button and verify it starts or stops the current
    connection without presenting the FlClash window.
11. Click the refresh button and verify the current URL-based profile refreshes
    without presenting the FlClash window.
12. Click an empty area of the widget and verify FlClash opens its main window.

## Architecture

The widget extension never starts, stops, or refreshes Clash directly. It writes
a pending `start`, `stop`, or `refreshProfile` request into the App Group store,
posts distributed and Darwin notifications, and silently wakes the containing
app when needed.

The Runner target receives the notification or app reopen event and asks Dart to
consume the pending request. Dart then calls the existing
`setupActionProvider.setRunning(...)` or `profilesActionProvider.updateProfile(...)`
paths, so connection and profile behavior remain owned by the existing Flutter
state layer. Flutter also syncs the latest running state and current profile
name back to the App Group store so WidgetKit can render the latest status.
