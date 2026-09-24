import 'dart:io';

import 'package:test/test.dart';

final _materialIcon = RegExp(r'\b(?:Animated)?Icons\.\w+');

void main() {
  test('lib draws its icons from AppGlyphs, not Material icons', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/generated/')) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final match = _materialIcon.firstMatch(lines[i]);
        if (match != null) {
          offenders.add(
            '${entity.path}:${i + 1} — ${match[0]} is a Material icon; '
            'draw it in AppGlyphs and show it with GlyphIcon.',
          );
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
