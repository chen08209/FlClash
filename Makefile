SHELL := /bin/bash
.DEFAULT_GOAL := help

##> TEST=paths     test: files or directories to run instead of all of test/
##> ARGS=...       test: flutter test arguments; package, run: extra tool arguments
##> FILES=paths    comment-density: files to measure instead of the uncommitted changes
##> ARCH=a,b       package: arm64, armv7, amd64 or universal; another desktop arch only with DRY=1
##> FORM=a,b       package: exe, zip, dmg, deb, rpm, appimage or apk
##> DRY=1          package: print artifact names and steps, build nothing
##> APP_ENV=name   package: dev, pre (default) or stable
##> TAG=vX.Y.Z     package: release tag to name the build after
##> DEVICE=id      run: flutter device to run on
##> KIND=name      release-plan: pre, rs (default) or stable

CARGO := env -u all_proxy -u ALL_PROXY CARGO_INCREMENTAL=0 cargo
CORE_MAX_BYTES ?= 30000000
# concord/.agents/commands.md lists the same crates: the members that declare default features.
CORE_FEATURE_CRATES := concord-common concord-engine concord-mitm
KIND ?= rs

PACKAGE := dart tool/package.dart
PACKAGE_FLAGS = $(if $(ARCH),--arch $(ARCH)) $(if $(FORM),--targets $(FORM)) \
	$(if $(filter 1,$(DRY)),--dry-run) $(if $(APP_ENV),--env $(APP_ENV)) $(if $(TAG),--tag $(TAG)) $(ARGS)
COMMENT_FILES = $(or $(FILES),$(shell git diff HEAD --name-only --diff-filter=d; git ls-files --others --exclude-standard))

.PHONY: help setup submodules pub-get doctor hooks worktrees \
	gen gen-watch l10n icons status-icons frb site \
	fmt fmt-check analyze test coverage lint strip-check hooks-test comment-density plugins-check setup-hooks-test \
	rust-check changelog-verify check \
	core-build core-fmt core-check core-test core-sent-config core-gate core-schema \
	package package-android package-windows package-macos package-linux package-dry manifest \
	run release-plan clean clean-core

help: ## List every target and variable
	@awk 'BEGIN { FS = ":.*## " } \
		/^##@ / { printf "\n%s\n", substr($$0, 5) } \
		/^[a-z0-9-]+:.*## / { printf "  %-18s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nVariables\n'
	@sed -n 's/^##> /  /p' $(MAKEFILE_LIST)

##@ Environment

setup: submodules pub-get ## Fetch submodules and Dart packages

submodules: ## Update git submodules (Concord core, prism_ui)
	git submodule update --init --recursive

pub-get: ## flutter pub get
	flutter pub get

doctor: ## Report missing toolchains: Flutter, cargo, the pinned Rust, NDK, JDK, packaging tools
	bash tool/doctor.sh

hooks: ## Install the pre-commit, pre-push and commit-msg git hooks
	pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg

worktrees: ## List worktrees with their owner tool and dirty state
	bash tool/worktrees.sh list

##@ Generate

gen: ## Run build_runner once (freezed, json, riverpod, drift)
	dart run build_runner build --delete-conflicting-outputs

gen-watch: ## Run build_runner in watch mode
	dart run build_runner watch --delete-conflicting-outputs

l10n: ## Regenerate lib/l10n from the ARB files
	flutter gen-l10n

icons: ## Regenerate the app icons, the running gradient and every tray icon
	dart run tool/generate_app_icons.dart

status-icons: ## Regenerate the tray icons only
	dart run tool/generate_status_icons.dart

frb: ## Regenerate the flutter_rust_bridge bindings of plugins/rust_api
	cd plugins/rust_api && flutter_rust_bridge_codegen generate

site: ## Build the website into build/site
	bash tool/build_site.sh

##@ Check

fmt: ## Format Dart sources in place
	dart format lib test tool plugins

fmt-check: ## Fail on unformatted Dart sources, as CI does
	dart format --output=none --set-exit-if-changed lib test tool plugins

analyze: ## flutter analyze --no-fatal-infos
	flutter analyze --no-fatal-infos

test: ## Run tests through tool/test.dart; TEST=paths, ARGS=flutter test arguments
	dart run tool/test.dart $(TEST) $(if $(ARGS),-- $(ARGS))

coverage: ## Run every test with coverage and hold it to CI's 75% floor
	dart run tool/test.dart -- --reporter expanded --coverage
	dart run tool/check_coverage.dart coverage/lcov.info 75

lint: ## Run the repository lint suite in test/lint
	flutter test test/lint

strip-check: ## Strip the rsFeature checks in a scratch copy and analyze what the rs line builds on
	bash tool/strip_check.sh

hooks-test: ## Test the git hook scripts in tool/hooks
	bash tool/hooks/test.sh

comment-density: ## Hold uncommitted changes, or FILES=paths, to the comment cap
	@files='$(strip $(COMMENT_FILES))'; \
	if [ -z "$$files" ]; then echo 'comment-density: nothing to measure'; \
	else tool/hooks/comment_density.sh $$files; fi

plugins-check: ## Analyze and test every plugin package, as CI does
	bash tool/check_plugins.sh

setup-hooks-test: ## Test the setup_hooks package with dart test
	cd plugins/setup/setup_hooks && dart test

rust-check: ## Format check and test the Helper and rust_api crates, as CI does
	$(CARGO) fmt --manifest-path services/helper/Cargo.toml -- --check
	$(CARGO) fmt --manifest-path plugins/rust_api/rust/Cargo.toml -- --check
	$(CARGO) fmt --manifest-path android/core/jni/Cargo.toml -- --check
	$(CARGO) test --manifest-path services/helper/Cargo.toml
	$(CARGO) test --manifest-path plugins/rust_api/rust/Cargo.toml

changelog-verify: ## Check changelog.json and CHANGELOG.md against the commits
	dart run tool/changelog.dart verify

check: hooks-test pub-get fmt-check analyze coverage ## Run CI's dart job: hooks, format, analyze, tests with coverage

##@ Concord

core-build: ## Build the desktop Core in debug
	cd concord && $(CARGO) build -p concord-desktop

core-fmt: ## Format the Concord workspace
	cd concord && $(CARGO) fmt

core-check: ## cargo fmt --check, clippy (also each crate without its default features), check-layers and schema --check
	cd concord && $(CARGO) fmt --check
	cd concord && $(CARGO) clippy --workspace --all-targets -- -D warnings
	cd concord && for crate in $(CORE_FEATURE_CRATES); do \
		$(CARGO) clippy -p $$crate --no-default-features --all-targets -- -D warnings || exit 1; done
	cd concord && $(CARGO) xtask check-layers
	cd concord && $(CARGO) xtask schema --check

core-test: ## cargo test --workspace, with the app-tree contract tests required, and each crate without its default features
	cd concord && CONCORD_REQUIRE_APP_TREE=1 $(CARGO) test --workspace
	cd concord && for crate in $(CORE_FEATURE_CRATES); do \
		$(CARGO) test -p $$crate --no-default-features || exit 1; done

core-sent-config: ## Load the config each platform sends with concord -t
	env -u all_proxy dart tool/check_sent_config.dart

core-gate: core-check core-test core-sent-config ## The full Concord gate: also deny, fuzz, release build and size budget
	cd concord && $(CARGO) deny check
	cd concord && $(CARGO) check --manifest-path fuzz/Cargo.toml
	cd concord && $(CARGO) build --release -p concord-desktop
	cd concord && $(CARGO) xtask check-size target/release/concord $(CORE_MAX_BYTES)

core-schema: ## Rewrite concord/schema/ after an API or config change
	cd concord && $(CARGO) xtask schema

##@ Package

package: ## Package this host into dist/; ARCH=, FORM=, DRY=1, APP_ENV=, TAG=
	$(PACKAGE) $(PACKAGE_FLAGS)

package-android: ## Package the Android APKs
	$(PACKAGE) android $(PACKAGE_FLAGS)

package-windows: ## Package Windows exe and zip (on Windows, elsewhere with DRY=1)
	$(PACKAGE) windows $(PACKAGE_FLAGS)

package-macos: ## Package the macOS dmg (on macOS, elsewhere with DRY=1)
	$(PACKAGE) macos $(PACKAGE_FLAGS)

package-linux: ## Package Linux deb, rpm and AppImage (on Linux, elsewhere with DRY=1)
	$(PACKAGE) linux $(PACKAGE_FLAGS)

package-dry: ## Print what package would build for this host
	$(PACKAGE) --dry-run $(PACKAGE_FLAGS)

manifest: ## Print dist/manifest.json
	@cat dist/manifest.json 2>/dev/null || { echo 'no dist/manifest.json: run a package target first' >&2; exit 1; }

##@ Run

run: ## Run a safe mode debug build, the only kind allowed on a shared host; DEVICE=, ARGS=
	flutter run $(if $(wildcard env.json),--dart-define-from-file=env.json) --dart-define=SAFE_MODE=true \
		$(if $(DEVICE),-d $(DEVICE)) $(ARGS)

##@ Release

release-plan: ## Print the next release tag and its notes without changing anything; KIND=pre|rs|stable
	bash tool/release.sh $(KIND) --dry-run

##@ Clean

clean: ## flutter clean and remove dist/
	flutter clean
	rm -rf dist

clean-core: ## Drop the staged Core and the build hook cache so the next build reruns the hook
	rm -rf libclash .dart_tool/setup_build_cache
