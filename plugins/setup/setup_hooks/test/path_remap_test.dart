import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/path_remap.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late String home;
  late String checkout;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('path_remap_test');
    home = temp.resolveSymbolicLinksSync();
    checkout = p.join(home, 'checkout');
    Directory(checkout).createSync();
  });

  tearDown(() => temp.deleteSync(recursive: true));

  Map<String, String> environment(
    String triple, [
    Map<String, String> extra = const {},
  ]) => trimmedPathEnvironment(
    checkoutDir: checkout,
    toolchainDir: Directory.current.path,
    targetTriple: triple,
    environment: {'HOME': home, ...extra},
  );

  List<String> rustflags(Map<String, String> env) =>
      env['CARGO_ENCODED_RUSTFLAGS']!.split('\x1f');

  List<String> targetRustflags(Map<String, String> env) =>
      env['CARGO_TARGET_AARCH64_APPLE_DARWIN_RUSTFLAGS']!.split(' ');

  test('maps the specific prefixes after the home directory', () {
    final flags = targetRustflags(environment('aarch64-apple-darwin'));
    expect(flags.first, '--remap-path-prefix=$home=~');
    expect(flags, contains('--remap-path-prefix=$checkout=.'));
    expect(
      flags,
      contains('--remap-path-prefix=${p.join(home, '.cargo')}=/cargo'),
    );
    expect(flags.last, matches(RegExp(r'^--remap-path-prefix=.+=/rustc/\S+$')));
  });

  test('keeps the flags the caller set', () {
    expect(
      rustflags(environment('aarch64-apple-darwin', {'RUSTFLAGS': '-C a'})),
      containsAllInOrder(['-C', 'a', '--remap-path-prefix=$home=~']),
    );
    expect(
      rustflags(
        environment('aarch64-apple-darwin', {
          'RUSTFLAGS': '-C ignored',
          'CARGO_ENCODED_RUSTFLAGS': '-C\x1fa b',
        }),
      ),
      allOf(containsAllInOrder(['-C', 'a b']), isNot(contains('ignored'))),
    );
    expect(
      environment('aarch64-linux-android', {
        'CFLAGS_aarch64_linux_android': '-O1',
      })['CFLAGS_aarch64_linux_android'],
      startsWith('-O1 -ffile-prefix-map=$home=~'),
    );
  });

  test('gives MSVC no path prefix maps for C', () {
    final env = environment('x86_64-pc-windows-msvc', {
      'CFLAGS_x86_64_pc_windows_msvc': '/W3',
    });
    expect(env['CFLAGS_x86_64_pc_windows_msvc'], '/W3 -DNDEBUG');
    expect(env['CXXFLAGS_x86_64_pc_windows_msvc'], '-DNDEBUG');
  });

  test('defines NDEBUG for C on every target', () {
    for (final triple in const [
      'aarch64-apple-darwin',
      'aarch64-linux-android',
      'x86_64-unknown-linux-gnu',
      'aarch64-pc-windows-msvc',
    ]) {
      final env = environment(triple);
      final under = triple.replaceAll('-', '_');
      for (final name in const ['CFLAGS', 'CXXFLAGS']) {
        expect(env['${name}_$under']!.split(' ').last, '-DNDEBUG');
      }
    }
  });

  test('adds to the target rustflags a Cargo config joins', () {
    final env = environment('aarch64-apple-darwin', {
      'CARGO_TARGET_AARCH64_APPLE_DARWIN_RUSTFLAGS': '-C a',
    });

    expect(env, isNot(contains('CARGO_ENCODED_RUSTFLAGS')));
    expect(
      targetRustflags(env),
      containsAllInOrder(['-C', 'a', '--remap-path-prefix=$home=~']),
    );
  });

  test('encodes the flags when a path has a space', () {
    checkout = p.join(home, 'check out');
    Directory(checkout).createSync();

    final env = environment('aarch64-apple-darwin', {
      'CARGO_TARGET_AARCH64_APPLE_DARWIN_RUSTFLAGS': '-C a',
    });

    expect(
      env.keys,
      isNot(contains('CARGO_TARGET_AARCH64_APPLE_DARWIN_RUSTFLAGS')),
    );
    expect(
      rustflags(env),
      containsAllInOrder(['-C', 'a', '--remap-path-prefix=$checkout=.']),
    );
  });
}
