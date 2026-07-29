# Commands

## Building

Update submodules first. The ClashMeta Go core lives in `core/Clash.Meta/`.

```bash
git submodule update --init --recursive
```

Full package build, including Go core, Flutter, and packaging, runs through `setup.dart`:

```bash
dart setup.dart macos
dart setup.dart linux
dart setup.dart windows
dart setup.dart android
```

Build only the Go core and skip Flutter packaging:

```bash
make core-macos
make core-linux
make core-windows
make core-android
```

Pass `ARCH` or `TARGET_PLATFORM` through `make` when needed, for example:

```bash
make core-macos ARCH=arm64
make core-android TARGET_PLATFORM=android-arm64
```

The Makefile wraps `plugins/setup/buildkit/run_build_tool.sh`; prefer the `make` entry points unless debugging the build tool itself.

## Flutter Development

The project is pinned with FVM.

```bash
fvm flutter pub get
fvm flutter run
fvm flutter test
```

Plain Flutter also works when the global SDK matches project constraints:

```bash
flutter pub get
flutter run
flutter test
```

Use `flutter test`, not `dart test`, because models pull in Flutter types.

## Code Generation

Run code generation after modifying models, providers, or database schema:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch
```

Code generation covers:

- Riverpod providers through `riverpod_generator`.
- Models through `freezed` and `json_serializable`.
- Database tables through `drift_dev`.

Generated output paths, configured in `build.yaml`:

- `lib/models/generated/*.g.dart`, `*.freezed.dart`.
- `lib/providers/generated/*.g.dart`.
- `lib/database/generated/*.g.dart`.

## Testing

Tests use `package:test/test.dart` for pure Dart logic and `flutter_test` for provider and widget tests. `mocktail` is the mocking framework.

```bash
flutter test test/models/
flutter test test/core/
flutter test test/providers/
flutter test test/common/
flutter test test/database/
flutter test test/widgets/
flutter test test/setup_test.dart
flutter test plugins/proxy/test/proxy_test.dart
```

Root `flutter test` only discovers the root package's `test/` directory by default. Include bundled plugin Dart tests by passing paths explicitly, or run `flutter test` from that plugin package directory. Native plugin tests under platform folders are not run by `flutter test`.

## Verify

CI runs these in order:

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

Run `flutter analyze` locally before committing when practical.
