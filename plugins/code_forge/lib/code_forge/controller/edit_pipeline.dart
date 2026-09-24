part of '../controller.dart';

extension _ControllerEditPipeline on CodeForgeController {
  void _applyUndoRedoOperation(EditOperation operation) {
    _flushBuffer();
    switch (operation) {
      case InsertOperation(:final offset, :final text, :final selectionAfter):
        _editRope(offset, offset, text, selectionAfter);
      case DeleteOperation(:final offset, :final text, :final selectionAfter):
        _editRope(offset, offset + text.runes.length, '', selectionAfter);
      case ReplaceOperation(
        :final offset,
        :final deletedText,
        :final insertedText,
        :final selectionAfter,
      ):
        _editRope(
          offset,
          offset + deletedText.runes.length,
          insertedText,
          selectionAfter,
        );
      case CompoundOperation(:final operations):
        for (final op in operations) {
          _applyUndoRedoOperation(op);
        }
        return;
    }
    notifyListeners();
  }

  void _recordChange(
    int offset,
    String deleted,
    String inserted,
    TextSelection selBefore,
    TextSelection selAfter,
  ) {
    _trackSnippetEdit(offset, deleted.runes.length, inserted.runes.length);
    final undo = _undoController;
    if (undo == null || undo.isUndoRedoInProgress) return;
    if (deleted.isEmpty && inserted.isEmpty) return;
    undo.recordEdit(
      deleted.isEmpty
          ? InsertOperation(
              offset: offset,
              text: inserted,
              selectionBefore: selBefore,
              selectionAfter: selAfter,
            )
          : inserted.isEmpty
          ? DeleteOperation(
              offset: offset,
              text: deleted,
              selectionBefore: selBefore,
              selectionAfter: selAfter,
            )
          : ReplaceOperation(
              offset: offset,
              deletedText: deleted,
              insertedText: inserted,
              selectionBefore: selBefore,
              selectionAfter: selAfter,
            ),
    );
  }

  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(CodeForgeController._flushDelay, _flushBuffer);
  }

  void _flushBuffer() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_bufferLineIndex == null || !_bufferDirty) return;

    final lineToInvalidate = _bufferLineIndex!;
    final start = _bufferLineRopeStart;
    final lineText = _bufferLineText!;

    if (_bufferLineOriginalLength > 0) {
      _rope.delete(start, start + _bufferLineOriginalLength);
    }
    if (lineText.isNotEmpty) {
      _rope.insert(start, lineText);
    }

    _rope.setSelection(_selectionCache);

    _bufferLineIndex = null;
    _bufferLineText = null;
    _bufferDirty = false;

    _invalidateImeSnapshotAndScheduleSync();

    dirtyLine = lineToInvalidate;
    dirtyRegion = TextRange(start: start, end: start + lineText.runes.length);
    _recordLineEdit(lineToInvalidate, '', '');
    notifyListeners();
  }

  /// Replaces [start, end) with [insert]. Edits that stay on one line go to
  /// the line buffer, which reaches the rope once typing pauses. CRLF in
  /// [insert] comes in as LF, which leaves the caret after it instead of at
  /// [after].
  void _edit(int start, int end, String insert, TextSelection after) {
    final inserted = CodeForgeController.normalizeLineBreaks(insert);
    final selectionAfter = inserted.length == insert.length
        ? after
        : TextSelection.collapsed(offset: start + inserted.runes.length);
    final onOneLine =
        !inserted.contains('\n') &&
        (_isOnBufferedLine(start, end) ||
            getLineAtOffset(start) == getLineAtOffset(end));
    if (onOneLine) {
      _editLine(start, end, inserted, selectionAfter);
    } else {
      _editRope(start, end, inserted, selectionAfter);
    }
  }

  bool _isOnBufferedLine(int start, int end) =>
      isBufferActive &&
      start >= _bufferLineRopeStart &&
      end <= _bufferLineRopeStart + _bufferLineLength;

  void _editLine(int start, int end, String insert, TextSelection after) {
    final before = _selection;
    if (!_isOnBufferedLine(start, end)) {
      _flushBuffer();
      _initBuffer(_rope.getLineAtOffset(start));
    }
    final lineText = _bufferLineText!;
    final from = lineText.toUtf16Offset(start - _bufferLineRopeStart);
    final to = lineText.toUtf16Offset(end - _bufferLineRopeStart);
    final deleted = lineText.substring(from, to);
    _bufferLineText = lineText.replaceRange(from, to, insert);
    _bufferDirty = true;
    _selection = after;
    _currentVersion++;
    dirtyLine = _bufferLineIndex;
    bufferNeedsRepaint = true;
    _recordChange(start, deleted, insert, before, after);
    if (deleted.isNotEmpty) _imeSelectionNeedsResync = true;
    _invalidateImeSnapshotAndScheduleSync();
    _scheduleFlush();
  }

  void _editRope(int start, int end, String insert, TextSelection after) {
    final before = _selection;
    _flushBuffer();
    final safeStart = start.clamp(0, _rope.length);
    final safeEnd = end.clamp(safeStart, _rope.length);
    final deleted = safeStart < safeEnd
        ? _rope.substring(safeStart, safeEnd)
        : '';
    if (deleted.isNotEmpty) _rope.delete(safeStart, safeEnd);
    if (insert.isNotEmpty) _rope.insert(safeStart, insert);
    _currentVersion++;
    _selection = after;
    dirtyLine = _rope.getLineAtOffset(safeStart);
    _recordLineEdit(dirtyLine!, deleted, insert);
    dirtyRegion = TextRange(
      start: safeStart,
      end: safeStart + insert.runes.length,
    );
    _recordChange(safeStart, deleted, insert, before, after);
    if (deleted.isNotEmpty) _imeSelectionNeedsResync = true;
    _invalidateImeSnapshotAndScheduleSync();
  }

  void _recordLineEdit(int line, String deleted, String inserted) {
    final removed = '\n'.allMatches(deleted).length;
    final added = '\n'.allMatches(inserted).length;
    final pending = lineEdit;
    if (pending == null) {
      lineEdit = (line: line, removed: removed, inserted: added);
      return;
    }
    // The covering range, in the lines between the two edits, maps both ways.
    final start = min(pending.line, line);
    final end = max(pending.line + pending.inserted, line + removed);
    final originalEnd = end - pending.inserted + pending.removed;
    final currentEnd = end - removed + added;
    lineEdit = (
      line: start,
      removed: originalEnd - start,
      inserted: currentEnd - start,
    );
  }

  String _documentSubstring(int start, int end) {
    if (!isBufferActive) return _rope.substring(start, end);
    final bufferStart = _bufferLineRopeStart;
    final bufferEnd = bufferStart + _bufferLineLength;
    final shift = _bufferLineLength - _bufferLineOriginalLength;
    return [
      if (start < bufferStart) _rope.substring(start, min(end, bufferStart)),
      if (start < bufferEnd && end > bufferStart)
        _bufferLineText!.scalarSubstring(
          max(start, bufferStart) - bufferStart,
          min(end, bufferEnd) - bufferStart,
        ),
      if (end > bufferEnd)
        _rope.substring(max(start, bufferEnd) - shift, end - shift),
    ].join();
  }

  String _charAt(int offset) => _documentSubstring(offset, offset + 1);

  void _handleInsertion(
    int offset,
    String insertedText,
    TextSelection newSelection,
  ) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    final currentLength = length;
    if (offset < 0 || offset > currentLength) {
      return;
    }

    String actualInsertedText = insertedText;
    TextSelection actualSelection = newSelection;

    if (insertedText.length == 1) {
      const pairs = {'(': ')', '{': '}', '[': ']', '"': '"', "'": "'"};
      final char = insertedText;
      if (pairs.containsValue(char) &&
          offset < currentLength &&
          _charAt(offset) == char) {
        _selection = TextSelection.collapsed(offset: offset + 1);
        return;
      }
      final closing = pairs[char];
      final isQuoteAfterWord =
          closing == char &&
          offset > 0 &&
          isWordChar(_charAt(offset - 1).codeUnitAt(0));
      if (closing != null && !isQuoteAfterWord) {
        actualInsertedText = '$char$closing';
        actualSelection = TextSelection.collapsed(offset: offset + 1);
      }
    }

    if (actualInsertedText == '\n') {
      final line = getLineAtOffset(offset);
      final lineText = getLineText(line);
      final column = lineText.toUtf16Offset(offset - getLineStartOffset(line));
      final prevLine = lineText.substring(0, column);
      final prevIndent = RegExp(r'^\s*').firstMatch(prevLine)!.group(0)!;
      final shouldIndent = RegExp(r'[:{[(]\s*$').hasMatch(prevLine);
      final indent = prevIndent + (shouldIndent ? tabSpace : '');
      const openToClose = {'{': '}', '(': ')', '[': ']'};
      final trimmedPrev = prevLine.trimRight();
      final lastChar = trimmedPrev.isNotEmpty
          ? trimmedPrev[trimmedPrev.length - 1]
          : null;
      final closer = openToClose[lastChar];
      if (closer != null && _firstNonSpaceFrom(line, column) == closer) {
        actualInsertedText = '\n$indent\n$prevIndent';
        actualSelection = TextSelection.collapsed(
          offset: offset + 1 + indent.runes.length,
        );
      } else {
        actualInsertedText = '\n$indent';
        actualSelection = TextSelection.collapsed(
          offset: offset + actualInsertedText.runes.length,
        );
      }
    }
    _edit(offset, offset, actualInsertedText, actualSelection);
  }

  String? _firstNonSpaceFrom(int line, int utf16Column) {
    var rest = getLineText(line).substring(utf16Column).trimLeft();
    while (rest.isEmpty && ++line < lineCount) {
      rest = getLineText(line).trimLeft();
    }
    return rest.isEmpty ? null : rest[0];
  }

  void _handleDeletion(TextRange range, TextSelection newSelection) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    if (range.start < 0 || range.end > length || range.start > range.end) {
      return;
    }
    _edit(range.start, range.end, '', newSelection);
  }

  void _handleReplacement(
    TextRange range,
    String text,
    TextSelection newSelection,
  ) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    _edit(range.start, range.end, text, newSelection);
  }

  void _initBuffer(int lineIndex) {
    _bufferLineIndex = lineIndex;
    _bufferLineText = _rope.getLineText(lineIndex);
    _bufferLineRopeStart = _rope.getLineStartOffset(lineIndex);
    _bufferLineOriginalLength = _bufferLineText!.runes.length;
    _bufferDirty = false;
  }

  int get _bufferLineLength => _bufferLineText!.runes.length;
}
