import 'dart:io';

import 'package:test/test.dart';

/// The one button that carries its label on an enclosing [Tooltip] instead of
/// its own `tooltip:`. Nesting a second tooltip inside would fight it.
const _wrappedInTooltip = 'lib/views/dashboard/widgets/core_status_button.dart';

final _iconButton = RegExp(
  r'\bIconButton(?:\.(?:filled|filledTonal|outlined))?\(',
);

Iterable<File> _dartFilesIn(String root) sync* {
  final directory = Directory(root);
  if (!directory.existsSync()) {
    fail('$root no longer exists; update this test.');
  }
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.endsWith('.g.dart') &&
        !entity.path.endsWith('.freezed.dart') &&
        !entity.path.contains('/generated/')) {
      yield entity;
    }
  }
}

/// The source of the constructor's argument list, starting after its `(`.
String _arguments(String source, int start) {
  var depth = 1;
  var index = start;
  while (index < source.length && depth > 0) {
    if (source[index] == '(') depth++;
    if (source[index] == ')') depth--;
    index++;
  }
  return source.substring(start, index - 1);
}

void main() {
  test('every icon-only IconButton carries a tooltip', () {
    final unlabelled = <String>[];

    for (final file in _dartFilesIn('lib')) {
      final source = file.readAsStringSync();
      if (file.path == _wrappedInTooltip) continue;

      for (final match in _iconButton.allMatches(source)) {
        final arguments = _arguments(source, match.end);
        if (RegExp(r'\btooltip\s*:').hasMatch(arguments)) continue;
        // An icon slot holding text is already its own visible label.
        if (RegExp(r'icon:\s*Text\(').hasMatch(arguments)) continue;

        final line = '\n'.allMatches(source.substring(0, match.start)).length;
        unlabelled.add(
          '${file.path}:${line + 1} — an icon has no accessible name, so '
          'TalkBack and VoiceOver announce nothing and the desktop build shows '
          'no hover hint.',
        );
      }
    }

    expect(unlabelled, isEmpty, reason: unlabelled.join('\n'));
  });

  test('the exempted button still gets its label from an enclosing Tooltip', () {
    final source = File(_wrappedInTooltip).readAsStringSync();

    expect(
      source,
      contains('Tooltip('),
      reason:
          '$_wrappedInTooltip is exempted from the tooltip rule because an '
          'enclosing Tooltip labels it. That wrapper is gone; either restore it '
          'or give the button its own tooltip and drop the exemption.',
    );
  });
}
