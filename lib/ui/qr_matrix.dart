/*
Copyright 2014, the Dart QR project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'dart:convert';
import 'dart:typed_data';

const _light = 1;
const _dark = 2;

const _eciMode = 7;
const _byteMode = 4;
const _utf8Eci = 26;

const _mediumLevelFormat = 0;
const _formatGenerator = 0x537;
const _formatMask = 0x5412;
const _versionGenerator = 0x1F25;

/// The modules of a QR code holding a string in byte mode at error correction
/// level M.
final class QrMatrix {
  final int size;
  final Uint8List _modules;

  QrMatrix._(this.size, this._modules);

  /// Null when [data] does not fit the largest code.
  static QrMatrix? encode(String data) {
    final bytes = utf8.encode(data);
    final eci = data.codeUnits.any((unit) => unit > 255);
    final version = _smallestVersion(bytes.length, eci);
    if (version == null) {
      return null;
    }
    return _Builder(version).build(_codewords(version, bytes, eci));
  }

  bool isDark(int row, int col) => _modules[row * size + col] == _dark;
}

int _countBits(int version) => version < 10 ? 8 : 16;

int _dataCodewords(int version) {
  final b = _blocks[version - 1];
  return b[0] * b[2] + (b.length > 3 ? b[3] * b[5] : 0);
}

int? _smallestVersion(int length, bool eci) {
  final header = eci ? 12 : 0;
  for (var version = 1; version <= 40; version++) {
    final bits = header + 4 + _countBits(version) + length * 8;
    if (bits <= _dataCodewords(version) * 8) {
      return version;
    }
  }
  return null;
}

Uint8List _codewords(int version, List<int> bytes, bool eci) {
  final capacity = _dataCodewords(version);
  final writer = _BitWriter(capacity);
  if (eci) {
    writer
      ..put(_eciMode, 4)
      ..put(_utf8Eci, 8);
  }
  writer
    ..put(_byteMode, 4)
    ..put(bytes.length, _countBits(version));
  for (final byte in bytes) {
    writer.put(byte, 8);
  }
  if (writer.length + 4 <= capacity * 8) {
    writer.put(0, 4);
  }
  writer.alignToByte();
  for (var i = 0; writer.length < capacity * 8; i++) {
    writer.put(i.isEven ? 0xEC : 0x11, 8);
  }
  return _interleave(version, writer.bytes);
}

Uint8List _interleave(int version, Uint8List data) {
  final b = _blocks[version - 1];
  final groups = [
    for (var i = 0; i < b.length; i += 3)
      for (var j = 0; j < b[i]; j++) (total: b[i + 1], data: b[i + 2]),
  ];
  final ecCount = groups.first.total - groups.first.data;
  final generator = _generator(ecCount);
  final dataBlocks = <Uint8List>[];
  final ecBlocks = <Uint8List>[];
  var offset = 0;
  for (final group in groups) {
    final block = data.sublist(offset, offset + group.data);
    offset += group.data;
    dataBlocks.add(block);
    ecBlocks.add(_remainder(block, generator));
  }
  final out = BytesBuilder(copy: false);
  for (var i = 0; i < groups.last.data; i++) {
    for (final block in dataBlocks) {
      if (i < block.length) {
        out.addByte(block[i]);
      }
    }
  }
  for (var i = 0; i < ecCount; i++) {
    for (final block in ecBlocks) {
      out.addByte(block[i]);
    }
  }
  return out.takeBytes();
}

final _exp = () {
  final table = Uint8List(256);
  for (var i = 0; i < 8; i++) {
    table[i] = 1 << i;
  }
  for (var i = 8; i < 256; i++) {
    table[i] = table[i - 4] ^ table[i - 5] ^ table[i - 6] ^ table[i - 8];
  }
  return table;
}();

final _log = () {
  final table = Uint8List(256);
  for (var i = 0; i < 255; i++) {
    table[_exp[i]] = i;
  }
  return table;
}();

int _multiply(int a, int b) =>
    a == 0 || b == 0 ? 0 : _exp[(_log[a] + _log[b]) % 255];

Uint8List _generator(int degree) {
  var poly = Uint8List.fromList([1]);
  for (var i = 0; i < degree; i++) {
    final next = Uint8List(poly.length + 1);
    final root = _exp[i % 255];
    for (var j = 0; j < poly.length; j++) {
      next[j] ^= poly[j];
      next[j + 1] ^= _multiply(poly[j], root);
    }
    poly = next;
  }
  return poly;
}

Uint8List _remainder(Uint8List data, Uint8List generator) {
  final degree = generator.length - 1;
  final work = Uint8List(data.length + degree)..setRange(0, data.length, data);
  for (var i = 0; i < data.length; i++) {
    final factor = work[i];
    if (factor != 0) {
      for (var j = 0; j <= degree; j++) {
        work[i + j] ^= _multiply(generator[j], factor);
      }
    }
  }
  return work.sublist(data.length);
}

final class _BitWriter {
  final Uint8List bytes;
  int length = 0;

  _BitWriter(int capacity) : bytes = Uint8List(capacity);

  void put(int value, int bits) {
    for (var i = bits - 1; i >= 0; i--) {
      if ((value >> i) & 1 == 1) {
        bytes[length >> 3] |= 0x80 >> (length & 7);
      }
      length++;
    }
  }

  void alignToByte() {
    length = (length + 7) & ~7;
  }
}

final class _Builder {
  final int version;
  final int size;
  final Uint8List reserved;

  _Builder(this.version)
    : size = version * 4 + 17,
      reserved = Uint8List((version * 4 + 17) * (version * 4 + 17));

  void _set(Uint8List grid, int row, int col, bool dark) {
    grid[row * size + col] = dark ? _dark : _light;
  }

  QrMatrix build(Uint8List codewords) {
    _placeFinder(0, 0);
    _placeFinder(size - 7, 0);
    _placeFinder(0, size - 7);
    _placeAlignment();
    _placeTiming();
    _placeFormat(reserved, 0, reserve: true);
    if (version >= 7) {
      _placeVersion(reserved, reserve: true);
    }
    final unmasked = Uint8List.fromList(reserved);
    _placeData(unmasked, codewords);

    Uint8List? best;
    var bestMask = 0;
    var bestScore = double.maxFinite;
    for (var mask = 0; mask < 8; mask++) {
      final candidate = Uint8List.fromList(unmasked);
      _applyMask(candidate, mask);
      final score = _penalty(candidate);
      if (score < bestScore) {
        bestScore = score;
        bestMask = mask;
        best = candidate;
      }
    }
    final modules = best!;
    _placeFormat(modules, bestMask, reserve: false);
    if (version >= 7) {
      _placeVersion(modules, reserve: false);
    }
    return QrMatrix._(size, modules);
  }

  void _placeFinder(int row, int col) {
    for (var r = -1; r <= 7; r++) {
      for (var c = -1; c <= 7; c++) {
        if (row + r < 0 || row + r >= size || col + c < 0 || col + c >= size) {
          continue;
        }
        final dark =
            (0 <= r && r <= 6 && (c == 0 || c == 6)) ||
            (0 <= c && c <= 6 && (r == 0 || r == 6)) ||
            (2 <= r && r <= 4 && 2 <= c && c <= 4);
        _set(reserved, row + r, col + c, dark);
      }
    }
  }

  void _placeAlignment() {
    final positions = _alignmentPositions[version - 1];
    for (final row in positions) {
      for (final col in positions) {
        if (reserved[row * size + col] != 0) {
          continue;
        }
        for (var r = -2; r <= 2; r++) {
          for (var c = -2; c <= 2; c++) {
            final dark = r.abs() == 2 || c.abs() == 2 || (r == 0 && c == 0);
            _set(reserved, row + r, col + c, dark);
          }
        }
      }
    }
  }

  void _placeTiming() {
    for (var i = 8; i < size - 8; i++) {
      if (reserved[i * size + 6] == 0) {
        _set(reserved, i, 6, i.isEven);
      }
      if (reserved[6 * size + i] == 0) {
        _set(reserved, 6, i, i.isEven);
      }
    }
  }

  void _placeFormat(Uint8List grid, int mask, {required bool reserve}) {
    final bits = _formatBits((_mediumLevelFormat << 3) | mask);
    for (var i = 0; i < 15; i++) {
      final dark = !reserve && (bits >> i) & 1 == 1;
      final row = i < 6 ? i : (i < 8 ? i + 1 : size - 15 + i);
      _set(grid, row, 8, dark);
      final col = i < 8 ? size - i - 1 : (i < 9 ? 15 - i : 14 - i);
      _set(grid, 8, col, dark);
    }
    _set(grid, size - 8, 8, !reserve);
  }

  void _placeVersion(Uint8List grid, {required bool reserve}) {
    final bits = _versionBits(version);
    for (var i = 0; i < 18; i++) {
      final dark = !reserve && (bits >> i) & 1 == 1;
      _set(grid, i ~/ 3, i % 3 + size - 11, dark);
      _set(grid, i % 3 + size - 11, i ~/ 3, dark);
    }
  }

  void _placeData(Uint8List grid, Uint8List data) {
    var inc = -1;
    var row = size - 1;
    var bit = 7;
    var index = 0;
    for (var col = size - 1; col > 0; col -= 2) {
      if (col == 6) {
        col--;
      }
      for (;;) {
        for (var c = 0; c < 2; c++) {
          if (grid[row * size + col - c] != 0) {
            continue;
          }
          final dark = index < data.length && (data[index] >> bit) & 1 == 1;
          _set(grid, row, col - c, dark);
          if (--bit < 0) {
            index++;
            bit = 7;
          }
        }
        row += inc;
        if (row < 0 || row >= size) {
          row -= inc;
          inc = -inc;
          break;
        }
      }
    }
  }

  void _applyMask(Uint8List grid, int mask) {
    final masked = _masks[mask];
    var index = 0;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++, index++) {
        if (reserved[index] == 0 && masked(row, col)) {
          grid[index] ^= _dark ^ _light;
        }
      }
    }
  }

  double _penalty(Uint8List data) {
    var penalty = 0.0;
    var darkCount = 0;
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final index = row * size + col;
        final module = data[index];
        if (module == _dark) {
          darkCount++;
        }
        var same = 0;
        for (var r = -1; r <= 1; r++) {
          for (var c = -1; c <= 1; c++) {
            if ((r != 0 || c != 0) &&
                row + r >= 0 &&
                row + r < size &&
                col + c >= 0 &&
                col + c < size &&
                data[index + r * size + c] == module) {
              same++;
            }
          }
        }
        if (same > 5) {
          penalty += same - 2;
        }
        if (row < size - 1 &&
            col < size - 1 &&
            module == data[index + 1] &&
            module == data[index + size] &&
            module == data[index + size + 1]) {
          penalty += 3;
        }
        if (module == _dark) {
          if (col < size - 6 && _isFinderLike(data, index, 1)) {
            penalty += 40;
          }
          if (row < size - 6 && _isFinderLike(data, index, size)) {
            penalty += 40;
          }
        }
      }
    }
    final ratio = (100 * darkCount / size / size - 50).abs() / 5;
    return penalty + ratio * 10;
  }

  bool _isFinderLike(Uint8List data, int index, int step) =>
      data[index + step] == _light &&
      data[index + 2 * step] == _dark &&
      data[index + 3 * step] == _dark &&
      data[index + 4 * step] == _dark &&
      data[index + 5 * step] == _light &&
      data[index + 6 * step] == _dark;
}

int _formatBits(int data) {
  var d = data << 10;
  while (d.bitLength >= 11) {
    d ^= _formatGenerator << (d.bitLength - 11);
  }
  return ((data << 10) | d) ^ _formatMask;
}

int _versionBits(int data) {
  var d = data << 12;
  while (d.bitLength >= 13) {
    d ^= _versionGenerator << (d.bitLength - 13);
  }
  return (data << 12) | d;
}

final _masks = <bool Function(int r, int c)>[
  (r, c) => (r + c).isEven,
  (r, c) => r.isEven,
  (r, c) => c % 3 == 0,
  (r, c) => (r + c) % 3 == 0,
  (r, c) => ((r ~/ 2) + (c ~/ 3)).isEven,
  (r, c) => (r * c) % 2 + (r * c) % 3 == 0,
  (r, c) => ((r * c) % 2 + (r * c) % 3).isEven,
  (r, c) => ((r * c) % 3 + (r + c) % 2).isEven,
];

const _alignmentPositions = <List<int>>[
  [],
  [6, 18],
  [6, 22],
  [6, 26],
  [6, 30],
  [6, 34],
  [6, 22, 38],
  [6, 24, 42],
  [6, 26, 46],
  [6, 28, 50],
  [6, 30, 54],
  [6, 32, 58],
  [6, 34, 62],
  [6, 26, 46, 66],
  [6, 26, 48, 70],
  [6, 26, 50, 74],
  [6, 30, 54, 78],
  [6, 30, 56, 82],
  [6, 30, 58, 86],
  [6, 34, 62, 90],
  [6, 28, 50, 72, 94],
  [6, 26, 50, 74, 98],
  [6, 30, 54, 78, 102],
  [6, 28, 54, 80, 106],
  [6, 32, 58, 84, 110],
  [6, 30, 58, 86, 114],
  [6, 34, 62, 90, 118],
  [6, 26, 50, 74, 98, 122],
  [6, 30, 54, 78, 102, 126],
  [6, 26, 52, 78, 104, 130],
  [6, 30, 56, 82, 108, 134],
  [6, 34, 60, 86, 112, 138],
  [6, 30, 58, 86, 114, 142],
  [6, 34, 62, 90, 118, 146],
  [6, 30, 54, 78, 102, 126, 150],
  [6, 24, 50, 76, 102, 128, 154],
  [6, 28, 54, 80, 106, 132, 158],
  [6, 32, 58, 84, 110, 136, 162],
  [6, 26, 54, 82, 110, 138, 166],
  [6, 30, 58, 86, 114, 142, 170],
];

// Per version: block count, codewords and data codewords of the first group,
// then of the second where there is one.
const _blocks = <List<int>>[
  [1, 26, 16],
  [1, 44, 28],
  [1, 70, 44],
  [2, 50, 32],
  [2, 67, 43],
  [4, 43, 27],
  [4, 49, 31],
  [2, 60, 38, 2, 61, 39],
  [3, 58, 36, 2, 59, 37],
  [4, 69, 43, 1, 70, 44],
  [1, 80, 50, 4, 81, 51],
  [6, 58, 36, 2, 59, 37],
  [8, 59, 37, 1, 60, 38],
  [4, 64, 40, 5, 65, 41],
  [5, 65, 41, 5, 66, 42],
  [7, 73, 45, 3, 74, 46],
  [10, 74, 46, 1, 75, 47],
  [9, 69, 43, 4, 70, 44],
  [3, 70, 44, 11, 71, 45],
  [3, 67, 41, 13, 68, 42],
  [17, 68, 42],
  [17, 74, 46],
  [4, 75, 47, 14, 76, 48],
  [6, 73, 45, 14, 74, 46],
  [8, 75, 47, 13, 76, 48],
  [19, 74, 46, 4, 75, 47],
  [22, 73, 45, 3, 74, 46],
  [3, 73, 45, 23, 74, 46],
  [21, 73, 45, 7, 74, 46],
  [19, 75, 47, 10, 76, 48],
  [2, 74, 46, 29, 75, 47],
  [10, 74, 46, 23, 75, 47],
  [14, 74, 46, 21, 75, 47],
  [14, 74, 46, 23, 75, 47],
  [12, 75, 47, 26, 76, 48],
  [6, 75, 47, 34, 76, 48],
  [29, 74, 46, 14, 75, 47],
  [13, 74, 46, 32, 75, 47],
  [40, 75, 47, 7, 76, 48],
  [18, 75, 47, 31, 76, 48],
];
