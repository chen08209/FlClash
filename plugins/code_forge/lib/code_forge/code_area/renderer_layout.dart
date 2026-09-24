part of '../code_area.dart';

extension _RendererLayout on _CodeFieldRenderer {
  ViewLineLayout get _lines {
    _ensureFoldedLineCacheValid();
    return _layout;
  }

  double _lineTop(int line) => _lines.lineTop(line);

  int _lineAtY(double y) => _lines.lineAt(y);

  double _lineExtent(int line) {
    final lines = _lines;
    if (lineWrap && !lines.isMeasured(line)) _measureWrappedLine(line);
    return lines.lineHeight(line);
  }

  void _measureWrappedLine(int line) => _recordRows(line, _paragraphFor(line));

  void _recordRows(int line, ui.Paragraph para) {
    if (!lineWrap) return;
    final rows = max(1, (para.height / _lineHeight).round());
    if (!_lines.setRows(line, rows)) return;
    _caretInfoCache.clear();
    if (_extentUpdateScheduled) return;
    _extentUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extentUpdateScheduled = false;
      if (attached) markNeedsLayout();
    });
  }

  void _estimateWrappedRows() {
    if (!_wrappedRowEstimateStale || !_wrapWidth.isFinite) return;
    _wrappedRowEstimateStale = false;
    final lines = _lines;
    final lineCount = lines.lineCount;
    if (lineCount <= kExactWrappedHeightThreshold) {
      for (var i = 0; i < lineCount; i++) {
        if (!lines.isMeasured(i)) _measureWrappedLine(i);
      }
      return;
    }
    final step = max(1, lineCount ~/ kWrappedHeightSampleSize);
    var rows = 0.0;
    var sampled = 0;
    for (var i = 0; i < lineCount; i += step) {
      if (!lines.isMeasured(i)) _measureWrappedLine(i);
      rows += lines.rowsOf(i);
      sampled++;
    }
    lines.setEstimate(rows / sampled);
  }

  // Widget listeners on the controller run before the renderer's and can
  // read the layout while an edit is still pending, so either side may apply
  // it; the line count shows whether it already has.
  bool _spliceLayout(({int line, int removed, int inserted}) edit) {
    if (_layout.lineCount - edit.removed + edit.inserted !=
        controller.lineCount) {
      return false;
    }
    _layout.splice(edit.line, edit.removed + 1, edit.inserted + 1);
    return true;
  }

  void _resetLineLayout() {
    _layout
      ..rowHeight = _lineHeight
      ..setEstimate(1)
      ..invalidateAll();
    _wrappedRowEstimateStale = true;
    _caretInfoCache.clear();
  }

  void _invalidateFrom(int line) {
    if (line <= 0) return _invalidateAll();
    bool stale(int key, Object? _) => key >= line;
    _paragraphCache.removeWhere(stale);
    _lineTextCache.removeWhere(stale);
    _lineWidthCache.removeWhere(stale);
    _indentGuideCache.removeWhere(stale);
    _lineIndentCache.removeWhere(stale);
    _bracketCache.clear();
    _invalidateCaret();
  }

  /// [layout] also drops the measured wrapped rows and the widest line.
  void _invalidateAll({bool layout = false}) {
    _paragraphCache.clear();
    _lineTextCache.clear();
    _lineWidthCache.clear();
    _indentGuideCache.clear();
    _lineIndentCache.clear();
    _bracketCache.clear();
    _invalidateCaret();
    if (!layout) return;
    _resetLineLayout();
    _longLineWidth = 0.0;
  }

  void _invalidateCaret() {
    _caretInfoCache.clear();
    _cachedCaretOffset = -1;
  }

  void _rebuildHighlighter({bool layout = false}) {
    _syntaxHighlighter.dispose();
    _syntaxHighlighter = SyntaxHighlighter(
      language: language,
      editorTheme: editorTheme,
      baseTextStyle: textStyle,
    );
    _invalidateAll(layout: layout);
    markNeedsLayout();
    markNeedsPaint();
  }

  void _applyTextStyle() {
    final fontSize = _textStyle?.fontSize ?? 14.0;
    final lineHeightMultiplier = _textStyle?.height ?? 1.2;
    _lineHeight = fontSize * lineHeightMultiplier;
    _gutterPadding = fontSize;
    _paragraphStyle = _buildParagraphStyle(
      _textStyle?.fontFamily,
      fontSize,
      lineHeightMultiplier,
    );
    _applyColors();
  }

  void _applyColors() {
    final color =
        _textStyle?.color ?? _editorTheme['root']?.color ?? Colors.black;
    _uiTextStyle = ui.TextStyle(
      color: color,
      fontSize: _textStyle?.fontSize ?? 14.0,
      fontFamily: _textStyle?.fontFamily,
    );
    _caretPainter.color = _selectionStyle.cursorColor ?? color;
  }

  // Forcing the strut keeps every row exactly _lineHeight tall, even where a
  // fallback font would grow it, so a line's height is its row count times
  // _lineHeight.
  ui.ParagraphStyle _buildParagraphStyle(
    String? fontFamily,
    double fontSize,
    double lineHeightMultiplier,
  ) {
    return ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeightMultiplier,
      textDirection: TextDirection.ltr,
      textAlign: ui.TextAlign.start,
      strutStyle: ui.StrutStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: lineHeightMultiplier,
        forceStrutHeight: true,
      ),
    );
  }

  ui.Paragraph _buildParagraph(String text, {double? width}) {
    final builder = ui.ParagraphBuilder(_paragraphStyle)
      ..pushStyle(_uiTextStyle)
      ..addText(text.isEmpty ? ' ' : text);
    final p = builder.build();
    p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
    return p;
  }

  String _lineText(int line) {
    if (controller.isBufferActive && line == controller.bufferLineIndex) {
      return controller.bufferLineText!;
    }
    return _lineTextCache[line] ??= controller.getLineText(line);
  }

  // A wrapped line's row count must not change when highlighting lands late.
  ui.Paragraph _paragraphFor(int line) {
    final text = _lineText(line);
    final cached = _paragraphCache[line];
    final synchronous = lineWrap || line == controller.bufferLineIndex;
    final highlighted =
        synchronous || _syntaxHighlighter.hasCachedLineSpan(line, text);
    if (cached != null &&
        cached.text == text &&
        (cached.highlighted || !highlighted)) {
      return cached.paragraph;
    }
    final paragraph = _syntaxHighlighter.buildHighlightedParagraph(
      line,
      text,
      _paragraphStyle,
      textStyle?.fontSize ?? 14.0,
      textStyle?.fontFamily,
      width: lineWrap ? _wrapWidth : null,
      allowSynchronousHighlight: synchronous,
    );
    _paragraphCache[line] = (
      text: text,
      paragraph: paragraph,
      highlighted: highlighted,
    );
    _recordRows(line, paragraph);
    return paragraph;
  }

  ({int lineIndex, int columnIndex, Offset offset, double height})
  _getCaretInfo() {
    final cursorOffset = controller.selection.extentOffset;

    final lineCount = controller.lineCount;
    if (lineCount == 0) {
      final result = (
        lineIndex: 0,
        columnIndex: 0,
        offset: Offset.zero,
        height: _lineHeight,
      );
      _caretInfoCache[cursorOffset] = result;
      return result;
    }

    if (_caretInfoCache.containsKey(cursorOffset)) {
      return _caretInfoCache[cursorOffset]!;
    }

    int lineIndex;
    int lineStartOffset;
    if (cursorOffset == _cachedCaretOffset) {
      lineIndex = _cachedCaretLine;
      lineStartOffset = _cachedCaretLineStart;
    } else {
      lineIndex = controller.getLineAtOffset(cursorOffset);
      lineStartOffset = controller.getLineStartOffset(lineIndex);
      _cachedCaretOffset = cursorOffset;
      _cachedCaretLine = lineIndex;
      _cachedCaretLineStart = lineStartOffset;
    }

    final columnIndex = cursorOffset - lineStartOffset;
    final lineY = _lineTop(lineIndex);
    final lineText = _lineText(lineIndex);
    final para = _paragraphFor(lineIndex);

    final utf16Col = lineText.toUtf16Offset(columnIndex);
    final clampedCol = utf16Col.clamp(0, lineText.length);
    double caretX = 0.0, caretYInLine = 0.0;

    if (lineText.isEmpty) {
      caretX = 0;
    } else if (clampedCol > 0) {
      final boxes = para.getBoxesForRange(0, clampedCol);
      if (boxes.isNotEmpty) {
        final lastBox = boxes.last;
        caretX = lastBox.right;
        caretYInLine = _rowTopForBox(lastBox);
      } else {
        final fallback = para.getBoxesForRange(0, 1);
        if (fallback.isNotEmpty) {
          caretX = fallback.first.right;
          caretYInLine = _rowTopForBox(fallback.first);
        }
      }
    }

    final result = (
      lineIndex: lineIndex,
      columnIndex: columnIndex,
      offset: Offset(caretX, lineY + caretYInLine),
      height: _lineHeight,
    );
    _caretInfoCache[cursorOffset] = result;
    return result;
  }

  int _getTextOffsetFromPosition(Offset position) {
    final lineCount = controller.lineCount;
    if (lineCount == 0) return 0;

    final tappedLineIndex = _lineAtY(position.dy);
    final lineText = _lineText(tappedLineIndex);
    final para = _paragraphFor(tappedLineIndex);

    final double localX = position.dx;

    final localY = position.dy - _lineTop(tappedLineIndex);

    final textPosition = para.getPositionForOffset(
      Offset(localX, localY.clamp(0, para.height)),
    );
    final utf16Column = textPosition.offset.clamp(0, lineText.length);
    final scalarColumn = lineText.toScalarOffset(utf16Column);

    final lineStartOffset = controller.getLineStartOffset(tappedLineIndex);
    final absoluteOffset = lineStartOffset + scalarColumn;

    return absoluteOffset.clamp(0, controller.length);
  }

  double get _handleRadius => (_lineHeight / 2).clamp(6.0, 12.0);

  double get _handleSize => _handleRadius * 2 * 1.2;

  bool _hitsCaretHandle(Offset local) =>
      _normalHandle?.inflate(_handleRadius * 1.5).contains(local) ?? false;

  Offset _toContent(Offset local) => Offset(
    local.dx - _textLeft,
    local.dy - (innerPadding?.top ?? 0) + vscrollController.offset,
  );

  FoldRange? _foldIconAt(Offset local, int line) {
    if (local.dx < _gutterWidth - _foldIconStripWidth) return null;
    final fold = _getFoldRangeAtLine(line);
    return fold != null && fold.endIndex > fold.startIndex ? fold : null;
  }

  // A folded block is selected whole, as it shows as a single line.
  ({int start, int end}) _gutterLineRange(int line) {
    final fold = _getFoldRangeAtLine(line);
    final last = fold != null && fold.isFolded ? fold.endIndex : line;
    return (
      start: controller.getLineStartOffset(line),
      end: last + 1 < controller.lineCount
          ? controller.getLineStartOffset(last + 1)
          : controller.length,
    );
  }

  void _selectLinesFromGutter(int line) {
    final base = controller.selection.baseOffset;
    _gutterSelectionAnchor =
        !isMobile && HardwareKeyboard.instance.isShiftPressed
        ? (start: base, end: base)
        : _gutterLineRange(line);
    _extendGutterSelection(line);
    if (isMobile) _selectionActive = selectionActiveNotifier.value = true;
  }

  void _extendGutterSelection(int line) {
    final anchor = _gutterSelectionAnchor!;
    final range = _gutterLineRange(line);
    controller.selection = range.start < anchor.start
        ? TextSelection(baseOffset: anchor.end, extentOffset: range.start)
        : TextSelection(baseOffset: anchor.start, extentOffset: range.end);
  }

  Offset getCaretOffset() => _getCaretInfo().offset;

  int getScrollbarLineNumberAtScrollOffset(double scrollOffset) {
    if (!vscrollController.hasClients || controller.lineCount == 0) {
      return 1;
    }

    final lineIndex = _lineAtY(scrollOffset).clamp(0, controller.lineCount - 1);
    return lineIndex + 1;
  }

  double _getLineWidth(int lineIndex) =>
      _lineWidthCache[lineIndex] ??= _buildParagraph(_lineText(lineIndex))
          .maxIntrinsicWidth;

  void _updateLongLineWidth(int lineCount) {
    if (_longLineWidth != 0 || lineCount == 0) return;
    final viewTop = vscrollController.hasClients
        ? vscrollController.offset
        : 0.0;
    final viewBottom =
        viewTop +
        (vscrollController.hasClients
            ? vscrollController.position.viewportDimension
            : constraints.minHeight);
    const buffer = 50;
    final start = max(0, _lineAtY(viewTop) - buffer);
    final end = min(lineCount - 1, _lineAtY(viewBottom) + buffer);
    for (int i = start; i <= end; i++) {
      final width = _getLineWidth(i);
      if (width > _longLineWidth) _longLineWidth = width;
    }
  }

  double _rowTopForBox(ui.TextBox box) {
    final center = (box.top + box.bottom) / 2.0;
    final rowIndex = (center / _lineHeight).floor();
    return (rowIndex < 0 ? 0 : rowIndex) * _lineHeight;
  }

  // Lines scrolled into the top padding stay visible, so a toolbar floating
  // over the editor shows the text passing beneath it.
  double get _paintViewTop =>
      max(0.0, vscrollController.offset - (innerPadding?.top ?? 0));

  // The visible lines intersecting [viewTop, viewBottom), measured, in order;
  // a folded run is stepped over rather than walked.
  List<int> _collectPaintLines(double viewTop, double viewBottom) {
    final lines = _lines;
    final lineCount = lines.lineCount;
    if (lineCount == 0) return const [0];
    final result = <int>[];
    var line = lines.lineAt(viewTop);
    while (true) {
      final height = _lineExtent(line);
      result.add(line);
      if (lines.lineTop(line) + height >= viewBottom) break;
      final next = lines.nextVisible(line + 1);
      if (next <= line) break;
      line = next;
    }
    return result;
  }

  void _pruneViewportCaches(int firstVisibleLine, int lastVisibleLine) {
    const int keepMargin = 400;
    const int maxLineBoundedCacheEntries = 3000;

    final minKeep = max(0, firstVisibleLine - keepMargin);
    final maxKeep = min(controller.lineCount - 1, lastVisibleLine + keepMargin);

    bool shouldPrune(Map<int, dynamic> cache) {
      return cache.length > maxLineBoundedCacheEntries;
    }

    void pruneIntKeyed(Map<int, dynamic> cache) {
      if (!shouldPrune(cache)) return;
      cache.removeWhere((line, _) => line < minKeep || line > maxKeep);
    }

    pruneIntKeyed(_lineTextCache);
    pruneIntKeyed(_lineWidthCache);
    pruneIntKeyed(_paragraphCache);
    pruneIntKeyed(_lineIndentCache);
    for (final offsetKeyed in [_bracketCache, _caretInfoCache]) {
      if (shouldPrune(offsetKeyed)) offsetKeyed.clear();
    }

    if (_indentGuideCache.length > maxLineBoundedCacheEntries) {
      _indentGuideCache.removeWhere(
        (line, _) => line < minKeep || line > maxKeep,
      );
    }
  }
}
