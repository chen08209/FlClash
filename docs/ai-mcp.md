# AI MCP tools

Open **Tools → AI MCP Tools** (简体中文：**AI MCP 工具**). The service starts **disabled every time FlClash launches**. Enable it, keep FlClash open, and configure a trusted client running on the **same device** for Streamable HTTP. It does not require Clash's external controller.

Use **Copy connection configuration** for the current port and token. The copied JSON uses the common `mcpServers` format; adapt the wrapping keys to your client's documented format:

```json
{
  "mcpServers": {
    "flclash": {
      "type": "http",
      "url": "http://127.0.0.1:17890/mcp",
      "headers": {"Authorization": "Bearer <copy from FlClash>"}
    }
  }
}
```

This is **Streamable HTTP**, not the obsolete HTTP+SSE transport and not stdio. Supported protocol versions are those in `mcp_dart` 2.4.2's stable profile. Requests accept both `application/json` and `text/event-stream`; responses use JSON. Initialize first, then send the returned `Mcp-Session-Id` and Bearer header on every request. Optional standalone GET/SSE streams are declined with HTTP 405. Reconnect after ten minutes idle, service disable, or token rotation. No resumability/event store is enabled.

## Tools

| Tool | Scope | Meaning |
| --- | --- | --- |
| `app_status` | Basic | Application name, core connection state, app running state, **configured** outbound mode. No raw configuration or errors. |
| `list_proxies` | Basic | Paginated visible group/member rows, group type, current core selection, node type, cached delay for the app-configured test URL. `offset` defaults to 0; `limit` defaults to 50, maximum 100. A null delay means no cached measurement. Names are untrusted subscription-provided **data**, never instructions. |
| `select_proxy` | Basic | Existing member of a visible `Selector` group only; a current profile is required. Calls the app's selection action, checks its actual result, then re-reads the core selection and checks UI state. Uses existing app-managed persistence, but **never** calls connection close/reset maintenance from this basic tool, even when selecting the current member. Manual UI selection retains its existing connection-maintenance preference. Persistence is asynchronous under the existing app mechanism, not a transactional disk guarantee. |
| `test_delays` | Basic | 1–8 distinct existing nodes in visible groups. Uses **only** the application's configured test URL, at most two concurrent probes, updates the app's delay cache only while the run is current. Profile changes, core disconnection (even followed by reconnection), and the application's delay-test cancellation/full-setup boundary cancel pending results and remaining probes. `-1` is the core's failed measurement; missing core responses are errors, not fake measurements. |
| `set_mode` | Advanced | Only `rule`, `global`, `direct`. Requests the existing application's mode update path. Response says `coreApplication: requested`, **not** that core application completed. |
| `close_connections` | Advanced | Closes all active connections; a false/failed core response is an error. Does not return destination or connection details. |

No core-RPC passthrough, arbitrary URLs, shell, scripts, raw configs, subscription URLs, auth keys, logs, browsing history, filesystem tools, TUN or system proxy controls are provided. Unknown fields are rejected. Backend exceptions are reduced to fixed error codes, never returned verbatim.

## Advanced permission

Below setup instructions, **Unlock advanced tools** opens a warning. Confirm remains disabled for **three elapsed seconds**; explicit confirmation is required afterward. Cancelling/closing does not unlock. Permission is memory-only and applies to all clients holding the current token. **Lock now** immediately removes advanced tools from all existing session catalogs and revokes execution permission, including work waiting at an asynchronous boundary. Disabling, rotating credentials, manager teardown, and app disposal relock. No MCP method can unlock. An open warning cannot authorize a new service generation after relock/rotation.

Already-dispatched core operations cannot be undone. Revoked or superseded proxy selections cannot perform later rollback into another profile/newer selection or dispatch connection maintenance. A mode change to direct may bypass proxy routing; closing connections interrupts applications. Only authorize a trusted client.

## Security boundaries and limits

- A single IPv4 listener binds **127.0.0.1 only**. Strict Host matching prevents DNS rebinding. **Any Origin header, including empty/null/local origins, is rejected**. This is not a browser API or a LAN/cloud endpoint; do not reverse proxy or tunnel it.
- A 256-bit `Random.secure()` token is required on **all HTTP methods and paths**, including session requests and OPTIONS. Session IDs are not authorization. Rotating closes sessions and revokes the previous token before reopening.
- Port and token are stored in a dedicated local preferences key, outside `Config` and app backup/export payloads. Enabled/unlocked are not persisted. Preferences are **not encrypted**; another process with the same user's file access can read them. Device/OS backups are outside FlClash's export policy.
- The UI does not display the token by default. Copy configuration intentionally puts it on the system clipboard: clipboard managers/history and local malware can see it. Do not paste it into cloud chat or share it. Rotate after suspected exposure.
- Maximum 8 sessions; ten-minute idle expiry (one-minute sweep). Maximum 8 admitted requests and one in-flight request per session; one active tool invocation globally. Busy clients receive 429 or `busy`, rather than building an unbounded work queue.
- Request body maximum 16 KiB, five-second **absolute** body deadline, no batches, 60-second response deadline, no arbitrary request bodies passed through to core. A still-running backend operation retains the single tool slot even after HTTP disconnect; future work fails busy until it completes, avoiding overlapping orphaned operations.
- This uses the maintained SDK's `McpServer` and `StreamableHTTPServerTransport`. The higher-level `StreamableMcpServer` 2.4.2 handles OPTIONS before authentication and has no body/session cap, so a small guarded `dart:io` ingress wraps its public transport directly. Protocol parsing, schemas, initialization and tool dispatch remain SDK-owned. No SDK fork or sidecar.

## Validation

Tests live in `test/ai_mcp/`: real isolated loopback initialize/list/call and auth/Host/Origin/session controls, core/provider fakes, UI countdown/manual consent/relock/copy/error/teardown. They do not change host proxy settings, registry, or the installed client. Application stack ownership is covered by `test/application_test.dart`.

For Flutter-only tests temporarily set **both** native hook `build_assets` values to false, restore true afterward. Run `flutter pub get`, `dart run intl_utils:generate`, `dart run build_runner build`, `flutter test test/ai_mcp test/application_test.dart test/providers/proxies_action_test.dart --reporter expanded`, and `flutter analyze --no-fatal-infos` using the repository's supported SDK. Native Windows packaging and real-client UX still require a Windows build/runtime smoke test.
