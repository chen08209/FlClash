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

Core builds use setup's input fingerprint cache. Pass `FORCE=1` to bypass it,
for example `make core-macos ARCH=arm64 FORCE=1`.

The Makefile wraps `plugins/setup/buildkit/run_build_tool.sh`; prefer the `make` entry points unless debugging the build tool itself.

## Flutter Development

Use the default Flutter SDK directly:

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
flutter test test/core/desktop/
flutter test test/providers/
flutter test test/common/
flutter test test/database/
flutter test test/widgets/
flutter test test/setup_test.dart
flutter test plugins/proxy/test/proxy_test.dart
```

Root `flutter test` only discovers the root package's `test/` directory by default. Include bundled plugin Dart tests by passing paths explicitly, or run `flutter test` from that plugin package directory. Native plugin tests under platform folders are not run by `flutter test`.

For the current Core/service architecture, useful focused checks are:

```bash
flutter test test/core/desktop/
flutter test test/core/service_test.dart
flutter test test/core/protocol_contract_test.dart
flutter test test/manager/core_manager_test.dart
flutter test test/providers/action_test.dart test/providers/system_action_test.dart
flutter test test/widgets/core_status_button_test.dart
```

What those suites own:

- `test/core/desktop/`: replaceable IPC transport, RPC request correlation/failure, direct/Helper process leases, and
  latest-intent desktop lifecycle convergence.
- `test/core/service_test.dart`: `CoreService` composition and terminal close behavior.
- `test/core/protocol_contract_test.dart`: shared Dart/Go method and event-envelope compatibility, including event batches.
- `test/providers/action_test.dart`: Core start/restart orchestration and overlapping restart requests.
- `test/providers/system_action_test.dart`: ordered, idempotent exit cleanup and watchdog behavior.
- `test/widgets/core_status_button_test.dart`: 600-millisecond connecting presentation hold, immediate failure display,
  long-running connecting state, and disconnected restart.

## Native Component Verification

The CI Go-wrapper checks can be reproduced without CGO:

```bash
cd core
CGO_ENABLED=0 go test .
CGO_ENABLED=0 go vet .
```

The Windows Helper's loopback/session protocol tests are host-independent by default. Windows CI additionally enables its
service implementation:

```bash
cargo fmt --manifest-path services/helper/Cargo.toml -- --check
cargo test --manifest-path services/helper/Cargo.toml
cargo test --manifest-path services/helper/Cargo.toml --features windows-service
```

The last command requires Windows for meaningful service coverage. Native Android lifecycle edits should at minimum
compile the modules they touch; use JDK 17 in this checkout:

```bash
cd android
JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ./gradlew :service:compileDebugKotlin
JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ./gradlew :app:compileDebugKotlin
```

Always-on VPN entry, system VPN revoke, actual permission UI, and rapid device start/stop still require Android device or
emulator validation; Kotlin compilation cannot prove those system callbacks.

## Verify

The tag-triggered release workflow runs these root-package checks in order:

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

Run `flutter analyze` locally before committing when practical.

The workflow runs only for `v*` tag pushes; pull requests do not trigger it.
Root analysis excludes `plugins/**`, and root tests do not discover nested
plugin packages, so CI also validates local Flutter packages, the setup build
tool, the Go wrapper, and Rust components from their own package directories. A
separate Windows runner compiles and tests the helper's `windows-service`
feature before release builds can start.
