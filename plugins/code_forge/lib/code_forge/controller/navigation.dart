part of '../controller.dart';

extension CodeForgeControllerNavigation on CodeForgeController {
  /// Moves the cursor one character to the left.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressLeftArrowKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    int newOffset;
    if (!isShiftPressed && selection.start != selection.end) {
      newOffset = selection.start;
    } else if (selection.extentOffset > 0) {
      newOffset = selection.extentOffset - 1;
    } else {
      newOffset = 0;
    }

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  void pressRightArrowKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    final int newOffset;
    if (!isShiftPressed && selection.start != selection.end) {
      newOffset = selection.end;
    } else {
      newOffset = min(selection.extentOffset + 1, length);
    }

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  /// Moves the caret to the start of the word before it, or over the line
  /// break when it is at a line start.
  void moveWordLeft({bool extend = false}) {
    final caret = selection.extentOffset;
    if (caret <= 0) return;

    final line = getLineAtOffset(caret);
    final lineStart = getLineStartOffset(line);
    if (caret == lineStart) {
      _moveCaret(caret - 1, extend: extend);
      return;
    }

    final before = getLineText(line).scalarSubstring(0, caret - lineStart);
    final lastWord = RegExp('[$wordCharClass]+|[^$wordCharClass\\s]+')
        .allMatches(before)
        .lastOrNull;
    _moveCaret(
      lineStart + before.toScalarOffset(lastWord?.start ?? 0),
      extend: extend,
    );
  }

  void moveWordRight({bool extend = false}) {
    final caret = selection.extentOffset;
    if (caret >= length) return;

    var line = getLineAtOffset(caret);
    final lineStart = getLineStartOffset(line);
    final lineText = getLineText(line);
    final column = lineText.toUtf16Offset(caret - lineStart);
    if (column >= lineText.length) {
      _moveCaret(caret + 1, extend: extend);
      return;
    }

    final rest = line + 1 < lineCount ? '$lineText\n' : lineText;
    final next = RegExp('[$wordCharClass]+|[^$wordCharClass\\s]+|\\s+')
        .allMatches(rest, column)
        .where((match) => match.start > column)
        .firstOrNull;
    if (next != null) {
      _moveCaret(
        lineStart + lineText.toScalarOffset(next.start),
        extend: extend,
      );
      return;
    }
    final nonSpace = RegExp(r'\S');
    while (++line < lineCount) {
      final text = getLineText(line);
      if (nonSpace.firstMatch(text) case final match?) {
        _moveCaret(
          getLineStartOffset(line) + text.toScalarOffset(match.start),
          extend: extend,
        );
        return;
      }
    }
    _moveCaret(length, extend: extend);
  }

  /// Moves the cursor up one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressUpArrowKey({bool isShiftPressed = false}) {
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (currentLine <= 0) {
      _moveCaret(0, extend: isShiftPressed);
      return;
    }

    var targetLine = currentLine - 1;
    while (targetLine > 0) {
      final hidden = _foldHiding(targetLine);
      if (hidden == null) break;
      targetLine = hidden.start;
    }

    final lineStart = getLineStartOffset(currentLine);
    final column = selection.extentOffset - lineStart;
    final prevLineStart = getLineStartOffset(targetLine);
    final prevLineText = getLineText(targetLine);
    final prevLineLength = prevLineText.runes.length;
    final newColumn = column.clamp(0, prevLineLength);
    final newOffset = (prevLineStart + newColumn).clamp(0, length);

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  /// Moves the cursor down one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressDownArrowKey({bool isShiftPressed = false}) {
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (currentLine >= lineCount - 1) {
      _moveCaret(length, extend: isShiftPressed);
      return;
    }

    final foldAtCurrent = foldings[currentLine];
    var targetLine = foldAtCurrent != null && foldAtCurrent.isFolded
        ? foldAtCurrent.endIndex + 1
        : currentLine + 1;
    while (targetLine < lineCount) {
      final hidden = _foldHiding(targetLine);
      if (hidden == null) break;
      targetLine = hidden.end + 1;
    }

    if (targetLine >= lineCount) {
      final endOffset = length;
      _moveCaret(endOffset, extend: isShiftPressed);
      return;
    }

    final lineStart = getLineStartOffset(currentLine);
    final column = selection.extentOffset - lineStart;
    final nextLineStart = getLineStartOffset(targetLine);
    final nextLineText = getLineText(targetLine);
    final nextLineLength = nextLineText.runes.length;
    final newColumn = column.clamp(0, nextLineLength);
    final newOffset = (nextLineStart + newColumn).clamp(0, length);

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  /// Moves the cursor to the beginning of the current line.
  ///
  /// If [isShiftPressed] is true, extends the selection to the line start.
  void pressHomeKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineStart = getLineStartOffset(currentLine);

    _moveCaret(lineStart, extend: isShiftPressed);
  }

  /// Moves the cursor to the end of the current line.
  ///
  /// If [isShiftPressed] is true, extends the selection to the line end.
  void pressEndKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineText = getLineText(currentLine);
    final lineStart = getLineStartOffset(currentLine);
    final scalarLength = lineText.runes.length;
    final lineEnd = lineStart + scalarLength;

    _moveCaret(lineEnd, extend: isShiftPressed);
  }

  /// Moves the cursor to the beginning of the document.
  ///
  /// If [isShiftPressed] is true, extends the selection to the document start.
  void pressDocumentHomeKey({bool isShiftPressed = false}) {
    _moveCaret(0, extend: isShiftPressed);
  }

  /// Moves the cursor to the end of the document.
  ///
  /// If [isShiftPressed] is true, extends the selection to the document end.
  void pressDocumentEndKey({bool isShiftPressed = false}) {
    final endOffset = length;
    _moveCaret(endOffset, extend: isShiftPressed);
  }

  void _moveCaret(int target, {required bool extend}) {
    final offset = _outOfFold(target, forward: target > selection.extentOffset);
    selection = extend
        ? TextSelection(baseOffset: selection.baseOffset, extentOffset: offset)
        : TextSelection.collapsed(offset: offset);
  }

  /// [offset], or where the caret lands instead when a fold hides its line:
  /// past the fold going [forward], else on the line that heads the fold.
  int _outOfFold(int offset, {required bool forward}) {
    final hidden = _foldHiding(getLineAtOffset(offset.clamp(0, length)));
    if (hidden == null) return offset;
    return forward && hidden.end + 1 < lineCount
        ? getLineStartOffset(hidden.end + 1)
        : _lineEndOffset(hidden.start);
  }

  /// Selects all text in the editor.
  void selectAll() {
    selection = TextSelection(baseOffset: 0, extentOffset: length);
  }
}
