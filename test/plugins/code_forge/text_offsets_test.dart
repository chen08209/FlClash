import 'package:code_forge/code_forge/text_offsets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const text = 'a😀b\n😀';

  test('scalar and UTF-16 offsets map across surrogate pairs', () {
    expect(
      [for (var i = 0; i <= 5; i++) text.toUtf16Offset(i)],
      [0, 1, 3, 4, 5, 7],
    );
    expect(text.toUtf16Offset(-1), 0);
    expect(text.toUtf16Offset(99), text.length);
    expect(
      [for (var i = 0; i <= 7; i++) text.toScalarOffset(i)],
      [0, 1, 2, 2, 3, 4, 5, 5],
    );
  });

  test('scalar substrings and ranges', () {
    expect(text.scalarSubstring(1, 3), '😀b');
    expect(text.scalarSubstring(4), '😀');
    expect(
      text.toScalarRanges(const [
        TextRange(start: 1, end: 3),
        TextRange(start: 5, end: 7),
      ]),
      const [TextRange(start: 1, end: 2), TextRange(start: 4, end: 5)],
    );
  });
}
