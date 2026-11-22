---
name: test-scope
description: Use when about to run `flutter test`, `dart run tool/test.dart`, `go test`, `cargo test`, Gradle unit tests or `tool/check_plugins.sh`; when deciding which checks a change needs, including changes under `core/`, `android/`, `plugins/`, `services/helper`, `tool/` or `.github/`; before sending a change for review or reporting it done; or when a run lists files that failed in a shared isolate.
---

# Test Scope

Size every check to the change. The commands live in `.agents/commands.md` (Testing, Native Component Verification,
Verify) and `make help`; this skill decides which of them a change runs and where.

## What a Change Runs

| Change under | Checks | Where |
|---|---|---|
| `lib/`, `test/`, `arb/`, `assets/` | Which Tests below, `flutter analyze --no-fatal-infos` | host |
| an `rsFeature` check or code behind one | the `rsFeature` pass below, `make strip-check` | host |
| `plugins/prism_ui`, `plugins/code_forge`, `plugins/dynamic_color`, Dart in `plugins/rust_api` | `make plugins-check`; the root `test/plugins/` files for the plugin | host |
| `plugins/setup` | `dart analyze` and `dart test` in `plugins/setup/setup_hooks` | host |
| `plugins/rust_api/rust` | `make rust-check`; the root tests that load the library, such as `test/plugins/code_forge/` and `test/core/desktop/ipc_native_test.dart` | host; Linux for `cfg(target_os = "linux")` |
| `services/helper` | `make rust-check` | host; Windows for `--features windows-service` |
| `core/*.go`, the `core/Clash.Meta` pointer | `make core-check core-test`; root tests that read Go sources, such as `test/core/protocol_contract_test.dart` and `test/models/` | host |
| `android/` | compile the touched modules, the JVM unit tests | host; a device or emulator for system callbacks such as always-on VPN, revoke, the permission UI, rapid start and stop |
| `linux/`, `macos/`, `windows/`, `plugins/*/{linux,macos,windows}` | `flutter build <platform> --debug` | that platform |
| `tool/` scripts, `Makefile` | `test/tool/` | host |
| `tool/package.dart` and packaging config | `test/tool/`, a `DRY=1` package target | host; that platform for a real package |
| `tool/hooks/` | `make hooks-test` | host |
| `site/` | `test/tool/site_palette_test.dart`, `test/tool/site_shapes_test.dart` | host |
| `changelog.json`, `CHANGELOG.md` | `make changelog-verify` | host |
| `.github/scripts/`, `.github/ISSUE_TEMPLATE/` | `node --test .github/scripts/` | host |
| `.github/workflows/` | none locally; only a run proves it | CI |

- Shared bases, listed under Which Tests, add the full root suite whatever row they fall in.
- On the private `origin` every CI job runs only when started by hand, so the rows above are what runs before a merge.
- Gradle, which also builds the gomobile AAR, a cold `cargo` build, a desktop debug build and the first Go core build
  of the build hook each take long and load the whole machine.
- Report a check you could not run as skipped, with the reason: a missing toolchain (`make doctor` names it), another
  platform, or no device. Never report it as passed.

## Which Tests

The root package's Flutter and Dart tests, sized to the change; keep the full suite for the two cases below.

- While editing, run only the tests of the files you changed: the mirrored path (`lib/a/b.dart` →
  `test/a/b_test.dart`), test files named for the same feature, and tests that import a changed file directly.
- Before sending a change for review, run the test directories it touches with `dart run tool/test.dart <dir>...`,
  adding `test/lint` whenever `lib/` changed, since those tests scan all of `lib/`. Name the directories and the test
  count from the run's last line in the report.
- Run the full suite (`dart run tool/test.dart`) only when the change touches a shared base, or in a branch's last
  review round; no other round runs it. The shared bases are `pubspec.yaml` and `pubspec.lock`, the build hook in
  `plugins/setup`, models and anything `build_runner` regenerates, `lib/common/` and the barrel files
  (`lib/models/models.dart`, `lib/widgets/widgets.dart` and the like), `plugins/prism_ui`, `analysis_options.yaml` and
  `lint_options.yaml`, and `test/helpers/` or `tool/test.dart`. Over half the test files import a barrel, so no import
  graph narrows such a change.
- Keep the last round's full run: on the private `origin` the CI checks run only when started by hand, so nothing else
  runs the suite before a merge.
- Run a test that only runs on another platform, such as a `cfg(target_os = "linux")` Rust test in
  `plugins/rust_api/rust` or a test that needs a display, on a machine of that platform, not on the host.
- A host test never starts the real app or Core and never changes the host's network, proxy or system settings; see
  Running the App Locally and the `@visibleForTesting` seams under Shared Test Isolate in `.agents/rules.md`.

## Reading a `tool/test.dart` Run

The script imports the test files into 32 entrypoints, and the files of one entrypoint share an isolate. When files
fail there, it prints `N file(s) failed in a shared isolate; running them on their own:` with their paths, then runs
them alone, and that run decides the exit code; the bundle failures printed above that line do not.

- `Every file above passes on its own` and exit 0: the run passed. Each listed file leans on, or is broken by, state
  another file left; name it in the report. If the change touched the file or the global it trips on, fix it as Shared
  Test Isolate in `.agents/rules.md` says.
- The rerun fails: a real failure.
- `The run still fails: other failures came from files that ran on their own, or from no file the report names`: a
  real failure whatever the rerun found. Files with a library-level annotation such as `@TestOn` always run alone.
- Passing your own `--file-reporter` turns the rerun off, so any failure fails the run.

After a rerun, report the first run's count and the rerun's result, not just the last line.

## The `rsFeature` Pass

Only when the change touches code behind an `rsFeature` check, or a test inside `if (rsFeature) { ... }`, also run the
tests it reaches with the feature on: set `const rsFeature = true;` in `lib/common/constant.dart`, run them, and set it
back before staging. Report both counts. The check forms are in rsFeature in `.agents/rules.md`.

## A Worktree Without the Go Core Build

The build hook builds the Go core for every `flutter test`, which needs Go, and on Linux and Windows `cargo`. For a
Dart-only run in a worktree that cannot build it:

1. Check out the submodules at the commits the tree records (`git submodule status`), or extract them from another
   checkout's submodule with `git -C <checkout>/<submodule> archive <commit> | tar -x -C <submodule>`.
   `flutter pub get` needs `plugins/prism_ui`; every `flutter test` needs the asset
   `core/Clash.Meta/component/ca/ca-certificates.crt` and stops at `No file or variants found for asset` without it;
   tests under `test/models/` and `test/providers/` read Go sources under `core/Clash.Meta/`.
2. Turn off only the `setup` hook:
   `perl -0pi -e 's/(setup:\n\s+build_assets:) true/$1 false/' pubspec.yaml`. Keep `rust_api` on: the editor tests in
   `test/plugins/code_forge/` and `test/core/desktop/ipc_native_test.dart` load the Rust library (see
   `.agents/commands.md`).
3. Set it back before staging, and never commit `false`.
