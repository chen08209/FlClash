import 'dart:convert';

import 'package:fl_clash/ui/qr_code.dart';
import 'package:fl_clash/ui/qr_matrix.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

const _eccPerBlock = [
  10,
  16,
  26,
  18,
  24,
  16,
  18,
  22,
  22,
  26,
  30,
  22,
  22,
  24,
  24,
  28,
  28,
  26,
  26,
  26, //
  26,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
  28,
];
const _blockCount = [
  1, 1, 1, 2, 2, 4, 4, 4, 5, 5, 5, 8, 9, 9, 10, 10, 11, 13, 14, 16, //
  17,
  17,
  18,
  20,
  21,
  23,
  25,
  26,
  28,
  29,
  31,
  33,
  35,
  37,
  38,
  40,
  43,
  45,
  47,
  49,
];

final _masks = <bool Function(int r, int c)>[
  (r, c) => (r + c) % 2 == 0,
  (r, c) => r % 2 == 0,
  (r, c) => c % 3 == 0,
  (r, c) => (r + c) % 3 == 0,
  (r, c) => (r ~/ 2 + c ~/ 3) % 2 == 0,
  (r, c) => r * c % 2 + r * c % 3 == 0,
  (r, c) => (r * c % 2 + r * c % 3) % 2 == 0,
  (r, c) => ((r + c) % 2 + r * c % 3) % 2 == 0,
];

int _alignmentCount(int version) => version == 1 ? 0 : version ~/ 7 + 2;

List<int> _alignmentCenters(int version) {
  final count = _alignmentCount(version);
  if (count == 0) {
    return const [];
  }
  final step = version == 32
      ? 26
      : (version * 4 + count * 2 + 1) ~/ (count * 2 - 2) * 2;
  final last = version * 4 + 10;
  return [6, for (var i = count - 2; i >= 0; i--) last - i * step];
}

int _totalCodewords(int version) {
  final count = _alignmentCount(version);
  var modules = (16 * version + 128) * version + 64;
  if (count > 0) {
    modules -= (25 * count - 10) * count - 55;
  }
  if (version >= 7) {
    modules -= 36;
  }
  return modules ~/ 8;
}

int _dataCodewords(int version) =>
    _totalCodewords(version) -
    _eccPerBlock[version - 1] * _blockCount[version - 1];

int _byteCapacity(int version) =>
    _dataCodewords(version) - (version < 10 ? 2 : 3);

int _gfMultiply(int a, int b) {
  var result = 0;
  for (var i = 7; i >= 0; i--) {
    result = (result << 1) ^ ((result >> 7) * 0x11D);
    result ^= ((b >> i) & 1) * a;
  }
  return result;
}

int _bchRemainder(int data, int generator, int degree) {
  var remainder = data << degree;
  for (var bit = generator.bitLength + 15; bit >= degree; bit--) {
    if ((remainder >> bit) & 1 == 1) {
      remainder ^= generator << (bit - degree);
    }
  }
  return remainder;
}

/// A decoder that shares nothing with `QrMatrix`, so a wrong table or module
/// placement there cannot cancel itself out in a round trip.
final class _Decoded {
  final int version;
  final int mask;
  final List<int> stream;

  _Decoded(this.version, this.mask, this.stream);

  factory _Decoded.of(QrMatrix matrix) {
    final size = matrix.size;
    final version = (size - 17) ~/ 4;
    bool dark(int r, int c) => matrix.isDark(r, c);

    _expectFinders(matrix);
    for (var i = 8; i < size - 8; i++) {
      expect(dark(6, i), i.isEven, reason: 'timing row at $i');
      expect(dark(i, 6), i.isEven, reason: 'timing column at $i');
    }
    expect(dark(size - 8, 8), isTrue, reason: 'the dark module');

    final mask = _readFormat(matrix);
    if (version >= 7) {
      _expectVersionInfo(matrix, version);
    }
    final reserved = _functionModules(version);
    _expectAlignmentPatterns(matrix, version);

    final total = _totalCodewords(version);
    final raw = List.filled(total, 0);
    var read = 0;
    for (var right = size - 1; right >= 1; right -= 2) {
      if (right == 6) {
        right = 5;
      }
      final upward = (right + 1) & 2 == 0;
      for (var step = 0; step < size; step++) {
        final r = upward ? size - 1 - step : step;
        for (var c = right; c >= right - 1; c--) {
          if (reserved[r * size + c] || read >= total * 8) {
            continue;
          }
          if (dark(r, c) != _masks[mask](r, c)) {
            raw[read >> 3] |= 0x80 >> (read & 7);
          }
          read++;
        }
      }
    }
    expect(read, total * 8, reason: 'codewords placed');
    return _Decoded(version, mask, _correctedData(version, raw));
  }

  static void _expectFinders(QrMatrix matrix) {
    final last = matrix.size - 7;
    for (final (top, left) in [(0, 0), (0, last), (last, 0)]) {
      for (var r = 0; r < 7; r++) {
        for (var c = 0; c < 7; c++) {
          final ring = r == 0 || r == 6 || c == 0 || c == 6;
          final core = r >= 2 && r <= 4 && c >= 2 && c <= 4;
          expect(
            matrix.isDark(top + r, left + c),
            ring || core,
            reason: 'finder at $top,$left module $r,$c',
          );
        }
      }
    }
  }

  static int _readFormat(QrMatrix matrix) {
    final size = matrix.size;
    var first = 0;
    var second = 0;
    void set(bool dark, int bit, void Function(int) apply) {
      if (dark) {
        apply(1 << bit);
      }
    }

    for (var i = 0; i <= 5; i++) {
      set(matrix.isDark(i, 8), i, (v) => first |= v);
    }
    set(matrix.isDark(7, 8), 6, (v) => first |= v);
    set(matrix.isDark(8, 8), 7, (v) => first |= v);
    set(matrix.isDark(8, 7), 8, (v) => first |= v);
    for (var i = 9; i <= 14; i++) {
      set(matrix.isDark(8, 14 - i), i, (v) => first |= v);
    }
    for (var i = 0; i <= 7; i++) {
      set(matrix.isDark(8, size - 1 - i), i, (v) => second |= v);
    }
    for (var i = 8; i <= 14; i++) {
      set(matrix.isDark(size - 15 + i, 8), i, (v) => second |= v);
    }
    expect(first, second, reason: 'both format copies');

    final format = first ^ 0x5412;
    final data = format >> 10;
    expect(data >> 3, 0, reason: 'error correction level M');
    expect(_bchRemainder(data, 0x537, 10), format & 0x3FF);
    return data & 7;
  }

  static void _expectVersionInfo(QrMatrix matrix, int version) {
    final bits = version << 12 | _bchRemainder(version, 0x1F25, 12);
    for (var i = 0; i < 18; i++) {
      final expected = (bits >> i) & 1 == 1;
      final near = matrix.size - 11 + i % 3;
      final far = i ~/ 3;
      expect(matrix.isDark(far, near), expected, reason: 'version bit $i');
      expect(matrix.isDark(near, far), expected, reason: 'version bit $i');
    }
  }

  static bool _overlapsFinder(int a, int b, int size) =>
      (a == 6 && b == 6) ||
      (a == 6 && b == size - 7) ||
      (a == size - 7 && b == 6);

  static void _expectAlignmentPatterns(QrMatrix matrix, int version) {
    final centers = _alignmentCenters(version);
    for (final a in centers) {
      for (final b in centers) {
        if (_overlapsFinder(a, b, matrix.size)) {
          continue;
        }
        for (var r = -2; r <= 2; r++) {
          for (var c = -2; c <= 2; c++) {
            final ring = r.abs() == 2 || c.abs() == 2;
            expect(
              matrix.isDark(a + r, b + c),
              ring || (r == 0 && c == 0),
              reason: 'v$version alignment at $a,$b',
            );
          }
        }
      }
    }
  }

  static List<bool> _functionModules(int version) {
    final size = version * 4 + 17;
    final reserved = List.filled(size * size, false);
    void block(int top, int left, int height, int width) {
      for (var r = top; r < top + height; r++) {
        for (var c = left; c < left + width; c++) {
          reserved[r * size + c] = true;
        }
      }
    }

    block(0, 0, 9, 9);
    block(0, size - 8, 9, 8);
    block(size - 8, 0, 8, 9);
    block(6, 0, 1, size);
    block(0, 6, size, 1);
    final centers = _alignmentCenters(version);
    for (final a in centers) {
      for (final b in centers) {
        if (!_overlapsFinder(a, b, size)) {
          block(a - 2, b - 2, 5, 5);
        }
      }
    }
    if (version >= 7) {
      block(0, size - 11, 6, 3);
      block(size - 11, 0, 3, 6);
    }
    return reserved;
  }

  static List<int> _correctedData(int version, List<int> raw) {
    final count = _blockCount[version - 1];
    final ecc = _eccPerBlock[version - 1];
    final total = raw.length;
    final shortBlocks = count - total % count;
    final shortData = total ~/ count - ecc;
    final blocks = [
      for (var i = 0; i < count; i++)
        List.filled(shortData + ecc + (i < shortBlocks ? 0 : 1), 0),
    ];
    var at = 0;
    for (var i = 0; i < shortData + 1; i++) {
      for (var b = 0; b < count; b++) {
        if (i < shortData || b >= shortBlocks) {
          blocks[b][i] = raw[at++];
        }
      }
    }
    for (var i = 0; i < ecc; i++) {
      for (final block in blocks) {
        block[block.length - ecc + i] = raw[at++];
      }
    }
    expect(at, total);

    for (final block in blocks) {
      var root = 1;
      for (var i = 0; i < ecc; i++) {
        var syndrome = 0;
        for (final codeword in block) {
          syndrome = _gfMultiply(syndrome, root) ^ codeword;
        }
        expect(syndrome, 0, reason: 'v$version syndrome $i');
        root = _gfMultiply(root, 2);
      }
    }
    return [for (final block in blocks) ...block.take(block.length - ecc)];
  }

  ({int? eci, String text}) get payload {
    var bit = 0;
    int take(int length) {
      var value = 0;
      for (var i = 0; i < length; i++, bit++) {
        value = value << 1 | ((stream[bit >> 3] >> (7 - (bit & 7))) & 1);
      }
      return value;
    }

    var mode = take(4);
    int? eci;
    if (mode == 7) {
      eci = take(8);
      mode = take(4);
    }
    expect(mode, 4, reason: 'byte mode');
    final length = take(version < 10 ? 8 : 16);
    final bytes = [for (var i = 0; i < length; i++) take(8)];

    final capacity = stream.length * 8;
    if (bit + 4 <= capacity) {
      expect(take(4), 0, reason: 'terminator');
    }
    bit = (bit + 7) & ~7;
    for (var pad = 0xEC; bit < capacity; pad ^= 0xEC ^ 0x11) {
      expect(take(8), pad, reason: 'pad codeword');
    }
    return (eci: eci, text: utf8.decode(bytes));
  }
}

void main() {
  group('QrMatrix', () {
    test('every version holds its full byte capacity and no more', () {
      for (var version = 1; version <= 40; version++) {
        final capacity = _byteCapacity(version);
        final text = String.fromCharCodes(
          List.generate(capacity, (i) => 0x21 + i * 7 % 90),
        );
        final matrix = QrMatrix.encode(text)!;
        expect(matrix.size, version * 4 + 17, reason: 'version $version');

        final decoded = _Decoded.of(matrix);
        expect(decoded.version, version);
        expect(decoded.payload.eci, isNull);
        expect(decoded.payload.text, text);

        if (version < 40) {
          expect(
            QrMatrix.encode('x' * (capacity + 1))!.size,
            (version + 1) * 4 + 17,
            reason: 'one byte past version $version',
          );
        }
      }
    });

    test('rejects what the largest code cannot hold', () {
      expect(_byteCapacity(40), 2331);
      expect(QrMatrix.encode('x' * 2332), isNull);
      expect(QrMatrix.encode('中' * 776), isNotNull);
      expect(QrMatrix.encode('中' * 777), isNull);
    });

    test('short data is padded out to the version capacity', () {
      for (final text in ['', 'a', 'https://example.com/sub?token=abc']) {
        final decoded = _Decoded.of(QrMatrix.encode(text)!);
        expect(decoded.payload.text, text);
      }
    });

    test('text beyond Latin-1 announces UTF-8 through an ECI header', () {
      const text = 'clash://install-config?name=配置';
      final decoded = _Decoded.of(QrMatrix.encode(text)!);
      expect(decoded.payload.eci, 26);
      expect(decoded.payload.text, text);
    });

    test('text within Latin-1 carries no ECI header', () {
      final decoded = _Decoded.of(QrMatrix.encode('café')!);
      expect(decoded.payload.eci, isNull);
      expect(decoded.payload.text, 'café');
    });

    test('mask selection is deterministic for the same data', () {
      final masks = <int>{};
      for (var i = 0; i < 200; i++) {
        final text = 'mask-$i';
        final first = _Decoded.of(QrMatrix.encode(text)!);
        final second = _Decoded.of(QrMatrix.encode(text)!);
        expect(first.mask, second.mask);
        masks.add(first.mask);
      }
      expect(masks.length, greaterThan(1));
    });
  });

  group('QrCodeView', () {
    Widget host(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

    test('fits follows the encoder limit', () {
      expect(QrCodeView.fits('x' * 2331), isTrue);
      expect(QrCodeView.fits('x' * 2332), isFalse);
    });

    testWidgets('paints a square code no wider than its size', (tester) async {
      await tester.pumpWidget(host(const QrCodeView(data: 'abc', size: 200)));
      expect(tester.takeException(), isNull);

      final paint = find.byType(CustomPaint);
      expect(paint, findsWidgets);
      expect(tester.getSize(paint.last), const Size(200, 200));
      expect(
        tester.getSemantics(find.byType(QrCodeView)).label,
        contains('abc'),
      );
    });

    testWidgets('repaints when the data changes', (tester) async {
      await tester.pumpWidget(host(const QrCodeView(data: 'first')));
      final before = tester.widget<CustomPaint>(find.byType(CustomPaint).last);

      await tester.pumpWidget(host(const QrCodeView(data: 'second')));
      final after = tester.widget<CustomPaint>(find.byType(CustomPaint).last);

      expect(after.painter!.shouldRepaint(before.painter!), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the text itself when it does not fit', (tester) async {
      final data = 'x' * 2332;
      await tester.pumpWidget(host(QrCodeView(data: data)));
      expect(tester.takeException(), isNull);

      expect(find.byType(SelectableText), findsOneWidget);
      expect(
        tester.widget<SelectableText>(find.byType(SelectableText)).data,
        data,
      );
    });
  });
}
