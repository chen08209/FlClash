import 'dart:io';

import 'package:path/path.dart' as p;

import 'util.dart';

/// `strip` leaves panic locations and C `__FILE__` in rodata, and
/// `profile.*.trim-paths` is unstable on the pinned toolchains. C code also
/// gets `NDEBUG`, as BoringSSL, AWS-LC and quickjs-ng release builds do: cc
/// never defines it and cmake-rs drops it under Visual Studio, and a live
/// `assert` aborts the whole core.
Map<String, String> trimmedPathEnvironment({
  required String checkoutDir,
  required String toolchainDir,
  required String targetTriple,
  Map<String, String>? environment,
}) {
  final env = environment ?? Platform.environment;
  final prefixes = _pathPrefixes(
    checkoutDir: checkoutDir,
    toolchainDir: toolchainDir,
    env: env,
  );
  return {
    ..._rustflags(env, targetTriple, [
      for (final (from, to) in prefixes) '--remap-path-prefix=$from=$to',
    ]),
    for (final name in const ['CFLAGS', 'CXXFLAGS'])
      _targetVariable(name, targetTriple): [
        ?env[_targetVariable(name, targetTriple)],
        if (!targetTriple.endsWith('-msvc'))
          for (final (from, to) in prefixes)
            if (!_splitsOnWhitespace(from)) '-ffile-prefix-map=$from=$to',
        '-DNDEBUG',
      ].join(' '),
  };
}

// rustc applies the last matching prefix, so the specific ones go last.
List<(String, String)> _pathPrefixes({
  required String checkoutDir,
  required String toolchainDir,
  required Map<String, String> env,
}) {
  final verbose =
      runCommand('rustc', ['-vV'], workingDirectory: toolchainDir).stdout
          as String;
  final commit =
      RegExp(
        r'^commit-hash: (\S+)$',
        multiLine: true,
      ).firstMatch(verbose)?.group(1) ??
      'unknown';
  final sysroot =
      (runCommand('rustc', [
                '--print',
                'sysroot',
              ], workingDirectory: toolchainDir).stdout
              as String)
          .trim();
  final home = env['HOME'] ?? env['USERPROFILE'];
  final cargoHome =
      env['CARGO_HOME'] ?? (home == null ? null : p.join(home, '.cargo'));
  return [
    if (home != null && home.isNotEmpty) ..._spellings(home, '~'),
    ..._spellings(checkoutDir, '.'),
    if (cargoHome != null && cargoHome.isNotEmpty)
      ..._spellings(cargoHome, '/cargo'),
    ..._spellings(
      p.join(sysroot, 'lib', 'rustlib', 'src', 'rust'),
      '/rustc/$commit',
    ),
  ];
}

List<(String, String)> _spellings(String path, String placeholder) {
  final absolute = p.normalize(p.absolute(path));
  String resolved;
  try {
    resolved = Directory(absolute).resolveSymbolicLinksSync();
  } on FileSystemException {
    resolved = absolute;
  }
  return [
    (absolute, placeholder),
    if (resolved != absolute) (resolved, placeholder),
  ];
}

// Cargo splits the target variable on whitespace, as it does RUSTFLAGS.
Map<String, String> _rustflags(
  Map<String, String> env,
  String triple,
  List<String> remaps,
) {
  final target =
      'CARGO_TARGET_${triple.toUpperCase().replaceAll('-', '_')}_RUSTFLAGS';
  final flags = [..._userRustflags(env, target), ...remaps];
  if (env.containsKey('CARGO_ENCODED_RUSTFLAGS') ||
      env.containsKey('RUSTFLAGS') ||
      remaps.any(_splitsOnWhitespace)) {
    return {'CARGO_ENCODED_RUSTFLAGS': flags.join('\x1f')};
  }
  return {target: flags.join(' ')};
}

List<String> _userRustflags(Map<String, String> env, String target) {
  final encoded = env['CARGO_ENCODED_RUSTFLAGS'];
  if (encoded != null && encoded.isNotEmpty) return encoded.split('\x1f');
  return (env['RUSTFLAGS'] ?? env[target] ?? '')
      .split(RegExp(r'\s+'))
      .where((flag) => flag.isNotEmpty)
      .toList();
}

bool _splitsOnWhitespace(String path) => path.contains(RegExp(r'\s'));

String _targetVariable(String name, String triple) =>
    '${name}_${triple.replaceAll('-', '_')}';
