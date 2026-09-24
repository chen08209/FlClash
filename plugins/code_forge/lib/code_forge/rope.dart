import 'package:flutter/widgets.dart';
import 'package:rust_api/editor.dart';

class Rope {
  final RopeBridge _rope;
  RopeBridge get core => _rope;

  Rope([String initialText = ''])
    : _rope = RopeBridge.create(initialText: initialText);

  int get length => _rope.lenChars().toInt();

  void dispose() => _rope.dispose();

  TextSelection get selection {
    final currentSelection = _rope.selection();
    return TextSelection(
      baseOffset: currentSelection.baseOffset.toInt(),
      extentOffset: currentSelection.extentOffset.toInt(),
    );
  }

  void setSelection(TextSelection selection) {
    _rope.setSelection(
      baseOffset: BigInt.from(selection.baseOffset),
      extentOffset: BigInt.from(selection.extentOffset),
    );
  }

  String getText() {
    return _rope.getText();
  }

  String substring(int start, [int? end]) {
    return _rope.slice(
      start: BigInt.from(start),
      end: BigInt.from(end ?? length),
    );
  }

  String charAt(int position) {
    return _rope.charAt(position: BigInt.from(position));
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
