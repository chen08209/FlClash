import 'dart:io';

import 'package:test/test.dart';

final _circularApi = RegExp(
  r'\b(?:RoundedRectangleBorder|ContinuousRectangleBorder|StadiumBorder'
  r'|ClipRRect|drawRRect|drawDRRect|addRRect|clipRRect)\b|\bRRect\.',
);

final _radiusCall = RegExp(r'\b(BoxDecoration|InkWell|InkResponse)\(');

bool _hasTopLevelBorderRadius(String source, int open) {
  var depth = 0;
  for (var i = open; i < source.length; i++) {
    switch (source[i]) {
      case '(' || '[' || '{':
        depth++;
      case ')' || ']' || '}':
        depth--;
        if (depth == 0) {
          return false;
        }
      default:
        if (depth == 1 &&
            source.startsWith('borderRadius:', i) &&
            !RegExp(r'\w').hasMatch(source[i - 1])) {
          return true;
        }
    }
  }
  return false;
}

int _lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

void main() {
  test('lib rounds corners with superellipses, not circular arcs', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.contains('/generated/')) {
        continue;
      }
      final source = entity.readAsStringSync();
      final reported = <int>{};
      for (final match in _circularApi.allMatches(source)) {
        if (!reported.add(_lineOf(source, match.start))) {
          continue;
        }
        offenders.add(
          '${entity.path}:${_lineOf(source, match.start)} — ${match[0]} '
          'draws circular corners; use the superellipse API or AppShape.',
        );
      }
      for (final match in _radiusCall.allMatches(source)) {
        if (_hasTopLevelBorderRadius(source, match.end - 1)) {
          offenders.add(
            '${entity.path}:${_lineOf(source, match.start)} — ${match[1]} '
            'with borderRadius rounds with circular arcs; use a '
            'ShapeDecoration or customBorder with an AppShape.',
          );
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
