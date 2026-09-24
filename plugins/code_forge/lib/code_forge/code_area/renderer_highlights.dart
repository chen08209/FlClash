part of '../code_area.dart';

extension _RendererCoordinates on _CodeFieldRenderer {
  double get _textLeft =>
      _gutterWidth +
      (innerPadding?.left ?? 0) -
      (lineWrap ? 0 : hscrollController.offset);

  double _screenX(Offset offset, double contentX) =>
      offset.dx + _textLeft + contentX;

  double _screenY(Offset offset, double contentY) =>
      offset.dy +
      (innerPadding?.top ?? 0) +
      contentY -
      vscrollController.offset;
}

extension _RendererHighlights on _CodeFieldRenderer {
  void _pauseBracketHighlightDuringTyping() {
    _suspendBracketHighlight = true;
    _bracketHighlightResumeTimer?.cancel();
    _bracketHighlightResumeTimer = Timer(const Duration(milliseconds: 500), () {
      _suspendBracketHighlight = false;
      markNeedsPaint();
    });
  }

  (int?, int?) _getBracketPairAtCursor() {
    if (_suspendBracketHighlight) return (null, null);

    final cursorOffset = controller.selection.extentOffset;
    final textLength = controller.length;
    const bracketChars = '{}[]()';
    const openingBracketChars = '{[(';

    if (cursorOffset < 0 || textLength == 0) return (null, null);

    if (cursorOffset > 0 && cursorOffset <= textLength) {
      final before = controller.rope.substring(cursorOffset - 1, cursorOffset);
      if (bracketChars.contains(before)) {
        final match = _findMatchingBracket(cursorOffset - 1);
        if (match != null) {
          return (cursorOffset - 1, match);
        }
      }
    }

    if (cursorOffset >= 0 && cursorOffset < textLength) {
      final after = controller.rope.substring(cursorOffset, cursorOffset + 1);
      if (openingBracketChars.contains(after)) {
        final match = _findMatchingBracket(cursorOffset);
        if (match != null) {
          return (cursorOffset, match);
        }
      }
    }

    return (null, null);
  }

  void _drawBracketHighlight(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    bool hasActiveFolds,
    Color textColor,
  ) {
    if (!controller.selection.isValid || !controller.selection.isCollapsed) {
      return;
    }

    if (_suspendBracketHighlight) {
      return;
    }

    final (bracket1, bracket2) = _getBracketPairAtCursor();
    if (bracket1 == null || bracket2 == null) return;

    for (final bracket in [bracket1, bracket2]) {
      final line = controller.getLineAtOffset(bracket);
      if (line >= firstVisibleLine &&
          line <= lastVisibleLine &&
          (!hasActiveFolds || !_isLineFolded(line))) {
        _drawBracketBox(canvas, offset, bracket, line, textColor);
      }
    }
  }

  void _drawBracketBox(
    Canvas canvas,
    Offset offset,
    int bracketOffset,
    int lineIndex,
    Color textColor,
  ) {
    final lineStartOffset = controller.getLineStartOffset(lineIndex);
    final columnIndex = bracketOffset - lineStartOffset;

    final lineText = _lineText(lineIndex);

    if (columnIndex < 0 || columnIndex >= lineText.length) return;

    final para = _paragraphFor(lineIndex);

    final utf16Col = lineText.toUtf16Offset(columnIndex);
    final boxes = para.getBoxesForRange(utf16Col, utf16Col + 1);
    if (boxes.isEmpty) return;

    final box = boxes.first;

    final screenX = _screenX(offset, box.left);
    final screenY = _screenY(offset, _lineTop(lineIndex) + box.top);

    final bracketRect = RSuperellipse.fromRectAndRadius(
      Rect.fromLTWH(
        screenX - 1.5,
        screenY - 1,
        box.right - box.left + 3,
        _lineHeight + 2.5,
      ),
      const Radius.circular(2),
    );

    _bracketHighlightPainter.color = textColor;
    canvas.drawRSuperellipse(bracketRect, _bracketHighlightPainter);
  }

  // Each visible line walks its shown text once for the matches in it,
  // however many a long line holds.
  void _drawSearchHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
  ) {
    final highlights = controller.searchHighlights;
    if (highlights.isEmpty) return;
    final current = Paint()..color = const Color(0xFF01A2FF);
    final other = Paint()..color = const Color.fromARGB(163, 72, 215, 255);
    for (final line in _paintLines) {
      if (line < firstVisibleLine || line > lastVisibleLine) continue;
      final text = _lineText(line);
      final paragraph = _paragraphFor(line);
      final slice = _sliceInView(line, text, paragraph);
      final lineStart = controller.getLineStartOffset(line);
      final shownStart = lineStart + (slice?.scalarStart ?? 0);
      final shownEnd = lineStart + (slice?.scalarEnd ?? text.runes.length);
      final origin = _lineOrigin(offset, line);
      var scalar = shownStart;
      var utf16 = slice?.start ?? 0;
      int column(int offset) {
        utf16 = text.utf16After(utf16, offset - scalar);
        scalar = offset;
        return utf16;
      }

      var low = 0, high = highlights.length;
      while (low < high) {
        final mid = (low + high) >> 1;
        if (highlights[mid].end <= shownStart) {
          low = mid + 1;
        } else {
          high = mid;
        }
      }
      for (var i = low; i < highlights.length; i++) {
        final highlight = highlights[i];
        if (highlight.start >= shownEnd) break;
        _fillRange(
          canvas,
          origin,
          slice,
          paragraph,
          column(max(highlight.start, shownStart)),
          column(min(highlight.end, shownEnd)),
          highlight.isCurrentMatch ? current : other,
        );
      }
    }
  }

  void _drawFoldedLineHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    bool hasActiveFolds,
  ) {
    if (!hasActiveFolds) return;

    final highlightColor = selectionStyle.selectionColor.withAlpha(60);

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    for (final foldRange in controller.foldings.values.where(
      (f) => f != null,
    )) {
      if (!foldRange!.isFolded) continue;

      final foldStartLine = foldRange.startIndex;

      if (foldStartLine < firstVisibleLine || foldStartLine > lastVisibleLine) {
        continue;
      }

      final lineHeight = _lineExtent(foldStartLine);
      final screenY = _screenY(offset, _lineTop(foldStartLine));

      final highlightX = offset.dx + _gutterWidth;
      final highlightWidth = size.width - _gutterWidth;

      canvas.drawRect(
        Rect.fromLTWH(highlightX, screenY, highlightWidth, lineHeight),
        highlightPaint,
      );
    }
  }

  void _drawSelection(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
  ) {
    _startHandleRect = _endHandleRect = null;
    final selection = controller.selection;
    if (selection.isCollapsed) return;

    final start = selection.start;
    final end = selection.end;
    final startLine = controller.getLineAtOffset(start);
    final endLine = controller.getLineAtOffset(end);
    if (endLine < firstVisibleLine || startLine > lastVisibleLine) return;

    final selectionPaint = Paint()
      ..color = selectionStyle.selectionColor
      ..style = PaintingStyle.fill;
    _drawRangeRows(
      canvas,
      offset,
      start,
      end,
      startLine,
      endLine,
      selectionPaint,
      markEmptyLines: true,
    );

    _updateSelectionHandleRects(offset, start, end, startLine, endLine);
  }

  // [markEmptyLines] gives a line the range crosses without covering any of
  // its text a short block at its end, so the line break reads as selected.
  void _drawRangeRows(
    Canvas canvas,
    Offset offset,
    int start,
    int end,
    int startLine,
    int endLine,
    Paint paint, {
    bool markEmptyLines = false,
  }) {
    for (final line in _paintLines) {
      if (line < startLine || line > endLine) continue;

      final lineStart = controller.getLineStartOffset(line);
      final lineText = _lineText(line);
      final utf16Start = lineText.toUtf16Offset(start - lineStart);
      final utf16End = lineText.toUtf16Offset(end - lineStart);

      if (utf16Start < utf16End) {
        final para = _paragraphFor(line);
        _fillRange(
          canvas,
          _lineOrigin(offset, line),
          _sliceInView(line, lineText, para),
          para,
          utf16Start,
          utf16End,
          paint,
        );
      } else if (markEmptyLines && line < endLine) {
        final lineEnd = _selectionHandleAnchor(offset, line, start - lineStart);
        canvas.drawRect(lineEnd & Size(8, _lineHeight), paint);
      }
    }
  }

  Offset _lineOrigin(Offset offset, int line) =>
      Offset(_screenX(offset, 0), _screenY(offset, _lineTop(line)));

  void _fillRange(
    Canvas canvas,
    Offset origin,
    _LineSlice? slice,
    ui.Paragraph paragraph,
    int from,
    int to,
    Paint paint,
  ) {
    final start = max(from, slice?.start ?? 0);
    final end = min(to, slice?.end ?? to);
    if (start >= end) return;
    final shown = slice?.paragraph ?? paragraph;
    final shift = slice?.start ?? 0;
    final at = origin + (slice?.origin ?? Offset.zero);
    final boxes = shown.getBoxesForRange(start - shift, end - shift);
    for (final row in _selectionRows(shown, boxes)) {
      canvas.drawRect(row.shift(at), paint);
    }
  }

  // One rect per visual row, spanning the row's full height: a style run or
  // fallback glyph gets its own box with its own font's extent, and stacked
  // translucent boxes would darken where they overlap.
  List<Rect> _selectionRows(ui.Paragraph para, List<ui.TextBox> boxes) {
    if (boxes.isEmpty) return const [];
    final rows = lineWrap
        ? [
            for (final metrics in para.computeLineMetrics())
              (
                top: metrics.baseline - metrics.ascent,
                bottom: metrics.baseline + metrics.descent,
              ),
          ]
        : [(top: 0.0, bottom: _lineHeight)];
    final spans = <int, Rect>{};
    for (final box in boxes) {
      final center = (box.top + box.bottom) / 2;
      var row = rows.indexWhere((row) => center < row.bottom);
      if (row < 0) row = rows.length - 1;
      final rect = Rect.fromLTRB(
        box.left,
        rows[row].top,
        box.right,
        rows[row].bottom,
      );
      spans.update(row, rect.expandToInclude, ifAbsent: () => rect);
    }
    return spans.values.toList();
  }

  void _updateSelectionHandleRects(
    Offset offset,
    int start,
    int end,
    int startLine,
    int endLine,
  ) {
    final handleRadius = _handleRadius;
    final handleSize = _handleSize;

    Rect handleBelow(int line, int offsetInDocument, double dx) {
      final anchor = _selectionHandleAnchor(
        offset,
        line,
        offsetInDocument - controller.getLineStartOffset(line),
      );
      return Rect.fromCenter(
        center: anchor.translate(dx, _lineHeight + handleRadius),
        width: handleSize,
        height: handleSize,
      );
    }

    if (_paintLines.contains(startLine)) {
      _startHandleRect = handleBelow(startLine, start, -_handleOverhang);
    }
    if (_paintLines.contains(endLine)) {
      _endHandleRect = handleBelow(endLine, end, _handleOverhang);
    }
  }

  Rect? getVisibleSelectionRect() {
    final selection = controller.selection;
    if (selection.isCollapsed) return null;
    double rowTop(int offset) {
      final line = controller.getLineAtOffset(offset);
      final text = _lineText(line);
      final box = _boxBefore(
        line,
        text,
        text.toUtf16Offset(offset - controller.getLineStartOffset(line)),
      );
      final top = box == null ? 0.0 : _rowTopForBox(box);
      return _screenY(Offset.zero, _lineTop(line) + top);
    }

    final rows = Rect.fromLTRB(
      _gutterWidth,
      rowTop(selection.start),
      size.width,
      rowTop(selection.end - 1) + _lineHeight + (isMobile ? _handleSize : 0),
    ).intersect(Offset.zero & size);
    return rows.isEmpty
        ? null
        : Rect.fromPoints(
            localToGlobal(rows.topLeft),
            localToGlobal(rows.bottomRight),
          );
  }

  Offset _selectionHandleAnchor(Offset offset, int line, int column) {
    final lineText = _lineText(line);
    final box = _boxBefore(line, lineText, lineText.toUtf16Offset(column));
    return Offset(
      _screenX(offset, box?.right ?? 0),
      _screenY(offset, _lineTop(line) + (box?.top ?? 0)),
    );
  }

  void _drawLineHighlight(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    bool hasActiveFolds,
  ) {
    if (_highlightedLine == null) return;

    final highlightLine = _highlightedLine!;

    if (highlightLine < firstVisibleLine || highlightLine > lastVisibleLine) {
      return;
    }

    if (hasActiveFolds && _isLineFolded(highlightLine)) return;

    final opacity = _lineHighlightAnimation.value;
    if (opacity <= 0.0) {
      _highlightedLine = null;
      return;
    }

    final lineHeight = _lineExtent(highlightLine);
    final screenY = _screenY(offset, _lineTop(highlightLine));
    final screenX = _screenX(offset, 0);

    final highlightColor =
        (textStyle?.color ?? editorTheme['root']?.color ?? Colors.yellow)
            .withValues(alpha: opacity);

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    final width = size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    canvas.drawRect(Rect.fromLTWH(screenX, screenY, width, lineHeight), paint);
  }
}
