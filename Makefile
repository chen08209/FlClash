android_arm64:
	dart ./setup.dart android --arch arm64
macos_arm64:
	dart ./setup.dart macos --arch arm64
android_arm64_core:
	dart ./setup.dart android --arch arm64 --out core
macos_arm64_core:
	dart ./setup.dart macos --arch arm64  --out core