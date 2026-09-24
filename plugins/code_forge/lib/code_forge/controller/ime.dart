part of '../controller.dart';

extension _ControllerIme on CodeForgeController {
  void _maybeAcquireFocusForInput() {
    final node = focusNode;
    if (node != null && !node.hasFocus && !isComposingActive) {
      node.requestFocus();
    }
  }

  void _syncToConnection() {
    if (_suppressImeSync) return;
    if (_imeComposition != null) return;
    if (connection != null && connection!.attached) {
      _ensureImeProjection();

      final projText = _imeProjectionText;
      final scalarSel = _imeProjectionSelection;
      final utf16Base = projText.toUtf16Offset(scalarSel.baseOffset);
      final utf16Extent = projText.toUtf16Offset(scalarSel.extentOffset);
      // Store in UTF-16 units so the platform echo (also UTF-16) matches correctly.
      // Android fires multiple NonTextUpdate deltas per arrow key; we must absorb
      // all of them without overwriting _selection with a wrong platform value.
      _lastSentSelection = TextSelection(
        baseOffset: utf16Base,
        extentOffset: utf16Extent,
      );
      connection!.setEditingState(
        TextEditingValue(
          text: projText,
          selection: TextSelection(
            baseOffset: utf16Base,
            extentOffset: utf16Extent,
          ),
        ),
      );
    }
  }

  void _invalidateImeSnapshotAndScheduleSync() {
    _imeProjectionDirty = true;
    _syncToConnection();
  }

  bool _platformValueDivergesFromProjection(List<TextEditingDelta> deltas) {
    if (connection == null || !connection!.attached) return false;
    String? platformText;
    for (final delta in deltas) {
      if (delta is TextEditingDeltaNonTextUpdate) continue;
      platformText = delta.oldText;
      break;
    }
    if (platformText == null) return false;
    var value = TextEditingValue(text: platformText);
    for (final delta in deltas) {
      value = delta.apply(value);
    }
    return value.text != _imeProjectionText;
  }

  void _ensureImeProjection() {
    if (!_imeProjectionDirty) return;

    final selection = _selection;
    final documentLength = length;
    if (documentLength == 0) {
      _imeProjectionStartOffset = 0;
      _imeProjectionText = '';
      _imeProjectionSelection = const TextSelection.collapsed(offset: 0);
      _imeProjectionDirty = false;
      return;
    }

    final selectionStart = selection.start.clamp(0, documentLength);
    final selectionEnd = selection.end.clamp(selectionStart, documentLength);
    final caretOffset = selection.extentOffset.clamp(0, documentLength);
    final firstSelLine = getLineAtOffset(selectionStart);
    final lastSelLine = getLineAtOffset(selectionEnd);
    final caretLine = getLineAtOffset(caretOffset);
    final anchorLow = firstSelLine < caretLine ? firstSelLine : caretLine;
    final anchorHigh = lastSelLine > caretLine ? lastSelLine : caretLine;
    final lineStart = (anchorLow - CodeForgeController._imeProjectionLineRadius)
        .clamp(0, lineCount - 1);
    final lineEnd = (anchorHigh + CodeForgeController._imeProjectionLineRadius)
        .clamp(0, lineCount - 1);

    final parts = <String>[];
    for (int line = lineStart; line <= lineEnd; line++) {
      parts.add(getLineText(line));
    }

    var projectionText = parts.join('\n');
    var projectionStartOffset = getLineStartOffset(lineStart);

    if (projectionText.length > CodeForgeController._imeProjectionMaxChars) {
      const halfWindow = CodeForgeController._imeProjectionMaxChars ~/ 2;
      final desiredStart = caretOffset - halfWindow;
      projectionStartOffset = desiredStart < 0 ? 0 : desiredStart;
      if (selectionStart < projectionStartOffset) {
        projectionStartOffset = selectionStart;
      }
      final selectionTail = selectionEnd + halfWindow;
      final projectionEndOffset =
          (projectionStartOffset + CodeForgeController._imeProjectionMaxChars)
              .clamp(0, documentLength);
      if (selectionTail > projectionEndOffset) {
        projectionStartOffset =
            (selectionTail - CodeForgeController._imeProjectionMaxChars).clamp(
              0,
              documentLength,
            );
      }
      final projectionEnd =
          (projectionStartOffset + CodeForgeController._imeProjectionMaxChars)
              .clamp(0, documentLength);
      projectionText = _documentSubstring(projectionStartOffset, projectionEnd);
    }

    final projectionLength = projectionText.runes.length;
    final localBase = (selection.baseOffset - projectionStartOffset).clamp(
      0,
      projectionLength,
    );
    final localExtent = (selection.extentOffset - projectionStartOffset).clamp(
      0,
      projectionLength,
    );

    _imeProjectionStartOffset = projectionStartOffset;
    _imeProjectionText = projectionText;
    _imeProjectionSelection = TextSelection(
      baseOffset: localBase,
      extentOffset: localExtent,
    );
    _imeProjectionDirty = false;
  }

  int _windowOffsetToGlobal(int windowStart, String windowText, int local) =>
      (windowStart +
              windowText.toScalarOffset(local) -
              _carriageReturnsBefore(windowText, local))
          .clamp(0, length);

  TextSelection _windowSelectionToGlobal(
    int windowStart,
    String windowText,
    TextSelection local,
  ) {
    return TextSelection(
      baseOffset: _windowOffsetToGlobal(
        windowStart,
        windowText,
        local.baseOffset,
      ),
      extentOffset: _windowOffsetToGlobal(
        windowStart,
        windowText,
        local.extentOffset,
      ),
    );
  }

  void _beginImeCompositionUndoGroup(bool incomingHasComposing) {
    if (incomingHasComposing && _imeCompositionUndoGroup == null) {
      _imeCompositionUndoGroup = _undoController?.beginCompoundOperation();
    }
  }

  void _endImeCompositionUndoGroupIfIdle() {
    if (_imeCompositionUndoGroup != null && _imeComposition == null) {
      _imeCompositionUndoGroup!.end();
      _imeCompositionUndoGroup = null;
    }
  }

  void _processCompositionDeltas(List<TextEditingDelta> deltas) {
    _suppressImeSync = true;
    final startingComposition = _imeComposition == null;
    final selectionToReplace = startingComposition
        ? _selectionToReplaceForComposition()
        : null;
    _seedImeMirrorIfIdle();
    final replacement = _captureSelectionReplacement(selectionToReplace);
    _beginImeCompositionUndoGroup(
      deltas.any((d) => d.composing.isValid && !d.composing.isCollapsed),
    );

    var value = TextEditingValue(
      text: _imeMirrorText,
      selection: _imeMirrorSelection,
      composing: _imeMirrorComposing,
    );
    var mirror = value;
    for (final delta in deltas) {
      value = delta.apply(value);
      mirror = _withoutCarriageReturns(value);
      _reconcileCommittedToDocument(mirror);
    }

    _applyLingeringSelectionDeletion(replacement);
    _finishImeMirrorUpdate(mirror);
    final composingEnded = _imeComposition == null;
    _suppressImeSync = false;
    if (composingEnded) {
      _syncToConnection();
    } else if (mirror.text != value.text) {
      _sendImeMirror();
    }
    notifyListeners();
  }

  void _processCompositionValue(TextEditingValue value) {
    _suppressImeSync = true;
    final startingComposition = _imeComposition == null;
    final selectionToReplace = startingComposition
        ? _selectionToReplaceForComposition()
        : null;
    _seedImeMirrorIfIdle();
    final replacement = _captureSelectionReplacement(selectionToReplace);
    _beginImeCompositionUndoGroup(
      value.composing.isValid && !value.composing.isCollapsed,
    );
    final mirror = _withoutCarriageReturns(value);
    _reconcileCommittedToDocument(mirror);
    _applyLingeringSelectionDeletion(replacement);
    _finishImeMirrorUpdate(mirror);
    final composingEnded = _imeComposition == null;
    _suppressImeSync = false;
    if (composingEnded) {
      _syncToConnection();
    } else if (mirror.text != value.text) {
      _sendImeMirror();
    }
    notifyListeners();
  }

  void _sendImeMirror() {
    if (connection != null && connection!.attached) {
      connection!.setEditingState(
        TextEditingValue(
          text: _imeMirrorText,
          selection: _imeMirrorSelection,
          composing: _imeMirrorComposing,
        ),
      );
    }
  }

  void _seedImeMirrorIfIdle() {
    if (_imeComposition != null) return;
    _flushBuffer();
    _ensureImeProjection();
    _imeMirrorText = _imeProjectionText;
    _imeMirrorSelection = TextSelection(
      baseOffset: _imeProjectionText.toUtf16Offset(
        _imeProjectionSelection.baseOffset,
      ),
      extentOffset: _imeProjectionText.toUtf16Offset(
        _imeProjectionSelection.extentOffset,
      ),
    );
    _imeMirrorComposing = TextRange.empty;
    _imeWindowStart = _imeProjectionStartOffset;
    _imeWindowCommitted = _imeProjectionText;
    _imeMirrorDeleteStart = -1;
    _imeMirrorDeleteLen = 0;
    _imeMirrorDeletedText = '';
    _rawTypedComposingText = '';
    _lastComposingText = '';
  }

  void _finishImeMirrorUpdate(TextEditingValue value) {
    _imeMirrorText = value.text;
    _imeMirrorSelection = value.selection;
    _imeMirrorComposing = value.composing;

    final composingActive =
        value.composing.isValid && !value.composing.isCollapsed;

    if (composingActive) {
      final newComposingText = value.text.substring(
        value.composing.start,
        value.composing.end,
      );

      final strippedOld = _lastComposingText
          .replaceAll("'", '')
          .replaceAll('\u2019', '');
      final strippedNew = newComposingText
          .replaceAll("'", '')
          .replaceAll('\u2019', '');

      if (strippedNew.length > strippedOld.length) {
        _rawTypedComposingText += strippedNew.substring(strippedOld.length);
      } else if (strippedNew.length < strippedOld.length) {
        final diff = strippedOld.length - strippedNew.length;
        if (_rawTypedComposingText.length >= diff) {
          _rawTypedComposingText = _rawTypedComposingText.substring(
            0,
            _rawTypedComposingText.length - diff,
          );
        } else {
          _rawTypedComposingText = '';
        }
      } else if (newComposingText.length > _lastComposingText.length) {
        _rawTypedComposingText += "'";
      } else if (newComposingText.length < _lastComposingText.length) {
        if (_rawTypedComposingText.endsWith("'") ||
            _rawTypedComposingText.endsWith('\u2019')) {
          _rawTypedComposingText = _rawTypedComposingText.substring(
            0,
            _rawTypedComposingText.length - 1,
          );
        }
      }

      _lastComposingText = newComposingText;
      _updateCompositionOverlayFromMirror();
    } else {
      _imeComposition = null;
      _pendingSelectionReplacement = null;
      _imeMirrorDeleteStart = -1;
      _imeMirrorDeleteLen = 0;
      _imeMirrorDeletedText = '';
      _rawTypedComposingText = '';
      _lastComposingText = '';
      _endImeCompositionUndoGroupIfIdle();
      _imeProjectionDirty = true;
    }

    _selection = _documentSelectionFromMirror(value.selection);
    imeCompositionChanged = true;
    _maybeAcquireFocusForInput();
  }

  void _reconcileCommittedToDocument(TextEditingValue value) {
    final composing = value.composing;
    String committedNew;
    if (composing.isValid && !composing.isCollapsed) {
      committedNew =
          value.text.substring(0, composing.start) +
          value.text.substring(composing.end);
    } else {
      committedNew = value.text;
    }

    if (_imeMirrorDeleteLen > 0 && _imeMirrorDeleteStart >= 0) {
      final end = _imeMirrorDeleteStart + _imeMirrorDeleteLen;
      if (end <= committedNew.length &&
          committedNew.substring(_imeMirrorDeleteStart, end) ==
              _imeMirrorDeletedText) {
        committedNew =
            committedNew.substring(0, _imeMirrorDeleteStart) +
            committedNew.substring(end);
      } else {
        _imeMirrorDeleteStart = -1;
        _imeMirrorDeleteLen = 0;
        _imeMirrorDeletedText = '';
      }
    }

    final committedOld = _imeWindowCommitted;
    if (committedNew == committedOld) return;

    final oldLen = committedOld.length;
    final newLen = committedNew.length;
    final maxPrefix = oldLen < newLen ? oldLen : newLen;
    int prefix = 0;
    while (prefix < maxPrefix &&
        committedOld.codeUnitAt(prefix) == committedNew.codeUnitAt(prefix)) {
      prefix++;
    }
    if (committedOld.isLowSurrogateAt(prefix)) prefix--;
    final oldTail = oldLen - prefix;
    final newTail = newLen - prefix;
    final maxSuffix = oldTail < newTail ? oldTail : newTail;
    int suffix = 0;
    while (suffix < maxSuffix &&
        committedOld.codeUnitAt(oldLen - 1 - suffix) ==
            committedNew.codeUnitAt(newLen - 1 - suffix)) {
      suffix++;
    }
    if (suffix > 0 && committedOld.isLowSurrogateAt(oldLen - suffix)) {
      suffix--;
    }

    final globalStart = _imeWindowStart + committedOld.toScalarOffset(prefix);
    final globalEnd =
        _imeWindowStart + committedOld.toScalarOffset(oldLen - suffix);
    final replacement = committedNew.substring(prefix, newLen - suffix);

    replaceRange(globalStart, globalEnd, replacement);
    _imeWindowCommitted = committedNew;
  }

  void _updateCompositionOverlayFromMirror() {
    final comp = _imeMirrorComposing;
    final raw = _imeMirrorText.substring(comp.start, comp.end);
    var compStartLocal = comp.start;
    if (_imeMirrorDeleteLen > 0 &&
        compStartLocal >= _imeMirrorDeleteStart + _imeMirrorDeleteLen) {
      compStartLocal -= _imeMirrorDeleteLen;
    }
    final anchorGlobal =
        (_imeWindowStart + _imeWindowCommitted.toScalarOffset(compStartLocal))
            .clamp(0, length);
    final caretLocalRaw = (_imeMirrorSelection.extentOffset - comp.start).clamp(
      0,
      raw.length,
    );
    _imeComposition = ImeComposition(
      anchor: anchorGlobal,
      displayText: raw,
      displayCaret: caretLocalRaw,
      commitText: _rawTypedComposingText.isNotEmpty
          ? _rawTypedComposingText
          : raw,
    );
  }

  TextSelection _documentSelectionFromMirror(TextSelection localSelection) {
    final comp = _imeComposition;
    if (comp != null) {
      return TextSelection.collapsed(offset: comp.anchor);
    }
    final base =
        (_imeWindowStart +
                _imeMirrorText.toScalarOffset(localSelection.baseOffset))
            .clamp(0, length);
    final extent =
        (_imeWindowStart +
                _imeMirrorText.toScalarOffset(localSelection.extentOffset))
            .clamp(0, length);
    return TextSelection(baseOffset: base, extentOffset: extent);
  }

  void _commitCompositionInPlace() {
    final comp = _imeComposition;
    if (comp == null) return;
    _imeComposition = null;
    if (comp.commitText.isNotEmpty) {
      final wasSuppressed = _suppressImeSync;
      _suppressImeSync = true;
      replaceRange(comp.anchor, comp.anchor, comp.commitText);
      _suppressImeSync = wasSuppressed;
    }
    _endImeCompositionUndoGroupIfIdle();
    _imeMirrorText = '';
    _imeMirrorSelection = const TextSelection.collapsed(offset: 0);
    _imeMirrorComposing = TextRange.empty;
    _imeWindowCommitted = '';
    _pendingSelectionReplacement = null;
    _imeMirrorDeleteStart = -1;
    _imeMirrorDeleteLen = 0;
    _imeMirrorDeletedText = '';
    imeCompositionChanged = true;
  }

  TextSelection _commitCompositionAndRemapSelection(TextSelection requested) {
    final comp = _imeComposition;
    final anchor = comp?.anchor ?? -1;
    final insertedLength = comp?.commitText.runes.length ?? 0;
    _commitCompositionInPlace();
    if (insertedLength <= 0 || anchor < 0) return requested;
    final base = requested.baseOffset > anchor
        ? requested.baseOffset + insertedLength
        : requested.baseOffset;
    final extent = requested.extentOffset > anchor
        ? requested.extentOffset + insertedLength
        : requested.extentOffset;
    if (base == requested.baseOffset && extent == requested.extentOffset) {
      return requested;
    }
    return requested.copyWith(baseOffset: base, extentOffset: extent);
  }

  TextSelection? _selectionToReplaceForComposition() {
    if (!_selection.isCollapsed) return _selection;
    final pending = _pendingSelectionReplacement;
    if (pending != null && !pending.isCollapsed) {
      final caret = _selection.extentOffset;
      if (caret >= pending.start && caret <= pending.end) return pending;
    }
    return null;
  }

  ({int localStart, String text}) _captureSelectionReplacement(
    TextSelection? sel,
  ) {
    if (sel == null || sel.isCollapsed) return (localStart: 0, text: '');
    final scalarStart = sel.start - _imeWindowStart;
    final scalarEnd = sel.end - _imeWindowStart;
    if (scalarStart < 0 ||
        scalarEnd > _imeWindowCommitted.runes.length ||
        scalarEnd <= scalarStart) {
      return (localStart: 0, text: '');
    }
    final localStart = _imeWindowCommitted.toUtf16Offset(scalarStart);
    final localEnd = _imeWindowCommitted.toUtf16Offset(scalarEnd);
    return (
      localStart: localStart,
      text: _imeWindowCommitted.substring(localStart, localEnd),
    );
  }

  void _applyLingeringSelectionDeletion(
    ({int localStart, String text}) capture,
  ) {
    if (capture.text.isEmpty) return;
    final localStart = capture.localStart;
    final localEnd = localStart + capture.text.length;
    if (localEnd > _imeWindowCommitted.length) return;
    if (_imeWindowCommitted.substring(localStart, localEnd) != capture.text) {
      return;
    }
    final globalStart =
        _imeWindowStart + _imeWindowCommitted.toScalarOffset(localStart);
    replaceRange(globalStart, globalStart + capture.text.runes.length, '');
    _imeWindowCommitted =
        _imeWindowCommitted.substring(0, localStart) +
        _imeWindowCommitted.substring(localEnd);
    _imeMirrorDeleteStart = localStart;
    _imeMirrorDeleteLen = capture.text.length;
    _imeMirrorDeletedText = capture.text;
  }

  TextEditingValue _buildCurrentImeEditingValue() {
    _ensureImeProjection();
    final projText = _imeProjectionText;
    final scalarSel = _imeProjectionSelection;
    final utf16Base = projText.toUtf16Offset(scalarSel.baseOffset);
    final utf16Extent = projText.toUtf16Offset(scalarSel.extentOffset);
    return TextEditingValue(
      text: projText,
      selection: TextSelection(
        baseOffset: utf16Base,
        extentOffset: utf16Extent,
      ),
    );
  }
}

/// The platform keeps the CR of a CRLF it types while the document drops it,
/// so each such CR ahead of an offset into the platform's text is one too many.
int _carriageReturnsBefore(String text, int end) => text.contains('\r\n')
    ? '\r\n'
          .allMatches(text.substring(0, (end + 1).clamp(0, text.length)))
          .length
    : 0;

TextEditingValue _withoutCarriageReturns(TextEditingValue value) {
  final TextEditingValue(:text, :selection, :composing) = value;
  if (!text.contains('\r\n')) return value;
  int strip(int offset) =>
      offset < 0 ? offset : offset - _carriageReturnsBefore(text, offset);
  return TextEditingValue(
    text: CodeForgeController.normalizeLineBreaks(text),
    selection: selection.copyWith(
      baseOffset: strip(selection.baseOffset),
      extentOffset: strip(selection.extentOffset),
    ),
    composing: TextRange(
      start: strip(composing.start),
      end: strip(composing.end),
    ),
  );
}
