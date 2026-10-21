import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _scopeRead = RegExp(r'BottomInsetScope\.of\(');

final _insetRead = RegExp(r'(\w+)\.bottomInset\b');

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
/// `State` getter, so the block it is read from is the whole class.
String? _declaringBlock(List<String> lines, int line, int column, String name) {
  if (_declares(lines[line].substring(0, column), name)) {
    return null;
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
      return _nestedBlockAt(lines, index);
    }
    if (lineIndent == 0) {
      return null;
    }
  }
  return null;
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
      if (p.isWithin('lib/ui', path)) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        if (_scopeRead.hasMatch(line)) {
          offenders.add(
            '$path:${index + 1} — reads BottomInsetScope, which leaves out '
            'the system bar the body runs under; read `context.bottomInset`.',
          );
        }
        for (final match in _insetRead.allMatches(line)) {
          final block = _declaringBlock(
            lines,
            index,
            match.start,
            match.group(1)!,
          );
          if (block != null &&
              block.contains('CommonScaffold(') &&
              block.contains('searchState:')) {
            offenders.add(
              '$path:${index + 1} — reads the bottom inset with the context '
              'its CommonScaffold is built with, above the room that scaffold '
              'adds for its docked search, so the end of the content stays '
              'under it; read it inside '
              '`body: Builder(builder: (context) => ...)`.',
            );
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
