import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/build_cache.dart';
import 'package:setup_hooks/src/options.dart';
import 'package:setup_hooks/src/rust_builder.dart';
import 'package:setup_hooks/src/target.dart';
import 'package:setup_hooks/src/util.dart';
import 'package:test/test.dart';

void main() {
  late Directory root;
  late String inherited;
  final config = BuildConfig.load(rootDir: Directory.systemTemp.path);
  const target = Target.linuxAmd64;

  setUp(() {
    root = Directory.systemTemp.createTempSync('setup_cargo_target_');
    root = Directory(root.resolveSymbolicLinksSync());
    inherited = p.join(root.path, 'elsewhere');
  });

  tearDown(() => root.deleteSync(recursive: true));

  /// Builds as Cargo does under the inherited CARGO_TARGET_DIR, unless the
  /// build names another.
  StreamedCommand cargo(String binary) {
    return (executable, arguments, {workingDirectory, environment}) async {
      File(
          p.join(
            environment?['CARGO_TARGET_DIR'] ?? inherited,
            target.rustTriple,
            'release',
            binary,
          ),
        )
        ..createSync(recursive: true)
        ..writeAsStringSync('fresh');
    };
  }

  test('the Helper comes from where Cargo built it', () async {
    File(
        p.join(
          root.path,
          config.helperDir,
          'target',
          target.rustTriple,
          'release',
          'helper',
        ),
      )
      ..createSync(recursive: true)
      ..writeAsStringSync('stale');

    await RustBuilder(
      rootDir: root.path,
      config: config,
      cache: BuildCache(rootDir: root.path),
      notice: BuildNotice(),
      cargo: cargo('helper'),
      environment: {'CARGO_TARGET_DIR': inherited},
    ).build(target, 'core-sha256');

    expect(
      File(
        p.join(
          root.path,
          config.outputDir,
          target.platformDir,
          config.helperName,
        ),
      ).readAsStringSync(),
      'fresh',
    );
  });
}
