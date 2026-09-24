part of '../controller.dart';

extension CodeForgeControllerNavigation on CodeForgeController {
  /// Moves the cursor one character to the left.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressLeftArrowKey({bool isShiftPressed = false}) {
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

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
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

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
    final text = this.text;
    final caret = text.toUtf16Offset(selection.extentOffset);
    if (caret <= 0) return;

    final lineStart = text.lastIndexOf('\n', caret - 1) + 1;
    if (caret == lineStart) {
      _moveCaret(selection.extentOffset - 1, extend: extend);
      return;
    }

    final lastWord = RegExp('[$wordCharClass]+|[^$wordCharClass\\s]+')
        .allMatches(text.substring(lineStart, caret))
        .lastOrNull;
    final utf16Offset = lineStart + (lastWord?.start ?? 0);
    _moveCaret(text.toScalarOffset(utf16Offset), extend: extend);
  }

  void moveWordRight({bool extend = false}) {
    final text = this.text;
    final caret = text.toUtf16Offset(selection.extentOffset);
    if (caret >= text.length) return;

    if (text[caret] == '\n') {
      _moveCaret(selection.extentOffset + 1, extend: extend);
      return;
    }

    final next = RegExp('[$wordCharClass]+|[^$wordCharClass\\s]+|\\s+')
        .allMatches(text, caret)
        .where((match) => match.start > caret)
        .firstOrNull;
    _moveCaret(text.toScalarOffset(next?.start ?? text.length), extend: extend);
  }

  /// Moves the cursor up one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressUpArrowKey({bool isShiftPressed = false}) {
    if (HardwareKeyboard.instance.isAltPressed) return;
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (currentLine <= 0) {
      _moveCaret(0, extend: isShiftPressed);
      return;
    }

    int targetLine = currentLine - 1;
    while (targetLine > 0 && isLineInFoldedRegion(targetLine)) {
      targetLine--;
    }

    if (isLineInFoldedRegion(targetLine)) {
      targetLine = getFoldStartForLine(targetLine) ?? 0;
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
    if (HardwareKeyboard.instance.isAltPressed) return;
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (currentLine >= lineCount - 1) {
      _moveCaret(length, extend: isShiftPressed);
      return;
    }

    final foldAtCurrent = getFoldRangeAtCurrentLine(currentLine);
    int targetLine;
    if (foldAtCurrent != null && foldAtCurrent.isFolded) {
      targetLine = foldAtCurrent.endIndex + 1;
    } else {
      targetLine = currentLine + 1;
    }

    while (targetLine < lineCount && isLineInFoldedRegion(targetLine)) {
      final foldStart = getFoldStartForLine(targetLine);
      if (foldStart != null) {
        final fold = foldings[foldStart] ?? FoldRange(targetLine, targetLine);
        targetLine = fold.endIndex + 1;
      } else {
        targetLine++;
      }
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
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineStart = getLineStartOffset(currentLine);

    _moveCaret(lineStart, extend: isShiftPressed);
  }

  /// Moves the cursor to the end of the current line.
  ///
  /// If [isShiftPressed] is true, extends the selection to the line end.
  void pressEndKey({bool isShiftPressed = false}) {
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

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

  /// Copies the selection, or the caret's whole line when nothing is selected.
  void copy() {
    final sel = selection;
    if (sel.isCollapsed) {
      _copiedLine = '${getLineText(getLineAtOffset(sel.start))}\n';
      Clipboard.setData(ClipboardData(text: _copiedLine!));
      return;
    }
    _copiedLine = null;
    Clipboard.setData(
      ClipboardData(text: text.scalarSubstring(sel.start, sel.end)),
    );
  }

  void cut() {
    if (readOnly) return;
    final sel = selection;
    if (!sel.isCollapsed) {
      copy();
      replaceRange(sel.start, sel.end, '');
      return;
    }
    final line = getLineAtOffset(sel.start);
    copy();
    var start = getLineStartOffset(line);
    var end = length;
    if (line < lineCount - 1) {
      end = getLineStartOffset(line + 1);
    } else if (line > 0) {
      start--;
    }
    replaceRange(start, end, '');
    setSelectionSilently(
      TextSelection.collapsed(
        offset: getLineStartOffset(min(line, lineCount - 1)),
      ),
    );
  }

  /// Pastes over the selection; a whole line from [copy] goes above the caret's.
  Future<void> paste() async {
    if (readOnly) return;
    final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (clip == null || clip.isEmpty) return;
    final pasted = CodeForgeController.normalizeLineBreaks(clip);
    final sel = selection;
    if (sel.isCollapsed && pasted == _copiedLine) {
      final lineStart = getLineStartOffset(getLineAtOffset(sel.start));
      replaceRange(lineStart, lineStart, pasted);
      setSelectionSilently(
        TextSelection.collapsed(offset: sel.start + pasted.runes.length),
      );
      return;
    }
    replaceRange(sel.start, sel.end, pasted);
  }

  void _moveCaret(int offset, {required bool extend}) {
    setSelectionSilently(
      extend
          ? TextSelection(
              baseOffset: selection.baseOffset,
              extentOffset: offset,
            )
          : TextSelection.collapsed(offset: offset),
    );
  }

  /// Selects all text in the editor.
  void selectAll() {
    setSelectionSilently(TextSelection(baseOffset: 0, extentOffset: length));
  }

  /// Updates selection and syncs to text input connection for keyboard navigation.
  ///
  /// This method flushes any pending buffer first to ensure IME state is consistent.
  /// Use this for programmatic selection changes that should sync with the platform.
  void setSelectionSilently(TextSelection newSelection) {
    if (_selection == newSelection) return;

    if (isComposingActive) {
      newSelection = _commitCompositionAndRemapSelection(newSelection);
      requestImeReset?.call();
    }
    _pendingSelectionReplacement = null;
    _flushBuffer();

    final textLength = length;
    final clampedBase = newSelection.baseOffset.clamp(0, textLength);
    final clampedExtent = newSelection.extentOffset.clamp(0, textLength);
    newSelection = newSelection.copyWith(
      baseOffset: clampedBase,
      extentOffset: clampedExtent,
    );

    _selection = newSelection;
    selectionOnly = true;
    _isTyping = false;
    _imeProjectionDirty = true;

    _syncToConnection();
    notifyListeners();
  }
}
