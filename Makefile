SHELL := /bin/bash

.PHONY: help submodules package

help:
	@echo 'make submodules  # update git submodules (Clash.Meta core sources)'
	@echo 'make package     # package this host; ARGS="--dry-run" or ARGS="android"'
	@echo ''
	@echo 'The Go core and Rust helper build automatically through the setup build'
	@echo 'hook during flutter build; see .agents/commands.md.'

submodules:
	git submodule update --init --recursive

package:
	dart run tool/package.dart $(ARGS)
