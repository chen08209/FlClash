part of '../code_area.dart';

// As in VS Code, an unwrapped line is shown up to this many characters
// until a tap past them or a caret beyond them shows every line whole.
const _cutLength = 10000;

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

  void _measureWrappedLine(int line) =>
      _recordExtent(line, _paragraphFor(line));

  // Layout measures the widest line only near the viewport, so an unwrapped
  // line wider than that widens the content once it is painted.
  void _recordExtent(int line, ui.Paragraph para) {
    if (lineWrap) {
      final rows = max(1, (para.height / _lineHeight).round());
      if (!_lines.setRows(line, rows)) return;
      _caretInfoCache.clear();
    } else {
      final width = para.maxIntrinsicWidth + _cutMarkerWidth(line);
      if (width <= _longLineWidth) return;
      _longLineWidth = width;
    }
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

  // A paragraph is checked against its text before reuse, so it can follow
  // its line past the edit and a long line keeps its layout.
  void _invalidateFrom(({int line, int removed, int inserted}) edit) {
    final line = edit.line;
    final replacedEnd = line + edit.removed;
    final shift = edit.inserted - edit.removed;
    final moved =
        <int, ({String text, ui.Paragraph paragraph, bool highlighted})>{};
    _paragraphCache.removeWhere((key, paragraph) {
      if (key < line) return false;
      if (key > replacedEnd && shift == 0) return false;
      if (key > replacedEnd) moved[key + shift] = paragraph;
      return true;
    });
    _paragraphCache.addAll(moved);
    bool stale(int key, Object? _) => key >= line;
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
    _lineSlices.clear();
    _bufferLineCut = null;
    _cutMarker = _foldMarker = null;
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
      return _shownBufferLine(controller.bufferLineText!);
    }
    return _lineTextCache[line] ??= _fetchLineText(line);
  }

  bool get _cutsLongLines => !lineWrap && !_wholeLines;

  String _fetchLineText(int line) {
    if (!_cutsLongLines) return controller.getLineText(line);
    final rope = controller.rope;
    final start = rope.getLineStartOffset(line);
    if (_ropeLineEnd(line) - start <= _cutLength) {
      return controller.getLineText(line);
    }
    return rope.substring(start, start + _cutLength);
  }

  String _shownBufferLine(String text) {
    final cut = _bufferLineCut;
    if (cut != null && identical(cut.source, text)) return cut.shown;
    final end = _cutsLongLines ? text.toUtf16Offset(_cutLength) : text.length;
    final shown = end < text.length ? text.substring(0, end) : text;
    _bufferLineCut = (source: text, shown: shown);
    return shown;
  }

  int _ropeLineEnd(int line) {
    final rope = controller.rope;
    return line + 1 < rope.lineCount
        ? rope.getLineStartOffset(line + 1) - 1
        : rope.length;
  }

  bool _isCut(int line) {
    if (!_cutsLongLines) return false;
    final text = _lineText(line);
    if (text.length < _cutLength) return false;
    if (controller.isBufferActive && line == controller.bufferLineIndex) {
      return !identical(text, controller.bufferLineText);
    }
    return _ropeLineEnd(line) - controller.rope.getLineStartOffset(line) >
        _cutLength;
  }

  ui.Paragraph get _cutMarkerParagraph => _cutMarker ??= _buildParagraph(' …');

  ui.Paragraph get _foldMarkerParagraph =>
      _foldMarker ??= _buildParagraph(' ...');

  double _cutMarkerWidth(int line) =>
      _isCut(line) ? _cutMarkerParagraph.maxIntrinsicWidth : 0;

  bool _pastCut(Offset position) {
    if (!_cutsLongLines || controller.lineCount == 0) return false;
    final line = _lineAtY(position.dy);
    return _isCut(line) && position.dx > _paragraphFor(line).longestLine;
  }

  void _showWholeLinesPastCaret() {
    final selection = controller.selection;
    if (selection == _seenSelection) return;
    _seenSelection = selection;
    if (!_cutsLongLines || !selection.isCollapsed) return;
    final line = controller.getLineAtOffset(selection.extentOffset);
    if (!_isCut(line) ||
        selection.extentOffset - controller.getLineStartOffset(line) <=
            _cutLength) {
      return;
    }
    _showWholeLines();
    _getLineWidth(line);
    // The view can scroll to the caret only once layout has widened it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) _ensureCaretVisible();
    });
  }

  void _showWholeLines() {
    _wholeLines = true;
    _invalidateAll();
    markNeedsLayout();
    markNeedsPaint();
  }

  // A wrapped line's row count must not change when highlighting lands late.
  ui.Paragraph _paragraphFor(int line) {
    final text = _lineText(line);
    final cached = _paragraphCache[line];
    final synchronous = lineWrap || line == controller.bufferLineIndex;
    final highlighted = synchronous || _syntaxHighlighter.hasLineSpan(text);
    if (cached != null &&
        cached.text == text &&
        (cached.highlighted || !highlighted)) {
      return cached.paragraph;
    }
    final paragraph = _syntaxHighlighter.buildHighlightedParagraph(
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
    _recordExtent(line, paragraph);
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

    final utf16Col = lineText.toUtf16Offset(columnIndex);
    final clampedCol = utf16Col.clamp(0, lineText.length);
    double caretX = 0.0, caretYInLine = 0.0;

    if (lineText.isNotEmpty && clampedCol > 0) {
      final box =
          _boxBefore(lineIndex, lineText, clampedCol) ??
          _boxBefore(lineIndex, lineText, 1);
      if (box != null) {
        caretX = box.right;
        caretYInLine = _rowTopForBox(box);
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

  // A selection handle hangs this far outside the text position it marks.
  double get _handleOverhang => (textStyle?.fontSize ?? 14) / 2;

  // Only below the caret line, so a press on the text at the caret still
  // reaches the text.
  bool _hitsCaretHandle(Offset local) {
    final handle = _normalHandle;
    return handle != null &&
        local.dy >= handle.top &&
        handle.inflate(_handleRadius * 1.5).contains(local);
  }

  Offset _toContent(Offset local) => Offset(
    local.dx - _textLeft,
    local.dy - (innerPadding?.top ?? 0) + vscrollController.offset,
  );

  FoldRange? _foldIconAt(Offset local, int line) {
    if (local.dx < _gutterWidth - _foldIconStripWidth) return null;
    final fold = _getFoldRangeAtLine(line);
    return fold != null && fold.endIndex > fold.startIndex ? fold : null;
  }

  FoldRange? _foldMarkerAt(Offset local) {
    if (local.dx < _gutterWidth || controller.lineCount == 0) return null;
    final content = _toContent(local);
    final line = _lineAtY(content.dy);
    final fold = _getFoldRangeAtLine(line);
    if (fold == null || !fold.isFolded || fold.endIndex <= fold.startIndex) {
      return null;
    }
    final marker = _foldMarkerParagraph;
    var left = _paragraphFor(line).longestLine;
    if (_isCut(line)) left += _cutMarkerParagraph.longestLine;
    final top = _lineTop(line);
    return content.dx >= left &&
            content.dx <= left + marker.longestLine &&
            content.dy >= top &&
            content.dy <= top + marker.height
        ? fold
        : null;
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
    if (isMobile) _selectionActive = true;
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

  double _getLineWidth(int lineIndex) {
    final text = _lineText(lineIndex);
    return _lineWidthCache[lineIndex] ??=
        (SyntaxHighlighter.isPlain(text)
            ? _paragraphFor(lineIndex).maxIntrinsicWidth
            : _buildParagraph(text).maxIntrinsicWidth) +
        _cutMarkerWidth(lineIndex);
  }

  // Plain text looks the same from any cluster on, so a slice around the
  // view spares the engine every glyph of a megabyte line on each frame.
  void _drawLine(Canvas canvas, int line, ui.Paragraph paragraph, Offset at) {
    final slice = _sliceInView(line, _lineText(line), paragraph);
    if (slice == null) {
      canvas.drawParagraph(paragraph, at);
    } else {
      canvas.drawParagraph(slice.paragraph, at + slice.origin);
    }
  }

  _LineSlice? _sliceInView(int line, String text, ui.Paragraph paragraph) {
    if (!SyntaxHighlighter.isPlain(text)) return null;
    final view = Rect.fromLTWH(
      -_textLeft,
      _paintViewTop - _lineTop(line),
      hscrollController.position.viewportDimension,
      vscrollController.position.viewportDimension,
    );
    final old = _lineSlices[line];
    final reusable = old != null && old.text == text ? old : null;
    if (reusable != null &&
        reusable.cover.left <= view.left &&
        reusable.cover.right >= view.right &&
        reusable.cover.top <= view.top &&
        reusable.cover.bottom >= view.bottom) {
      return reusable;
    }
    final slice = lineWrap
        ? _sliceRows(text, paragraph, view, reusable)
        : _sliceColumns(text, paragraph, view, reusable);
    _lineSlices[line] = slice;
    return slice;
  }

  _LineSlice _sliceRows(
    String text,
    ui.Paragraph paragraph,
    Rect view,
    _LineSlice? old,
  ) {
    final rows = max(1, (paragraph.height / _lineHeight).round());
    final firstRow = max(0, ((view.top - view.height) / _lineHeight).floor());
    final lastRow = min(
      rows - 1,
      ((view.bottom + view.height) / _lineHeight).ceil(),
    );
    int rowStart(int row) =>
        paragraph
            .getClosestGlyphInfoForOffset(Offset(0, (row + 0.5) * _lineHeight))
            ?.graphemeClusterCodeUnitRange
            .start ??
        text.length;
    final start = firstRow == 0 ? 0 : rowStart(firstRow);
    final end = lastRow == rows - 1
        ? text.length
        : max(start, rowStart(lastRow + 1));
    return _slice(
      text,
      start,
      end,
      old,
      origin: Offset(0, firstRow * _lineHeight),
      cover: Rect.fromLTRB(
        double.negativeInfinity,
        firstRow == 0 ? double.negativeInfinity : firstRow * _lineHeight,
        double.infinity,
        lastRow == rows - 1 ? double.infinity : (lastRow + 1) * _lineHeight,
      ),
      width: _wrapWidth,
    );
  }

  // The previous slice places one edge without walking the whole line, and
  // the other edge is reached by laying out characters until they cover it.
  _LineSlice _sliceColumns(
    String text,
    ui.Paragraph paragraph,
    Rect view,
    _LineSlice? old,
  ) {
    final from = view.left - view.width;
    final to = view.right + view.width;
    final margin = 2 * (textStyle?.fontSize ?? 14.0);
    final oldRight = old == null
        ? 0.0
        : old.origin.dx + old.paragraph.maxIntrinsicWidth;
    if (old != null && from > 0 && from >= old.origin.dx && from < oldRight) {
      final first = _clusterIn(old, from);
      if (first != null) {
        var end = first.start;
        ui.Paragraph built;
        do {
          end = _codeUnitBoundary(
            text,
            end + max(64, ((to - first.left) / _advanceOf(old)).ceil()),
          );
          built = _plainParagraph(text.substring(first.start, end));
        } while (end < text.length &&
            built.maxIntrinsicWidth - margin < to - first.left);
        return _slice(
          text,
          first.start,
          end,
          old,
          origin: Offset(first.left, 0),
          cover: Rect.fromLTRB(
            first.left,
            double.negativeInfinity,
            end >= text.length
                ? double.infinity
                : first.left + built.maxIntrinsicWidth - margin,
            double.infinity,
          ),
          paragraph: built,
        );
      }
    }
    if (old != null && to > old.origin.dx && to < oldRight) {
      final last = _clusterIn(old, to);
      if (last != null) {
        var start = last.end;
        ui.Paragraph built;
        do {
          start = _codeUnitBoundary(
            text,
            start - max(64, ((last.right - from) / _advanceOf(old)).ceil()),
          );
          built = _plainParagraph(text.substring(start, last.end));
        } while (start > 0 &&
            built.maxIntrinsicWidth - margin < last.right - from);
        final left = last.right - built.maxIntrinsicWidth;
        return _slice(
          text,
          start,
          last.end,
          old,
          origin: Offset(left, 0),
          cover: Rect.fromLTRB(
            start == 0 ? double.negativeInfinity : left + margin,
            double.negativeInfinity,
            last.right,
            double.infinity,
          ),
          paragraph: built,
        );
      }
    }
    final y = _lineHeight / 2;
    final first = from > 0
        ? paragraph.getClosestGlyphInfoForOffset(Offset(from, y))
        : null;
    final last = to < paragraph.maxIntrinsicWidth
        ? paragraph.getClosestGlyphInfoForOffset(Offset(to, y))
        : null;
    final start = first?.graphemeClusterCodeUnitRange.start ?? 0;
    final end = max(
      start,
      last?.graphemeClusterCodeUnitRange.end ?? text.length,
    );
    final x = start == 0 ? 0.0 : first!.graphemeClusterLayoutBounds.left;
    return _slice(
      text,
      start,
      end,
      old,
      origin: Offset(x, 0),
      cover: Rect.fromLTRB(
        start == 0 ? double.negativeInfinity : x,
        double.negativeInfinity,
        end >= text.length
            ? double.infinity
            : last!.graphemeClusterLayoutBounds.right,
        double.infinity,
      ),
    );
  }

  _LineSlice _slice(
    String text,
    int start,
    int end,
    _LineSlice? old, {
    required Offset origin,
    required Rect cover,
    ui.Paragraph? paragraph,
    double? width,
  }) {
    final shown = text.substring(start, end);
    final scalarStart = old == null
        ? text.toScalarOffset(start)
        : start >= old.start
        ? old.scalarStart + text.substring(old.start, start).runes.length
        : old.scalarStart - text.substring(start, old.start).runes.length;
    return (
      text: text,
      start: start,
      end: end,
      scalarStart: scalarStart,
      scalarEnd: scalarStart + shown.runes.length,
      origin: origin,
      cover: cover,
      paragraph: paragraph ?? _plainParagraph(shown, width: width),
    );
  }

  ui.Paragraph _plainParagraph(String text, {double? width}) =>
      _syntaxHighlighter.buildPlainParagraph(
        text,
        _paragraphStyle,
        textStyle?.fontSize ?? 14.0,
        textStyle?.fontFamily,
        width: width,
      );

  ({int start, int end, double left, double right})? _clusterIn(
    _LineSlice slice,
    double x,
  ) {
    final glyph = slice.paragraph.getClosestGlyphInfoForOffset(
      Offset(x - slice.origin.dx, _lineHeight / 2),
    );
    if (glyph == null) return null;
    return (
      start: slice.start + glyph.graphemeClusterCodeUnitRange.start,
      end: slice.start + glyph.graphemeClusterCodeUnitRange.end,
      left: slice.origin.dx + glyph.graphemeClusterLayoutBounds.left,
      right: slice.origin.dx + glyph.graphemeClusterLayoutBounds.right,
    );
  }

  double _advanceOf(_LineSlice slice) => max(
    1.0,
    slice.paragraph.maxIntrinsicWidth / max(1, slice.end - slice.start),
  );

  int _codeUnitBoundary(String text, int index) {
    final clamped = index.clamp(0, text.length);
    return text.isLowSurrogateAt(clamped) ? clamped + 1 : clamped;
  }

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
    for (var i = _lines.nextVisible(start); i <= end;) {
      final width = _getLineWidth(i);
      if (width > _longLineWidth) _longLineWidth = width;
      final next = _lines.nextVisible(i + 1);
      if (next <= i) break;
      i = next;
    }
  }

  // The engine walks every run of a paragraph for any range, so a megabyte
  // plain line is asked only about the character before [column], and its
  // slice answers when it holds that character.
  ui.TextBox? _boxBefore(
    int line,
    String text,
    int column, {
    ui.BoxHeightStyle boxHeightStyle = ui.BoxHeightStyle.tight,
  }) {
    if (column <= 0) return null;
    final paragraph = _paragraphFor(line);
    if (SyntaxHighlighter.isPlain(text)) {
      final from = text.isLowSurrogateAt(column - 1) ? column - 2 : column - 1;
      final boxes =
          _sliceBoxes(line, text, from, column, boxHeightStyle) ??
          paragraph.getBoxesForRange(
            from,
            column,
            boxHeightStyle: boxHeightStyle,
          );
      if (boxes.isNotEmpty) return boxes.last;
    }
    final boxes = paragraph.getBoxesForRange(
      0,
      column,
      boxHeightStyle: boxHeightStyle,
    );
    return boxes.isEmpty ? null : boxes.last;
  }

  List<ui.TextBox>? _sliceBoxes(
    int line,
    String text,
    int from,
    int to, [
    ui.BoxHeightStyle boxHeightStyle = ui.BoxHeightStyle.tight,
  ]) {
    final slice = _lineSlices[line];
    if (slice == null ||
        slice.text != text ||
        from < slice.start ||
        to > slice.end) {
      return null;
    }
    return [
      for (final box in slice.paragraph.getBoxesForRange(
        from - slice.start,
        to - slice.start,
        boxHeightStyle: boxHeightStyle,
      ))
        ui.TextBox.fromLTRBD(
          box.left + slice.origin.dx,
          box.top + slice.origin.dy,
          box.right + slice.origin.dx,
          box.bottom + slice.origin.dy,
          box.direction,
        ),
    ];
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
