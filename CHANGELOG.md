# Changelog

## v0.9.5 (2026-11-26)

**Features**

- **about** Icons and even spacing for the update settings on the About page (1951468)
- **window** Pause live updates on desktop while the screen is asleep or locked (0981835)
- **update** Install macOS updates from inside the app (73a0182)
- **proxies** Proxy groups unfold smoothly as one block (94288d7)
- **connection** Connection, request, DNS, outbound IP and log details use smaller text with more room (a27fab5)
- **prism_ui** List rows follow a smaller text size, as they already did a larger one (83214b6)
- **prism_ui** The phone tab bar spaces five tabs and sets out icons and labels as iOS does (219bc95)
- **about** The automatic update check and the update channel moved from General settings to the About page (7b97a68)
- **logs** Filter logs from a button beside search (0db670d)
- **logs** Set the log level from the Logs page (ef7dc6e)
- **requests** Connections become Requests: connections by minute with All, Active and Failed counts, conditions on app, exit, rule or protocol, a timeline for each connection, DNS queries, segments that keep their place, and new rows held under a desktop pointer (9c931f7)
- **update** Choose between stable and prerelease updates in the settings; the prerelease check finds the newest release and names the installed prerelease (562e11f)
- **ui** Lists and cards share one set of margins, so rows line up across pages (8fc8909)
- **dashboard** The dashboard's outbound mode card is titled Outbound, leaving its mode buttons more room (0eb1e11)
- **ui** Grouped lists match iOS 27: row heights, margins, corners and section spacing (79d5a59)
- **logs** On desktop, Logs moves from the sidebar into Tools (46522eb)
- **connections** Connections on macOS, Windows and Linux show the icon of the app that made them (888a1df)
- **navigation** Requests sits right after Proxies in the desktop sidebar (f18f92e)
- **connections** Connections that failed to connect now show in the requests list, with the reason (8736f48)
- **update** When an update has no file to download, the app opens the release page to download it by hand (afe7136)

**Bug Fixes**

- **proxies** A rounder, larger delay test icon on proxy cards (0105a4f)
- **prism_ui** Navigation bar tabs fit their titles, and a tap near a tab's edge selects it (4abbd15)
- **dashboard** Live connections on the dashboard open on the active ones (8682368)
- **rules** The rule type picker and rule lists show rule types as profiles write them, such as DOMAIN-KEYWORD, and rule search finds a rule by that name (9b01010)
- **core** A stop whose answer is lost with the connection to the core no longer turns the proxy back on when the core comes back (06643c3)
- **setup** Restarting the core with TUN on no longer hangs when it has to ask for authorization again (932826b)
- **core** On desktop, a restart asked for while the core is still starting, such as after installing the helper, now restarts it, and the core can start again after a start whose local connection setup hung (f95f0f1)
- **core** On Android, stopping while the core is still starting no longer leaves it running, and a start that failed while sending settings to the core no longer blocks the next start (7a63bb4)
- **probes** Recheck watched service failures with backoff (fee1b89)
- **probes** Service checks recover automatically when a chain switches to a working front proxy (1a57072)
- **setup** Dashboard checks wait for startup to finish when you tap Start as the app opens (fac7b07)
- **l10n** Shorter descriptions in network, DNS and general settings (18eaaea)
- **segmented-control** Segmented controls follow the system's reduce motion setting (a47cac5)
- **connected-button** Screen readers can now switch the dashboard's outbound mode (d45da9d)
- **scaffold** On wider phones the top bar buttons line up with the list cards below them (21846fc)
- **scaffold** Opening search puts the cursor in its field even when something else on the page has the focus (e3b13e7)
- **android** App icons in access control and connections load from the cache instead of being redrawn every day (e3ebcf1)
- **core** On macOS, connections show the app that opened them again (30817b4)
- **window** A hidden window no longer takes the foreground from a full-screen game on Windows (6611671)
- **linux** The Linux window is no longer drawn shifted toward the bottom left on NVIDIA and other drivers without glBlitFramebuffer (0ff56e5)
- **tray** When the menu bar or tray icon cannot be shown, the log says why (746f7b0)
- **macos** Intel Macs render with Skia again, fixing the hang at launch on older GPUs (0d3a33f)
- **dashboard** Service checks show the address Claude and ChatGPT actually saw, not only the node's exit address (b16e2db)
- **core** Gemini check no longer reports Hong Kong and Macau nodes as unsupported (80a86bc)
- **core** macOS no longer collects defunct dscacheutil processes each time TUN is turned on or off (e7b017e)
- **config** The default bypass list no longer skips the proxy for public 172.2* addresses, and the default fake-ip filter names Windows' real connectivity check hosts (80cc61b)
- **ui** Pages open and close again after the display sleeps or changes (ce13953)

**Performance**

- **code_forge** Large files open in the editor without a pause (c5c7ef0)
- **db** Profiles with many rules, groups or proxies open and update without stalling the screen (c8d1e9d)
- **route** Pages that load their data open at once with a spinner instead of pausing before they slide in (b2267cb)
- **android** Use less battery on Android in the background (7393ea4)
- **ui** Open list editors and pages over others more smoothly (8eb40a9)
- **dashboard** Smoother dashboard and tab switches, with one redraw a second while connected (edc6709)
- **proxies** Smoother proxy pages when switching groups, sorting and scrolling (e21abb4)
- **prism_ui** Swiping back on phones drops fewer frames (49df9ea)

## v0.9.4 (2026-11-19)

**Features**

- **dashboard** One status button gathers core, update and resource states, with counts, download progress and new card icons (a89b339)
- **rules** Added rules can go to named custom exits; a profile's script and added rules run together and open from the extend page (c8b34f2)
- **proxy** PAC mode for the desktop system proxy; new Windows installs bypass <local>; GTK apps on KDE Plasma follow the proxy (7633c3c)
- **dns** respect-rules, hosts and cache-algorithm in the DNS overrides; macOS system DNS through tun.dns-mode native (ca2693a)
- **logs** Open a log on a phone to select and copy it (c85bf3a)
- **resources** Geo resources update automatically by default (1b2ea11)
- **desktop** Impeller on Windows and Intel Macs; the Apple Silicon download no longer carries Intel code (848583d)
- Update the core to mihomo v1.19.34, with editor completion for its new keys (e57e5ac)

**Bug Fixes**

- **core** A start that fails or a lost Core says why; a mixed port of 0 is replaced; the mixed port opens without a profile (8298573)
- **config** Process rules match by default; picked override keys are written as set, empty included (044f5b5)
- **android** WireGuard, Hysteria2 and TUIC reconnect after a network change; core sockets opened before the VPN are protected (b13cf52)
- **dashboard** Service and exit IP checks no longer fail while the proxy starts, stops or changes network (408aaa9)
- **core** HTTPUpgrade share links no longer import as WebSocket (47824d4)
- **connections** App icons show whenever the app is known and keep their place while loading (5c5964f)
- **desktop** macOS tray windows stay on the current Space; windows use the target display's scale; AppImage without a bundled libstdc++; cleaner deb removal; the Windows installer only stops its own processes (c620dc9)
- **ui** Pages open at the top and on the selected profile; sheets open from sheets as pages; the editor shows its spinner and grows its sheet; calmer success and warning colors; remote icons hold their size (b08bcd9)

**Performance**

- **connections** Connections rank and sort off the UI thread; proxy and group icons use less memory (19fb1b0)

## v0.9.3 (2026-11-04)

**Features**

- **connections** Merged requests and connections; quick edit lists (52b975f)
- **ui** iOS 27 transitions, press and text selection; smoother pages (bb47f2c)
- **update** Download and install updates in the app (b8f84b3)
- **core** One delay test timeout; VPN crash and startup fixes (2a5a42c)

**Bug Fixes**

- **core** Auto-select leaves an unusable first node at once (7d5db7e)
- **access** Keep selections a filter hides (63aaf6d)

## v0.9.2 (2026-10-24)

**Features**

- **access** Access control state shown in a bar at the bottom (e8aac17)
- **config** Optional general overrides; settings apply sooner (5d6552d)
- **dashboard** IP quality cached for 3 days; simpler Android dashboard (8176cce)
- Update the core to mihomo v1.19.33 (0817c3b)
- **tray** Colored tray status icons; monochrome option on macOS (bbfafde)
- **desktop** Sidebar blur; Windows fixes; keeps system proxies FlClash didn't set (6928521)
- **profiles** Profile QR codes, phone-to-TV links, more proxy fields (eaaf3e3)
- **proxies** Add proxies to local proxies; adjustable delay test timeout (0f9f89c)
- **theme** Higher-contrast dark mode and a refreshed app icon (a4fc067)
- **ui** iOS-style docked search and menus; bar buttons lift on hover (0d98a9d)
- **ui** iOS-style switches, stretchy sheets, menus and long-press reordering (ae902ed)
- **ui** Pages scroll under the Android navigation bar (4837fb3)
- **core** Clear the DNS cache by hand or on network change (09e7e56)

**Bug Fixes**

- **android** Opening the app no longer reloads a running VPN (99b3381)

**Performance**

- **editor** Smoother editor for large files and in sheets (7035edd)

## v0.9.1 (2026-10-17)

**Breaking Changes**

- **network** Desktop TUN keys follow the profile unless picked; changed values carry over (cb08088)

**Features**

- **l10n** French, Spanish and Korean translations (f43755c)
- **android** No more Firebase analytics or crash reporting (bc72bba)
- **network** Per-key desktop TUN settings; system proxy and tray fixes (cb08088)
- **theme** Redesigned theme colors and color styles (5eafd7a)
- **dashboard** A redesigned dashboard around the current exit (9bd258f)
- **profiles** Profile-detail resources and include-all in custom groups (0bac500)
- **proxies** Proxy groups as cards, group tabs as chips (2ea52fd)
- **views** Sortable tables for connections, requests and DNS (da6fb0a)
- **ui** Optional two-tier Liquid Glass and slide-to-pick menus (7c9627f)
- **ui** iOS-style surfaces, alerts and sheets; clearer TV focus (9bd2286)

**Bug Fixes**

- **ui** Fix pasting and Chinese input in text fields (5607f70)
- **core** Large profiles no longer crash; downloads trust core CAs (5984c16)

**Performance**

- **android** Smoother Android UI while the proxy is busy (2201c19)

## v0.9.0 (2026-10-14)

**Breaking Changes**

- **views** DNS and NTP override toggles are removed; picked keys apply to every profile (491fae1)
- **database** Custom overwrites are removed; rebuild them as custom profiles (1677024)

**Features**

- **views** Per-key DNS, NTP, sniffer and TUN settings (491fae1)
- **profiles** Custom profiles (3abda78)
- **ui** Stacked sheets, context menus and a sort mode (8c43053)
- **providers** DNS, Hosts and ports apply without a restart (532ebf0)
- **android** Launcher shortcuts and one-step on-demand access (d3fa225)
- **core** Share link import and mrs rule sets (2fa2f7f)

**Bug Fixes**

- **database** Unreadable settings no longer block startup or restores (1677024)
- **desktop** Windows and Linux desktop fixes (94a25f4)
- **core,helper** The elevated Core only answers its owner (d780cb8)

## v0.8.99 (2026-10-03)

**Features**

- **editor** Editor word wrap and snippets (e131675)
- **dashboard** More dashboard cards (e62afb7)
- **views** Hide timed-out nodes and search every list (8378c70)
- **ui** Sidebar, floating dock and drag to go back (841d603)
- **ui** New app glyphs, empty states and theme page (ee6a497)
- **overwrite** Invalid override warnings and rule presets (46fb7fe)
- **config** DNS query log and per-key DNS/NTP overrides (a390a42)
- **core** Proxied service checks and outbound IP risk (8068e68)
- **platform** Tray hotkeys, node delays and a delay test (1e97716)

**Bug Fixes**

- **core** A changed resource link is now used by the next sync and by auto update (ff23f30)
- **core** DNS lookups no longer fail on networks that report no DNS servers (e55f6d1)
- **proxies** Smaller icons in icon-only group headers (786a6ab)
- **core,android** Push notifications reconnect in Doze (1e9955d)
- **backup,database** Restores never apply halfway (bee8f24)

## v0.8.98 (2026-09-14)

**Bug Fixes**

- **resources** Refresh the geo file size and time after an update finishes (c5bf5bd)
- **core** Keep the core running while Windows sleeps with the app suspended (60f371a)

## v0.8.97 (2026-09-10)

**Features**

- **ui** Rework the app UI and refresh the localization (26cfbaf)
- **app** Rework the app layer and window handling, and add proxy authentication (aaf934c)
- **desktop** Rework the desktop runners, packaging, and native build (c0fcbc0)
- **android** Rework the Android VPN service and lifecycle handling (ae29f38)
- **plugins** Rework the desktop plugins and add the Helper service and Rust bridge (adf715f)
- **core** Rework the core IPC and process lifecycle (c6eaa0a)

<!-- changelog:frozen -->
<!-- Entries below predate the structured pipeline. Their wording is kept as written; only the heading and list style were normalized. -->

## v0.8.96 (2026-08-17)

- Optimize commented policy
- Fix whole group delay test failing on Windows
- Optimize package icon loading and connections polling

## v0.8.95 (2026-08-14)

- Optimize core service
- Optimize Android TV launcher icon
- Optimize back navigation
- Optimize more details
- Fix some issues
- Optimize app layout
- Optimize focus control
- Adjust android process

## v0.8.94 (2026-07-11)

- Fix macos performance issue
- Support custom global-ua
- Update core
- Optimize some details
- Fix linux silent launching not working

## v0.8.93 (2026-05-29)

- Support custom overwrite
- Support run on demand
- Optimize windows ipc
- Optimize windows arm64
- Optimize build
- Optimize some details
- Update core

## v0.8.92 (2026-02-02)

- Add sqlite store
- Optimize android quick action
- Optimize backup and restore
- Optimize more details

## v0.8.91 (2025-12-12)

- Fix windows some issues
- Optimize overwrite handle
- Optimize access control page
- Optimize some details

## v0.8.90 (2025-10-08)

- Fix android tile service
- Support append system DNS
- Fix some issues
- Update changelog

## v0.8.89 (2025-09-27)

- Fix some issues
- Optimize Windows service mode
- Update core
- Update changelog

## v0.8.88 (2025-09-23)

- Add android separates the core process
- Support core status check and force restart
- Optimize proxies page and access page
- Update flutter and pub dependencies
- Update go version
- Optimize more details
- Update changelog

## v0.8.87 (2025-07-29)

- Optimize desktop view
- Optimize logs, requests, connection pages
- Optimize windows tray auto hide
- Optimize some details
- Update core
- Update changelog

## v0.8.86 (2025-06-15)

- Fix windows tun issues
- Optimize android get system dns
- Optimize more details
- Update changelog

## v0.8.85 (2025-06-07)

- Support override script
- Support proxies search
- Support svg display
- Optimize config persistence
- Add some scenes auto close connections
- Update core
- Optimize more details

## v0.8.84 (2025-05-01)

- Fix windows service verify issues
- Update changelog

## v0.8.83 (2025-05-01)

- Add windows server mode start process verify
- Add linux deb dependencies
- Add backup recovery strategy select
- Support custom text scaling
- Optimize the display of different text scale
- Optimize windows setup experience
- Optimize startTun performance
- Optimize android tv experience
- Optimize default option
- Optimize computed text size
- Optimize hyperOS freeform window
- Add developer mode
- Update core
- Optimize more details
- Add issues template
- Update changelog

## v0.8.82 (2025-04-18)

- Optimize android vpn performance
- Add custom primary color and color scheme
- Add linux nad windows arm release
- Optimize requests and logs page
- Fix map input page delete issues
- Update changelog

## v0.8.81 (2025-04-08)

- Add rule override
- Update core
- Optimize more details
- Update changelog

## v0.8.80 (2025-03-10)

- Optimize dashboard performance
- Fix some issues
- Fix unselected proxy group delay issues
- Fix asn url issues
- Update changelog

## v0.8.79 (2025-03-07)

- Fix tab delay view issues
- Fix tray action issues
- Fix get profile redirect client ua issues
- Fix proxy card delay view issues
- Add Russian, Japanese adaptation
- Fix some issues
- Update changelog

## v0.8.78 (2025-03-05)

- Fix list form input view issues
- Fix traffic view issues
- Update changelog

## v0.8.77 (2025-03-05)

- Optimize performance
- Update core
- Optimize core stability
- Fix linux tun authority check error
- Fix some issues
- Fix scroll physics error
- Update changelog

## v0.8.75 (2025-02-09)

- Add windows storage corruption detection
- Fix core crash caused by windows resource manager restart
- Optimize logs, requests, access to pages
- Fix macos bypass domain issues
- Update changelog

## v0.8.74 (2025-02-03)

- Fix some issues
- Update changelog

## v0.8.73 (2025-02-02)

- Update popup menu
- Add file editor
- Fix android service issues
- Optimize desktop background performance
- Optimize android main process performance
- Optimize delay test
- Optimize vpn protect
- Update changelog

## v0.8.72 (2025-01-10)

- Update core
- Fix some issues
- Update changelog

## v0.8.71 (2025-01-09)

- Remake dashboard
- Optimize theme
- Optimize more details
- Update flutter version
- Update changelog

## v0.8.70 (2024-12-09)

- Support better window position memory
- Add windows arm64 and linux arm64 build script
- Optimize some details

## v0.8.69 (2024-12-06)

- Remake desktop
- Optimize change proxy
- Optimize network check
- Fix fallback issues
- Optimize lots of details
- Update change.yaml
- Fix android tile issues
- Fix windows tray issues
- Support setting bypassDomain
- Update flutter version
- Fix android service issues
- Fix macos dock exit button issues
- Add route address setting
- Optimize provider view
- Update changelog
- Update CHANGELOG.md

## v0.8.67 (2024-11-09)

- Add android shortcuts
- Fix init params issues
- Fix dynamic color issues
- Optimize navigator animate
- Optimize window init
- Optimize fab
- Optimize save

## v0.8.66 (2024-10-26)

- Fix the collapse issues
- Add fontFamily options

## v0.8.65 (2024-10-26)

- Update core version
- Update flutter version
- Optimize ip check
- Optimize url-test

## v0.8.64 (2024-10-12)

- Update release message
- Init auto gen changelog
- Fix windows tray issues
- Fix urltest issues
- Add auto changelog
- Fix windows admin auto launch issues
- Add android vpn options
- Support proxies icon configuration
- Optimize android immersion display
- Fix some issues
- Optimize ip detection
- Support android vpn ipv6 inbound switch
- Support log export
- Optimize more details
- Fix android system dns issues
- Optimize dns default option
- Fix some issues
- Update readme

## v0.8.60 (2024-09-17)

- Fix build error2
- Fix build error
- Support desktop hotkey
- Support android ipv6 inbound
- Support android system dns
- fix some bugs

## v0.8.59 (2024-09-09)

- Fix delete profile error

## v0.8.58 (2024-09-08)

- Fix submit error 2
- Fix submit error
- Optimize DNS strategy
- Fix the problem that the tray is not displayed in some cases
- Optimize tray
- Update core
- Fix some error

## v0.8.57 (2024-09-02)

- Fix tun update issues
- Add DNS override
- Fixed some bugs
- Optimize more detail
- Add Hosts override

## v0.8.56 (2024-08-26)

- fix android tip error
- fix windows auto launch error

## v0.8.55 (2024-08-25)

- Fix windows tray issues
- Optimize windows logic
- Optimize app logic
- Support windows administrator auto launch
- Support android close vpn

## v0.8.53 (2024-08-15)

- Change flutter version
- Support profiles sort
- Support windows country flags display
- Optimize proxies page and profiles page columns

## v0.8.52 (2024-08-11)

- Update flutter version
- Update version
- Update timeout time
- Update access control page
- Fix bug

## v0.8.51 (2024-08-05)

- Optimize provider page
- Optimize delay test
- Support local backup and recovery
- Fix android tile service issues

## v0.8.49 (2024-07-31)

- Fix linux core build error
- Add proxy-only traffic statistics
- Update core
- Optimize more details
- Merge pull request #140 from txyyh/main
- 添加自建 F-Droid 仓库相关 workflow
- Rename readme fingerprint
- Rename workflow deploy repo name
- Add download guide to README
- Add push release files to fdroid-repo

## v0.8.48 (2024-07-25)

- Optimize proxies page
- Fix ua issues
- Optimize more details

## v0.8.47 (2024-07-22)

- Fix windows build error

## v0.8.46 (2024-07-22)

- Update app icon
- Fix desktop backup error
- Optimize request ua
- Change android icon
- Optimize dashboard

## v0.8.44 (2024-07-18)

- Remove request validate certificate
- Sync core

## v0.8.43 (2024-07-18)

- Fix windows error

## v0.8.42 (2024-07-18)

- Fix setup.dart error
- Fix android system proxy not effective
- Add macos arm64

## v0.8.41 (2024-07-17)

- Optimize proxies page
- Support mouse drag scroll
- Adjust desktop ui
- Revert "Fix android vpn issues"
- This reverts commit 891977408e6938e2acd74e9b9adb959c48c79988.

## v0.8.40 (2024-07-15)

- Fix android vpn issues
- Fix android vpn issues
- Rollback partial modification

## v0.8.39 (2024-07-15)

- Fix the problem that ui can't be synchronized when android vpn is occupied by an external
- Override default socksPort,port

## v0.8.38 (2024-07-14)

- Fix fab issues

## v0.8.37 (2024-07-14)

- Update version
- Fix the problem that vpn cannot be started in some cases
- Fix the problem that geodata url does not take effect

## v0.8.36 (2024-07-13)

- Update ua
- Fix change outbound mode without check ip issues
- Separate android ui and vpn
- Fix url validate issues 2
- Add android hidden from the recent task
- Add geoip file
- Support modify geoData URL

## v0.8.35 (2024-07-07)

- Fix url validate issues
- Fix check ip performance problem
- Optimize resources page

## v0.8.34 (2024-07-04)

- Add ua selector
- Support modify test url
- Optimize android proxy
- Fix the error that async proxy provider could not selected the proxy

## v0.8.33 (2024-07-01)

- Fix android proxy error
- Fix submit error
- Add windows tun
- Optimize android proxy
- Optimize change profile
- Update application ua
- Optimize delay test

## v0.8.32 (2024-06-28)

- Fix android repeated request notification issues

## v0.8.31 (2024-06-28)

- Fix memory overflow issues

## v0.8.30 (2024-06-27)

- Optimize proxies expansion panel 2
- Fix android scan qrcode error

## v0.8.29 (2024-06-27)

- Optimize proxies expansion panel
- Fix text error

## v0.8.28 (2024-06-26)

- Optimize proxy
- Optimize delayed sorting performance
- Add expansion panel proxies page
- Support to adjust the proxy card size
- Support to adjust proxies columns number
- Fix autoRun show issues
- Fix Android 10 issues
- Optimize ip show

## v0.8.26 (2024-06-22)

- Add intranet IP display
- Add connections page
- Add search in connections, requests
- Add keyword search in connections, requests, logs
- Add basic viewing editing capabilities
- Optimize update profile

## v0.8.25 (2024-06-19)

- Update version
- Fix the problem of excessive memory usage in traffic usage.
- Add lightBlue theme color
- Fix start unable to update profile issues
- Fix flashback caused by process

## v0.8.23 (2024-06-16)

- Add build version
- Optimize quick start
- Update system default option

## v0.8.22 (2024-06-16)

- Update build.yml
- Fix android vpn close issues
- Add requests page
- Fix checkUpdate dark mode style error
- Fix quickStart error open app
- Add memory proxies tab index
- Support hidden group
- Optimize logs
- Fix externalController hot load error

## v0.8.21 (2024-06-13)

- Add tcp concurrent switch
- Add system proxy switch
- Add geodata loader switch
- Add external controller switch
- Add auto gc on trim memory
- Fix android notification error

## v0.8.20 (2024-06-12)

- Fix ipv6 error
- Fix android udp direct error
- Add ipv6 switch
- Add access all selected button
- Remove android low version splash

## v0.8.19 (2024-06-10)

- Update version
- Add allowBypass
- Fix Android only pick .text file issues

## v0.8.18 (2024-06-09)

- Fix search issues

## v0.8.17 (2024-06-09)

- Fix LoadBalance, Relay load error
- Fix build.yml4
- Fix build.yml3
- Fix build.yml2
- Fix build.yml
- Add search function at access control
- Fix the issues with the profile add button to cover the edit button
- Adapt LoadBalance and Relay
- Add arm
- Fix android notification icon error

## v0.8.16 (2024-06-08)

- Add one-click update all profiles
- Add expire show

## v0.8.15 (2024-06-06)

- Temp remove tun mode
- Remove macos in workflow
- Change go version

## v0.8.14 (2024-06-06)

- Update Version
- Fix tun unable to open

## v0.8.13 (2024-06-06)

- Optimize delay test2
- Optimize delay test
- Add check ip
- add check ip request

## v0.8.12 (2024-06-06)

- Fix the problem that the download of remote resources failed after GeodataMode was turned on, which caused the
  application to flash back.
- Fix edit profile error
- Fix quickStart change proxy error
- Fix core version

## v0.8.10 (2024-06-05)

- Fix core version

## v0.8.9 (2024-06-05)

- Update file_picker
- Add resources page
- Optimize more detail
- Add access selected sorted
- Fix notification duplicate creation issue
- Fix AccessControl click issue

## v0.8.7 (2024-05-31)

- Fix Workflow
- Fix Linux unable to open
- Update README.md 3
- Create LICENSE
- Update README.md 2
- Update README.md
- Optimize workFlow

## v0.8.6 (2024-05-31)

- optimize checkUpdate

## v0.8.5 (2024-05-30)

- Fix submit error

## v0.8.4 (2024-05-30)

- add WebDAV
- add Auto check updates
- Optimize more details
- optimize delayTest

## v0.8.2 (2024-05-15)

- upgrade flutter version

## v0.8.1 (2024-05-15)

- Update kernel
- Add import profile via QR code image

## v0.8.0 (2024-05-11)

- Add compatibility mode and adapt clash scheme.

## v0.7.14 (2024-05-07)

- update Version
- Reconstruction application proxy logic

## v0.7.13 (2024-05-06)

- Fix Tab destroy error

## v0.7.12 (2024-05-06)

- Optimize repeat healthcheck

## v0.7.11 (2024-05-06)

- Optimize Direct mode ui

## v0.7.10 (2024-05-06)

- Optimize Healthcheck
- Remove proxies position animation, improve performance
- Add Telegram Link
- Update healthcheck policy
- New Check URLTest
- Fix the problem of invalid auto-selection

## v0.7.8 (2024-05-05)

- New Async UpdateConfig
- add changeProfileDebounce
- Update Workflow
- Fix ChangeProfile block
- Fix Release Message Error

## v0.7.7 (2024-05-04)

- Update Selector 2

## v0.7.6 (2024-05-04)

- Update Version
- Fix Proxies Select Error

## v0.7.5 (2024-05-03)

- Fix the problem that the proxy group is empty in global mode.
- Fix the problem that the proxy group is empty in global mode.

## v0.7.4 (2024-05-03)

- Add ProxyProvider2

## v0.7.3 (2024-05-03)

- Add ProxyProvider
- Update Version
- Update ProxyGroup Sort
- Fix Android quickStart VpnService some problems

## v0.7.1 (2024-05-01)

- Update version
- Set Android notification low importance
- Fix the issue that VpnService can't be closed correctly in special cases
- Fix the problem that TileService is not destroyed correctly in some cases
- Adjust tab animation defaults
- Add Telegram in README_zh_CN.md
- Add Telegram

## v0.7.0 (2024-04-30)

- update mobile_scanner
- Initial commit
