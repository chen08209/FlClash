# rust_api

Flutter Rust Bridge FFI package for FlClash. The Rust crate under `rust/` is compiled by the Dart build hook in
`hook/build.dart` through Native Assets, so there are no platform folders: Flutter runs the hook during every build
and bundles the resulting `librust_api` itself.

## Requirements

- `rustup`, with the toolchain and targets pinned in `rust/rust-toolchain.toml` (installed on first build).
- The Android NDK for Android builds.
- `flutter_rust_bridge_codegen` matching the `flutter_rust_bridge` version in `pubspec.yaml`, to regenerate bindings:

```bash
flutter_rust_bridge_codegen generate
```
