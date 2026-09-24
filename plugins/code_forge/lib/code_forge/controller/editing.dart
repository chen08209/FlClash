part of '../controller.dart';

extension CodeForgeControllerEditing on CodeForgeController {
  /// Moves the current line up by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the top or if the controller is read-only.
  void moveLineUp() {
    if (readOnly) return;
    final selection = this.selection;
    final text = this.text;
    final selStart = text.toUtf16Offset(selection.start);
    final selEnd = text.toUtf16Offset(selection.end);
    final lineStart = CodeForgeController._lineStartBefore(text, selStart);
    int lineEnd = text.indexOf('\n', selEnd);
    if (lineEnd == -1) lineEnd = text.length;
    if (lineStart == 0) return;

    final prevLineEnd = lineStart - 1;
    final prevLineStart = CodeForgeController._lineStartBefore(
      text,
      prevLineEnd,
    );
    final prevLine = text.substring(prevLineStart, prevLineEnd);
    final currentLines = text.substring(lineStart, lineEnd);

    replaceRange(
      text.toScalarOffset(prevLineStart),
      text.toScalarOffset(lineEnd),
      '$currentLines\n$prevLine',
    );

    final offsetDelta = prevLine.runes.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset - offsetDelta,
      extentOffset: selection.extentOffset - offsetDelta,
    );
    setSelectionSilently(newSelection);
  }

  /// Moves the current line down by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the bottom or if the controller is read-only.
  void moveLineDown() {
    if (readOnly) return;
    final selection = this.selection;
    final text = this.text;
    final selStart = text.toUtf16Offset(selection.start);
    final selEnd = text.toUtf16Offset(selection.end);
    final lineStart = CodeForgeController._lineStartBefore(text, selStart);
    int lineEnd = text.indexOf('\n', selEnd);
    if (lineEnd == -1) lineEnd = text.length;
    if (lineEnd == text.length) return;
    final nextLineStart = lineEnd + 1;
    int nextLineEnd = text.indexOf('\n', nextLineStart);
    if (nextLineEnd == -1) nextLineEnd = text.length;

    final currentLines = text.substring(lineStart, lineEnd);
    final nextLine = text.substring(nextLineStart, nextLineEnd);

    replaceRange(
      text.toScalarOffset(lineStart),
      text.toScalarOffset(nextLineEnd),
      '$nextLine\n$currentLines',
    );

    final offsetDelta = nextLine.runes.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset + offsetDelta,
      extentOffset: selection.extentOffset + offsetDelta,
    );
    setSelectionSilently(newSelection);
  }

  /// Duplicates the current line or selected text.
  ///
  /// If text is selected, duplicates the selected text.
  /// If no selection, duplicates the line at the cursor position.
  /// The cursor is moved to the end of the duplicated content.
  /// Does nothing if the controller is read-only.
  void duplicateLine() {
    if (readOnly) return;
    final text = this.text;
    final selection = this.selection;

    if (selection.start != selection.end) {
      final selectedText = text.scalarSubstring(selection.start, selection.end);
      replaceRange(selection.end, selection.end, selectedText);
      setSelectionSilently(
        TextSelection.collapsed(
          offset: selection.end + selectedText.runes.length,
        ),
      );
    } else {
      final caret = text.toUtf16Offset(selection.extentOffset);
      final prevNewline = (caret > 0) ? text.lastIndexOf('\n', caret - 1) : -1;
      final nextNewline = text.indexOf('\n', caret);
      final lineStart = prevNewline == -1 ? 0 : prevNewline + 1;
      final lineEnd = nextNewline == -1 ? text.length : nextNewline;
      final lineText = text.substring(lineStart, lineEnd);
      final scalarLineEnd = text.toScalarOffset(lineEnd);

      replaceRange(scalarLineEnd, scalarLineEnd, '\n$lineText');
      setSelectionSilently(TextSelection.collapsed(offset: scalarLineEnd + 1));
    }
  }

  /// Insert text at the current cursor position (or replace selection).
  void insertAtCurrentCursor(
    String textToInsert, {
    bool replaceTypedChar = false,
  }) {
    if (readOnly) return;

    _flushBuffer();

    final cursorPosition = selection.extentOffset;
    final safePosition = cursorPosition.clamp(0, _rope.length);
    final currentLine = _rope.getLineAtOffset(safePosition);
    final isFolded = foldings.values.any(
      (fold) =>
          fold != null &&
          fold.isFolded &&
          currentLine > fold.startIndex &&
          currentLine <= fold.endIndex,
    );

    if (isFolded) {
      final newPosition = length;
      selection = TextSelection.collapsed(offset: newPosition);
      return;
    }

    if (replaceTypedChar) {
      final prefix = getCurrentWordPrefixAt(safePosition);
      final prefixStart = (safePosition - prefix.runes.length).clamp(
        0,
        _rope.length,
      );

      replaceRange(prefixStart, safePosition, textToInsert);
    } else {
      replaceRange(safePosition, safePosition, textToInsert);
    }
  }

  /// Remove the selection or last char if the selection is empty (backspace key)
  void backspace() {
    final sel = _selection;
    if (sel.isCollapsed) {
      _deleteRange(sel.start - 1, sel.start);
    } else {
      _deleteRange(sel.start, sel.end);
    }
  }

  /// Remove the selection or the char at cursor position (delete key)
  void delete() {
    final sel = _selection;
    if (sel.isCollapsed) {
      _deleteRange(sel.start, sel.start + 1);
    } else {
      _deleteRange(sel.start, sel.end);
    }
  }

  void _deleteRange(int start, int end) {
    if (readOnly) return;
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    if (start < 0 || end > length) return;
    _edit(start, end, '', TextSelection.collapsed(offset: start));
    notifyListeners();
  }

  /// Replace a range of text with new text.
  /// Used for clipboard operations and text manipulation.
  void replaceRange(int start, int end, String replacement) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    final inserted = CodeForgeController.normalizeLineBreaks(replacement);
    final selectionBefore = _selection;
    _flushBuffer();
    final safeStart = start.clamp(0, _rope.length);
    final safeEnd = end.clamp(safeStart, _rope.length);
    final deletedText = safeStart < safeEnd
        ? _rope.substring(safeStart, safeEnd)
        : '';

    final result = _rope.core.replaceRangeAndUpdateSelection(
      start: BigInt.from(safeStart),
      end: BigInt.from(safeEnd),
      replacement: inserted,
    );
    _currentVersion++;
    final newSelection = TextSelection(
      baseOffset: result.baseOffset.toInt(),
      extentOffset: result.extentOffset.toInt(),
    );
    _selection = newSelection;
    dirtyLine = _rope.getLineAtOffset(safeStart);
    _recordLineEdit(dirtyLine!, deletedText, inserted);
    dirtyRegion = TextRange(
      start: safeStart,
      end: safeStart + inserted.runes.length,
    );

    _recordChange(
      safeStart,
      deletedText,
      inserted,
      selectionBefore,
      _selection,
    );

    _invalidateImeSnapshotAndScheduleSync();
    notifyListeners();
  }

  void indent() {
    if (selection.baseOffset != selection.extentOffset) {
      final text = this.text;
      final selStart = text.toUtf16Offset(selection.start);
      final selEnd = text.toUtf16Offset(selection.end);

      final lineStart = CodeForgeController._lineStartBefore(text, selStart);
      int lineEnd = text.indexOf('\n', selEnd);
      if (lineEnd == -1) lineEnd = text.length;

      final selectedBlock = text.substring(lineStart, lineEnd);
      final indentedBlock = selectedBlock
          .split('\n')
          .map((line) => '$tabSpace$line')
          .join('\n');

      final lines = selectedBlock.split('\n');
      final addedChars = tabSize * lines.length;
      final newSelection = _withEnds(
        selection,
        selection.start + tabSize,
        selection.end + addedChars,
      );

      replaceRange(
        text.toScalarOffset(lineStart),
        text.toScalarOffset(lineEnd),
        indentedBlock,
      );
      setSelectionSilently(newSelection);
    } else {
      insertAtCurrentCursor(tabSpace);
    }
  }

  void unindent() {
    if (selection.baseOffset != selection.extentOffset) {
      final text = this.text;
      final selStart = text.toUtf16Offset(selection.start);
      final selEnd = text.toUtf16Offset(selection.end);

      final lineStart = CodeForgeController._lineStartBefore(text, selStart);
      int lineEnd = text.indexOf('\n', selEnd);
      if (lineEnd == -1) lineEnd = text.length;

      final selectedBlock = text.substring(lineStart, lineEnd);
      final lines = selectedBlock.split('\n');
      final removed = [for (final line in lines) _outdentWidth(line)];
      final unindentedBlock = [
        for (final (index, line) in lines.indexed)
          line.substring(removed[index]),
      ].join('\n');

      final removedChars = removed.fold(0, (sum, count) => sum + count);
      final scalarLineStart = text.toScalarOffset(lineStart);
      final lastLineStart =
          text.toScalarOffset(lineEnd - lines.last.length) -
          (removedChars - removed.last);
      final newSelection = _withEnds(
        selection,
        max(selection.start - removed.first, scalarLineStart),
        max(selection.end - removedChars, lastLineStart),
      );

      replaceRange(
        text.toScalarOffset(lineStart),
        text.toScalarOffset(lineEnd),
        unindentedBlock,
      );
      setSelectionSilently(newSelection);
    } else {
      final text = this.text;
      final caret = text.toUtf16Offset(selection.start);
      final lineStart = CodeForgeController._lineStartBefore(text, caret);
      final nextNewline = text.indexOf('\n', caret);
      final lineEnd = nextNewline == -1 ? text.length : nextNewline;
      final line = text.substring(lineStart, lineEnd);

      final removeCount = _outdentWidth(line);
      final newLine = line.substring(removeCount);
      final scalarLineStart = text.toScalarOffset(lineStart);
      final newOffset = selection.start - removeCount > scalarLineStart
          ? selection.start - removeCount
          : scalarLineStart;

      replaceRange(scalarLineStart, text.toScalarOffset(lineEnd), newLine);
      setSelectionSilently(TextSelection.collapsed(offset: newOffset));
    }
  }

  int _outdentWidth(String line) => line.startsWith(tabSpace)
      ? tabSize
      : RegExp(r'^ +').stringMatch(line)?.length ?? 0;

  TextSelection _withEnds(TextSelection selection, int start, int end) =>
      selection.baseOffset <= selection.extentOffset
      ? TextSelection(baseOffset: start, extentOffset: end)
      : TextSelection(baseOffset: end, extentOffset: start);

  /// Also deletes the spaces between the word and the caret.
  void deleteWordBackward() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final text = this.text;
    final scalarCaret = selection.extentOffset;
    if (scalarCaret <= 0) return;
    final caret = text.toUtf16Offset(scalarCaret);
    if (text[caret - 1] == '\n') {
      replaceRange(scalarCaret - 1, scalarCaret, '');
      return;
    }
    final lineStart = text.lastIndexOf('\n', caret - 1) + 1;
    final match = RegExp('([$wordCharClass]+|[^$wordCharClass\\s]+)\\s*\$')
        .firstMatch(text.substring(lineStart, caret));
    final deleteFrom = match != null
        ? text.toScalarOffset(lineStart + match.start)
        : scalarCaret - 1;
    replaceRange(deleteFrom, scalarCaret, '');
  }

  void deleteWordForward() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final text = this.text;
    final scalarCaret = selection.extentOffset;
    final caret = text.toUtf16Offset(scalarCaret);
    if (caret >= text.length) return;
    final match = RegExp('^\\s*([$wordCharClass]+|[^$wordCharClass\\s]+)')
        .firstMatch(text.substring(caret));
    final deleteTo = match != null
        ? text.toScalarOffset(caret + match.end)
        : scalarCaret + 1;
    replaceRange(scalarCaret, deleteTo, '');
  }

  /// At a line start, joins the line with the previous one.
  void deleteToLineStart() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final caret = selection.extentOffset;
    if (caret <= 0) return;
    final lineStart = getLineStartOffset(getLineAtOffset(caret));
    replaceRange(caret == lineStart ? caret - 1 : lineStart, caret, '');
  }
}
