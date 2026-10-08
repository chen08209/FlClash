import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _plainController = RegExp(r'\bScrollController\(');

final _primaryOptOut = RegExp(r'\bprimary:\s*false\b');

const _allowed = {
  'lib/widgets/inherited.dart',
  // A drag on the editor's completion overlay must never move a sheet.
  'lib/features/editor/completion_popup.dart',
};

int _lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

void main() {
  test('scroll views in lib let a bottom sheet take their drags', () {
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
      for (final match in _plainController.allMatches(source)) {
        offenders.add(
          '$path:${_lineOf(source, match.start)} — a plain ScrollController '
          'never hands a drag to the bottom sheet around it; use '
          'sheetScrollController(context).',
        );
      }
      for (final match in _primaryOptOut.allMatches(source)) {
        offenders.add(
          '$path:${_lineOf(source, match.start)} — primary: false scrolls '
          'with a controller of its own, which never hands a drag to the '
          'bottom sheet around it; pass sheetScrollController(context).',
        );
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
