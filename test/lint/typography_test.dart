import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _typography = 'lib/ui/typography.dart';

// The code editor sizes its text from the editor font-size setting.
const _editorSizes = ['lib/pages/editor.dart', 'lib/features/editor/'];

final _textTheme = RegExp(r'\btextTheme\b');
final _fontSize = RegExp(r'\bfontSize:');
final _fontWeight = RegExp(r'\bfontWeight:');

bool _isGenerated(String path) =>
    path.contains('/generated/') ||
    path.endsWith('.g.dart') ||
    path.startsWith('lib/l10n/');

void main() {
  test('lib takes its text sizes from AppTextStyle', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      final path = p.relative(entity.path);
      if (entity is! File || !path.endsWith('.dart') || _isGenerated(path)) {
        continue;
      }
      final checksSize =
          !path.startsWith('lib/ui/') && !_editorSizes.any(path.startsWith);
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (path != _typography && _textTheme.hasMatch(line)) {
          offenders.add(
            '$path:${i + 1} — reads a Material TextTheme slot; use an '
            'AppTextStyle from $_typography.',
          );
        }
        if (checksSize && _fontSize.hasMatch(line)) {
          offenders.add(
            '$path:${i + 1} — sets a font size outside lib/ui; use an '
            'AppTextStyle, or AppTextStyle.custom for a size off the scale.',
          );
        }
        if (checksSize && _fontWeight.hasMatch(line)) {
          offenders.add(
            '$path:${i + 1} — sets a font weight outside lib/ui; pass '
            'emphasized to AppTextStyle.of.',
          );
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
