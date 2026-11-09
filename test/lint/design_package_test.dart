import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _roots = ['lib', 'test', 'tool', 'plugins'];

const _forbiddenImports = <String, String>{
  'package:material_ui/':
      'widgets come from package:flutter/widgets.dart and components from '
      'prism_ui',
  'package:cupertino_ui/':
      'widgets come from package:flutter/widgets.dart and components from '
      'prism_ui',
  'package:flutter/material.dart':
      'widgets come from package:flutter/widgets.dart and components from '
      'prism_ui',
  'package:flutter/cupertino.dart':
      'widgets come from package:flutter/widgets.dart and components from '
      'prism_ui',
};

const _generatedL10n = ['lib/l10n/l10n.dart', 'lib/l10n/intl/'];

bool _isGenerated(String path) {
  return path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      _generatedL10n.any(path.startsWith);
}

void main() {
  test('the project imports no design library', () {
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
