# tray

System tray integration for FlClash on Linux, macOS and Windows.

## API

The plugin owns call ordering, idempotency, call serialization and unchanged-payload suppression.
Callers declare the desired tray state; they never sequence platform calls themselves.

```dart
await Tray.instance.show(
  TraySpec(
    icon: TrayIcon.asset('assets/images/icon/status_1.png', isTemplate: true),
    toolTip: 'FlClash',
    menu: [
      TrayMenuAction(label: 'Show', onSelected: showWindow),
      const TrayMenuSeparator(),
      TrayMenuCheckbox(label: 'TUN', checked: true, onSelected: toggleTun),
      TrayMenuSubmenu(label: 'Proxy', items: proxyItems),
    ],
  ),
);

await Tray.instance.setTitle('↑ 1.2 MB/s');
await Tray.instance.hide();
```

- `show` creates the tray on first call and reconciles it afterwards. Re-sending a structurally
  identical `TraySpec` performs no platform call, so callbacks may be rebuilt freely.
- `setTitle` is the incremental path for high-frequency text. It is a no-op where
  `capabilities.title` is false, and while no tray is visible.
- `hide` is idempotent and returns native state to "`show` was never called", so a later `show`
  rebuilds the tray from scratch.
- `openMenu` is a no-op where `capabilities.menuControl` is false.

Menu item ids are assigned by pre-order position, so an unchanged menu serializes identically across
rebuilds and click dispatch stays stable while a menu is open.

## Events

`Tray.instance.events` is a broadcast stream of `TrayIconActivated`, `TrayMenuRequested` and
`TrayMenuItemSelected`. Per-item `onSelected` callbacks fire before the corresponding stream event.

## Capabilities

`Tray.instance.capabilities` reports what the current platform can do, so callers branch on ability
rather than on `Platform.isX`.

| | macOS | Windows | Linux |
| --- | --- | --- | --- |
| `title` | yes | no | yes |
| `toolTip` | yes | yes | yes |
| `iconEvents` | yes | yes | no |
| `menuControl` | yes | yes | no |

Linux runs on AppIndicator/StatusNotifierItem, where the desktop shell owns the menu; the application
cannot receive icon clicks or open the menu itself.

## Linux requirements

`libayatana-appindicator3-dev`, or `libappindicator3-dev` as a fallback.
