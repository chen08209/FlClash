import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _roots = ['lib', 'test', 'tool', 'plugins'];

const _forbiddenImports = <String, String>{
  'package:cupertino_ui/':
      'the app is Material only; take widgets-layer types from '
      'package:flutter/widgets.dart instead',
  'package:flutter/material.dart':
      'Material comes from package:material_ui/material_ui.dart',
  'package:flutter/cupertino.dart':
      'the app is Material only; take widgets-layer types from '
      'package:flutter/widgets.dart instead',
};

const _generatedL10n = ['lib/l10n/l10n.dart', 'lib/l10n/intl/'];

bool _isGenerated(String path) {
  return path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      _generatedL10n.any(path.startsWith);
}

void main() {
  test('material_ui is the only design library the project imports', () {
    final offenders = <String>[];

    for (final root in _roots) {
      final directory = Directory(root);
      if (!directory.existsSync()) {
        fail('$root no longer exists; update _roots.');
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
          final line = lines[i].trimLeft();
          if (!line.startsWith('import ') && !line.startsWith('export ')) {
            continue;
          }
          for (final entry in _forbiddenImports.entries) {
            if (line.contains("'${entry.key}") ||
                line.contains('"${entry.key}')) {
              offenders.add('$relative:${i + 1} — ${entry.value}');
            }
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
