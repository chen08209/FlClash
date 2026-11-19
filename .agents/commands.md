# Commands

`make` is the entry point on macOS and Linux: `make help` lists every target with its variables, generated from the
`##` comments in the `Makefile`, and `test/tool/makefile_test.dart` keeps the two in step. Each target only calls the
command this file documents, so the logic stays in `tool/`; `make doctor` names a missing toolchain, `make check` is
CI's `dart` job, `make core-check` and `make core-test` the Go wrapper checks CI runs, and `make run` starts the safe mode
build, the only kind a shared host may run.

## Building

Update submodules first. The ClashMeta Go core lives in `core/Clash.Meta/`, the UI library in `plugins/prism_ui/`.

```bash
git submodule update --init --recursive
```

Full package build, including Go core, Flutter, and packaging, runs through `tool/package.dart` (`make package`,
`make package-android`, with `ARCH=`, `FORM=` and `DRY=1`). Run it with `dart`, not `dart run`, which first runs
every build hook for the host:

```bash
dart tool/package.dart                     # this host: dmg, exe + zip, or deb + AppImage + rpm
dart tool/package.dart android             # every ABI; --arch arm64 for one
dart tool/package.dart linux --dry-run --arch arm64   # names and steps only, any platform
```

Artifacts land in `dist/` as `FlClash-<line>-<version>-<os>-<arch>[-<form>].<ext>`, with `manifest.json` and
`FlClash-<line>-<version>-SHA256SUMS`; see Packaging in `architecture.md`.

The desktop Go core and the Rust helper build automatically: Flutter runs
`plugins/setup/hook/build.dart` on every `flutter build` and `flutter test`,
and the hook drives `CoreBuilder` from the `setup_hooks` package in
`plugins/setup/setup_hooks/`. Artifacts land in `libclash/`. Android's Core is
the AAR the `:core` Gradle module builds with `gomobile bind` before anything
compiles against it; that needs `go` on `PATH` and nothing else, since the
gomobile tools come from `core/go.mod` and the NDK from AGP. The hook reruns only when Go, Rust, or
`setup_hooks` inputs change; the fingerprint cache lives in
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
too, so a pure Dart test run needs the Go toolchain, and on Linux and Windows
also `cargo` and `rustc` — the Helper fingerprint shells out to both even on a
cache hit. The hook protocol carries no build mode and no caller, so the only
switch is the user-define in the root `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    setup:
      build_assets: true   # false turns the Go core and Helper hook into a no-op
    rust_api:
      build_assets: true   # false does the same for the Rust library
```

CI flips `setup` to `false` with `yq` in its throwaway checkout before
`dart run tool/changelog.dart` and `dart run tool/test.dart`; no test loads the Go core. `rust_api`
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
is kept apart, and only for some builds: a macOS debug build is `com.follow.clash.debug` and an Android debug build `com.follow.clash.dev`,
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

Tray and Windows app icons are generated, not hand-edited. `assets_source/images/icon/*.svg` is
the source of truth; the script needs `rsvg-convert` (librsvg) on `PATH`:

```bash
dart run tool/generate_status_icons.dart
```

It writes the tray PNGs with Flutter `2.0x/`–`4.0x/` resolution variants to `assets/images/tray/unix/`,
multi-size tray `.ico` files to `assets/images/tray/windows/`, and `windows/runner/resources/app_icon.ico`
from `assets/images/icon.png`. `status_1`–`status_3` are the logo glyph alone and tell stopped, running and TUN
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
flutter test test/setup_test.dart
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

`plugins/setup/setup_hooks/` is a pure Dart package and is tested with `dart test` from its own directory, which is
also what CI runs; `tool/check_plugins.sh` does not descend into it. It must stay out of `flutter test`, because a test
run of `plugins/setup` would execute the build hook itself.

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
flutter test test/core/protocol_contract_test.dart
flutter test test/manager/core_manager_test.dart
flutter test test/providers/action_test.dart test/providers/system_action_test.dart
flutter test test/views/dashboard/live_status_test.dart
```

What those suites own:

- `test/core/desktop/`: replaceable IPC transport, RPC request correlation/failure, direct/Helper process leases, and
  latest-intent desktop lifecycle convergence. `ipc_native_test.dart` runs the transport over a real socket through
  the Rust `IpcServer`; the server's own behavior is covered by `cargo test` in `plugins/rust_api/rust`.
- `test/core/service_test.dart`: `CoreService` composition and terminal close behavior.
- `test/core/protocol_contract_test.dart`: shared Dart/Go method and event-envelope compatibility, including event batches.
- `test/providers/action_test.dart`: Core start/restart orchestration and overlapping restart requests.
- `test/providers/system_action_test.dart`: ordered, idempotent exit cleanup and watchdog behavior.
- `test/views/dashboard/live_status_test.dart`: 600-millisecond starting presentation hold, immediate failure display,
  the order of the live status deck, where it sits, a list opening in place, and the confirmation before a force
  restart.

## Native Component Verification

The CI Go-wrapper checks can be reproduced without CGO. They cover the Android files too, except the cgo one in
`timezone/`, which only the gomobile build compiles:

```bash
cd core
CGO_ENABLED=0 go test .
CGO_ENABLED=0 go vet . ./cmd/...
GOOS=android GOARCH=arm64 CGO_ENABLED=0 go vet -tags=with_gvisor . ./mobile ./tun ./platform
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
./gradlew :core:compileDebugKotlin -Ptarget-platform=android-arm64   # builds the gomobile AAR for one ABI
./gradlew :service:compileDebugKotlin
./gradlew :app:compileDebugKotlin
```

Always-on VPN entry, system VPN revoke, actual permission UI, and rapid device start/stop still require Android device or
emulator validation; Kotlin compilation cannot prove those system callbacks.

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
dart run tool/changelog.dart render telegram --out telegram.md
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
rebuilds prerelease N after a fix; the `version` job rejects any other `v*` tag. It writes `X.Y.Z` from the tag into
`pubspec.yaml` for the build and upload jobs, with a build number of the tag run's UTC `YYYYMMDDHH`, raised above the
committed one when that is not already larger, because Android refuses an update with a lower versionCode. The app's
version name stays `X.Y.Z` for a prerelease too: `compareVersions` reads only numbers. The build number in
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

Prerelease tags (`v0.8.96-pre.N[+M]`) skip the release commit, and CI renders their notes with `build --unreleased` for
the Telegram post. They publish no GitHub release, so the update dialog never sees them. `build --unreleased` reads the
version from `pubspec.yaml`, which the upload job has already set from the tag, and refuses to collect anything while
`v<that version>` is tagged, so a prerelease tag must name the next, untagged `X.Y.Z`. The changelog builder walks
stable tags only and ignores a `+M` tag.

### Website

`site/` is the GitHub Pages site: a static page that renders `CHANGELOG.md` and the download links in the browser, and
works as is for local previews. `tool/build_site.sh [dir]` assembles it with the preview images, the app icon,
`CHANGELOG.md` read at the latest release tag, and a `release.json` of asset names, sizes and digests fetched through
`gh`. Without `gh` access the page falls back to the newest version in `CHANGELOG.md` and lists the files without sizes.
It then runs `tool/render_site.mjs` (Node), which writes the English page and a `zh/` copy for search engines: page
text, the first changelog releases, canonical and `hreflang` links, JSON-LD and `sitemap.xml`, all from the strings,
changelog parser and release markup in `site/assets/shared.js`, plus the GitHub star count from `release.json` so the
nav does not grow when the page loads. `SITE_URL` overrides the published URL these point at.
On the built site each URL keeps its language: the language button links to the other page and carries the section in
view, the chosen platform and the changelog search. Only the English root sends readers who chose or prefer Chinese on
to `zh/`, unless its URL carries `?lang=en`: the button on `zh/` links there with it, so getting back to English never
depends on browser storage. A project site cannot serve the `robots.txt` that would announce the sitemap, so submit
`sitemap.xml` in Google Search Console and Bing Webmaster Tools once.

```bash
tool/build_site.sh && python3 -m http.server -d build/site
```

The page's look is deliberate: low-saturation flat colour, no blur, glow, glass or soft shadow, and motion that follows
the logo's 30° lattice. `site/assets/field.js` draws the hero's capsules on that lattice with the glyph's own
proportions, and the slanted wipes, the dot-to-bar marks and the theme transition reuse the same angle. Text that sits
inside the hero has to be listed in `wireField` in `app.js`, or the capsules run behind it.

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
directories: `plugins` (local Flutter packages and the setup build tool), `go`
(the Core wrapper, plus a vet of the Android files), `android` (JVM unit tests
for `:common`, `:service` and `:app`, with the Flutter compile tasks excluded
and the gomobile AAR built for one ABI), `rust` (both crates), and a
Windows runner for the helper's `windows-service` feature. On branch pushes a
`desktop` job also compiles a debug build per desktop platform; a tag skips it,
since its release matrix compiles the same native code. Release builds run only
in the public repository and start alongside the checks; `upload` publishes
only once every build and every check job passes.

`bash tool/check_plugins.sh` is that plugin gate, and CI runs the same script.
It discovers every `plugins/*/pubspec.yaml`, analyzes each package, and runs
`flutter test` wherever `test/*_test.dart` exists. Adding a plugin package needs
no workflow edit.

### CI Caches

A run restores only cache entries saved on its own branch or tag, or on the default branch (`main`), and the
repository holds 10 GB before evicting the least recently used entries. Every release is a new tag that no later run
reads from, so `BRANCH_CACHE` turns caching off in tag runs, whose entries would evict what `dev` saved. Release
builds therefore start cold; branch runs, chiefly `dev`, keep the caches.

- setup-go keys its entry on the `cache-dependency-path` files alone and saves only on a miss, so jobs listing the
  same files share one entry holding the build cache of whichever finished first. `desktop` and `android` each add
  the file that drives their Core build to get an entry of their own.
- setup-gradle writes only on the default branch unless told otherwise, so `android` lets `dev` write as well. Its
  entries are keyed by job, which is one more reason the release build gains nothing from caching.

## Worktree Tooling

```bash
bash tool/worktrees.sh list       # every worktree with owner tool and dirty/clean state
bash tool/worktrees.sh prune      # remove clean worktrees; add --force to drop dirty ones too
```
