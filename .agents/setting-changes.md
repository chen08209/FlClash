# Setting Changes

A changed setting takes one of three paths. The path depends on who reads the setting and when it reads it, not on
which page edits it. Choose the path when you add a setting or move one.

| Path    | Who reads the setting                       | Watched provider                       | Acts                          | Effect                                     |
|---------|---------------------------------------------|----------------------------------------|-------------------------------|--------------------------------------------|
| Update  | Core, and Go can change it in place         | `updateParamsProvider`                 | `CoreManager`, automatically  | Patches the running config, no reload      |
| Apply   | Core, only when it parses a config          | `setupPatchProvider`                   | `CoreManager`, automatically  | Rebuilds the profile and reloads the Core  |
| Restart | Android service, when it starts             | `vpnOptionsProvider`                   | `VpnManager` asks the user    | Stop and start of the service              |

Update and apply run on their own, debounced. A restart never does: rebuilding the tunnel cuts every connection
through it, so `VpnManager` only shows a notifier and the user taps its restart action. A setting that only Flutter
reads takes no path.

## Update

`CoreManager` hands each change of `updateParamsProvider` to `SetupAction.updateConfigDebounce`. `updateConfig` then sends
`PatchClashConfig.toUpdateParams` to Go's `updateConfig` in `core/config.go`. That function writes the fields into the
running config and calls the runtime setter for each one, or `updateListeners` for the inbounds. Nothing is re-parsed.

The update path carries these fields:

- From `PatchClashConfig`: `mode`, `log-level`, `mixed-port`, `allow-lan`, `find-process-mode`, `external-controller`,
  `secret`, `geo-auto-update`, `geo-update-interval`, `geox-url`, and the `tun` keys of `Tun.coreJson`: `enable`,
  `device`, `stack`, and `auto-route`, always on.
- From `PatchClashConfig`, only while picked in `generalOverrideKeys`: `ipv6`, `tcp-concurrent` and `unified-delay`.
  Unpicked, they go as null and Go leaves the profile's value running.
- From other settings: `NetworkProps.authentication`, and `AppSettingProps.checkCertificate`, sent as
  `skip-cert-verify`.

On desktop, `updateListeners` rebuilds the TUN from the patched `tun`. Enabling TUN may need authorization first. When
`requestAdmin` gets it newly granted, `updateConfig` restarts the Core instead of patching it. On Android,
`updateListeners` skips TUN, so a `tun` update reaches the VPN only through a restart.

To move a setting onto this path:

1. Add it to Dart `UpdateParams` and `toUpdateParams`.
2. Add it to Go `UpdateParams` in `core/protocol.go` and apply it in `updateConfig`.
3. Reset it in `PatchClashConfig.setupOnly`. If you skip this, every change also reloads the profile. The
   `PatchClashConfig.setupOnly` test in `test/models/config_test.dart` fails until its fixture changes the field and
   `setupOnly` resets it.
4. Keep writing it in `_makeRealProfileTask`, so a full apply hands the Core the same value. A general override is
   written there through `generalOverrideJson` and sent by `toUpdateParams` only while picked, so both paths leave an
   unpicked one to the profile.

Prefer update whenever Go has a setter for the setting, because an apply reloads the whole config.

## Apply

`CoreManager` answers each change of `setupPatchProvider` with `applyProfileDebounce(silence: true)`. That call
rebuilds the profile YAML and hands it to Go's `applyConfig` through `setupConfig`. The provider holds three values:

- `PatchClashConfig.setupOnly`: the config with every field that update carries reset to its default.
- `NetworkProps.appendSystemDns`.
- `NetworkProps.bypassPrivateRoute` on desktop, where the task adds the private ranges to the TUN's final
  `route-exclude-address`.

A change to anything else in `PatchClashConfig` therefore reaches it. Today that is the DNS, TUN and general overrides
(`dns`, `dnsOverrideKeys`, `tunOverride`, `tunOverrideKeys`, `generalOverrideKeys`, `geodata-loader`, `testUrl`),
`hosts`, the extra inbound ports (`port`, `socks-port`, `redir-port`, `tproxy-port`), the dialer options
(`keep-alive-*`, `disable-keep-alive`, `interface-name`, its mode, `routing-mark`) and `global-ua`. A new
`PatchClashConfig` field written by `_makeRealProfileTask` lands here without further work. A value the profile build
reads from another settings object has to be added to `setupPatchProvider`.

`applyProfileDebounce` waits for the changes to stop for at least 2 s, and no less than the last push to the Core
took, up to 10 s. The floor takes in a few switches flipped in a row and keeps a change made just before leaving a page
from reloading during the transition; the push time keeps a run of changes on a large profile from queuing one reload
right behind another. The push is timed from building the profile to the groups refreshed after it: a subscription
refresh or an authorization prompt before it waits on the network or the user, and an apply that sends nothing leaves
the time as it was. The ceiling covers a push held up by a rule-set download or a Core timeout, which every caller,
subscription updates and the start's catch-up apply included, would otherwise wait out. A setting therefore reaches the
Core a little after it is changed, not at once; until then the Core keeps running what it had.

A page waits for its own close to apply only behind a save or an apply-now button. The list editors
(`EditViewState`: Hosts, bypass domains, route addresses, DNS lists and policies, sniff ports) hand their entries back
through their save button alone, and leaving with unsaved entries asks first.

An apply without `force` sends nothing when the md5 of the generated YAML has not changed. A value that only
`SetupParams` carries never changes the YAML, so this path does not deliver it. `PatchClashConfig.testUrl` is that
case, so `CoreManager` asks for a `force` apply when it changes.

Profile content does not go through `setupPatchProvider`. `setupStateProvider` reads rules, groups and scripts from the
database once instead of watching them. Content is applied explicitly by whatever changes it:

- The profile's edit form, the custom profile editor, whose edits make a working profile only together, and the
  extension page call `autoApplyProfile` when they close. The extension page also shows an apply-now button while its
  profile is the current one and holds changes not applied yet, for applying them without leaving: changes made on
  the page, and whatever `inputsApplied` found unapplied when it opened.
- Subscription updates, scripts and app-level providers call `applyProfileDebounce`. The global added rules are the
  one content `CoreManager` watches, small enough to keep watched, so no writer has to remember the apply: any change
  to them calls `applyIfGlobalRulesUsed`, since only a profile with the standard extension takes them in.
- A profile switch runs `fullSetup`.
- A start applies again with `force` unless the last apply saw the same inputs (`inputsApplied`), the `testUrl` and
  `skipCertVerify` that only `SetupParams` carries included.

## Restart

`VpnService.handleStart` builds the tunnel once from `VpnOptions` and never reads them again.
`ServiceController.start` uses `enable` to choose between `VpnService` and `ProxyService`.

`vpnOptionsProvider` derives the options the service would start with now. `runningVpnOptionsProvider` records what
the last listener start handed it. The route list is subtracted in an isolate by `vpnRouteAddressProvider`, which
reruns only when the route lists or `bypassPrivateRoute` change, so `vpnOptionsProvider` is async: a start awaits it
before recording, the Android Core awaits it before its first `syncState`, and the shared state keeps the last options
while new routes compute rather than handing the service an empty list. `SetupAction` owns every start and stop: it
sets the record on a start and clears it on a stop, on-demand SSID suspension included.

`VpnManager` shows the notifier whenever a change leaves `VpnOptions.effective` different from the recorded options.
Repeated changes refresh the same notifier instead of stacking new ones. Changing a setting back to the running value
asks for nothing. The tap runs `SetupAction.restartVpn`: a stop, then a start, and only while a run is up.

| `VpnOptions` field     | Taken from                                                    | The service reads it                   |
|------------------------|---------------------------------------------------------------|----------------------------------------|
| `enable`               | `VpnProps.enable`, off in safe mode                           | always                                 |
| `stack`                | `Tun.stack`                                                   | with the VPN                           |
| `ipv6`, `dnsHijacking` | `VpnProps`                                                    | with the VPN                           |
| `allowBypass`          | `VpnProps`                                                    | with the VPN                           |
| `accessControlProps`   | `VpnProps.accessControlProps`                                 | `enable`, `mode` and that mode's list  |
| `systemProxy`          | `VpnProps.systemProxy`, off under local auth or safe mode     | with the VPN                           |
| `port`                 | `PatchClashConfig.mixedPort`                                  | with `systemProxy`                     |
| `bypassDomain`         | `NetworkProps.bypassDomain`                                   | with `systemProxy`                     |
| `routeAddress`         | `Tun.routeAddress` and `bypassPrivateRoute`                   | with the VPN                           |
| `mtu`                  | `Tun`                                                         | with the VPN                           |
| `congestionController` | `Tun`                                                         | with the VPN                           |

The service never reads the access list's sort and filter fields. `effective` resets them, along with every field
the table does not mark as read, so changing them does not ask for a restart.

To add a VPN option:

1. Add it to Dart and Kotlin `VpnOptions` and to `vpnOptionsProvider`.
2. If the service reads it only under a condition, put that condition in `VpnOptions.effective`, which mirrors
   `ServiceController.start` and `VpnService.handleStart`.

The notifier stays off while nothing runs, during on-demand suspension, in safe mode, and on desktop, where
`VpnManager` is not mounted. When Flutter reattaches to a service that is already running, it records the current
options, because the service does not report the options it was started with.

## One Setting, Several Paths

Each path watches its own provider, so a single setting can take more than one of them:

- `mixedPort`: update moves the Core's listener; under the VPN system proxy, the restart notice follows.
- TUN switch and stack: update rebuilds the desktop TUN. On Android the update reaches no TUN, and the restart notice
  carries the stack.
- MTU, congestion control and routes: Android's rows take the restart path; on desktop they are TUN overrides, applied
  with the profile.
- `bypassPrivateRoute`: apply on desktop, restart on Android.
- Local authentication: update applies it to the inbounds. It also switches the VPN system proxy, which needs a
  restart.

## Choosing The Path

For a new or moved setting, answer each question. More than one answer can be yes.

1. Does the Android service read it when it starts? Then it belongs in `VpnOptions` and takes the restart path.
2. Does the Core read it, and can Go change it in place? Then it belongs in `UpdateParams` and takes the update path.
3. Does the Core read it only when it parses a config? Then write it into the generated config, and it takes the
   apply path.
4. Does only Flutter read it? Then it takes no path.

Tests that hold these rules:

- `test/models/config_test.dart` (`PatchClashConfig.setupOnly`, the general overrides and their migration).
- `test/common/task_general_override_test.dart` (only picked general overrides reach the generated config).
- `test/views/general_config_test.dart` (removing an override resets its value).
- `test/models/core_test.dart` (`VpnOptions.effective`).
- `test/providers/state_derived_test.dart` (the setup patch).
- `test/manager/core_manager_test.dart` (update against apply).
- `test/manager/vpn_manager_test.dart` (the restart notice).
- `test/providers/setup_action_test.dart` (running options, suspension, `restartVpn`, the apply debounce).
