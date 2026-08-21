# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI.

## Version Notes

- Release CI pins Flutter 3.44.4. Local SDK may diverge, so trust the CI
  version as the source of truth for release builds.
- Dart SDK constraint: `>=3.8.0 <4.0.0`.

## Forked Dependencies

Three `pubspec.yaml` dependencies are pinned to a fork by commit SHA. All three
forks live under `chen08209`, the same account that owns this repository, so they
are maintained in-house rather than tracked from a third party: advancing a pin
is a local decision, and there is no external maintainer to wait on for the patch
itself. What each fork still waits on is the *upstream* fix that would let the
pin be dropped entirely, recorded below.

Each entry records what the fork changes and what has to be true before it can go
back to the published package, so a future upgrade does not have to rediscover it.
Re-verify a fork by diffing its pub cache checkout against the published version
of the same number:

```bash
diff -ru ~/.pub-cache/hosted/pub.dev/<name>-<version> ~/.pub-cache/git/<name>-<sha>
```

`window_manager` — `chen08209/window_manager`, path `packages/window_manager`,
version 0.5.1.

- Changes `windows/window_manager_plugin.cpp` only. With `titleBarStyle: hidden`
  a maximized window uses the monitor work area (`GetMonitorInfo().rcWork`)
  instead of upstream's `adjustNCCALCSIZE` border fudge, so the maximized window
  no longer covers the taskbar.
- Drop the fork once upstream constrains a hidden-title-bar maximized window to
  the work area on Windows. Dart API is untouched, so nothing in `lib/` changes.

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

## Dependency Ceilings

Several dependencies cannot be advanced from this repository, and re-running
`flutter pub outdated` will keep listing them. The blocker is upstream in every
case, so treat the list as resolved-until-the-ceiling-moves rather than as debt:

`freezed` is pinned exactly to `3.2.6-dev.1`, which is a pre-release *ahead* of
the newest stable `3.2.5`. It is not a stale pin and must not be "fixed" by
moving to `3.2.5`: stable `3.2.5` requires `analyzer >=9.0.0 <11.0.0`, while the
pinned Flutter SDK resolves `analyzer` 12. `3.2.6-dev.1` is the only published
freezed release that accepts `analyzer` 12. Move to a stable release only once
one exists that accepts the analyzer the SDK actually resolves.

One `analyzer` ceiling holds most of the remaining `flutter pub outdated` list.
The newest `build_runner`, `drift_dev`, `intl_utils`, `test`, and
`riverpod_generator` all require `analyzer` 13; `test` 1.31.2 additionally
requires `test_api` 0.7.13, while `flutter_test` from the pinned SDK depends on
`test_api` 0.7.11. Raising any of those bounds therefore fails version solving.

The `riverpod` chain is the visible symptom. It is held at
`riverpod`/`flutter_riverpod` 3.3.2, `riverpod_annotation` 4.0.3, and
`riverpod_generator` 4.0.4 as one rigid unit, because `riverpod_annotation`
4.0.3 depends on `riverpod` exactly 3.3.2: the runtime cannot move without the
generator, and the generator cannot move without `analyzer` 13. Retry the whole
set after a Flutter SDK bump raises `test_api`, not before.

`intl` is intentionally unbounded (`any`) and `material_color_utilities` is
resolved by the SDK; neither is a bound this repository sets.

`isolate_contactor` is discontinued and `isolate_manager` is several majors
behind. Both arrive through `re_editor`, which pins `isolate_manager: ^4.1.5+1`
and is already at its own latest release. Nothing in this repository can advance
them.

`CorePalette` is deprecated in `material_color_utilities` in favour of
`DynamicScheme`/`CorePalettes`, but `dynamic_color` 1.9.0 — its newest release —
still exposes only `DynamicColorPlugin.getCorePalette()`, which returns the
deprecated type. There is no migration available from this repository short of
calling the `io.material.plugins/dynamic_color` method channel directly and
decoding the palette int list by hand, which is not worth owning. The deprecated
type is therefore confined to `GlobalState._initDynamicColor`, which converts it
to the two plain seed colours the app actually consumes; everything downstream
sees `DynamicColorSeeds`. Revisit when `dynamic_color` ships a non-deprecated
accessor — only that one function has to change.

## Build Dependencies

Linux:

```bash
sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev
```

Windows:

- GCC and Inno Setup.
- `ANDROID_NDK` env var for Android builds.

macOS:

```bash
npm install -g appdmg
```
