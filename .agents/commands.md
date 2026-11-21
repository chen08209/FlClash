# Commands

`make` is the entry point on macOS and Linux: `make help` lists every target with its variables, generated from the
`##` comments in the `Makefile`, and `test/tool/makefile_test.dart` keeps the two in step. Each target only calls the
command this file documents, so the logic stays in `tool/` and `xtask`; `make doctor` names a missing toolchain,
`make check` is CI's `dart` job, `make core-gate` the Concord gate, and `make run` starts the safe mode build, the only
kind a shared host may run.

## Building

Update submodules first. The Core is Concord in the `concord/` submodule, which needs `cargo` and
the toolchain pinned in `concord/rust-toolchain.toml`.

```bash
git submodule update --init --recursive
```

Full package build, including the Concord core, Flutter, and packaging, runs through `tool/package.dart` (`make package`,
`make package-android`, with `ARCH=`, `FORM=` and `DRY=1`). Run it with `dart`, not `dart run`, which first runs
every build hook for the host:

```bash
dart tool/package.dart                     # this host: dmg, exe + zip, or deb + AppImage + rpm
dart tool/package.dart android             # every ABI; --arch arm64 for one
dart tool/package.dart linux --dry-run --arch arm64   # names and steps only, any platform
```

Artifacts land in `dist/` as `FlClash-<version>-<os>-<arch>[-<form>].<ext>`, with `manifest.json` and
`FlClash-<version>-SHA256SUMS`; see Packaging in `architecture.md`.

The desktop Concord core and the Rust helper build automatically: Flutter runs
`plugins/setup/hook/build.dart` on every `flutter build` and `flutter test`,
and the hook drives `CoreBuilder` from the `setup_hooks` package in
`plugins/setup/setup_hooks/`, which runs `cargo build` for `concord-desktop` and the Helper. Artifacts land in
`libclash/`. Android's Core is `libconcord.so` with the JNI glue `libcore_jni.so`, which the `:core` Gradle
module builds with its `cargoCore` task before anything compiles against it; that needs `cargo` on `PATH` and the NDK from AGP. The hook reruns only when Concord,
Helper, or `setup_hooks` inputs change; the fingerprint cache lives in
`.dart_tool/setup_build_cache/`. To force a rebuild, delete that directory:

```bash
rm -rf .dart_tool/setup_build_cache
```

Flutter hides the hook's output on success, so to see why the Core was or was
not rebuilt read `.dart_tool/setup_build_cache/hook.log`; each invocation starts
with a `===` line carrying its timestamp and target.

Both Rust builds, the Helper and `rust_api`, pass `--remap-path-prefix` so no
local path lands in a binary. With neither `RUSTFLAGS` nor
`CARGO_ENCODED_RUSTFLAGS` set, the flags go into `CARGO_TARGET_<TRIPLE>_RUSTFLAGS`,
which Cargo joins with `target.<triple>.rustflags` from a Cargo config but which
leaves `build.rustflags` unread, so put custom flags under the target table.
Either variable set, or a home, checkout or Cargo home path with a space, sends
the flags through `CARGO_ENCODED_RUSTFLAGS` instead, and Cargo then reads no
rustflags from its config.

The hook runs for `flutter test` and for `dart run` of any root-package script
too, so a pure Dart test run needs `cargo` and `rustc` — the fingerprints shell out to
both even on a cache hit. The hook protocol carries no build mode and no caller, so the only
switch is the user-define in the root `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    setup:
      build_assets: true   # false turns the Core and Helper hook into a no-op
    rust_api:
      build_assets: true   # false does the same for the Rust library
```

CI flips `setup` to `false` with `yq` in its throwaway checkout before
`dart run tool/changelog.dart` and `dart run tool/test.dart`; no test loads the Core. `rust_api`
stays on there because the editor tests in `test/plugins/code_forge/` and the socket
test in `test/core/desktop/ipc_native_test.dart` load the Rust library the hook
builds; the release-notes job, which runs no tests, flips both.
Never commit `false`: a build with it set stages whatever `libclash/` already
holds and bundles no Rust library, which is why `tool/package.dart` refuses to package
while it is set. Locally, `false` is worth setting for a Dart-only test loop,
but the hook cache keys on the user-define, so the first build afterwards runs
the hooks again. The editor and IPC socket tests still need the Rust library: keep `rust_api`
on, or point `FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR` at a directory that
holds a `rust_api` library built from the same sources.

## Flutter Development

Use the default Flutter SDK directly:

```bash
flutter pub get
flutter run
flutter test
```

Use `flutter test`, not `dart test`, because models pull in Flutter types.

A development build takes over the host exactly like a release: it creates the TUN device, sets the system proxy, on
macOS registers the TUN as the system resolver, registers itself as the login item, and on Windows and Linux starts its
Core through the shared privileged Helper, which stops the Core an installed FlClash is running. Only the data directory
is kept apart, and only for some builds: a macOS debug build is `com.follow.clash.rs.debug` and an Android debug build `com.follow.clash.rs.dev`,
while profile and release builds, and every build on Windows and Linux, share the directory and preferences of the
installed app. Safe mode keeps all of the host changes off and never opens the Core's listeners or external
controller, so it does not compete with the installed app for the mixed, DNS, RESTful API and other loopback ports:

```bash
flutter run --dart-define-from-file=env.json --dart-define=SAFE_MODE=true
```

`.run/main_safe_mode.run.xml` is the same launch for IntelliJ, and `Flutter App (Safe Mode)` in `.zed/debug.json` (debugger) or `flutter run (Safe Mode)` in `.zed/tasks.json`
(plain run) for Zed. The build is bannered `SAFE MODE`, the tray shows the
`status_4` bug icon with a menu of only show and exit and no traffic title, and the settings keep their values, so
nothing has to be flipped back before a normal run. See the safe mode section of `architecture.md` for the owners that consult the flag.

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

The Dart-Rust bindings in `plugins/rust_api` are generated by `flutter_rust_bridge_codegen` from
`plugins/rust_api/flutter_rust_bridge.yaml`; rerun it from that directory after changing anything under
`rust/src/api/`:

```bash
cd plugins/rust_api && flutter_rust_bridge_codegen generate
```

Generated output paths, configured in each package's `build.yaml`:

- `lib/models/generated/*.g.dart`, `*.freezed.dart`.
- `lib/providers/generated/*.g.dart`.
- `lib/database/generated/*.g.dart`.

Localizations in `lib/l10n/` come from the ARB files in `arb/` through Flutter's `gen-l10n`, configured in `l10n.yaml`.
`flutter pub get` regenerates them, since `pubspec.yaml` sets `generate: true`; after editing an ARB file alone:

```bash
flutter gen-l10n
```

App and tray icons are generated, not hand-edited. `assets_source/images/icon/*.svg` is the source of truth;
the scripts need `rsvg-convert` (librsvg) and, for the app icon, `cwebp` (webp) on `PATH`:

```bash
dart run tool/generate_app_icons.dart     # app icons, the running gradient, then every tray icon
dart run tool/generate_status_icons.dart  # tray icons only, after editing status_1, status_3 or status_4
```

`app.svg` is the app icon: `#base` is the plate, an Apple continuous-corner square whose 234 units map to the
824 px plate of the macOS template; `#plate-fill` is its color over the whole square; `#art` is the glyph with its
shadows, scaled by the `#mask` factor so it stands 596/824 of the plate. `generate_app_icons.dart` renders every
app icon from those layers and keeps each platform's glyph at the size it had on `main`:

| Output | Layout |
| --- | --- |
| `assets/images/icon.png`, `assets/images/icon.ico`, `windows/runner/resources/app_icon.ico` | `app.svg` as drawn |
| macOS `AppIcon.appiconset` | plate 824 of 1024 at 100, shadow dy 14, blur 10, 25% black |
| Android adaptive layers | `ic_launcher_plate` full bleed, `ic_launcher_art` inset so the glyph is 45.69 of 108 dp |
| Android monochrome layer | the glyph paths at the same 45.69 dp |
| Android TV foreground and TV launcher rasters | full bleed, glyph 70.12 of 108 dp |
| Play Store image | full bleed, glyph 336 of 512 px |
| Pre-O `ic_launcher` and `ic_launcher_round` | Android Studio's legacy frames: square 152 of 192 px, round 176, both with a 2 px shadow, showing the adaptive icon's visible 72 dp |
| TV `ic_banner` | glyph 96 px tall at (73.5, 89.5); the wordmark right of x = 140 is kept from the committed file |

Launchers on Android 8 and later shape and shadow the adaptive layers themselves, so the layers carry no frame.
The splash screen draws `ic_launcher_foreground` on `ic_launcher_background`, the plate's middle color.

The running state uses the app icon's colors: the script copies `#face` of `app.svg`, with its axis mapped from the
scaled glyph back to the lattice, into `status_2.svg`, `glyph.svg` and the Android `ic_service.xml`. Edit the
running gradient in `app.svg` only. `status_1` (stopped) and `status_3` (TUN) keep their own hand-set colors.

`generate_status_icons.dart` writes the tray PNGs with Flutter `2.0x/`–`4.0x/` resolution variants to
`assets/images/tray/unix/` and multi-size tray `.ico` files to `assets/images/tray/windows/`. `status_1`–`status_3` are the logo glyph alone and tell stopped, running and TUN
apart only by color, so they carry no rings or shadow. macOS draws its menu bar icon as a template by default,
where color is lost: `status_1` renders the bare logo from `assets_source/images/icon/glyph.svg` and `status_4`
reuses `status_4.svg`, both recolored to black into `assets/images/tray/macos/`; the sources keep their colors.
With the tray menu's monochrome icon turned off, macOS loads the color PNGs from `assets/images/tray/unix/`.
`glyph.svg` is also the geometry of the Android notification drawables
`android/service/src/main/res/drawable/ic.xml` and `ic_service.xml`; change them together. `pubspec.yaml` declares the three tray directories with `platforms:` so each
build only bundles the formats its tray loads; a new status icon needs a source SVG and an entry in the
script's `statusIconNames`, nothing in `pubspec.yaml`.

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
```

For the whole suite, or a directory of more than a few files, use `tool/test.dart`, which is also what CI runs:

```bash
dart run tool/test.dart                                  # all of test/
dart run tool/test.dart test/widgets test/views          # some paths
dart run tool/test.dart -- --reporter expanded --coverage
```

Plain `flutter test` compiles each file into its own program and starts an engine for it, one file after another, and
that dominates a full run. `tool/test.dart` imports the files into 32 generated entrypoints under
`.dart_tool/test_bundles/` and runs those with one worker per core, about half the time of a plain run, and less than
a third with `--coverage`. Files in one entrypoint share an
isolate, so a test can see state a file before it left behind; the script runs every file that failed there again on
its own, lets that run decide, and names the files that only failed together. See the Shared Test Isolate section of
`rules.md` before fixing one.

`plugins/setup/setup_hooks/` is a pure Dart package, checked with `dart analyze` and `dart test` from its own
directory, which is also what CI runs; `tool/check_plugins.sh` does not descend into it. It must stay out of
`flutter test`, because a test run of `plugins/setup` would execute the build hook itself.

`.github/scripts/issue-gate.js` is tested with `node --test .github/scripts/`, against the forms in
`.github/ISSUE_TEMPLATE/`; no workflow runs it, so run it after changing the script or a form.

Native plugin code under `plugins/*/{linux,macos,windows}` is compiled by the CI `desktop` job, which runs
`flutter build <platform> --debug` on every branch push, and by the release matrix on a tag; `tool/check_plugins.sh`
only analyzes and tests the Dart side.

Root `flutter test` only discovers the root package's `test/` directory by default. Include bundled plugin Dart tests by passing paths explicitly, or run `flutter test` from that plugin package directory, or run `bash tool/check_plugins.sh` to analyze and test every plugin package the way CI does. Native plugin tests under platform folders are not run by `flutter test`.

For the current Core/service architecture, useful focused checks are:

```bash
flutter test test/core/desktop/
flutter test test/core/service_test.dart
flutter test test/core/api/
flutter test test/manager/core_manager_test.dart
flutter test test/providers/action_test.dart test/providers/system_action_test.dart
flutter test test/views/dashboard/live_status_test.dart
```

What those suites own:

- `test/core/desktop/`: replaceable IPC transport, direct/Helper process leases, and
  latest-intent desktop lifecycle convergence. `ipc_native_test.dart` runs the transport over a real socket through
  the Rust `IpcServer`; the server's own behavior is covered by `cargo test` in `plugins/rust_api/rust`.
- `test/core/service_test.dart`: `CoreService` composition and terminal close behavior.
- `test/core/api/`: `CoreClient` framing, streams, credit and cancellation against a fake channel, and `contract_test.dart`,
  which checks every `CoreApi` call and DTO against `concord/schema/api.json`; a new schema method must be called there or
  listed as not called by Dart.
- `test/providers/action_test.dart`: Core start/restart orchestration and overlapping restart requests.
- `test/providers/system_action_test.dart`: ordered, idempotent exit cleanup and watchdog behavior.
- `test/views/dashboard/live_status_test.dart`: 600-millisecond starting presentation hold, immediate failure display,
  the order of the live status deck, where it sits, a list opening in place, config warnings, and the confirmation
  before a force restart.

## Native Component Verification

`plugins/rust_api/rust` is checked the same way as the Helper below; `make rust-check` runs both crates' format
checks and tests as CI does. Tests under `cfg(target_os = "linux")` compile and run only on Linux:

```bash
cargo fmt --manifest-path plugins/rust_api/rust/Cargo.toml -- --check
cargo test --manifest-path plugins/rust_api/rust/Cargo.toml
```

The Windows Helper's loopback/session protocol tests are host-independent by default. Windows CI additionally enables its
service implementation:

```bash
cargo fmt --manifest-path services/helper/Cargo.toml -- --check
cargo test --manifest-path services/helper/Cargo.toml
cargo test --manifest-path services/helper/Cargo.toml --features windows-service
```

The last command requires Windows for meaningful service coverage. Native Android lifecycle edits should at minimum
compile the modules they touch, with the JDK 17 that CI installs. On macOS the Homebrew `openjdk@17` keg is not
registered with `java_home`, so export it by prefix:

```bash
cd android
export JAVA_HOME="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"   # elsewhere: any JDK 17
./gradlew :core:compileDebugKotlin -Ptarget-platform=android-arm64   # builds the Core and JNI glue for one ABI
./gradlew :service:compileDebugKotlin
./gradlew :app:compileDebugKotlin
```

Run the JVM unit tests of `:common`, `:service` and `:app` as the CI `android` job does. No test loads the Core or
the Flutter build, but `:core` builds the Concord library, so `cargo`, the pinned toolchain and the NDK are needed and
one ABI is built. `android/gradlew` and `android/local.properties` are ignored by git; CI copies the wrapper from
Flutter's cache and writes the SDK paths, and a checkout without them needs the same:

```bash
cd android
flutter_root="$(flutter --version --machine | jq -r .flutterRoot)"
test -f gradlew || { cp -R "$flutter_root/bin/cache/artifacts/gradle_wrapper/." . && chmod +x gradlew; }
test -f local.properties ||
  printf 'flutter.sdk=%s\nsdk.dir=%s\n' "$flutter_root" "${ANDROID_HOME:?the Android SDK}" > local.properties
./gradlew :common:testDebugUnitTest :service:testDebugUnitTest :app:testDebugUnitTest \
  -Ptarget-platform=android-arm64 -x :app:compileFlutterBuildDebug -x :app:copyFlutterAssetsDebug
```

Always-on VPN entry, system VPN revoke, actual permission UI, and rapid device start/stop still require Android device or
emulator validation; Kotlin compilation cannot prove those system callbacks.

## Concord Core

Concord is the Rust core in `concord/` (see Concord Core in `architecture.md`). A normal `flutter test`, `flutter run` or
`tool/package.dart` build compiles it through the setup hook, and Android through the `:core` Gradle module, so `cargo` and
the toolchain pinned in `concord/rust-toolchain.toml` must be installed.

Work inside it from `concord/`:

```bash
cargo build --release -p concord-desktop          # target/release/concord
cargo fmt --check
cargo clippy --workspace --all-targets -- -D warnings
CONCORD_REQUIRE_APP_TREE=1 cargo test --workspace
cargo run -p xtask -- check-layers
cargo run -p xtask -- schema                      # rewrite concord/schema/, then commit it
cargo run -p xtask -- schema --check
cargo deny check
cargo run -p xtask -- check-size target/release/concord 15000000
```

`make core-sent-config` (`dart tool/check_sent_config.dart` from the repository root, part of `make core-gate` and CI's
Core job) loads each `test/fixtures/sent_config/` golden with `concord -t`; see Config Keys Sent To The Core in the
`core-platform` skill.

`CONCORD_REQUIRE_APP_TREE=1` turns the contract tests that read `lib/` from a skip into a failure when the FlClash tree
is missing. Tests marked `#[ignore]` need an external peer; `concord/.agents/commands.md` lists the environment variables.

Disk: the workspace has one target directory, `concord/target`, and it grows past 10 GB with debug, release and the
Android and Windows targets. Never point cargo at another target directory, never keep one per crate or per agent, and
do not `cargo clean` a tree someone else is building. Release uses fat LTO, so build it only when its size or speed is
the question. Run `cargo` with `CARGO_INCREMENTAL=0` and without a stale `all_proxy`.

CI runs the `rust-core` job in `build.yaml`, and `concord/.github/workflows/ci.yaml` runs the same steps inside the
Concord repository. The first checks the public `chen08209/concord` submodule out into `concord/` without a token and
is not a release gate: `upload` does not wait for it.

## Changelog And Release

The changelog is derived from Conventional Commits by `tool/changelog.dart` and written to two committed files:
`CHANGELOG.md` for readers and `changelog.json` for the renderers. See `.agents/rules.md` for the `Changelog:` trailers
that decide the wording.

The app ships no changelog of its own. `render release` appends the released version as JSON inside an HTML comment
(`<!-- flclash:changelog:json … -->`), so the release body GitHub already returns to `checkForUpdate` carries the
notes shown in the update dialog. `parseReleaseChangelog` reads that block and falls back to the English
bullets when a release predates it.

```bash
dart run tool/changelog.dart verify                  # what CI checks
dart run tool/changelog.dart release --version 0.8.96
dart run tool/changelog.dart build --unreleased      # changelog.json only, includes untagged work
dart run tool/changelog.dart markdown                # CHANGELOG.md from changelog.json after a hand edit
dart run tool/changelog.dart render release --out release.md
```

Releasing a stable version, in order:

```bash
tool/bump_version.sh major
dart run tool/changelog.dart release --version 0.8.96
# edit changelog.json, then:
dart run tool/changelog.dart markdown
dart run tool/changelog.dart verify
git commit -am "chore(release): v0.8.96"
git tag v0.8.96
git push origin main && git push origin v0.8.96
```

The tag decides the version, not a commit. A release tag is `vX.Y.Z`, `vX.Y.Z-pre.N`, or `vX.Y.Z-pre.N+M`, where `+M`
rebuilds prerelease N after a fix, or `vX.Y.Z-rs.N[+M]`, which releases the Concord build exactly as a pre tag does;
the `version` job rejects any other `v*` tag. It writes `X.Y.Z` from the tag into
`pubspec.yaml` for the build and upload jobs, with a build number of the tag run's UTC `YYYYMMDDHH`, raised above the
committed one when that is not already larger, because Android refuses an update with a lower versionCode. The app's
version name stays `X.Y.Z` for a prerelease too, so the packager hands the build its tag as `RELEASE_TAG`, and the
update check compares that tag, not the version name. The build number in
`pubspec.yaml` stays fixed; a local build that must install over a CI one passes its own
`--build-number`.

Push the tag by name. Every release tag here is lightweight, and `--follow-tags` carries annotated tags only: it skips a
lightweight one silently, so the branch lands, the tag does not, and the release workflow never fires.

`tool/release.sh` drives both paths so the ordering below cannot be got wrong by hand. It resolves the version (bumping
the patch when pubspec still names an already tagged one), prints the notes the tag would ship, and only pushes with
`--push`:

```bash
tool/release.sh pre --dry-run            # plan and notes, changes nothing
tool/release.sh pre --push               # tag vX.Y.Z-pre.N on HEAD, push; no commit
tool/release.sh pre --rebuild --push     # tag vX.Y.Z-pre.N+M on HEAD after a fix
tool/release.sh rs --push                # tag vX.Y.Z-rs.N on HEAD (the rs branch), push; no commit
tool/release.sh stable --push            # changelog, pause for edits, chore(release) commit, tag, push
```

`--push` goes to `origin`; `--remote NAME` pushes to another remote instead, such as the public repository in a
checkout whose `origin` is a private mirror.

The release commit comes before the tag on purpose: the generated wording is reviewable in the diff before it ships, and
the tag is what `render release` reads. CI never writes back to the repository; it only runs `verify`.

The generated notes are a draft. `release.sh stable` stops after `release` so the new version in `changelog.json` can be
edited, then rewrites `CHANGELOG.md` with `markdown` and runs `verify` before it commits; a failed `verify` stops
again for another edit. `--yes` skips the stop and commits the generated notes. In the version being released:

- Reword an entry's `text` or `scope`, or write an entry for a commit git would not collect, such as a `refactor`
  users notice; its `id` is any commit in the range.
- `"merges": ["<id>", …]` on an entry folds those commits into it, so they need no entry of their own.
- `"omit": ["<id>", …]` on the version leaves commits out of its notes: internal fixes, or work behind a flag the
  release ships off, such as MITM under `rsFeature`.

`verify` holds every commit git derives to an entry in its group, a merge or an omission, and every id, merge and
omission to the version's range. It also checks the newest version before its tag exists, so the release commit is
checked before it is tagged. `release` and `build` keep every stable version `changelog.json` already records as
written and derive only the new one, so an edit outlives later releases.

Entries at or below `v0.8.96` are frozen: they predate the pipeline, live under the `<!-- changelog:frozen -->` marker
in `CHANGELOG.md`, and are never regenerated.

`verify` compares a version only when its tag is reachable from `HEAD`, because that is the same scope the builder walks
(`git tag --merged`). A branch cut before the newest release cannot derive that version at all, so `verify` names it as
skipped and moves on instead of reporting drift that does not exist.

Prerelease tags (`v0.8.96-pre.N[+M]`) skip the release commit, and CI renders their notes with `build --unreleased`.
They publish a GitHub release marked as a prerelease and never as latest, with the same files as a stable one, and the
update check offers them only on the prerelease update channel. `build --unreleased` reads the
version from `pubspec.yaml`, which the upload job has already set from the tag, and refuses to collect anything while
`v<that version>` is tagged, so a prerelease tag must name the next, untagged `X.Y.Z`. The changelog builder walks
stable tags only and ignores a `+M` tag.

Once the release is up, `tool/publish.dart` posts its title and page to the Telegram channel, then deletes superseded
prereleases of the same line: all but the newest two, and after a stable release every prerelease below it. It deletes
the releases and their files but keeps the tags, since `tool/release.sh` numbers the next prerelease from them. Both
take `--dry-run`, which prints the message or the releases it would delete:

```bash
dart tool/publish.dart --dry-run telegram v0.9.5-pre.1
gh api --paginate 'repos/chen08209/FlClash/releases?per_page=100' | jq -s add > releases.json
dart tool/publish.dart --dry-run prune v0.9.5-pre.1 --releases releases.json
```

The update channel in the general settings picks what the update check offers. Stable asks for `releases/latest`.
Prerelease reads the release list and takes the highest version among stable and prerelease releases of the app's line,
counting only releases whose checksum file is uploaded. Once the API's unauthenticated hourly quota is spent, it falls
back to `releases.atom`, which is not counted but carries no notes and lists bare tags too, so a tag counts there only
after a HEAD request finds its checksum file.

The rs line publishes only `-rs.N` prereleases, so it hides the channel and always reads the list, where its line
is the rs releases alone.

### Release File Names

The site, the release notes, the Homebrew cask and the in-app updater each find a release's files by name, so a change
to `releaseAssetName` or to the build matrix has to reach all of them:

- `site/assets/app.js`: the ids in `buildsFor` and the checksum link.
- `.github/release_template.md`: one link per file.
- `.github/homebrew_cask_template.rb`: the disk image url.
- `selfUpdateAssetFor` in `lib/common/release_asset.dart`: the installers the updater downloads and verifies against
  `FlClash-<version>-SHA256SUMS`.

`dart run tool/package.dart check dist` reads the names out of those files and fails when the merged release lacks one
or its checksum file misstates an installer; the upload job runs it before it publishes anything, and
`test/tool/release_contract_test.dart` runs it against the names the packager plans for every row of the build matrix.
Released apps keep looking up the names they shipped with. When the updater cannot find its file, it opens the release
page and says to download the update there.

#### Backfilling Old Names By Hand

Optional, after a stable release, and never in CI. Updaters of 0.9.3 and 0.9.4 ask for older names; without these
copies their users see "Update failed" and download the update from the release page instead. 0.9.3 fetches
`FlClash-<v>-android-{arm64-v8a,armeabi-v7a,x86_64}.apk` and the Windows installers under their current names, all
listed in `SHA256SUMS`; 0.9.4 fetches `FlClash-dev-<v>-*` names listed in `FlClash-dev-<v>-SHA256SUMS`. Releases up to
0.9.2 only open the release page.

```bash
v=0.9.5
cd "$(mktemp -d)"
gh release download "v$v" -R chen08209/FlClash \
  -p "FlClash-$v-android-arm64.apk" -p "FlClash-$v-android-armv7.apk" -p "FlClash-$v-android-amd64.apk" \
  -p "FlClash-$v-windows-amd64-setup.exe" -p "FlClash-$v-windows-arm64-setup.exe"
cp "FlClash-$v-android-arm64.apk" "FlClash-$v-android-arm64-v8a.apk"
cp "FlClash-$v-android-armv7.apk" "FlClash-$v-android-armeabi-v7a.apk"
cp "FlClash-$v-android-amd64.apk" "FlClash-$v-android-x86_64.apk"
shasum -a 256 "FlClash-$v-android-arm64-v8a.apk" "FlClash-$v-android-armeabi-v7a.apk" \
  "FlClash-$v-android-x86_64.apk" "FlClash-$v-windows-amd64-setup.exe" \
  "FlClash-$v-windows-arm64-setup.exe" > SHA256SUMS
for f in android-arm64.apk android-armv7.apk android-amd64.apk windows-amd64-setup.exe windows-arm64-setup.exe; do
  cp "FlClash-$v-$f" "FlClash-dev-$v-$f"
done
shasum -a 256 "FlClash-dev-$v-android-arm64.apk" "FlClash-dev-$v-android-armv7.apk" \
  "FlClash-dev-$v-android-amd64.apk" "FlClash-dev-$v-windows-amd64-setup.exe" \
  "FlClash-dev-$v-windows-arm64-setup.exe" > "FlClash-dev-$v-SHA256SUMS"
gh release upload "v$v" -R chen08209/FlClash \
  "FlClash-$v-android-arm64-v8a.apk" "FlClash-$v-android-armeabi-v7a.apk" "FlClash-$v-android-x86_64.apk" \
  SHA256SUMS "FlClash-dev-$v"-*
```

### Website

`site/` is the GitHub Pages site: a static page that renders `CHANGELOG.md` and the download links in the browser, and
works as is for local previews. `tool/build_site.sh [dir]` assembles it with the preview images, the app icon,
`CHANGELOG.md` read at the latest release tag, and a `release.json` of asset names, sizes and digests fetched through
`gh`. Without `gh` access the page falls back to the newest version in `CHANGELOG.md` and lists the files without sizes.
It then runs `tool/render_site.mjs` (Node), which writes the English page and a `zh/` copy for search engines: page
text, the first changelog releases, canonical and `hreflang` links, JSON-LD and `sitemap.xml`, all from the strings,
changelog parser and release markup in `site/assets/shared.js`, plus the GitHub star count from `release.json` so the
bar does not grow when the page loads. `SITE_URL` overrides the published URL these point at.
On the built site each URL keeps its language: the bar shows both languages, the current one selected, and the other
links to its page carrying the section in view, the chosen platform and the changelog search. Only the English root
sends readers who chose or prefer Chinese on to `zh/`, unless its URL carries `?lang=en`: the English link on `zh/`
carries it, so getting back to English never depends on browser storage. A project site cannot serve the `robots.txt`
that would announce the sitemap, so submit `sitemap.xml` in Google Search Console and Bing Webmaster Tools once.

```bash
tool/build_site.sh && python3 -m http.server -d build/site
```

The page's look is deliberate: flat colour, no glow, glass or soft shadow, and the app icon only in the nav and the
favicon. The one blur is the floating bar's backdrop; the bar hides as the page scrolls down and comes back on the way
up. Controls take Material 3 Expressive shapes: pill buttons whose corners tighten on press, connected button groups
for the platform, the architecture, the bar's links and languages and the footer's links, the downloads and install
tips as segmented lists. Archivo, Instrument Sans and Martian Mono are
self-hosted in `site/assets/fonts/` under the OFL. There is no colour picker: the page steps through the app's theme
colours (`defaultPrimaryColors` without graphite) as it scrolls, one per emblem shape, by setting `data-accent` on the
root, and the palette tokens are registered `@property` colours so the change eases. Dark mode follows the system only.

Colours are the app's, not tuned for the page: every token is a role of the vivid `seededColorScheme` of a
`defaultPrimaryColors` seed, used as `.agents/surfaces.md` uses it: page, card and block levels instead of borders, the
floating level for the bar and the next level up for the boxes in it, `primary` for the chosen tab, the main download
and the emblem, `success`, `warning` and `error` for the changelog's kinds, and dividers in `onSurface` at 14%.
`test/tool/site_palette_test.dart` fails when the palette in `site/assets/style.css` drifts from the app, and
`flutter test --update-goldens test/tool/site_palette_test.dart` rewrites it.

The hero's emblem is the dashboard's start button: a circle with play that morphs into the nine-sided cookie with pause,
on the curves `_StartToggle` uses, and a click toggles it. Past the hero, every half screen of scroll morphs it one step
further through a cycle of Compose's `MaterialShapes` (sunny, clover, burst, flower and the rest), springing past each
shape on `easeOutBack` and turning a ninth of a turn per step. `site/assets/shapes.js` holds those morphs as cubic
pairs; `test/tool/site_shapes_test.dart` builds them, with Compose's values for the shapes prism_ui lacks, fails when
the file drifts, and `--update-goldens` rewrites it. On a wide screen the emblem grows on scroll, crosses to a sticky
left column, and the downloads, hidden until then, blur in at the line the docked column starts on. The column shows the
section's number in the emblem and its name and summary underneath, swapping with a fade-through as the changelog
arrives; the right column's own section heads stay only for screen readers. Below 960 px the emblem stays in the hero,
under the copy, and the heads show as usual. `site/assets/scene.js` drives all of it from script, as CSS scroll
timelines stuttered in Android WebView; the emblem starts on `#spot` in the hero and docks where its CSS box is, and
`data-part` on the root tells the stylesheet which section the column names.

`.github/workflows/pages.yaml` deploys it after every successful stable tag build and on pushes to `main` that touch the
site, in the public repository only; its Pages source has to be set to GitHub Actions once. The file names come from the
release matrix in `build.yaml`, so a renamed artifact needs the same change in `buildsFor` in `site/assets/app.js`.

## Verify

In the public repository every branch push runs the `dart` job; in the private
`origin` every check job runs only when started by hand (`workflow_dispatch`).
The `dart` job performs these root-package checks in order:

```bash
bash tool/hooks/test.sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool plugins
flutter analyze --no-fatal-infos
bash tool/strip_check.sh              # make strip-check
dart run tool/changelog.dart verify   # main and tags only
dart run tool/test.dart -- --reporter expanded --coverage
dart run tool/check_coverage.dart coverage/lcov.info 75
```

`tool/hooks/` holds the scripts the git hooks run, and `tool/hooks/test.sh` runs every `*_test.sh` beside them, so a
new hook script needs only its test file next to it, not a workflow step.

Run `flutter analyze --no-fatal-infos` before committing; CI runs the same command and fails on a warning or error.

Release builds run only for `v*` tag pushes; pull requests trigger nothing.
Root analysis excludes `plugins/**`, and root tests do not discover nested
plugin packages, so parallel jobs validate the rest from their own package
directories: `plugins` (local Flutter packages and the setup build tool), `android` (JVM unit tests
for `:common`, `:service` and `:app`, with the Flutter compile tasks excluded
and the Core built for one ABI), `rust` (both crates), `rust-core` (the Concord
workspace), and a
Windows runner for the helper's `windows-service` feature. On branch pushes a
`desktop` job also compiles a debug build per desktop platform; a tag skips it,
since its release matrix compiles the same native code. Release builds run only
in the public repository and start alongside the checks; `upload` publishes
only once every build and every check job passes.

`bash tool/check_plugins.sh` is that plugin gate, and CI runs the same script.
It discovers every `plugins/*/pubspec.yaml`, analyzes each package, and runs
`flutter test` wherever a `*_test.dart` sits anywhere under its `test/`. Adding a
plugin package needs no workflow edit.

### CI Caches

A run restores only cache entries saved on its own branch or tag, or on the default branch (`main`), and the
repository holds 10 GB before evicting the least recently used entries. Every release is a new tag that no later run
reads from, so `BRANCH_CACHE` turns caching off in tag runs, whose entries would evict what `dev` saved. Release
builds therefore start cold; branch runs, chiefly `dev`, keep the caches.

- `Swatinem/rust-cache` keys each entry on its `workspaces` and `key`, and the branch jobs save only when
  `BRANCH_CACHE` is on; `desktop` adds a per-platform `key` to get an entry of its own.
- setup-gradle writes only on the default branch unless told otherwise, so `android` lets `dev` write as well. Its
  entries are keyed by job, which is one more reason the release build gains nothing from caching.

## Worktree Tooling

```bash
bash tool/worktrees.sh list       # every worktree with owner tool and dirty/clean state
bash tool/worktrees.sh prune      # remove clean worktrees; add --force to drop dirty ones too
```
