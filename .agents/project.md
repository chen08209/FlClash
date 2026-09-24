# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI.

## Version Notes

- Flutter stays on the 3.47.x line. Release CI pins 3.47.4 and is the source
  of truth for release builds; `.fvmrc` and local SDKs may sit on another 3.47
  patch. `code_forge` 10.13 and later need Dart 3.13.2, so the CI pin cannot go
  below Flutter 3.47.2.
- The Dart SDK lower bound in `pubspec.yaml` sets the package language
  version. `flutter analyze` excludes `lib/**/generated/**`, so a raise is
  proven by `flutter test`, which parses the generated code, not by analyze.

## Forked Dependencies

Three `pubspec.yaml` dependencies are pinned to a fork, two by commit SHA and
`code_forge` by tag. All three forks live under `chen08209`, the same account
that owns this repository, so they are maintained in-house rather than tracked
from a third party: advancing a pin is a local decision, and there is no external
maintainer to wait on for the patch itself. What each fork still waits on is the
*upstream* fix that would let the pin be dropped entirely, recorded below.

Each entry records what the fork changes and what has to be true before it can go
back to the published package, so a future upgrade does not have to rediscover it.
Re-verify a fork by diffing its pub cache checkout against the published version
of the same number:

```bash
diff -ru ~/.pub-cache/hosted/pub.dev/<name>-<version> ~/.pub-cache/git/<name>-<sha>
```

The `window_manager` fork (`chen08209/window_manager`, tag `v0.5.1-flclash.3`)
was replaced by the in-repo `plugins/window` package; the behaviors it carried
(work-area maximize with a hidden title bar on Windows, geometry restore on
re-map on Linux, corner preference, terminate and activate events) live there
now, see the window plugin section of `architecture.md`.

`launch_at_startup` — `chen08209/launch_at_startup`, version 0.5.1.

- Migrates `win32_registry` from `^2.0.0` to `^3.0.3`, which is a breaking rename
  across the whole Windows implementation (`Registry.openPath` → `CURRENT_USER.open`,
  `createValue` → `setValue`, `getStringValue` → `getString`).
- This one is not optional while it lasts: FlClash depends on `win32_registry: ^3.0.3`
  directly, and upstream's `^2.0.0` constraint cannot co-resolve with it.
- Drop the fork when upstream publishes a release that accepts `win32_registry` 3.x.

`yaml_writer` — `chen08209/yaml_writer`, version 2.1.0.

- Adds `StringNode.quoteKey()` and applies it to map keys in `lib/src/node.dart`.
  Upstream quotes values but emits keys verbatim, so a profile key needing quotes
  is written as invalid YAML.
- Drop the fork once upstream quotes map keys by the same
  `isValidUnquotedString` rule it already applies to values.

`code_forge` — `chen08209/code_forge`, tag `v10.14.0-flclash.4`, version 10.14.0.
A new pin is a new `v<upstream version>-flclash.N` tag on the fork's `main`.

- Builds the Rust crate through a `hook/build.dart` Native Assets hook, the same
  `flutter_rust_bridge_hooks` path as `plugins/rust_api`, instead of the cargokit
  FFI plugin. The platform folders and `cargokit/` are gone, so macOS needs no
  CocoaPods fallback beside Swift Package Manager, and `rust/rust-toolchain.toml`
  pins the same channel and targets as `rust_api`.
- The hook honours `hooks.user_defines.code_forge.build_assets`, and
  `flutter_rust_bridge` is pinned to the exact version `rust_api` generates with,
  because a codegen and runtime mismatch throws in `RustLib.init()`.
- `CodeForgeKeyboardShortcuts.forPlatform` gives Cmd/Option bindings on Apple
  platforms, and `onContextMenu` and `scrollbarBuilder` let `lib/pages/editor.dart`
  show `CommonPopupMenu` and `FloatingScrollbar` instead of the built-in menu and
  scrollbar.
- Also fixes the caret drawn while read-only, word-left movement from the end of
  a word, the `attached` assertion when a tap arrives after the input method
  connection closed, and a caret left under the software keyboard when a tap
  opens it.
- Each change is its own commit, so one upstream adopts can be dropped on its
  own. The fork goes away only once upstream builds through Native Assets and has
  the hooks above.

## Dependency Ceilings

`flutter pub outdated` lists only upstream-held entries, so treat them as
resolved-until-the-ceiling-moves rather than as debt:

- `intl` is intentionally unbounded (`any`) and `material_color_utilities` is
  resolved by the Flutter SDK; neither is a bound this repository sets.

`freezed`, the `riverpod` set, `build_runner`, `drift_dev`, `intl_utils` and
`test` all resolve against the analyzer the pinned SDK ships; none of them is
held back. When an upgrade fails version solving, record the blocker here with
what has to change upstream before the pin can move, so the next
`flutter pub outdated` run does not rediscover it.

`_initDynamicColor` in `lib/bootstrap.dart` reads the `dynamic_color` method
channel directly and decodes the palette list into a `TonalPalette`, instead of
going through `DynamicColorPlugin.getCorePalette()` and its deprecated
`CorePalette` return type. Everything downstream sees `DynamicColorSeeds`, so a
non-deprecated plugin accessor changes only that one function.

## Build Dependencies

Linux:

```bash
sudo apt-get install libayatana-appindicator3-dev
```

Windows:

- GCC and Inno Setup.

macOS:

```bash
npm install -g appdmg
```
