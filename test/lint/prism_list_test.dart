import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'sources.dart';

final _flutterList = RegExp(
  r'\b(?:ListView\.(?:builder|separated)|SliverList\.(?:builder|separated)|'
  r'ReorderableListView(?:\.\w+)?|ReorderableList|SliverReorderableList|'
  r'SuperListView(?:\.\w+)?|SuperSliverList(?:\.\w+)?)\(',
);

const _allowed = {
  'lib/ui/scaffold/scaffold_actions.dart': 'the keyword strip runs sideways',
  'lib/features/editor/completion_popup.dart': 'a few suggestions at most',
  'lib/views/dashboard/edit.dart': 'a few cards, each lifting its own way',
};

void main() {
  test('lazily built lists in lib use PrismListView or SliverPrismList', () {
    final offenders = <String>[];
    for (final entity in sourceEntities()) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final path = p.relative(entity.path);
      if (_allowed.containsKey(path)) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final match in _flutterList.allMatches(source)) {
        final line = '\n'.allMatches(source.substring(0, match.start)).length;
        offenders.add(
          '$path:${line + 1} — ${match[0]} lays out every row a scrollbar '
          'drag passes; use the prism_list equivalent.',
        );
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
