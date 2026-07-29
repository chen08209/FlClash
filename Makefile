SHELL := /bin/bash

PLATFORM ?= macos
BUILDKIT := plugins/setup/buildkit/run_build_tool.sh
ARCH_ARG := $(if $(ARCH),--arch $(ARCH),)
TARGET_PLATFORM_ARG := $(if $(TARGET_PLATFORM),--target-platform $(TARGET_PLATFORM),)

.PHONY: help submodules core core-macos core-linux core-windows core-android

help:
	@echo 'make core                         # build macOS core by default'
	@echo 'make core PLATFORM=linux ARCH=amd64'
	@echo 'make core-macos ARCH=arm64'
	@echo 'make core-android ARCH=arm64'
	@echo 'make core-android TARGET_PLATFORM=android-arm64'

submodules:
	git submodule update --init --recursive

core:
	bash $(BUILDKIT) $(PLATFORM) $(ARCH_ARG) $(TARGET_PLATFORM_ARG)

core-macos:
	$(MAKE) core PLATFORM=macos

core-linux:
	$(MAKE) core PLATFORM=linux

core-windows:
	$(MAKE) core PLATFORM=windows

core-android:
	$(MAKE) core PLATFORM=android
