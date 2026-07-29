# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI.

## Version Notes

- `.fvmrc` pins Flutter 3.35.7 for local development.
- CI uses Flutter 3.41.9. These may diverge; trust CI as the source of truth for release builds.
- Dart SDK constraint: `>=3.8.0 <4.0.0`.

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
