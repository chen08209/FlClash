import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final gradle = File('android/core/build.gradle.kts').readAsStringSync();

  String braced(String text, String opening) {
    final start = text.indexOf(opening);
    expect(start, isNot(-1), reason: opening);
    var depth = 0;
    for (var index = text.indexOf('{', start); index < text.length; index++) {
      if (text[index] == '{') depth++;
      if (text[index] == '}' && --depth == 0) {
        return text.substring(start, index + 1);
      }
    }
    fail('unbalanced $opening');
  }

  test('the Android Core build compiles C dependencies with NDEBUG, as the '
      'desktop builds do', () {
    final flags = braced(
      gradle.substring(gradle.indexOf('listOf("CFLAGS", "CXXFLAGS")')),
      '.forEach {',
    );

    expect(flags, contains('"-DNDEBUG"'));
  });

  test('both Cargo builds of the Android Core write where the copy reads', () {
    final environment = braced(gradle, 'val ndkEnvironment');

    expect(
      environment,
      contains('environment("CARGO_TARGET_DIR", target.path)'),
    );
    expect(gradle, contains('resolve(System.getenv("CARGO_TARGET_DIR")'));
    expect(gradle, contains('val release = target.resolve('));
  });

  test('the JNI glue builds with the toolchain Concord pins', () {
    String channel(String path) => RegExp(
      r'channel\s*=\s*"([^"]+)"',
    ).firstMatch(File(path).readAsStringSync())!.group(1)!;

    expect(
      channel('android/core/jni/rust-toolchain.toml'),
      channel('concord/rust-toolchain.toml'),
    );
  });

  test('CI runs the unit tests of every Android module that has them', () {
    final workflow =
        loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
            as YamlMap;
    final gradlew = (workflow['jobs']['android']['steps'] as YamlList)
        .cast<YamlMap>()
        .map((step) => step['run'] as String? ?? '')
        .singleWhere((run) => run.contains('./gradlew'));
    final modules = [
      for (final entry in Directory('android/tests').listSync())
        if (entry is Directory)
          entry.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty),
    ];

    expect(modules, contains('core'));
    for (final module in modules) {
      expect(gradlew, contains(':$module:testDebugUnitTest'));
    }
  });
}
