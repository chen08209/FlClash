part of '../controller.dart';

/// An IME composition in progress, painted at [anchor] while the document
/// holds none of it until the input method commits.
@immutable
class ImeComposition {
  final int anchor;

  /// As the platform reports it, the input method's separators included.
  final String displayText;

  final int displayCaret;

  /// What an interruption commits; see `_interruptedCommitText`.
  final String commitText;

  const ImeComposition({
    required this.anchor,
    required this.displayText,
    required this.displayCaret,
    required this.commitText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImeComposition &&
          other.anchor == anchor &&
          other.displayText == displayText &&
          other.displayCaret == displayCaret &&
          other.commitText == commitText;

  @override
  int get hashCode =>
      Object.hash(anchor, displayText, displayCaret, commitText);
}

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
      final value = _buildCurrentImeEditingValue();
      // Store in UTF-16 units so the platform echo (also UTF-16) matches correctly.
      // Android fires multiple NonTextUpdate deltas per arrow key; we must absorb
      // all of them without overwriting _selection with a wrong platform value.
      _lastSentSelection = value.selection;
      _imeHeldWindow = (
        start: _imeProjectionStartOffset,
        length: _imeProjectionText.runes.length,
      );
      connection!.setEditingState(value);
    }
  }

  void _replacePlatformWindow(
    TextEditingValue platform,
    int platformStart, {
    bool always = false,
  }) {
    final platformText = platform.text;
    _imeHeldWindow = (
      start: platformStart,
      length:
          _windowOffsetToGlobal(
            platformStart,
            platformText,
            platformText.length,
          ) -
          platformStart,
    );
    _ensureImeProjection();
    final textDiffers = platformText != _imeProjectionText;
    final moved = platformStart != _imeProjectionStartOffset;
    if (textDiffers) _supersededPlatformTexts.add(platformText);
    _imeShiftedWindow = !textDiffers && moved
        ? (start: platformStart, caret: platform.selection.extentOffset)
        : null;
    if (always || textDiffers || moved) _syncToConnection();
  }

  /// The window the platform held before one of the same text took its
  /// place, when [deltas] edit at the caret it had there.
  ({int start, int caret})? _shiftedWindowEdited(
    List<TextEditingDelta> deltas,
    TextEditingValue current,
  ) {
    final shifted = _imeShiftedWindow;
    final edit = deltas.where(_changesText).firstOrNull;
    if (shifted == null || edit == null || edit.oldText != current.text) {
      return null;
    }
    final range = switch (edit) {
      TextEditingDeltaInsertion(:final insertionOffset) => TextRange.collapsed(
        insertionOffset,
      ),
      _ => _removedRange(edit)!,
    };
    bool at(int caret) => range.start <= caret && caret <= range.end;
    return at(shifted.caret) && !at(current.selection.extentOffset)
        ? shifted
        : null;
  }

  void _invalidateImeSnapshotAndScheduleSync() {
    _imeProjectionDirty = true;
    _syncToConnection();
  }

  /// Whether the platform made [deltas] before the window sent in place of
  /// the one they edit reached it; that window then wipes them on its side.
  bool _editSupersededWindow(List<TextEditingDelta> deltas) {
    if (_imeComposition != null || deltas.isEmpty) return false;
    final platformText = deltas.first.oldText;
    return _supersededPlatformTexts.contains(platformText) &&
        platformText != _imeProjectionText;
  }

  void _retypeSupersededInsertions(List<TextEditingDelta> deltas) {
    _supersededPlatformTexts.add(
      deltas
          .fold(
            TextEditingValue(text: deltas.first.oldText),
            (value, delta) => delta.apply(value),
          )
          .text,
    );
    final typed = [
      for (final delta in deltas.where(_changesText))
        delta is TextEditingDeltaInsertion ? delta.textInserted : null,
    ];
    if (typed.isEmpty || typed.contains(null) || !_selection.isCollapsed) {
      return;
    }
    final text = typed.join();
    final caret = _selection.extentOffset;
    _supersededPlatformTexts.add(_imeProjectionText);
    _suppressImeSync = true;
    final removal = _joinSelectionRemoval();
    _handleInsertion(
      caret,
      text,
      TextSelection.collapsed(offset: caret + text.runes.length),
    );
    removal?.end();
    _suppressImeSync = false;
    _isTyping = _startsWord(text);
    _invalidateImeSnapshotAndScheduleSync();
    notifyListeners();
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

    var projectionStartOffset = getLineStartOffset(lineStart);
    final linesEndOffset = lineEnd + 1 < lineCount
        ? getLineStartOffset(lineEnd + 1) - 1
        : documentLength;
    var projectionText =
        linesEndOffset - projectionStartOffset <=
            CodeForgeController._imeProjectionMaxChars
        ? _documentSubstring(projectionStartOffset, linesEndOffset)
        : null;

    if (projectionText == null ||
        projectionText.length > CodeForgeController._imeProjectionMaxChars) {
      final held = _heldWindowAround(selectionStart, selectionEnd);
      if (held != null) {
        projectionStartOffset = held.start;
        projectionText = _documentSubstring(held.start, held.end);
      } else {
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
              (selectionTail - CodeForgeController._imeProjectionMaxChars)
                  .clamp(0, documentLength);
        }
        final projectionEnd =
            (projectionStartOffset + CodeForgeController._imeProjectionMaxChars)
                .clamp(0, documentLength);
        projectionText = _documentSubstring(
          projectionStartOffset,
          projectionEnd,
        );
      }
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

  // A window cut by character count would otherwise start anew at every
  // caret move, and the platform's text never be the one expected of it.
  ({int start, int end})? _heldWindowAround(
    int selectionStart,
    int selectionEnd,
  ) {
    final held = _imeHeldWindow;
    if (held == null) return null;
    const margin = CodeForgeController._imeProjectionMaxChars ~/ 16;
    const limit =
        CodeForgeController._imeProjectionMaxChars +
        CodeForgeController._imeProjectionMaxChars ~/ 2;
    final end = min(held.start + held.length, length);
    final holds =
        held.length <= limit &&
        (held.start == 0 || selectionStart - held.start >= margin) &&
        (end == length || end - selectionEnd >= margin);
    return holds ? (start: held.start, end: end) : null;
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

  /// An input method that collapsed the selection first is replacing it only
  /// when it removes exactly the part the window showed.
  TextSelection? _selectionCutShortByWindow(
    int windowStart,
    int windowEnd,
    TextRange removed,
  ) {
    final selection = _selectionBeingReplaced();
    if (selection == null) return null;
    final shownStart = max(selection.start, windowStart);
    final shownEnd = min(selection.end, windowEnd);
    if (shownStart == selection.start && shownEnd == selection.end) return null;
    final removesWhatWasShown =
        removed.start == shownStart && removed.end == shownEnd;
    return !_selection.isCollapsed || removesWhatWasShown ? selection : null;
  }

  /// A selection collapsed by the input method is replaced only from its ends.
  void _keepPendingSelectionAtRest(
    TextSelection before,
    int windowStart,
    int windowEnd,
  ) {
    final pending = _pendingSelectionReplacement;
    if (pending == null) return;
    final caret = _selection.extentOffset;
    final rests = before.isCollapsed
        ? caret == before.extentOffset
        : caret == max(pending.start, windowStart) ||
              caret == min(pending.end, windowEnd);
    if (!_selection.isCollapsed || !rests) _pendingSelectionReplacement = null;
  }

  // The platform's own cut copies only what its window held of the selection.
  Future<void> _widenPlatformCut(String cut, String whole) async {
    if (await _readClipboard() == cut) await _writeClipboard(whole);
  }

  int _deleteSelectionOutsideWindow(
    TextSelection selection,
    int windowStart,
    int windowEnd,
  ) {
    if (selection.end > windowEnd) {
      _deleteAroundWindow(max(selection.start, windowEnd), selection.end);
    }
    final ahead = min(selection.end, windowStart) - selection.start;
    if (ahead <= 0) return windowStart;
    _deleteAroundWindow(selection.start, selection.start + ahead);
    return windowStart - ahead;
  }

  void _deleteAroundWindow(int start, int end) {
    int moved(int offset) =>
        offset <= start ? offset : max(start, offset - (end - start));
    _editRope(
      start,
      end,
      '',
      _selection.copyWith(
        baseOffset: moved(_selection.baseOffset),
        extentOffset: moved(_selection.extentOffset),
      ),
    );
  }

  void _beginImeCompositionUndoGroup(bool incomingHasComposing) {
    if (incomingHasComposing && _imeCompositionUndoGroup == null) {
      _imeCompositionUndoGroup =
          _joinSelectionRemoval() ?? _undoController?.beginCompoundOperation();
    }
  }

  /// Gboard types over a selection in two batches, which undo as one step.
  CompoundOperationHandle? _joinSelectionRemoval() {
    final removal = _selectionRemoval;
    _selectionRemoval = null;
    final follows =
        removal != null &&
        removal.version == _currentVersion &&
        DateTime.now().difference(removal.at) <
            const Duration(milliseconds: 150);
    return follows ? _undoController?.resumeLast() : null;
  }

  void _processCompositionDeltas(List<TextEditingDelta> deltas) {
    _processComposition(deltas.any((d) => _isComposing(d.composing)), (
      mirror,
    ) sync* {
      for (final delta in deltas) {
        yield mirror = delta.apply(mirror);
      }
    });
  }

  int _typingAfterComposition(List<TextEditingDelta> deltas) {
    final from = deltas.lastIndexWhere((d) => _isComposing(d.composing)) + 1;
    final rest = deltas.skip(from);
    final types =
        rest.any((d) => d is TextEditingDeltaInsertion) &&
        rest.every((d) => d is TextEditingDeltaInsertion || !_changesText(d));
    return types ? from : -1;
  }

  void _endCompositionBefore(
    List<TextEditingDelta> composed,
    TextEditingDelta next,
  ) {
    _processComposition(composed.any((d) => _isComposing(d.composing)), (
      mirror,
    ) sync* {
      for (final delta in composed) {
        yield mirror = delta.apply(mirror);
      }
      yield TextEditingValue(text: next.oldText, selection: mirror.selection);
    }, platformContinues: true);
    final TextEditingValue(:text, :selection) = _imeMirror;
    _imeProjectionStartOffset = _imeWindowStart;
    _imeProjectionText = text;
    _imeProjectionSelection = TextSelection(
      baseOffset: text.toScalarOffset(selection.baseOffset),
      extentOffset: text.toScalarOffset(selection.extentOffset),
    );
    _imeProjectionDirty = false;
  }

  // Android reports a finished composition with no delta at all.
  void _endCompositionAsShown() {
    _processComposition(
      false,
      (mirror) => [
        TextEditingValue(text: mirror.text, selection: mirror.selection),
      ],
      resends: false,
    );
  }

  void _processCompositionValue(TextEditingValue value) {
    _processComposition(_isComposing(value.composing), (_) => [value]);
  }

  void _processComposition(
    bool incomingHasComposing,
    Iterable<TextEditingValue> Function(TextEditingValue mirror)
    platformValues, {
    bool platformContinues = false,
    bool resends = true,
  }) {
    _suppressImeSync = true;
    final selectionToReplace = _imeComposition == null
        ? _selectionBeingReplaced()
        : null;
    _seedImeMirrorIfIdle();
    final replacement = _captureSelectionReplacement(selectionToReplace);
    final committedBefore = _imeWindowCommitted;
    _beginImeCompositionUndoGroup(incomingHasComposing);
    if (selectionToReplace != null) {
      _imeWindowStart = _deleteSelectionOutsideWindow(
        selectionToReplace,
        _imeWindowStart,
        _imeWindowStart + _imeWindowCommitted.runes.length,
      );
    }

    var platform = _imeMirror;
    var mirror = platform;
    for (final value in platformValues(_imeMirror)) {
      platform = value;
      mirror = _withoutCarriageReturns(value);
      _reconcileCommittedToDocument(mirror);
    }

    // In committed text the platform changed, a match may not be the selection.
    if (_imeWindowCommitted == committedBefore) {
      _applyLingeringSelectionDeletion(replacement);
    }
    _finishImeMirrorUpdate(mirror);
    _suppressImeSync = false;
    if (platformContinues) return;
    if (_imeComposition == null) {
      _replacePlatformWindow(platform, _imeWindowStart, always: resends);
    } else if (mirror.text != platform.text) {
      _sendImeMirror();
    }
    notifyListeners();
  }

  void _sendImeMirror() {
    if (connection != null && connection!.attached) {
      connection!.setEditingState(_imeMirror);
    }
  }

  void _seedImeMirrorIfIdle() {
    if (_imeComposition != null) return;
    _flushBuffer();
    final value = _buildCurrentImeEditingValue();
    _imeMirror = value;
    _imeWindowStart = _imeProjectionStartOffset;
    _imeWindowCommitted = value.text;
  }

  void _finishImeMirrorUpdate(TextEditingValue value) {
    _imeMirror = value;

    if (_isComposing(value.composing)) {
      final newComposingText = value.composing.textInside(value.text);

      final strippedOld = _withoutSyllableSeparators(_lastComposingText);
      final strippedNew = _withoutSyllableSeparators(newComposingText);

      final grown = strippedNew.length - strippedOld.length;
      if (grown == 1) {
        _rawTypedComposingText += strippedNew.substring(strippedOld.length);
      } else if (grown > 1) {
        // More than a keystroke at once is text whose separators are its own.
        _rawTypedComposingText = newComposingText;
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
            _rawTypedComposingText.endsWith('’')) {
          _rawTypedComposingText = _rawTypedComposingText.substring(
            0,
            _rawTypedComposingText.length - 1,
          );
        }
      }

      _lastComposingText = newComposingText;
      _updateCompositionOverlayFromMirror();
      _selection = TextSelection.collapsed(offset: _imeComposition!.anchor);
    } else {
      _selection = _mirrorSelectionInDocument(value);
      _dropImeComposition();
      _imeProjectionDirty = true;
    }
    _change._composition = true;
    _maybeAcquireFocusForInput();
  }

  void _reconcileCommittedToDocument(TextEditingValue value) {
    final composing = value.composing;
    var committedNew = _isComposing(composing)
        ? value.text.replaceRange(composing.start, composing.end, '')
        : value.text;

    if (_imeMirrorDeletion case (:final start, :final text)) {
      // What the platform commits ahead of the text it still shows moves it.
      final before = _imeWindowCommitted.substring(0, start);
      final after = _imeWindowCommitted.substring(start);
      final movedStart = committedNew.endsWith('$text$after')
          ? committedNew.length - after.length - text.length
          : committedNew.startsWith('$before$text')
          ? start
          : null;
      if (movedStart != null) {
        committedNew = committedNew.replaceRange(
          movedStart,
          movedStart + text.length,
          '',
        );
        _imeMirrorDeletion = (start: movedStart, text: text);
      } else {
        _imeMirrorDeletion = null;
      }
    }

    final committedOld = _imeWindowCommitted;
    final change = _changedSpan(committedOld, committedNew);
    if (change == null) return;
    replaceRange(
      _imeWindowStart + committedOld.toScalarOffset(change.start),
      _imeWindowStart + committedOld.toScalarOffset(change.end),
      change.replacement,
    );
    _imeWindowCommitted = committedNew;
  }

  void _updateCompositionOverlayFromMirror() {
    final comp = _imeMirror.composing;
    final raw = comp.textInside(_imeMirror.text);
    var compStartLocal = comp.start;
    if (_imeMirrorDeletion case (:final start, :final text)
        when compStartLocal >= start + text.length) {
      compStartLocal -= text.length;
    }
    final anchorGlobal =
        (_imeWindowStart + _imeWindowCommitted.toScalarOffset(compStartLocal))
            .clamp(0, length);
    final caretLocalRaw = (_imeMirror.selection.extentOffset - comp.start)
        .clamp(0, raw.length);
    _imeComposition = ImeComposition(
      anchor: anchorGlobal,
      displayText: raw,
      displayCaret: caretLocalRaw,
      commitText: _interruptedCommitText(raw),
    );
  }

  // The typed letters only stand for the composition while the input method
  // shows them split by its own separators, as pinyin does; kana, hangul and
  // Telex show converted text, and that is what an interruption commits.
  String _interruptedCommitText(String displayed) {
    final typed = _rawTypedComposingText;
    return typed.isNotEmpty &&
            _withoutSyllableSeparators(typed) ==
                _withoutSyllableSeparators(displayed)
        ? typed
        : displayed;
  }

  TextSelection _mirrorSelectionInDocument(TextEditingValue mirror) {
    var TextEditingValue(:text, :selection) = mirror;
    if (_imeMirrorDeletion case (:final start, text: final removed)) {
      int kept(int offset) =>
          offset <= start ? offset : max(start, offset - removed.length);
      text = text.replaceRange(start, start + removed.length, '');
      selection = selection.copyWith(
        baseOffset: kept(selection.baseOffset),
        extentOffset: kept(selection.extentOffset),
      );
    }
    return _windowSelectionToGlobal(_imeWindowStart, text, selection);
  }

  void _commitCompositionInPlace() {
    final comp = _imeComposition;
    if (comp == null) return;
    _imeComposition = null;
    if (comp.commitText.isNotEmpty) {
      final wasSuppressed = _suppressImeSync;
      _suppressImeSync = true;
      _editRope(comp.anchor, comp.anchor, comp.commitText, null);
      _suppressImeSync = wasSuppressed;
    }
    _dropImeComposition();
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

  TextSelection? _selectionBeingReplaced() {
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
    final windowLength = _imeWindowCommitted.runes.length;
    final scalarStart = (sel.start - _imeWindowStart).clamp(0, windowLength);
    final scalarEnd = (sel.end - _imeWindowStart).clamp(0, windowLength);
    if (scalarEnd <= scalarStart) return (localStart: 0, text: '');
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
    _imeWindowCommitted = _imeWindowCommitted.replaceRange(
      localStart,
      localEnd,
      '',
    );
    _imeMirrorDeletion = (start: localStart, text: capture.text);
  }

  TextEditingValue _buildCurrentImeEditingValue() {
    _ensureImeProjection();
    final projText = _imeProjectionText;
    final scalarSel = _imeProjectionSelection;
    return TextEditingValue(
      text: projText,
      selection: TextSelection(
        baseOffset: projText.toUtf16Offset(scalarSel.baseOffset),
        extentOffset: projText.toUtf16Offset(scalarSel.extentOffset),
      ),
    );
  }
}

bool _isComposing(TextRange composing) =>
    composing.isValid && !composing.isCollapsed;

// Input methods such as Gboard mark the word at the caret as composing
// without changing it; only an edit starts a composition here.
bool _changesText(TextEditingDelta delta) => switch (delta) {
  TextEditingDeltaNonTextUpdate() => false,
  TextEditingDeltaReplacement(:final textReplaced, :final replacementText) =>
    textReplaced != replacementText,
  _ => true,
};

TextRange? _removedRange(TextEditingDelta delta) => switch (delta) {
  TextEditingDeltaDeletion(:final deletedRange) => deletedRange,
  TextEditingDeltaReplacement(:final replacedRange) => replacedRange,
  _ => null,
};

/// The span of [before], in UTF-16 units, that [after] rewrites, never
/// splitting a surrogate pair, or null when they are equal.
({int start, int end, String replacement})? _changedSpan(
  String before,
  String after,
) {
  if (before == after) return null;
  final shorter = min(before.length, after.length);
  var prefix = 0;
  while (prefix < shorter &&
      before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
    prefix++;
  }
  if (before.isLowSurrogateAt(prefix)) prefix--;
  var suffix = 0;
  while (suffix < shorter - prefix &&
      before.codeUnitAt(before.length - 1 - suffix) ==
          after.codeUnitAt(after.length - 1 - suffix)) {
    suffix++;
  }
  if (suffix > 0 && before.isLowSurrogateAt(before.length - suffix)) {
    suffix--;
  }
  return (
    start: prefix,
    end: before.length - suffix,
    replacement: after.substring(prefix, after.length - suffix),
  );
}

String _withoutSyllableSeparators(String text) =>
    text.replaceAll("'", '').replaceAll('’', '');

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
