import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _uiRoots = ['lib/views', 'lib/widgets', 'lib/pages', 'lib/features'];

const _forbidden = <String, String>{
  r'globalState\.container':
      'read providers through a WidgetRef, not the global container',
  r'(?<![\w.])coreController\b':
      'reach Core through coreHandlerProvider, not the global singleton',
};

bool _isGenerated(String path) {
  return path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');
}

void main() {
  test('the UI layer never reaches a process-wide singleton directly', () {
    final offenders = <String>[];

    for (final root in _uiRoots) {
      final directory = Directory(root);
      if (!directory.existsSync()) {
        fail('$root no longer exists; update _uiRoots.');
      }
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final relative = p.relative(entity.path);
        if (_isGenerated(relative)) {
          continue;
        }
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) {
            continue;
          }
          for (final entry in _forbidden.entries) {
            if (RegExp(entry.key).hasMatch(line)) {
              offenders.add('$relative:${i + 1} — ${entry.value}');
            }
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
