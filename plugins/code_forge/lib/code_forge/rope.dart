import 'dart:typed_data';

import 'package:rust_api/editor.dart';

/// From this many UTF-16 code units on, text is handled off the UI isolate.
const backgroundTextLength = 1 << 17;

class Rope {
  final RopeBridge _rope;
  RopeBridge get core => _rope;

  Rope([String initialText = ''])
    : _rope = RopeBridge.create(initialText: initialText);

  Rope._(this._rope);

  static Future<Rope> openFile(String path) async =>
      Rope._(await RopeBridge.openFile(path: path));

  static Future<Rope> fromUtf8(Uint8List bytes) async =>
      Rope._(await RopeBridge.fromUtf8(bytes: bytes));

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

  int get length => _rope.lenChars().toInt();

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
  }

  void delete(int start, int end) {
    _rope.remove(start: BigInt.from(start), end: BigInt.from(end));
  }

  List<String> cachedLinesRange(int startLine, int endLine) {
    return _rope.cachedLinesRange(
      startLine: BigInt.from(startLine),
      endLine: BigInt.from(endLine),
    );
  }

  int get lineCount => _rope.lenLines().toInt();

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
