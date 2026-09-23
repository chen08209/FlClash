import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _disposableTypes = {
  'AnimationController',
  'FocusNode',
  'PageController',
  'ScrollController',
  'StreamController',
  'TabController',
  'TextEditingController',
  'ValueNotifier',
};

/// Fields the analyzer would flag that are deliberately never released, keyed by
/// `<path>#<field>`. Everything here has to outlive the process, not a widget.
const _allowed = {
  // `CoreEventManager` is a private-constructor singleton that fans core events
  // out for the whole run; closing its controller would end event delivery.
  'lib/core/event.dart#_controller',
};

final _declaration = RegExp(
  r'^\s+(?:late\s+)?final\s+(?:[A-Za-z][\w<>,\s?]*\s+)?(_?[A-Za-z]\w*)\s*=\s*'
  r'(?:[A-Za-z]\w*)?'
  '(${_disposableTypes.join('|')})'
  r'\b',
);

/// A `late` field declared without an initialiser, which the pattern above
/// cannot see because there is no constructor call on the line. These are
/// built in `initState` and owned just the same — `pages/editor.dart` kept a
/// `late TextEditingController` alive for the process this way.
final _lateDeclaration = RegExp(
  '^\\s+late\\s+(?:final\\s+)?(${_disposableTypes.join('|')})'
  r'(?:<[\w<>,\s?]*>)?\??\s+(_?[A-Za-z]\w*)\s*;',
);

bool _isGenerated(String path) {
  return path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');
}

void main() {
  test('every self-created disposable field is released in the same file', () {
    final root = Directory('lib');
    final offenders = <String>[];

    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final relative = p.relative(entity.path);
      if (_isGenerated(relative)) {
        continue;
      }
      final source = entity.readAsStringSync();
      final lines = source.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final match = _declaration.firstMatch(lines[i]);
        final lateMatch = match == null
            ? _lateDeclaration.firstMatch(lines[i])
            : null;
        if (match == null && lateMatch == null) {
          continue;
        }
        final field = match?.group(1) ?? lateMatch!.group(2)!;
        final type = match?.group(2) ?? lateMatch!.group(1)!;
        if (_allowed.contains('$relative#$field')) {
          continue;
        }
        final released =
            source.contains('$field.dispose()') ||
            source.contains('$field.close()');
        if (!released) {
          offenders.add('$relative:${i + 1} $field ($type)');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These fields are constructed by their owner but never disposed or '
          'closed. Release them in `dispose()`, or add the declaration to '
          '`_allowed` with the reason it outlives its owner.\n'
          '${offenders.join('\n')}',
    );
  });

  test('the allow list has no stale entries', () {
    for (final entry in _allowed) {
      final parts = entry.split('#');
      final file = File(parts.first);
      expect(
        file.existsSync(),
        isTrue,
        reason: '$entry names a file that no longer exists',
      );
      expect(
        file.readAsStringSync(),
        contains(parts.last),
        reason: '$entry names a field that no longer exists',
      );
    }
  });
}
