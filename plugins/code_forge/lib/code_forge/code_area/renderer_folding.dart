part of '../code_area.dart';

extension _RendererFolding on _CodeFieldRenderer {
  void _invalidateFoldRanges() {
    _foldRanges.clear();
    _foldedLineCacheDirty = true;
    if (controller.lineCount > 10000) {
      _scheduleAsyncFoldComputation();
    }
  }

  // A fold the edit touches is dropped rather than guessed at: a stale range
  // would hide lines that no longer belong to it.
  void _applyLineEditToFolds(({int line, int removed, int inserted}) edit) {
    if (edit.removed == 0 && edit.inserted == 0) {
      return _refreshFoldAt(edit.line);
    }
    final last = edit.line + edit.removed;
    final delta = edit.inserted - edit.removed;
    final kept = Map<FoldRange, FoldRange>.identity();
    for (final fold in _foldRanges.values.nonNulls) {
      final start = fold.startIndex, end = fold.endIndex;
      if (end < edit.line) {
        kept[fold] = fold;
      } else if (start > last) {
        kept[fold] = fold._moved(start + delta, end + delta);
      } else if (start < edit.line && end > last) {
        kept[fold] = fold._moved(start, end + delta);
      }
    }
    for (final fold in kept.values) {
      fold.originallyFoldedChildren = [
        for (final child in fold.originallyFoldedChildren) ?kept[child],
      ];
    }
    _foldRanges
      ..clear()
      ..addAll({for (final fold in kept.values) fold.startIndex: fold});
    _commitFoldChange();
  }

  void _refreshFoldAt(int line) {
    final fold = _foldRanges[line];
    if (fold != null && fold.isFolded && _opensBlock(_lineText(line))) return;
    _foldRanges.remove(line);
    if (fold != null) {
      _commitFoldChange();
    } else {
      _foldedLineCacheDirty = true;
    }
  }

  bool _opensBlock(String line) {
    if (line.trimRight().endsWith(':')) return true;
    if (_extractOpeningTagName(line) != null) return true;
    var depth = 0;
    for (final unit in line.codeUnits) {
      switch (unit) {
        case 0x7B || 0x5B || 0x28:
          depth++;
        case 0x7D || 0x5D || 0x29 when depth > 0:
          depth--;
      }
    }
    return depth > 0;
  }

  void _rebuildFoldedLineCache() {
    if (_layout.lineCount != controller.lineCount) {
      final edit = controller.lineEdit;
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

      for (final rustFold in computed) {
        final startLine = rustFold.startLine.toInt();
        final endLine = rustFold.endLine.toInt();
        if (_foldRanges[startLine] == null) {
          final existing = controller.foldings[startLine];
          final fold = FoldRange(startLine, endLine);
          if (existing != null && existing.isFolded) {
            fold.isFolded = true;
            fold.originallyFoldedChildren = existing.originallyFoldedChildren;
          }
          _foldRanges[startLine] = fold;
        }
      }
      _asyncFoldComputationPending = false;
      _asyncFoldsVersion = version;
      markNeedsPaint();
    } catch (e) {
      _asyncFoldComputationPending = false;
      debugPrint('Error computing folds in isolate: $e');
    }
  }

  FoldRange? _computeFoldRangeForLine(int lineIndex) {
    const openers = {'{', '[', '('};
    const closerToOpener = {'}': '{', ']': '[', ')': '('};

    final line = controller.getLineText(lineIndex);

    if (!openers.any(line.contains) && !line.trim().endsWith(':')) {
      return null;
    }

    final Map<String, List<int>> stacks = {'{': [], '[': [], '(': []};
    bool foundForLineIndex = false;

    final maxScan = controller.lineCount <= 10000
        ? controller.lineCount
        : min(lineIndex + 10000, controller.lineCount);
    for (int i = lineIndex; i < maxScan; i++) {
      final checkLine = controller.getLineText(i);
      for (int c = 0; c < checkLine.length; c++) {
        final ch = checkLine[c];
        if (openers.contains(ch)) {
          stacks[ch]!.add(i);
        } else if (closerToOpener.containsKey(ch)) {
          final opener = closerToOpener[ch]!;
          final stack = stacks[opener]!;
          if (stack.isNotEmpty) {
            final start = stack.removeLast();
            final end = i;
            if (end > start) {
              _foldRanges.putIfAbsent(start, () => FoldRange(start, end));
              if (start == lineIndex) {
                foundForLineIndex = true;
              }
            }
          }
        }
      }

      if (!stacks.values.any((s) => s.contains(lineIndex))) {
        if (foundForLineIndex) return _foldRanges[lineIndex];
        break;
      }
    }

    if (_foldRanges.containsKey(lineIndex)) {
      final cachedFold = _foldRanges[lineIndex];
      if (cachedFold != null && line.trim().endsWith(':')) {
        final exactFold = _computeIndentFoldRangeForLine(lineIndex, line);
        if (exactFold != null && exactFold.endIndex < cachedFold.endIndex) {
          _foldRanges[lineIndex] = exactFold;
          return exactFold;
        }
      }
      return _foldRanges[lineIndex];
    }

    final colonFold = _computeIndentFoldRangeForLine(lineIndex, line);
    if (colonFold != null) {
      return colonFold;
    }

    final openingTagName = _extractOpeningTagName(line);
    if (openingTagName != null) {
      final matchLine = _findMatchingClosingTagLine(openingTagName, lineIndex);
      if (matchLine != null && matchLine > lineIndex) {
        return FoldRange(lineIndex, matchLine);
      }
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

  FoldRange? _computeIndentFoldRangeForLine(int lineIndex, String line) {
    if (!line.trim().endsWith(':')) return null;

    final startIndent = _measureLeadingIndentColumns(line);
    int endLine = lineIndex;

    final maxIndentScan = min(lineIndex + 5000, controller.lineCount);
    for (int j = lineIndex + 1; j < maxIndentScan; j++) {
      final next = controller.getLineText(j);
      if (next.trim().isEmpty) continue;
      final nextIndent = _measureLeadingIndentColumns(next);

      if (nextIndent < startIndent) {
        break;
      }

      if (nextIndent == startIndent) {
        break;
      }
      endLine = j;
    }

    if (endLine > lineIndex) {
      final fold = FoldRange(lineIndex, endLine);
      _foldRanges[lineIndex] = fold;
      return fold;
    }

    return null;
  }

  FoldRange? _getOrComputeFoldRange(int lineIndex) {
    if (_foldRanges.containsKey(lineIndex)) {
      return _foldRanges[lineIndex];
    }

    if (controller.lineCount <= 10000) {
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

  void _toggleFold(FoldRange fold) {
    try {
      _isFoldToggleInProgress = true;
      if (fold.isFolded) {
        _unfoldWithChildren(fold);
      } else {
        _foldWithChildren(fold);
      }

      _commitFoldChange();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isFoldToggleInProgress = false;
        _clampScrollAfterFold();
      });
    } catch (e) {
      debugPrint('Error toggling fold: $e');
      _isFoldToggleInProgress = false;
    }
  }

  void _commitFoldChange() {
    controller.foldings = {
      for (final fold in _foldRanges.values.nonNulls) fold.startIndex: fold,
    };
    _foldedLineCacheDirty = true;
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
    parentFold.clearOriginallyFoldedChildren();

    for (final childFold in _foldRanges.values.where((f) => f != null)) {
      if (childFold!.isFolded &&
          childFold != parentFold &&
          childFold.startIndex > parentFold.startIndex &&
          childFold.endIndex <= parentFold.endIndex) {
        parentFold.addOriginallyFoldedChild(childFold);
        childFold.isFolded = false;
      }
    }

    parentFold.isFolded = true;
  }

  void _unfoldWithChildren(FoldRange parentFold) {
    parentFold.isFolded = false;
    for (final childFold in parentFold.originallyFoldedChildren) {
      if (childFold.startIndex > parentFold.startIndex &&
          childFold.endIndex <= parentFold.endIndex) {
        childFold.isFolded = true;
      }
    }
    parentFold.clearOriginallyFoldedChildren();
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

  String? _extractOpeningTagName(String lineText) {
    final trimmed = lineText.trimRight();
    final openTagMatch = RegExp(r'<([A-Za-z][A-Za-z0-9:_-]*)(?:\s[^>]*)?>$')
        .firstMatch(trimmed);
    if (openTagMatch != null) {
      final tagName = openTagMatch.group(1);
      if (!trimmed.endsWith('/>') && !trimmed.endsWith('-->')) {
        return tagName;
      }
    }
    return null;
  }

  int? _findMatchingClosingTagLine(String tagName, int startLine) {
    final closeTagPattern = RegExp(r'</' + RegExp.escape(tagName) + r'\s*>');
    int depth = 1;

    final maxScan = controller.lineCount <= 10000
        ? controller.lineCount
        : min(startLine + 10000, controller.lineCount);
    for (int i = startLine + 1; i < maxScan; i++) {
      final lineText = _lineText(i);

      final openMatches = RegExp(
        r'<' + RegExp.escape(tagName) + r'(?:\s[^>]*)?>',
      ).allMatches(lineText);
      for (final match in openMatches) {
        final fullMatch = match.group(0)!;
        if (!fullMatch.endsWith('/>')) {
          depth++;
        }
      }

      final closeMatches = closeTagPattern.allMatches(lineText);
      for (final _ in closeMatches) {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }

    return null;
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
