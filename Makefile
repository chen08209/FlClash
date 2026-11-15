SHELL := /bin/bash

.PHONY: help submodules

help:
	@echo 'make submodules  # update git submodules (Concord core, prism_ui)'
	@echo ''
	@echo 'Concord and the Rust helper build automatically through the setup build'
	@echo 'hook during flutter build; see .agents/commands.md.'

submodules:
	git submodule update --init --recursive
