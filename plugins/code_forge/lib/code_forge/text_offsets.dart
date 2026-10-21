import 'dart:typed_data';

import 'package:flutter/services.dart' show TextRange;

/// The document and the rope count Unicode scalar values; Dart strings,
/// paragraphs and regex matches count UTF-16 code units.
extension TextOffsets on String {
  int toUtf16Offset(int scalarOffset) =>
      scalarOffset >= length ? length : utf16After(0, scalarOffset);

  /// The code unit [scalars] scalar values on from the code unit [utf16].
  int utf16After(int utf16, int scalars) {
    var index = utf16;
    for (var scalar = 0; scalar < scalars && index < length; scalar++) {
      index += _pairWidthAt(index);
    }
    return index;
  }

  int toScalarOffset(int utf16Offset) {
    var utf16 = 0;
    var scalar = 0;
    while (utf16 < utf16Offset && utf16 < length) {
      utf16 += _pairWidthAt(utf16);
      scalar++;
    }
    return scalar;
  }

  String scalarSubstring(int start, [int? end]) {
    final from = toUtf16Offset(start);
    return substring(from, end == null ? length : toUtf16Offset(end));
  }

  /// Each range's start and end in turn.
  Int32List toScalarRanges(Iterable<TextRange> ranges) {
    var utf16 = 0;
    var scalar = 0;
    int advance(int target) {
      if (target < utf16) {
        utf16 = 0;
        scalar = 0;
      }
      while (utf16 < target && utf16 < length) {
        utf16 += _pairWidthAt(utf16);
        scalar++;
      }
      return scalar;
    }

    return Int32List.fromList([
      for (final range in ranges) ...[advance(range.start), advance(range.end)],
    ]);
  }

  bool isLowSurrogateAt(int index) =>
      index > 0 && index < length && (codeUnitAt(index) & 0xFC00) == 0xDC00;

  int _pairWidthAt(int index) =>
      (codeUnitAt(index) & 0xFC00) == 0xD800 && isLowSurrogateAt(index + 1)
      ? 2
      : 1;
}
