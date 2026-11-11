# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, drawing its own components in the `prism_ui` package: a color system of its own with Apple's Human Interface interaction conventions.

## Version Notes

- Flutter stays on the 3.50.x line. Release CI pins 3.50.0 and is the source
  of truth for release builds; `.fvmrc` and local SDKs may sit on another 3.50
  patch. `pubspec.yaml` requires Flutter 3.50.0, because the app imports
  `ScrollCacheExtent` through `package:flutter/widgets.dart`, which re-exports it
  only from 3.50.
- Before moving the pin, walk `flutter-upgrade.md`: it lists the workarounds tied to
  the current SDK, such as Impeller disabled on the Intel macOS release build.
- The Dart SDK lower bound in `pubspec.yaml` sets the package language
  version. `flutter analyze` excludes `lib/**/generated/**`, so a raise is
  proven by `flutter test`, which parses the generated code, not by analyze.
  The root package stays at 3.10 while the SDK is 3.14: at 3.13 and above
  `dart format` rewrites about 190 files and `final` parameters stop compiling,
  and APIs marked `@Since("3.14")`, such as `rangeEquals` on typed data, fail
  analysis with `sdk_version_since` until the bound moves.

## Forked Dependencies

One `pubspec.yaml` dependency is pinned to a fork by commit SHA. The fork lives
under `chen08209`, the same account that owns this repository, so it is
maintained in-house rather than tracked from a third party: advancing a pin is a
local decision, and there is no external maintainer to wait on for the patch
itself. What the fork still waits on is the *upstream* fix that would let the pin
be dropped entirely, recorded below.

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

The `yaml_writer` fork (`chen08209/yaml_writer`) was replaced by
`lib/common/yaml_writer.dart`. Its key quoting let keys such as `!a`, `'a` or
`0x1F` reach the Core's yaml.v3 as a parse error or a non-string; a merge key
`<<` stays plain on purpose, because `package:yaml` keeps it as an ordinary key
and the Core applies the merge.

The `code_forge` fork (`chen08209/code_forge`) is frozen: its Dart code now lives
in the in-repo `plugins/code_forge` package and its Rust code in the `editor/`
module of `plugins/rust_api`, both trimmed to what FlClash uses.
`plugins/code_forge/README.md` records what was kept and what was removed;
upstream's MIT notice stays in `plugins/code_forge/LICENSE`.

## Dependency Ceilings

`flutter pub outdated` lists only upstream-held entries, so treat them as
resolved-until-the-ceiling-moves rather than as debt:

- `intl` is intentionally unbounded (`any`), which is not a bound this repository
  sets.

The rest trail their latest releases only because the lock file was not
refreshed, except for these:

- `flutter_riverpod` 3.5.0 depends on `material_ui`, so a plain
  `flutter pub upgrade` brings `material_ui` and `cupertino_ui` into the lock
  file. Nothing fails when it does: `test/lint/design_package_test.dart` checks
  imports, not the lock file.
- `freezed` 4.0.3 needs `analyzer` 14, which `intl_utils` accepts from 2.8.17;
  both resolve together once the lock file is refreshed. `intl_utils` is
  discontinued.
- `test` 1.33.0 needs `test_api` 0.7.15, and `flutter_test` on Flutter 3.50 pins
  0.7.14. It moves with the SDK.
- `file_picker` 13 is a major upgrade. Until it lands, `android_file_picker` 1.x
  keeps `android.newDsl=false` in `android/gradle.properties`: it configures
  AGP's legacy `LibraryExtension`, which the new DSL does not register.

When an upgrade fails version solving, record the blocker here with
what has to change upstream before the pin can move, so the next
`flutter pub outdated` run does not rediscover it.

`_initDynamicColor` in `lib/bootstrap.dart` takes the system's seeds and accent color from `DynamicColorPlugin`,
in the plugin at `plugins/dynamic_color`, which keeps the native side out of the UI library's
own tree. Everything downstream sees `DynamicColorSeeds`.

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
