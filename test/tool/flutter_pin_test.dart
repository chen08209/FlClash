import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

List<int> _parts(String version) =>
    version.split('.').map(int.parse).toList(growable: false);

int _compare(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  for (var i = 0; i < left.length && i < right.length; i++) {
    if (left[i] != right[i]) {
      return left[i].compareTo(right[i]);
    }
  }
  return left.length.compareTo(right.length);
}

void main() {
  test('release builds pin a Flutter whose Linux engine draws without '
      'glBlitFramebuffer in place', () {
    final workflow =
        loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
            as YamlMap;
    final pinned = (workflow['env'] as YamlMap)['FLUTTER_VERSION'] as String;

    expect(
      _compare(pinned, '3.50.1'),
      greaterThanOrEqualTo(0),
      reason:
          'Flutter 3.50.0 shifts the Linux window content by half its size '
          'on drivers without glBlitFramebuffer, all NVIDIA ones included '
          '(flutter/flutter#195885, fixed in 3.50.1)',
    );
  });
}
