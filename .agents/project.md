# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI.

## Version Notes

- CI pins Flutter 3.44.4 via `FLUTTER_VERSION` in `.github/workflows/build.yaml`; treat it as the source of
  truth. There is no `.fvmrc` in the repository.
- `pubspec.yaml` declares the Dart SDK constraint `>=3.8.0 <4.0.0`, but the effective minimum is higher:
  `app_links` requires Dart `>=3.12.0`, so anything older than Flutter 3.44 fails to resolve.

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
