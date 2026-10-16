import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _reorderableList = RegExp(
  r'\b(?:ReorderableListView(?:\.\w+)?|ReorderableList|SliverReorderableList|'
  r'SuperSliverReorderableList)\(',
);

const _allowed = {
  'lib/ui/super_reorderable_list.dart',
  'lib/views/dashboard/edit.dart',
};

int _lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

String _argumentsOf(String source, int open) {
  var depth = 0;
  for (var i = open; i < source.length; i++) {
    switch (source[i]) {
      case '(':
        depth++;
      case ')':
        depth--;
        if (depth == 0) {
          return source.substring(open, i + 1);
        }
    }
  }
  return source.substring(open);
}

void main() {
  test(
    'reorderable lists in lib lift their rows with commonProxyDecorator',
    () {
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File ||
            !entity.path.endsWith('.dart') ||
            entity.path.contains('/generated/')) {
          continue;
        }
        final path = p.relative(entity.path);
        if (_allowed.contains(path)) {
          continue;
        }
        final source = entity.readAsStringSync();
        for (final match in _reorderableList.allMatches(source)) {
          final arguments = _argumentsOf(source, match.end - 1);
          if (!arguments.contains('commonProxyDecorator(')) {
            offenders.add(
              '$path:${_lineOf(source, match.start)} — a lifted row without '
              'commonProxyDecorator keeps its place in the run, square edges '
              'and separator included.',
            );
          }
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
    },
  );
}
