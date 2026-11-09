import 'dart:io';

import 'package:test/test.dart';

import 'sources.dart';

final _circularProgress = RegExp(r'\bCircularProgressIndicator\b');

void main() {
  test('lib shows circular loading with ActivityIndicator', () {
    final offenders = <String>[];

    for (final entity in sourceEntities()) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/generated/')) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (_circularProgress.hasMatch(lines[i])) {
          offenders.add(
            '${entity.path}:${i + 1} — use ActivityIndicator, sized as the '
            'glyph it stands in for.',
          );
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
