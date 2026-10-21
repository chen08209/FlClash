import 'dart:math';
import 'dart:typed_data';

import 'package:rust_api/editor.dart';

/// From this many UTF-16 code units on, text is handled off the UI isolate.
const backgroundTextLength = 1 << 17;

const _uploadChunkBytes = 1 << 18;

class Rope {
  final RopeBridge _rope;
  RopeBridge get core => _rope;
  int? _length, _lineCount;

  Rope([String initialText = ''])
    : _rope = RopeBridge.create(initialText: initialText);

  Rope._(this._rope);

  static Future<Rope> openFile(String path) async =>
      Rope._(await RopeBridge.openFile(path: path));

  static Future<Rope> fromUtf8(Uint8List bytes) async {
    if (bytes.length <= _uploadChunkBytes) {
      return Rope._(await RopeBridge.fromUtf8(bytes: bytes));
    }
    final upload = RopeUpload(capacity: BigInt.from(bytes.length));
    try {
      for (var start = 0; start < bytes.length; start += _uploadChunkBytes) {
        final end = min(start + _uploadChunkBytes, bytes.length);
        await upload.push(chunk: Uint8List.sublistView(bytes, start, end));
      }
      return Rope._(await upload.finish());
    } finally {
      upload.dispose();
    }
  }

  Rope snapshot() => Rope._(_rope.snapshot());

  Future<Uint8List> utf8Bytes() => _rope.utf8Bytes();

  bool sameText(
    Rope original, {
    int spliceStart = 0,
    int spliceLength = 0,
    String spliceText = '',
  }) => _rope.sameText(
    original: original._rope,
    spliceStart: BigInt.from(spliceStart),
    spliceLen: BigInt.from(spliceLength),
    spliceText: spliceText,
  );

  int get length => _length ??= _rope.lenChars().toInt();

  void dispose() => _rope.dispose();

  String getText() {
    return _rope.getText();
  }

  String substring(int start, [int? end]) {
    return _rope.slice(
      start: BigInt.from(start),
      end: BigInt.from(end ?? length),
    );
  }

  void insert(int position, String text) {
    _rope.insert(charIdx: BigInt.from(position), text: text);
    _length = _lineCount = null;
  }

  void delete(int start, int end) {
    _rope.remove(start: BigInt.from(start), end: BigInt.from(end));
    _length = _lineCount = null;
  }

  List<String> cachedLinesRange(int startLine, int endLine) {
    return _rope.cachedLinesRange(
      startLine: BigInt.from(startLine),
      endLine: BigInt.from(endLine),
    );
  }

  int get lineCount => _lineCount ??= _rope.lenLines().toInt();

  String getLineText(int lineIndex) {
    return _rope.line(lineIdx: BigInt.from(lineIndex));
  }

  int getLineAtOffset(int charOffset) {
    return _rope.charToLine(charIdx: BigInt.from(charOffset)).toInt();
  }

  int getLineStartOffset(int lineIndex) {
    return _rope.lineToChar(lineIdx: BigInt.from(lineIndex)).toInt();
  }
}
