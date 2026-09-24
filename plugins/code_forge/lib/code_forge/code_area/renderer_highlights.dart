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

    if (controller.dirtyRegion != null) {
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

  void _drawSearchHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
  ) {
    for (final highlight in controller.searchHighlights) {
      final startLine = controller.getLineAtOffset(highlight.start);
      final endLine = controller.getLineAtOffset(highlight.end);
      if (endLine < firstVisibleLine || startLine > lastVisibleLine) continue;

      final highlightStyle = highlight.isCurrentMatch
          ? const TextStyle(backgroundColor: Color(0xFF01A2FF))
          : const TextStyle(backgroundColor: Color.fromARGB(163, 72, 215, 255));

      final highlightPaint = Paint()
        ..color = highlightStyle.backgroundColor ?? Colors.amberAccent
        ..style = PaintingStyle.fill;

      _drawRangeRows(
        canvas,
        offset,
        highlight.start,
        highlight.end,
        startLine,
        endLine,
        highlightPaint,
      );
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
      final origin = Offset(
        _screenX(offset, 0),
        _screenY(offset, _lineTop(line)),
      );

      if (utf16Start < utf16End) {
        final para = _paragraphFor(line);
        final boxes = para.getBoxesForRange(utf16Start, utf16End);
        for (final row in _selectionRows(para, boxes)) {
          canvas.drawRect(row.shift(origin), paint);
        }
      } else if (markEmptyLines && line < endLine) {
        final lineEnd = _selectionHandleAnchor(offset, line, start - lineStart);
        canvas.drawRect(lineEnd & Size(8, _lineHeight), paint);
      }
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
    final halfGlyph = (textStyle?.fontSize ?? 14) / 2;

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
      _startHandleRect = handleBelow(startLine, start, -halfGlyph);
    }
    if (_paintLines.contains(endLine)) {
      _endHandleRect = handleBelow(endLine, end, halfGlyph);
    }
  }

  Rect? getVisibleSelectionRect() {
    final selection = controller.selection;
    if (selection.isCollapsed) return null;
    double rowTop(int offset) {
      final line = controller.getLineAtOffset(offset);
      final column = _lineText(line)
          .toUtf16Offset(offset - controller.getLineStartOffset(line));
      final boxes = column > 0
          ? _paragraphFor(line).getBoxesForRange(0, column)
          : const <ui.TextBox>[];
      final top = boxes.isEmpty ? 0.0 : _rowTopForBox(boxes.last);
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
    final utf16Column = lineText.toUtf16Offset(column);
    var x = 0.0;
    var rowTop = 0.0;
    if (utf16Column > 0) {
      final para = _paragraphFor(line);
      final boxes = para.getBoxesForRange(0, utf16Column);
      if (boxes.isNotEmpty) {
        x = boxes.last.right;
        rowTop = boxes.last.top;
      }
    }
    return Offset(
      _screenX(offset, x),
      _screenY(offset, _lineTop(line) + rowTop),
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
