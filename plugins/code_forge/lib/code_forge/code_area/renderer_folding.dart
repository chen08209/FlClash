part of '../code_area.dart';

// Up to this many lines, a line's fold is found as it is painted; a longer
// document is folded in one pass off the UI isolate.
const _perLineFoldLimit = 10000;

extension _RendererFolding on _CodeFieldRenderer {
  bool get _foldsInBackground => controller.lineCount > _perLineFoldLimit;

  void _adoptControllerFolds() {
    _foldRanges.addAll({
      for (final fold in controller.foldings.values.nonNulls)
        if (fold.isFolded &&
            fold.endIndex < controller.lineCount &&
            _stillFolds(fold))
          fold.startIndex: fold,
    });
    controller.foldings = Map.of(_foldRanges);
  }

  void _invalidateFoldRanges() {
    _foldRanges.clear();
    _foldedLineCacheDirty = true;
    if (_foldsInBackground) _scheduleAsyncFoldComputation();
  }

  // A folded range, or one it remembers, is kept only while the text still
  // gives it: a stale one would hide lines that no longer belong to it.
  void _applyLineEditToFolds(({int line, int removed, int inserted}) edit) {
    final withinLine = edit.removed == 0 && edit.inserted == 0;
    if (withinLine && _foldsInBackground) {
      if (_foldRanges[edit.line]?.isFolded == false) {
        _foldRanges.remove(edit.line);
      }
      _foldedLineCacheDirty = true;
      if (!_asyncFoldComputationPending) _scheduleAsyncFoldComputation();
      return;
    }
    final last = edit.line + edit.removed;
    final delta = edit.inserted - edit.removed;
    final remembered = _rememberedFolds();
    final folds = Set<FoldRange>.identity()
      ..addAll(_foldRanges.values.nonNulls)
      ..addAll(remembered);
    final kept = Map<FoldRange, FoldRange>.identity();
    for (final fold in folds) {
      final start = fold.startIndex, end = fold.endIndex;
      final FoldRange? after;
      if (end < edit.line) {
        after = _lengthenedBy(fold, edit.line) ? null : fold;
      } else if (start > last) {
        after = fold._moved(start + delta, end + delta);
      } else if (fold.isFolded || remembered.contains(fold)) {
        after = _touchedFoldAfter(fold, edit);
      } else {
        after = _touchedCachedFoldAfter(fold, edit);
      }
      if (after != null) kept[fold] = after;
    }
    final unfolds = folds.any(
      (fold) => fold.isFolded && !kept.containsKey(fold),
    );
    if (!withinLine) {
      _foldRanges
        ..clear()
        ..addAll({for (final fold in kept.values) fold.startIndex: fold});
    } else {
      _foldRanges.removeWhere(
        (line, fold) =>
            fold == null ? line <= edit.line : !kept.containsKey(fold),
      );
    }
    _passOnRememberedFolds(folds, (fold) => kept[fold]);
    if (!withinLine || unfolds) {
      _commitFoldChange();
    } else {
      _foldedLineCacheDirty = true;
    }
    if (_foldsInBackground && !_asyncFoldComputationPending) {
      _scheduleAsyncFoldComputation();
    }
  }

  Set<FoldRange> _rememberedFolds() {
    final remembered = Set<FoldRange>.identity();
    void collect(FoldRange fold) {
      for (final child in fold.originallyFoldedChildren) {
        if (remembered.add(child)) collect(child);
      }
    }

    _foldRanges.values.nonNulls.forEach(collect);
    return remembered;
  }

  /// Hands what [folds] remember on to what [after] makes of them, and folds
  /// what a folded one that went had remembered.
  void _passOnRememberedFolds(
    Iterable<FoldRange> folds,
    FoldRange? Function(FoldRange fold) after,
  ) {
    Iterable<FoldRange> survivors(FoldRange fold) sync* {
      for (final child in fold.originallyFoldedChildren) {
        final kept = after(child);
        if (kept != null) {
          yield kept;
        } else {
          yield* survivors(child);
        }
      }
    }

    final remembered = [
      for (final fold in folds) (fold, survivors(fold).toList()),
    ];
    for (final (fold, children) in remembered) {
      final kept = after(fold);
      if (kept != null) {
        kept.originallyFoldedChildren = children;
      } else if (fold.isFolded) {
        for (final child in children.where(_stillFolds)) {
          _foldRanges[child.startIndex] = child..isFolded = true;
        }
      }
    }
  }

  bool _lengthenedBy(FoldRange fold, int editedLine) {
    if (!fold.isFolded || _foldsInBackground) return false;
    for (var line = fold.endIndex + 1; line < editedLine; line++) {
      if (controller.getLineText(line).trim().isNotEmpty) return false;
    }
    return !_stillFolds(fold);
  }

  FoldRange? _touchedCachedFoldAfter(
    FoldRange fold,
    ({int line, int removed, int inserted}) edit,
  ) {
    final start = fold.startIndex, end = fold.endIndex;
    final withinLine = edit.removed == 0 && edit.inserted == 0;
    final holdsEdit = withinLine || end > edit.line + edit.removed;
    if (start >= edit.line || !holdsEdit) return null;
    if (!_foldsInBackground) _scheduleFoldCacheRecheck();
    return fold._moved(start, end + edit.inserted - edit.removed);
  }

  void _scheduleFoldCacheRecheck() {
    _foldCacheRecheckTimer?.cancel();
    _foldCacheRecheckTimer = Timer(const Duration(milliseconds: 300), () {
      _foldRanges.removeWhere((_, fold) => fold != null && !fold.isFolded);
      markNeedsPaint();
    });
  }

  FoldRange? _touchedFoldAfter(
    FoldRange fold,
    ({int line, int removed, int inserted}) edit,
  ) {
    final start = fold.startIndex, end = fold.endIndex;
    final delta = edit.inserted - edit.removed;
    final withinLine = delta == 0 && edit.removed == 0;
    if (start < edit.line || withinLine) {
      final grown = fold._moved(start, end + delta);
      if (_foldsInBackground) {
        return withinLine || end > edit.line + edit.removed ? grown : null;
      }
      return _foldsAt(grown) ? grown : null;
    }
    // The edit names the lines that changed, not where in them: only a fold
    // heading the first or the last has a place the text can confirm.
    final places = [
      if (delta == 0 || start == edit.line) fold,
      if (delta != 0 && start == edit.line + edit.removed)
        fold._moved(start + delta, end + delta),
    ].where(_foldsAt).toList();
    return places.length == 1 ? places.single : null;
  }

  bool _foldsAt(FoldRange range) =>
      range.endIndex > range.startIndex &&
      range.startIndex < controller.lineCount &&
      _computeFoldRangeForLine(range.startIndex) == range;

  // Past the per-line limit, the whole-document pass decides once it lands.
  bool _stillFolds(FoldRange fold) => _foldsInBackground || _foldsAt(fold);

  void _rebuildFoldedLineCache() {
    if (_layout.lineCount != controller.lineCount) {
      final edit = controller.pendingLineEdit;
      if (edit == null || !_spliceLayout(edit)) {
        _layout.reset(controller.lineCount);
        _wrappedRowEstimateStale = true;
      }
    }
    final hidden = <({int start, int end})>[];
    for (final fold in _foldRanges.values) {
      if (fold != null && fold.isFolded) {
        hidden.add((start: fold.startIndex + 1, end: fold.endIndex + 1));
      }
    }
    _hasActiveFoldsCache = hidden.isNotEmpty;
    _layout.setHiddenRanges(hidden);
    _caretInfoCache.clear();
    _foldedLineCacheDirty = false;
  }

  void _ensureFoldedLineCacheValid() {
    if (_foldedLineCacheDirty || _layout.lineCount != controller.lineCount) {
      _rebuildFoldedLineCache();
    }
  }

  bool get _hasActiveFolds {
    _ensureFoldedLineCacheValid();
    return _hasActiveFoldsCache;
  }

  void _scheduleAsyncFoldComputation() {
    _foldComputeTimer?.cancel();
    _foldComputeTimer = Timer(const Duration(milliseconds: 300), () {
      _runAsyncFoldComputation();
    });
  }

  Future<void> _runAsyncFoldComputation() async {
    // Buffered typing is in the version before it is in the rope read here.
    if (controller.isBufferActive) {
      _scheduleAsyncFoldComputation();
      return;
    }
    _asyncFoldComputationPending = true;
    final version = controller.contentVersion;

    try {
      final computed = await foldsComputeAll(
        rope: controller.rope.core,
        tabSize: BigInt.from(controller.tabSize),
      );
      if (!attached) {
        _asyncFoldComputationPending = false;
        return;
      }
      if (controller.contentVersion != version) {
        _asyncFoldComputationPending = false;
        _scheduleAsyncFoldComputation();
        return;
      }

      final folds = {
        for (final fold in computed)
          fold.startLine: FoldRange(fold.startLine, fold.endLine),
      };
      final before = Set<FoldRange>.identity()
        ..addAll(_foldRanges.values.nonNulls)
        ..addAll(_rememberedFolds());
      for (final fold in before) {
        if (folds[fold.startIndex] == fold) folds[fold.startIndex] = fold;
      }
      bool survives(FoldRange fold) => identical(folds[fold.startIndex], fold);
      final unfolds = before.any((fold) => fold.isFolded && !survives(fold));
      _foldRanges
        ..clear()
        ..addAll(folds);
      _passOnRememberedFolds(before, (fold) => survives(fold) ? fold : null);
      _asyncFoldComputationPending = false;
      _asyncFoldsVersion = version;
      if (unfolds) {
        _commitFoldChange();
      } else {
        markNeedsPaint();
      }
    } catch (e) {
      _asyncFoldComputationPending = false;
      debugPrint('Error computing folds in isolate: $e');
    }
  }

  // Kept in step with `compute_all` in rust_api's editor/folds.rs.
  FoldRange? _computeFoldRangeForLine(int lineIndex) {
    final line = controller.getLineText(lineIndex);
    final bracketEnd = _bracketFoldEnd(lineIndex);
    final indentEnd = line.trimRight().endsWith(':')
        ? _indentFoldEnd(lineIndex, line)
        : null;
    final end = bracketEnd == null || indentEnd == null
        ? bracketEnd ?? indentEnd
        : min(bracketEnd, indentEnd);
    return end == null ? null : FoldRange(lineIndex, end);
  }

  int? _bracketFoldEnd(int lineIndex) {
    final own = [0, 0, 0], nested = [0, 0, 0];
    for (var i = lineIndex; i < controller.lineCount; i++) {
      for (final unit in controller.getLineText(i).codeUnits) {
        final kind = switch (unit) {
          0x7B || 0x7D => 0,
          0x5B || 0x5D => 1,
          0x28 || 0x29 => 2,
          _ => null,
        };
        if (kind == null) continue;
        if (unit == 0x7B || unit == 0x5B || unit == 0x28) {
          (i == lineIndex ? own : nested)[kind]++;
        } else if (nested[kind] > 0) {
          nested[kind]--;
        } else if (own[kind] > 0) {
          if (i > lineIndex) return i;
          own[kind]--;
        }
      }
      if (own.every((count) => count == 0)) return null;
    }
    return null;
  }

  int _measureLeadingIndentColumns(String lineText) {
    final tabSize = controller.tabSize;
    int columns = 0;

    for (int i = 0; i < lineText.length; i++) {
      final ch = lineText[i];
      if (ch == ' ') {
        columns += 1;
      } else if (ch == '\t') {
        final nextStop = tabSize <= 0
            ? columns + 1
            : columns + (tabSize - (columns % tabSize));
        columns = nextStop;
      } else {
        break;
      }
    }

    return columns;
  }

  int? _indentFoldEnd(int lineIndex, String line) {
    final startIndent = _measureLeadingIndentColumns(line);
    var endLine = lineIndex;
    for (var j = lineIndex + 1; j < controller.lineCount; j++) {
      final next = controller.getLineText(j);
      if (next.trim().isEmpty) continue;
      if (_measureLeadingIndentColumns(next) <= startIndent) break;
      endLine = j;
    }
    return endLine > lineIndex ? endLine : null;
  }

  FoldRange? _getOrComputeFoldRange(int lineIndex) {
    if (_foldRanges.containsKey(lineIndex)) {
      return _foldRanges[lineIndex];
    }

    if (!_foldsInBackground) {
      final fold = _computeFoldRangeForLine(lineIndex);
      _foldRanges[lineIndex] = fold;
      return fold;
    }

    // Lines the whole-document pass found no fold at stay absent from
    // _foldRanges, so only a newer document may schedule another pass.
    if (!_asyncFoldComputationPending &&
        _asyncFoldsVersion != controller.contentVersion) {
      _scheduleAsyncFoldComputation();
    }
    return null;
  }

  /// False when the text no longer gives [fold] a range to fold.
  bool _toggleFold(FoldRange fold) {
    final current = fold.isFolded ? fold : _currentFold(fold);
    if (current == null) {
      markNeedsPaint();
      return false;
    }
    _isFoldToggleInProgress = true;
    if (current.isFolded) {
      _unfoldWithChildren(current);
    } else {
      _foldWithChildren(current);
      _moveSelectionOutOf(current);
    }
    _commitFoldChange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isFoldToggleInProgress = false;
      _clampScrollAfterFold();
    });
    return true;
  }

  void _moveSelectionOutOf(FoldRange fold) {
    bool hides(int offset) {
      final line = controller.getLineAtOffset(offset);
      return line > fold.startIndex && line <= fold.endIndex;
    }

    final selection = controller.selection;
    if (!hides(selection.baseOffset) && !hides(selection.extentOffset)) return;
    controller.selection = TextSelection.collapsed(
      offset:
          controller.getLineStartOffset(fold.startIndex) +
          controller.getLineText(fold.startIndex).runes.length,
    );
  }

  bool _unfoldAround(int line) {
    FoldRange? hiding() => _foldRanges.values.nonNulls
        .where(
          (fold) =>
              fold.isFolded && line > fold.startIndex && line <= fold.endIndex,
        )
        .firstOrNull;
    var fold = hiding();
    if (fold == null) return false;
    for (; fold != null; fold = hiding()) {
      _unfoldWithChildren(fold);
    }
    _commitFoldChange();
    return true;
  }

  void _revealCaret() {
    final selection = controller.selection;
    if (!selection.isCollapsed) return;
    final line = controller.getLineAtOffset(selection.extentOffset);
    if (controller.isLineInFoldedRegion(line)) _unfoldAround(line);
  }

  // An edit inside an unfolded fold leaves its cached range as it was.
  FoldRange? _currentFold(FoldRange fold) {
    if (_foldsInBackground) return fold;
    final current = _computeFoldRangeForLine(fold.startIndex);
    if (current == fold) return fold;
    return _foldRanges[fold.startIndex] = current;
  }

  void _commitFoldChange() {
    controller.foldings = {
      for (final fold in _foldRanges.values.nonNulls) fold.startIndex: fold,
    };
    _foldedLineCacheDirty = true;
    _foldLayoutPending = true;
    _invalidateCaret();
    markNeedsLayout();
    markNeedsPaint();
  }

  void _toggleFoldAtLine(int lineNumber) {
    if (lineNumber < 0 || lineNumber >= controller.lineCount) return;

    final foldRange = _getFoldRangeAtLine(lineNumber);
    if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
      _toggleFold(foldRange);
    }
  }

  void _clampScrollAfterFold() {
    if (!vscrollController.hasClients) return;
    final maxExtent = vscrollController.position.maxScrollExtent;
    if (vscrollController.offset > maxExtent) {
      vscrollController.jumpTo(maxExtent.clamp(0.0, double.infinity));
    }
  }

  void _foldWithChildren(FoldRange parentFold) {
    parentFold.originallyFoldedChildren = [
      for (final childFold in _foldRanges.values.nonNulls)
        if (childFold.isFolded &&
            childFold != parentFold &&
            childFold.startIndex > parentFold.startIndex &&
            childFold.endIndex <= parentFold.endIndex)
          childFold..isFolded = false,
    ];
    parentFold.isFolded = true;
  }

  void _unfoldWithChildren(FoldRange parentFold) {
    parentFold.isFolded = false;
    for (final childFold in parentFold.originallyFoldedChildren) {
      if (childFold.startIndex > parentFold.startIndex &&
          childFold.endIndex <= parentFold.endIndex &&
          identical(_currentFold(childFold), childFold)) {
        _foldRanges[childFold.startIndex] = childFold..isFolded = true;
      }
    }
    parentFold.originallyFoldedChildren = [];
  }

  bool _isLineFolded(int lineIndex) => _lines.isHidden(lineIndex);

  int? _findMatchingBracket(int pos) {
    if (_bracketCache.containsKey(pos)) {
      return _bracketCache[pos];
    }

    if (pos < 0 || pos >= controller.rope.length) {
      _bracketCache[pos] = null;
      return null;
    }

    final result = foldsFindMatchingBracket(
      rope: controller.rope.core,
      targetOffset: BigInt.from(pos),
    )?.toInt();

    _bracketCache[pos] = result;
    return result;
  }

  FoldRange? _getFoldRangeAtLine(int lineIndex) =>
      _getOrComputeFoldRange(lineIndex);
}

extension on FoldRange {
  FoldRange _moved(int start, int end) => start == startIndex && end == endIndex
      ? this
      : (FoldRange(start, end)
          ..isFolded = isFolded
          ..originallyFoldedChildren = originallyFoldedChildren);
}
