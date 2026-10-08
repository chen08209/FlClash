import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _read = RegExp(r'BottomInsetScope\.of\((\w+)\)');

final _parameterList = RegExp(r'\(([^()]*)\)\s*(?:async\s*)?(?:=>|\{)');

int _indentOf(String line) => line.length - line.trimLeft().length;

bool _declares(String text, String name) {
  for (final match in _parameterList.allMatches(text)) {
    for (final parameter in match.group(1)!.split(',')) {
      if (parameter.trim().split(RegExp(r'\s+')).last == name) {
        return true;
      }
    }
  }
  return false;
}

String _nestedBlockAt(List<String> lines, int start) {
  final indent = _indentOf(lines[start]);
  var end = start + 1;
  while (end < lines.length &&
      (lines[end].trim().isEmpty || _indentOf(lines[end]) > indent)) {
    end++;
  }
  return lines.sublist(start, end).join('\n');
}

/// A bare `context` that no enclosing closure or member declares is the
/// `State` getter, so the scope it is read from is the whole class.
bool _readsAboveScaffold(
  List<String> lines,
  int line,
  int column,
  String name,
) {
  if (_declares(lines[line].substring(0, column), name)) {
    return false;
  }
  var indent = _indentOf(lines[line]);
  for (var index = line - 1; index >= 0; index--) {
    final text = lines[index];
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty || trimmed.startsWith('//')) {
      continue;
    }
    final lineIndent = _indentOf(text);
    if (lineIndent >= indent) {
      continue;
    }
    indent = lineIndent;
    if (_declares(text, name) || (lineIndent == 0 && name == 'context')) {
      return _nestedBlockAt(lines, index).contains('CommonScaffold(');
    }
    if (lineIndent == 0) {
      return false;
    }
  }
  return false;
}

void main() {
  test('pages read the bottom inset below the scaffold that adds to it', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/generated/')) {
        continue;
      }
      final path = p.relative(entity.path);
      if (path == 'lib/widgets/scaffold.dart') {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        for (final match in _read.allMatches(line)) {
          if (_readsAboveScaffold(lines, index, match.start, match.group(1)!)) {
            offenders.add(
              '$path:${index + 1} — reads BottomInsetScope with the context '
              'its CommonScaffold is built with, above the scope that scaffold '
              'adds for its docked search and floating action button, so the '
              'end of the content stays under them; read it inside '
              '`body: Builder(builder: (context) => ...)`.',
            );
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
