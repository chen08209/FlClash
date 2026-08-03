# Performance improvement tasks

Investigation snapshot against fork `main` (`0.8.101`, based on upstream `7c83185`).
Goal: cut steady-state CPU/IPC while started, and reduce jank on Proxies / Connections / macOS tray.

## How to use

- Prefer **P0 → P1 → P2** order.
- Each task should land as its own PR with before/after notes (DevTools CPU / Timeline, or a short manual checklist).
- Do not regress: start/stop, delay test, profile apply, TUN/VPN.

## Already in good shape (do not redo)

- Delay → `updateGroups` debounced (~5s); profile apply / changeProxy debounced.
- Heavy profile/group work uses `compute()` isolates (`lib/common/task.dart`).
- Dashboard cards `keep: false`; requests/logs UI throttled (`FunctionTag.requests`).
- Charts wrapped in `RepaintBoundary`.
- macOS tray title split from full menu (`trayTitleStateProvider` vs `trayStateProvider`).
- Transparent/blur macOS sidebar left disabled.

Upstream history of note: `de9c5ba` dashboard, `c9cd80b` Android VPN, `7e7f1f8` macOS (mixed commit; tray/title isolation is the lasting pattern).

---

## P0 — High impact, clear evidence

### PERF-01 — Coalesce traffic IPC (1 Hz → less work) — DONE

**Problem:** While started, `SetupAction._handleStart` ran a 1s timer that called both `getTraffic` and `getTotalTraffic`.

**Done:**
- Added `getTrafficSnapshot` core action (`core/hub.go`, `ActionMethod.getTrafficSnapshot`).
- `CommonAction.updateTraffic` uses one IPC call and skips Riverpod writes when values are unchanged.

**Touches:** `lib/providers/action.dart`, `lib/core/*`, `core/hub.go` / `action.go` / `constant.go`

### PERF-02 — Connections page: lazy build + lighter poll — DONE

**Problem:** Eager widget map + 1s full snapshot poll.

**Done:**
- Build `TrackerInfoItem` only in `itemBuilder` (fixed separator `itemCount`).
- Poll every 2s; skip notifier updates on identical snapshots; pause when route inactive / app not resumed.
- Decode connection JSON via `compute()`.

**Touches:** `lib/views/connection/connections.dart`, `lib/core/controller.dart`

### PERF-03 — Proxies list: stop eager card materialization — DONE

**Problem:** `_buildItems` materialized every card before `ListView.builder`.

**Done:**
- Row descriptors (`_ProxyListEntry`); widgets built in `itemBuilder` only.
- Height extents still precomputed from descriptors.

**Touches:** `lib/views/proxies/list.dart`

### PERF-04 — Slim per-proxy delay watches — DONE

**Problem:** Each `delayProvider` → `realSelectedProxyState` watched full `groupsProvider`.

**Done:**
- `realSelectedProxyStateMapProvider` resolves once; per-proxy provider selects by name (equality-stable).

**Touches:** `lib/providers/state.dart`

### PERF-05 — Default `findProcessMode` to off — DONE

**Problem:** Default was `FindProcessMode.always`.

**Done:**
- Default and unknown-enum fallback set to `off` for new / unspecified configs.
- Persisted `"always"` values still restore as always.

**Touches:** `lib/models/clash_config.dart` (+ generated)

---

## P1 — Medium impact

### PERF-06 — macOS tray: avoid rebuilding all proxy submenus — DONE

**Done:**
- Cap each group submenu at 30 proxies (keep selected if outside head) + “Proxies…” to focus the window.
- Skip full tray menu rebuild when groups only reorder (same proxy-name set) or non-menu fields are unchanged; title still updates via `trayTitleStateProvider`.

**Touches:** `lib/common/tray.dart`, `lib/manager/tray_manager.dart`

### PERF-07 — FixedList / event ingest copies — DONE

**Problem:** Logs, requests, traffics used `FixedList.copyWith()` on every add, copying up to 500 entries.

**Done:**
- Mutate in place + `notifyClone()` (new identity, shared backing list) for Logs / Requests / Traffics.

**Touches:** `lib/common/fixed.dart`, `lib/providers/app.dart`

### PERF-08 — Preferences: dirty-section saves — DONE (pragmatic)

**Problem:** Debounced full `Config` JSON encode on every aggregate change.

**Done:**
- Skip SharedPreferences write when encoded JSON matches last saved payload.
- Debounce window increased to 1200ms for preference saves.

**Still open (optional):** true per-leaf persistence keys.

**Touches:** `lib/common/preferences.dart`, `lib/providers/action.dart`

### PERF-09 — Delay-test batch pressure — DONE

**Problem:** Delay tests batched 100 concurrent IPC calls.

**Done:**
- Adaptive batch size: 20 on Android, 40 elsewhere.

**Touches:** `lib/views/proxies/common.dart`

### PERF-10 — Access control package list — DONE

**Problem:** Access page refiltered packages and re-fetched icons on rebuild.

**Done:**
- Debounced search (`FunctionTag.accessQuery`).
- Memoized filtered view list.
- `Set` for selected lookups.
- Cached package icon futures.

**Touches:** `lib/views/access.dart`, `lib/enum/enum.dart`

---

## P2 — Lower priority / larger design

### PERF-11 — Push model for traffic / connections from core — DONE

**Problem:** Dart polled traffic every 1s (and connections every 2s) with request/response IPC while started.

**Done:**
- Core pushes a `traffic` event every 1s while the listener is running (`TrafficMessage`).
- Payload includes both all-traffic and proxy-only counters so Dart can honor `onlyStatisticsProxy` without another round trip.
- Dart timer only updates run-time; one-shot `getTrafficSnapshot` remains for immediate UI on start.
- Core also pushes a `connections` snapshot every 2s while listening (`ConnectionsMessage`); Connections page consumes the push and no longer polls when the listener is active.

**Touches:** `core/hub.go`, `core/constant.go`, `lib/core/event.dart`, `lib/enum/enum.dart`, `lib/manager/core_manager.dart`, `lib/providers/action.dart`, `lib/views/connection/connections.dart`

### PERF-12 — Narrow `configProvider` aggregation — DONE

**Done:**
- Preference dirty detection listens to leaf setting providers instead of `configProvider` (avoids rebuilding aggregate `Config` on every leaf change).
- High-churn derived providers / MaterialApp / sidebar use `.select` for the fields they need.
- `configProvider` documented as save/load/test aggregate only.

**Touches:** `lib/manager/app_manager.dart`, `lib/providers/state.dart`, `lib/application.dart`, `lib/providers/config.dart`

### PERF-13 — `EmojiText` cost on proxy names — DONE

**Done:** Skip emoji regex for BMP-only names; cache `TextSpan` lists.

**Touches:** `lib/widgets/text.dart`

### PERF-14 — Theme / layout storm — DONE

**Done:** `ThemeAction.updateViewSize` no-ops when size unchanged.

**Touches:** `lib/providers/action.dart`

### PERF-15 — Desktop IPC protocol — DEFERRED

Line-delimited / framed JSON for every action (`lib/core/service.dart`, `core/server.go` length-prefixed frames) is an architecture ceiling. Binary framing for hot counters is a long-term option; traffic/connections push (PERF-11) already removes the request half of those hot paths.

---

## Suggested next sprint

| Order | ID | Why |
|------|----|-----------|
| — | — | P0–P2 backlog complete except PERF-15 (deferred) |
| optional | PERF-15 | Binary / shared-memory counters if profiling still shows IPC ceiling |
| optional | PERF-08 follow-up | True per-leaf preference persistence keys |

## Out of scope for this list

- Geo identity / Tailscale feature work (unless they add new timers/IPC).
- Upstream mihomo internals beyond FlClash hub wrappers (track upstream separately).
- Rewriting the entire desktop IPC stack in one PR (see PERF-15).
