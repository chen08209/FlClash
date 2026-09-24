import 'dart:io';

import 'package:test/test.dart';

final _filledButton = RegExp(
  r'\b(?:IconButton\.filled(?:Tonal)?|FilledButton(?:\.tonal|\.icon|\.tonalIcon)?'
  r'|(?:Common)?FloatingActionButton(?:\.extended|\.small|\.large)?)\(',
);
final _glyphIcon = RegExp(r'\bGlyphIcon\(');
final _filled = RegExp(r'\bfill:\s*1\b');

int _closingParen(String source, int open) {
  var depth = 0;
  String? quote;
  for (var i = open; i < source.length; i++) {
    final char = source[i];
    if (quote != null) {
      if (char == r'\') {
        i++;
      } else if (char == quote) {
        quote = null;
      }
    } else if (char == "'" || char == '"') {
      quote = char;
    } else if (char == '(') {
      depth++;
    } else if (char == ')' && --depth == 0) {
      return i;
    }
  }
  return source.length - 1;
}

void main() {
  test('glyphs inside filled buttons are drawn filled', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/generated/')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final button in _filledButton.allMatches(source)) {
        final end = _closingParen(source, button.end - 1);
        final arguments = source.substring(button.end, end);
        for (final glyph in _glyphIcon.allMatches(arguments)) {
          final start = button.end + glyph.start;
          final call = source.substring(
            start,
            _closingParen(source, button.end + glyph.end - 1) + 1,
          );
          if (!_filled.hasMatch(call)) {
            final line = '\n'.allMatches(source.substring(0, start)).length;
            offenders.add(
              '${entity.path}:${line + 1} — ${button[0]} holds $call; '
              'pass fill: 1.',
            );
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
