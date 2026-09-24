part of '../controller.dart';

extension _ControllerEditPipeline on CodeForgeController {
  void _applyUndoRedoOperation(EditOperation operation) {
    _flushBuffer();
    _closeCompletion();
    _snippetStops = null;
    _change._selection = true;
    switch (operation) {
      case InsertOperation(:final offset, :final text, :final selectionAfter):
        _editRope(offset, offset, text, selectionAfter);
      case DeleteOperation(:final offset, :final length, :final selectionAfter):
        _editRope(offset, offset + length, '', selectionAfter);
      case ReplaceOperation(
        :final offset,
        :final deletedLength,
        :final insertedText,
        :final selectionAfter,
      ):
        _editRope(offset, offset + deletedLength, insertedText, selectionAfter);
      case CompoundOperation(:final operations):
        for (final op in operations) {
          _applyUndoRedoOperation(op);
        }
        return;
    }
    notifyListeners();
  }

  bool get _recordsUndo {
    final undo = _undoController;
    return undo != null && !undo.isUndoRedoInProgress;
  }

  /// [removed] and [added] count scalars; [deleted] is only read when
  /// [_recordsUndo], so a caller that is not recording may leave it empty.
  void _recordChange(
    int offset,
    String deleted,
    String inserted,
    TextSelection selBefore,
    TextSelection selAfter, {
    required int removed,
    required int added,
  }) {
    if (_snippetStops != null) {
      _trackSnippetEdit(offset, removed, added);
    }
    _pendingSelectionReplacement = null;
    if (removed == 0 && added == 0) return;
    _notifyEdit(offset, removed, added);
    if (!_recordsUndo) return;
    _undoController!.recordEdit(
      removed == 0
          ? InsertOperation(
              offset: offset,
              text: inserted,
              length: added,
              selectionBefore: selBefore,
              selectionAfter: selAfter,
            )
          : added == 0
          ? DeleteOperation(
              offset: offset,
              text: deleted,
              length: removed,
              selectionBefore: selBefore,
              selectionAfter: selAfter,
            )
          : ReplaceOperation(
              offset: offset,
              deletedText: deleted,
              insertedText: inserted,
              deletedLength: removed,
              insertedLength: added,
              selectionBefore: selBefore,
              selectionAfter: selAfter,
            ),
    );
  }

  void _notifyEdit(int offset, int removed, int added) {
    for (final listener in List.of(_editListeners)) {
      listener(offset, removed, added);
    }
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

    _bufferLineIndex = null;
    _bufferLineText = null;
    _bufferDirty = false;

    _invalidateImeSnapshotAndScheduleSync();

    _recordLineEdit(lineToInvalidate, 0, 0);
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
    _logLineEdit(_bufferLineIndex!, 0, 0);
    _change._typing = true;
    _recordChange(
      start,
      deleted,
      insert,
      before,
      after,
      removed: end - start,
      added: insert.runes.length,
    );
    if (deleted.isNotEmpty) _imeSelectionNeedsResync = true;
    _invalidateImeSnapshotAndScheduleSync();
    _scheduleFlush();
  }

  /// With no [after], the caret lands after [insert]. [deleted], when the
  /// caller already holds it, is the text [start, end) replaces.
  void _editRope(
    int start,
    int end,
    String insert,
    TextSelection? after, {
    String? deleted,
  }) {
    final before = _selection;
    _flushBuffer();
    final length = _rope.length;
    final safeStart = start.clamp(0, length);
    final safeEnd = end.clamp(safeStart, length);
    final deletedText =
        deleted ??
        (_recordsUndo && safeStart < safeEnd
            ? _rope.substring(safeStart, safeEnd)
            : '');
    final lines = _spliceRope(safeStart, safeEnd, () {
      if (safeStart < safeEnd) _rope.delete(safeStart, safeEnd);
      if (insert.isNotEmpty) _rope.insert(safeStart, insert);
    });
    final added = _rope.length - length + safeEnd - safeStart;
    _currentVersion++;
    _selection = after ?? TextSelection.collapsed(offset: safeStart + added);
    _recordLineEdit(lines.line, lines.removed, lines.added);
    _recordChange(
      safeStart,
      deletedText,
      insert,
      before,
      _selection,
      removed: safeEnd - safeStart,
      added: added,
    );
    if (safeStart < safeEnd) _imeSelectionNeedsResync = true;
    _invalidateImeSnapshotAndScheduleSync();
  }

  ({int line, int removed, int added}) _spliceRope(
    int start,
    int end,
    void Function() edit,
  ) {
    final line = _rope.getLineAtOffset(start);
    final removed = _rope.getLineAtOffset(end) - line;
    final lineCount = _rope.lineCount;
    edit();
    return (
      line: line,
      removed: removed,
      added: removed + _rope.lineCount - lineCount,
    );
  }

  void _recordLineEdit(int line, int removed, int added) {
    _logLineEdit(line, removed, added);
    final edit = (line: line, removed: removed, inserted: added);
    final pending = _change._lines;
    _change._lines = pending == null ? edit : _mergeLineEdits(pending, edit);
  }

  void _logLineEdit(int line, int removed, int added) {
    _lineEditLog.add((
      version: _currentVersion,
      line: line,
      removed: removed,
      inserted: added,
    ));
    if (_lineEditLog.length > CodeForgeController._lineEditLogLimit) {
      _lineEditLogStart = _lineEditLog.removeAt(0).version;
    }
  }

  ({int line, int removed, int inserted})? _linesEditedBetween(
    int from,
    int to,
  ) {
    if (from < _lineEditLogStart || from >= to) return null;
    ({int line, int removed, int inserted})? merged;
    for (final entry in _lineEditLog) {
      if (entry.version <= from || entry.version > to) continue;
      final edit = (
        line: entry.line,
        removed: entry.removed,
        inserted: entry.inserted,
      );
      merged = merged == null ? edit : _mergeLineEdits(merged, edit);
    }
    return merged;
  }

  String _documentSubstring(int start, int end) {
    if (start == 0 && end >= length && _cachedTextVersion == _currentVersion) {
      return _cachedText!;
    }
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
        _change._typing = true;
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

({int line, int removed, int inserted}) _mergeLineEdits(
  ({int line, int removed, int inserted}) first,
  ({int line, int removed, int inserted}) then,
) {
  final start = min(first.line, then.line);
  final end = max(first.line + first.inserted, then.line + then.removed);
  final originalEnd = end - first.inserted + first.removed;
  final currentEnd = end - then.removed + then.inserted;
  return (
    line: start,
    removed: originalEnd - start,
    inserted: currentEnd - start,
  );
}
