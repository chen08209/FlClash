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
    final (first, last) = _selectedLines(selection);
    if (first == 0) return;

    final prevLine = getLineText(first - 1);
    replaceRange(
      getLineStartOffset(first - 1),
      _lineEndOffset(last),
      '${_linesText(first, last)}\n$prevLine',
    );

    final offsetDelta = prevLine.runes.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset - offsetDelta,
      extentOffset: selection.extentOffset - offsetDelta,
    );
    this.selection = newSelection;
  }

  /// Moves the current line down by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the bottom or if the controller is read-only.
  void moveLineDown() {
    if (readOnly) return;
    final selection = this.selection;
    final (first, last) = _selectedLines(selection);
    if (last + 1 >= lineCount) return;

    final nextLine = getLineText(last + 1);
    replaceRange(
      getLineStartOffset(first),
      _lineEndOffset(last + 1),
      '$nextLine\n${_linesText(first, last)}',
    );

    final offsetDelta = nextLine.runes.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset + offsetDelta,
      extentOffset: selection.extentOffset + offsetDelta,
    );
    this.selection = newSelection;
  }

  /// Duplicates the current line or selected text.
  ///
  /// If text is selected, duplicates the selected text.
  /// If no selection, duplicates the line at the cursor position.
  /// The cursor is moved to the end of the duplicated content.
  /// Does nothing if the controller is read-only.
  void duplicateLine() {
    if (readOnly) return;
    final selection = this.selection;

    if (selection.start != selection.end) {
      final selectedText = _documentSubstring(selection.start, selection.end);
      replaceRange(selection.end, selection.end, selectedText);
      this.selection = TextSelection.collapsed(
        offset: selection.end + selection.end - selection.start,
      );
    } else {
      final line = getLineAtOffset(selection.extentOffset);
      final lineText = getLineText(line);
      final lineEnd = _lineEndOffset(line);

      replaceRange(lineEnd, lineEnd, '\n$lineText');
      this.selection = TextSelection.collapsed(offset: lineEnd + 1);
    }
  }

  /// Copies the selection, or the caret's whole line when nothing is selected.
  Future<void> copy() async {
    final sel = selection;
    if (sel.isCollapsed) {
      await _copyLine(getLineAtOffset(sel.start));
      return;
    }
    await _writeClipboard(_documentSubstring(sel.start, sel.end));
  }

  /// Leaves the text when the clipboard refuses it, or when the document, the
  /// selection or read-only changes before the clipboard has it.
  Future<void> cut() async {
    if (readOnly) return;
    final sel = selection;
    final version = _currentVersion;
    bool stillCuts() =>
        !_isDisposed &&
        !readOnly &&
        version == _currentVersion &&
        sel == selection;
    if (!sel.isCollapsed) {
      final text = _documentSubstring(sel.start, sel.end);
      if (!await _writeClipboard(text) || !stillCuts()) return;
      _replaceRange(sel.start, sel.end, '', deleted: text);
      return;
    }
    final line = getLineAtOffset(sel.start);
    if (!await _copyLine(line) || !stillCuts()) return;
    var start = getLineStartOffset(line);
    var end = length;
    if (line < lineCount - 1) {
      end = getLineStartOffset(line + 1);
    } else if (line > 0) {
      start--;
    }
    replaceRange(start, end, '');
    selection = TextSelection.collapsed(
      offset: getLineStartOffset(min(line, lineCount - 1)),
    );
  }

  Future<bool> _copyLine(int line) =>
      _writeClipboard('${getLineText(line)}\n', wholeLine: true);

  Future<bool> _writeClipboard(String text, {bool wholeLine = false}) async {
    if (!await setClipboardText(text)) {
      onClipboardWriteFailed?.call();
      return false;
    }
    _copiedLine = wholeLine ? text : null;
    return true;
  }

  Future<String?> _readClipboard() async {
    try {
      return await getClipboardText();
    } on Exception {
      return null;
    }
  }

  /// Pastes over the selection; a whole line from [copy] goes above the caret's.
  Future<void> paste() async {
    if (readOnly) return;
    final clip = await _readClipboard();
    if (clip == null || clip.isEmpty || _isDisposed || readOnly) return;
    final pasted = CodeForgeController.normalizeLineBreaks(clip);
    final sel = selection;
    if (sel.isCollapsed && pasted == _copiedLine) {
      final lineStart = getLineStartOffset(getLineAtOffset(sel.start));
      _replaceRange(lineStart, lineStart, pasted);
      selection = TextSelection.collapsed(
        offset: sel.start + pasted.runes.length,
      );
      return;
    }
    _replaceRange(sel.start, sel.end, pasted);
  }

  (int, int) _selectedLines(TextSelection selection) =>
      (getLineAtOffset(selection.start), getLineAtOffset(selection.end));

  int _lineEndOffset(int line) =>
      line + 1 < lineCount ? getLineStartOffset(line + 1) - 1 : length;

  String _linesText(int first, int last) =>
      _documentSubstring(getLineStartOffset(first), _lineEndOffset(last));

  void insertAtCurrentCursor(String text) {
    if (readOnly) return;
    final caret = selection.extentOffset;
    replaceRange(caret, caret, text);
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
  void replaceRange(int start, int end, String replacement) {
    _replaceRange(
      start,
      end,
      CodeForgeController.normalizeLineBreaks(replacement),
    );
  }

  void _replaceRange(int start, int end, String normalized, {String? deleted}) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    _closeCompletion();
    _editRope(start, end, normalized, null, deleted: deleted);
    notifyListeners();
  }

  /// Rewrites the document as [text] in one edit over only what differs.
  void replaceText(String text) {
    final current = this.text;
    final change = _changedSpan(
      current,
      CodeForgeController.normalizeLineBreaks(text),
    );
    if (change == null) return;
    _replaceRange(
      current.toScalarOffset(change.start),
      current.toScalarOffset(change.end),
      change.replacement,
    );
  }

  void _closeCompletion() {
    _isTyping = false;
    suggestionsNotifier.value = null;
  }

  void indent() {
    if (readOnly) return;
    final selection = this.selection;
    if (selection.baseOffset != selection.extentOffset) {
      final (first, last) = _selectedLines(selection);
      final lines = getLinesRange(first, last + 1);
      final newSelection = _withEnds(
        selection,
        selection.start + tabSize,
        selection.end + tabSize * lines.length,
      );

      replaceRange(
        getLineStartOffset(first),
        _lineEndOffset(last),
        [for (final line in lines) '$tabSpace$line'].join('\n'),
      );
      this.selection = newSelection;
    } else {
      insertAtCurrentCursor(tabSpace);
    }
  }

  void unindent() {
    if (readOnly) return;
    final selection = this.selection;
    final (first, last) = _selectedLines(selection);
    final lines = getLinesRange(first, last + 1);
    final removed = [for (final line in lines) _outdentWidth(line)];
    final lineStart = getLineStartOffset(first);
    final TextSelection newSelection;
    if (selection.baseOffset != selection.extentOffset) {
      final removedChars = removed.fold(0, (sum, count) => sum + count);
      final lastLineStart =
          getLineStartOffset(last) - (removedChars - removed.last);
      newSelection = _withEnds(
        selection,
        max(selection.start - removed.first, lineStart),
        max(selection.end - removedChars, lastLineStart),
      );
    } else {
      newSelection = TextSelection.collapsed(
        offset: max(selection.start - removed.first, lineStart),
      );
    }

    replaceRange(
      lineStart,
      _lineEndOffset(last),
      [
        for (final (index, line) in lines.indexed)
          line.substring(removed[index]),
      ].join('\n'),
    );
    this.selection = newSelection;
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
    final caret = selection.extentOffset;
    if (caret <= 0) return;
    final line = getLineAtOffset(caret);
    final lineStart = getLineStartOffset(line);
    if (caret == lineStart) {
      replaceRange(caret - 1, caret, '');
      return;
    }
    final before = getLineText(line).scalarSubstring(0, caret - lineStart);
    final match = RegExp('([$wordCharClass]+|[^$wordCharClass\\s]+)\\s*\$')
        .firstMatch(before);
    replaceRange(
      match != null
          ? lineStart + before.toScalarOffset(match.start)
          : caret - 1,
      caret,
      '',
    );
  }

  void deleteWordForward() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final caret = selection.extentOffset;
    if (caret >= length) return;
    final word = RegExp('^\\s*([$wordCharClass]+|[^$wordCharClass\\s]+)');
    var line = getLineAtOffset(caret);
    var lineStart = getLineStartOffset(line);
    var text = getLineText(line).scalarSubstring(caret - lineStart);
    lineStart = caret;
    while (true) {
      if (word.firstMatch(text) case final match?) {
        replaceRange(caret, lineStart + text.toScalarOffset(match.end), '');
        return;
      }
      if (++line >= lineCount) break;
      lineStart = getLineStartOffset(line);
      text = getLineText(line);
    }
    replaceRange(caret, length, '');
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
