import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/release_asset.dart';

import 'steps.dart';

Future<bool> _hasCommand(String command) async {
  final result = Platform.isWindows
      ? await Process.run('where', [command])
      : await Process.run('sh', ['-c', 'command -v "\$1"', 'sh', command]);
  return result.exitCode == 0;
}

const _appImageToolReleases =
    'https://github.com/AppImage/AppImageKit/releases/download/continuous';

String appImageToolArch(ReleaseArch arch) {
  return arch == ReleaseArch.arm64 ? 'aarch64' : 'x86_64';
}

/// Installs the native packaging tools a host is missing; CI runners start
/// without them.
Future<void> ensurePackagingTools(ReleaseOs os, ReleaseArch arch) async {
  switch (os) {
    case ReleaseOs.macos:
      if (await _hasCommand('appdmg')) return;
      await const Command('npm', [
        'install',
        '-g',
        'appdmg',
      ]).run(verbose: true);
    case ReleaseOs.linux:
      await _ensureLinuxTools(arch);
    case ReleaseOs.windows || ReleaseOs.android:
      return;
  }
}

const _linuxPackages = [
  ['ninja-build', 'libgtk-3-dev'],
  ['libsecret-1-dev'],
  ['rpm', 'patchelf'],
  ['libfuse2'],
];

/// Ubuntu 24.04 ships libfuse2 under its time64 name, which `dpkg -s libfuse2`
/// cannot see.
const _debianPackageAliases = <String, List<String>>{
  'libfuse2': ['libfuse2t64'],
};

Future<bool> _isDebianPackageInstalled(String package) async {
  for (final name in [package, ...?_debianPackageAliases[package]]) {
    final result = await Process.run('dpkg', ['-s', name]);
    if (result.exitCode == 0 &&
        (result.stdout as String).contains('Status: install ok installed')) {
      return true;
    }
  }
  return false;
}

Future<void> _ensureLinuxTools(ReleaseArch arch) async {
  final missing = <List<String>>[];
  for (final group in _linuxPackages) {
    final absent = [
      for (final package in group)
        if (!await _isDebianPackageInstalled(package)) package,
    ];
    if (absent.isNotEmpty) missing.add(absent);
  }
  if (missing.isNotEmpty) {
    await _sudo(['apt-get', 'update', '-y'], mayFail: true);
    for (final group in missing) {
      await _sudo(['apt-get', 'install', '-y', ...group], mayFail: true);
      for (final package in group) {
        if (!await _isDebianPackageInstalled(package)) {
          throw PackageError('apt-get could not install $package');
        }
      }
    }
  }
  if (await _hasCommand('appimagetool')) return;
  const appimagetool = '/usr/local/bin/appimagetool';
  await _sudo([
    'wget',
    '-O',
    appimagetool,
    '$_appImageToolReleases/appimagetool-${appImageToolArch(arch)}.AppImage',
  ]);
  await _sudo(['chmod', '+x', appimagetool]);
}

Future<void> _sudo(List<String> command, {bool mayFail = false}) async {
  final full = [
    'env',
    'DEBIAN_FRONTEND=noninteractive',
    'NEEDRESTART_MODE=a',
    ...command,
  ];
  stdout.writeln('\$ sudo ${full.join(' ')}');
  final process = await Process.start('sudo', full);
  await Future.wait([
    process.stdout.transform(utf8.decoder).forEach(stdout.write),
    process.stderr.transform(utf8.decoder).forEach(stderr.write),
  ]);
  final code = await process.exitCode;
  if (code != 0 && !mayFail) {
    throw PackageError('sudo ${command.join(' ')} exited with $code');
  }
}
