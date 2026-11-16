import 'package:code_assets/code_assets.dart';

import 'error.dart';

class Target {
  const Target({required this.goos, required this.goarch});

  final String goos;
  final String goarch;

  static const macosArm64 = Target(goos: 'darwin', goarch: 'arm64');
  static const macosAmd64 = Target(goos: 'darwin', goarch: 'amd64');

  static const linuxArm64 = Target(goos: 'linux', goarch: 'arm64');
  static const linuxAmd64 = Target(goos: 'linux', goarch: 'amd64');

  static const windowsAmd64 = Target(goos: 'windows', goarch: 'amd64');
  static const windowsArm64 = Target(goos: 'windows', goarch: 'arm64');

  static const all = [
    macosArm64,
    macosAmd64,
    linuxArm64,
    linuxAmd64,
    windowsAmd64,
    windowsArm64,
  ];

  static List<Target> forPlatform(String platform) =>
      all.where((target) => target.platformDir == platform).toList();

  static Target resolve({required String platform, required String goarch}) {
    for (final target in forPlatform(platform)) {
      if (target.goarch == goarch) return target;
    }
    throw BuildException('No $platform Core target for GOARCH $goarch');
  }

  bool get hasHelper => goos == 'linux' || goos == 'windows';

  String get executableExtension => goos == 'windows' ? '.exe' : '';

  String get platformDir => goos == 'darwin' ? 'macos' : goos;

  String get rustTriple {
    final arch = switch (goarch) {
      'amd64' => 'x86_64',
      'arm64' => 'aarch64',
      _ => throw BuildException('No Rust target for $this'),
    };
    return switch (goos) {
      'windows' => '$arch-pc-windows-msvc',
      'linux' => '$arch-unknown-linux-gnu',
      _ => throw BuildException('No Rust target for $this'),
    };
  }

  @override
  String toString() => '$goos/$goarch';
}

String rustTargetTriple(CodeConfig code) {
  final arch = switch (code.targetArchitecture) {
    Architecture.arm64 => 'aarch64',
    Architecture.x64 => 'x86_64',
    Architecture.arm when code.targetOS == OS.android => 'armv7',
    final other => throw BuildException('No Rust target for $other'),
  };
  return switch (code.targetOS) {
    OS.android when arch == 'armv7' => 'armv7-linux-androideabi',
    OS.android => '$arch-linux-android',
    OS.macOS => '$arch-apple-darwin',
    OS.linux => '$arch-unknown-linux-gnu',
    OS.windows => '$arch-pc-windows-msvc',
    final other => throw BuildException('No Rust target for $other'),
  };
}
