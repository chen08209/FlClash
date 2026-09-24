# Flutter Upgrade Checklist

Read this before changing `FLUTTER_VERSION` in `.github/workflows/build.yaml` or `.fvmrc`. Each entry is a
workaround tied to a Flutter bug: what it does, where it lives, and what has to be true before it can go. Remove an
entry together with its workaround; add one whenever a new workaround is pinned to the SDK.

## Stable cadence

Flutter ships a stable release about once a quarter, three minor versions apart (3.41 in February, 3.44 in May, 3.47
in August 2026). The two minors in between (3.48, 3.49) are beta only, so a fix that lands on `main` reaches stable
in the next multiple, 3.50, expected around mid-November 2026. Hotfix releases (3.47.x) carry only cherry-picks
listed in the SDK's `CHANGELOG.md`.

## Impeller disabled on Intel macOS release builds

- **Bug:** [flutter/flutter#191538](https://github.com/flutter/flutter/issues/191538). From 3.47, when Impeller
  became the default desktop renderer, Intel (x86_64) Macs flicker across the whole window while scrolling or
  animating, and text can render garbled. Apple Silicon is not affected.
- **Fix upstream:** landed on `main` before 2026-08-25 and verified on `3.48.0-1.0.pre-404`; it is not in any
  3.47.x hotfix (checked through 3.47.5).
- **Workaround:** the release job for `macos-15-intel` (`arch: amd64`) runs
  `plutil -replace FLTEnableImpeller -bool NO macos/Runner/Info.plist` before `dart setup.dart`, so only the Intel
  DMG falls back to Skia. The checked-in `Info.plist` does not set the key, so local builds and the arm64 DMG keep
  Impeller. The macOS embedder reads the key at launch in `FlutterDartProject.mm` (`enableImpeller`), release
  builds included.
- **Side effect:** Skia on Intel renders blur, shadows and text slightly differently; judge Intel-only visual reports
  against Skia, not Impeller.
- **Remove when:** `FLUTTER_VERSION` moves to a stable that contains the fix (3.50 or later, or a 3.47.x whose
  changelog lists #191538). Before dropping the step, build the Intel DMG without it and scroll the proxies and
  dashboard pages on an Intel Mac with its integrated GPU driving the built-in display; an external display can
  switch to the discrete GPU and hide the flicker.
