part of '../code_area.dart';

extension _RendererCaret on _CodeFieldRenderer {
  void _publishCaretRect() {
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;
    final caret = _getCaretInfo();
    final rect = Rect.fromLTWH(
      caret.offset.dx + _textLeft,
      caret.offset.dy + (innerPadding?.top ?? 0) - vscrollController.offset,
      0,
      caret.height,
    );
    final visible =
        rect.left >= _gutterWidth &&
        rect.left <= hscrollController.position.viewportDimension &&
        rect.top >= 0 &&
        rect.bottom <= vscrollController.position.viewportDimension;
    caretRectNotifier.value = visible ? rect : null;
  }

  void _ensureCaretVisible() {
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;

    final caretInfo = _getCaretInfo();
    final caretX = caretInfo.offset.dx + _textLeft;
    final caretY = caretInfo.offset.dy + (innerPadding?.top ?? 0);
    final caretHeight = caretInfo.height;
    final vScrollOffset = vscrollController.offset;
    final hScrollOffset = hscrollController.offset;
    final viewportHeight =
        vscrollController.position.viewportDimension -
        (innerPadding?.bottom ?? 0);
    final viewportWidth =
        hscrollController.position.viewportDimension -
        (innerPadding?.right ?? 0);
    if (caretY >= 0 && caretY <= vScrollOffset + (innerPadding?.top ?? 0)) {
      final targetOffset = caretY - (innerPadding?.top ?? 0);
      vscrollController.jumpTo(
        targetOffset.clamp(0, vscrollController.position.maxScrollExtent),
      );
    } else if (caretY + caretHeight > vScrollOffset + viewportHeight) {
      final targetOffset = caretY + caretHeight - viewportHeight;
      vscrollController.jumpTo(
        targetOffset.clamp(0, vscrollController.position.maxScrollExtent),
      );
    }

    final textStart = _gutterWidth + (innerPadding?.left ?? 0);
    if (caretX < textStart) {
      final targetOffset = hScrollOffset + caretX - textStart;
      hscrollController.jumpTo(
        targetOffset.clamp(0, hscrollController.position.maxScrollExtent),
      );
    } else if (caretX + 1.5 > viewportWidth) {
      final targetOffset = hScrollOffset + caretX + 1.5 - viewportWidth;
      hscrollController.jumpTo(
        targetOffset.clamp(0, hscrollController.position.maxScrollExtent),
      );
    }
    _publishCaretRect();
  }

  void _scheduleCaretSyncAfterLayout() {
    if (_caretSyncAfterLayoutScheduled || _isFoldToggleInProgress) return;
    _caretSyncAfterLayoutScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caretSyncAfterLayoutScheduled = false;
      if (!attached) return;
      if (!vscrollController.hasClients || !hscrollController.hasClients) {
        return;
      }
      _ensureCaretVisible();
    });
  }

  void _scrollToLine(int line) {
    if (line < 0 || line >= controller.lineCount) return;

    for (final fold in _foldRanges.values.where((f) => f != null)) {
      if (fold!.isFolded && line > fold.startIndex && line <= fold.endIndex) {
        _unfoldWithChildren(fold);
        _commitFoldChange();
        break;
      }
    }

    final targetY = _lineTop(line);
    final targetLineHeight = _lineExtent(line);
    final topPadding = innerPadding?.top ?? 0;
    final bottomPadding = innerPadding?.bottom ?? 0;
    final viewportHeight = vscrollController.position.viewportDimension;
    final visibleHeight = max(0.0, viewportHeight - topPadding - bottomPadding);
    final centerHeight = visibleHeight > 0 ? visibleHeight : viewportHeight;
    final maxScroll = vscrollController.position.maxScrollExtent;
    double scrollTarget = targetY + (targetLineHeight / 2) - (centerHeight / 2);

    scrollTarget = scrollTarget.clamp(0.0, maxScroll);

    vscrollController
        .animateTo(
          scrollTarget,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!attached) return;
          _highlightedLine = line;
          lineHighlightController.forward(from: 0.0);
        });
  }

  void _updateImeGeometry() {
    final conn = controller.connection;
    if (conn == null || !conn.attached) return;
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;

    final caretInfo = _getCaretInfo();
    final vScroll = vscrollController.offset;
    final composing = controller.imeComposition != null;

    final caretY = caretInfo.offset.dy + (innerPadding?.top ?? 0);

    final caretInLine =
        caretInfo.offset.dx + (composing ? _imeComposingCaretDx : 0.0);
    final caretRect = Rect.fromLTWH(
      caretInLine + _textLeft,
      caretY - vScroll,
      2.0,
      caretInfo.height,
    );

    final composingRect = composing
        ? Rect.fromLTWH(
            caretInfo.offset.dx + _textLeft,
            caretY - vScroll,
            _imeComposingWidth > 0 ? _imeComposingWidth : 2.0,
            caretInfo.height,
          )
        : caretRect;

    final editableSize = size;

    if (caretRect == _lastImeCaretRect &&
        composingRect == _lastImeComposingRect &&
        editableSize == _lastImeEditableSize) {
      return;
    }
    _lastImeCaretRect = caretRect;
    _lastImeComposingRect = composingRect;
    _lastImeEditableSize = editableSize;

    conn.setEditableSizeAndTransform(editableSize, getTransformTo(null));
    conn.setCaretRect(caretRect);
    conn.setComposingRect(composingRect);
  }

  void _drawImeComposition(Canvas canvas, Offset offset, bool hasActiveFolds) {
    _imeComposingCaretDx = 0.0;
    _imeComposingWidth = 0.0;

    final comp = controller.imeComposition;
    if (comp == null || comp.displayText.isEmpty) return;

    final anchorLine = controller.getLineAtOffset(comp.anchor);
    if (hasActiveFolds && _isLineFolded(anchorLine)) return;

    final viewportHeight = vscrollController.position.viewportDimension;
    final screenYBase = _screenY(offset, _lineTop(anchorLine));
    if (screenYBase + _lineHeight < offset.dy ||
        screenYBase > offset.dy + viewportHeight) {
      return;
    }

    final lineStartOffset = controller.getLineStartOffset(anchorLine);
    final lineText = _lineText(anchorLine);
    final anchorCol = lineText.toUtf16Offset(comp.anchor - lineStartOffset);
    final linePara = _paragraphFor(anchorLine);

    double anchorX = 0;
    double rowTop = 0;
    if (anchorCol > 0) {
      final boxes = linePara.getBoxesForRange(
        0,
        anchorCol,
        boxHeightStyle: ui.BoxHeightStyle.max,
      );
      if (boxes.isNotEmpty) {
        final lastBox = boxes.last;
        anchorX = lastBox.right;
        rowTop = _rowTopForBox(lastBox);
      }
    }

    final screenX = _screenX(offset, anchorX);
    final screenY = screenYBase + rowTop;

    final baseColor =
        textStyle?.color ?? editorTheme['root']?.color ?? Colors.white;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
    final fontSize = textStyle?.fontSize ?? 14.0;
    final fontFamily = textStyle?.fontFamily;
    final overlayParagraphStyle = ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: textStyle?.height ?? 1.2,
      textDirection: TextDirection.ltr,
      textAlign: ui.TextAlign.start,
    );
    ui.Paragraph overlayParagraph(String text, ui.TextStyle style) {
      final builder = ui.ParagraphBuilder(overlayParagraphStyle)
        ..pushStyle(style)
        ..addText(text);
      return builder.build()
        ..layout(const ui.ParagraphConstraints(width: double.infinity));
    }

    final composingPara = overlayParagraph(
      comp.displayText,
      ui.TextStyle(
        color: baseColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        decoration: TextDecoration.underline,
        decorationColor: baseColor.withAlpha(150),
      ),
    );
    final composingWidth = composingPara.longestLine;

    final remainderWidth = (linePara.longestLine - anchorX).clamp(
      0.0,
      double.infinity,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        screenX,
        screenY,
        composingWidth + remainderWidth + 2,
        _lineHeight,
      ),
      Paint()..color = bgColor,
    );

    canvas.drawParagraph(composingPara, Offset(screenX, screenY));

    if (anchorCol < lineText.length) {
      final remainingPara = overlayParagraph(
        lineText.substring(anchorCol),
        ui.TextStyle(
          color: baseColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: textStyle?.fontWeight,
        ),
      );
      canvas.drawParagraph(
        remainingPara,
        Offset(screenX + composingWidth, screenY),
      );
    }

    double caretDx = 0;
    if (comp.displayCaret > 0) {
      final caretBoxes = composingPara.getBoxesForRange(
        0,
        comp.displayCaret.clamp(0, comp.displayText.length),
      );
      if (caretBoxes.isNotEmpty) caretDx = caretBoxes.last.right;
    }

    _imeComposingCaretDx = caretDx;
    _imeComposingWidth = composingWidth;

    if (focusNode.hasFocus && caretBlinkController.value > 0.5) {
      canvas.drawRect(
        Rect.fromLTWH(screenX + caretDx, screenY, 1.5, _lineHeight),
        _caretPainter,
      );
    }
  }

  void _selectWordAtOffset(int offset) {
    if (isMobile) {
      _selectionActive = selectionActiveNotifier.value = true;
    }

    final text = controller.text;
    final utf16Offset = text.toUtf16Offset(offset);
    int start = utf16Offset, end = utf16Offset;

    while (start > 0 && isWordChar(text.codeUnitAt(start - 1))) {
      start--;
    }
    while (end < text.length && isWordChar(text.codeUnitAt(end))) {
      end++;
    }

    controller.selection = TextSelection(
      baseOffset: text.toScalarOffset(start),
      extentOffset: text.toScalarOffset(end),
    );
    markNeedsPaint();
  }

  void _paintMobileHandles(Canvas canvas, Offset offset) {
    final selection = controller.selection;
    final handleColor = selectionStyle.cursorBubbleColor;
    final handleRadius = _handleRadius;

    final handlePaint = Paint()
      ..color = handleColor
      ..style = PaintingStyle.fill;

    _normalHandle = null;
    if (selection.isCollapsed) {
      if (!_readOnly && (_showBubble || _selectionActive)) {
        final caretInfo = _getCaretInfo();
        final handleSize = caretInfo.height;

        final handleX = _screenX(offset, caretInfo.offset.dx);
        final handleY = _screenY(offset, caretInfo.offset.dy + _lineHeight);

        canvas.save();
        canvas.translate(handleX, handleY);
        canvas.rotate(pi / 4);
        _drawTeardrop(
          canvas,
          Rect.fromCenter(
            center: Offset((handleSize / 1.5), (handleSize / 1.5)),
            width: handleSize * 1.3,
            height: handleSize * 1.3,
          ),
          sharpCorner: _HandleCorner.topLeft,
          paint: handlePaint,
        );
        canvas.restore();

        _normalHandle = Rect.fromCenter(
          center: Offset(handleX, handleY + handleRadius),
          width: handleRadius * 2,
          height: handleRadius * 2,
        );

        if (_draggingCHandle) {
          _selectionActive = selectionActiveNotifier.value = true;
        }
      }
    } else {
      if (_startHandleRect case final startRect?) {
        _drawTeardrop(
          canvas,
          startRect,
          sharpCorner: _HandleCorner.topRight,
          paint: handlePaint,
        );
      }

      if (_endHandleRect case final endRect?) {
        _drawTeardrop(
          canvas,
          endRect,
          sharpCorner: _HandleCorner.topLeft,
          paint: handlePaint,
        );
      }
    }
  }

  void _drawTeardrop(
    Canvas canvas,
    Rect rect, {
    required _HandleCorner sharpCorner,
    required Paint paint,
  }) {
    final round = Radius.circular(rect.shortestSide / 2);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndCorners(
        rect,
        topLeft: sharpCorner == _HandleCorner.topLeft ? Radius.zero : round,
        topRight: sharpCorner == _HandleCorner.topRight ? Radius.zero : round,
        bottomLeft: round,
        bottomRight: round,
      ),
      paint,
    );
  }

  int? get _magnifiedTextOffset {
    if (!isMobile) return null;
    final selection = controller.selection;
    if (_draggingCHandle && selection.isCollapsed) return selection.baseOffset;
    if (selection.isCollapsed) return null;
    if (_draggingStartHandle) return selection.start;
    if (_draggingEndHandle) return selection.end;
    if (_selectionActive && _isDragging) return selection.extentOffset;
    return null;
  }

  // Paint runs after layout, so the caret geometry is final here, but the
  // overlay may only rebuild once the frame is done.
  void _publishMagnifier() {
    final textOffset = _magnifiedTextOffset;
    MagnifierInfo? info;
    if (textOffset != null) {
      final line = controller.getLineAtOffset(textOffset);
      final anchor = _selectionHandleAnchor(
        Offset.zero,
        line,
        textOffset - controller.getLineStartOffset(line),
      );
      final origin = localToGlobal(Offset.zero);
      info = MagnifierInfo(
        globalGesturePosition: localToGlobal(_currentPosition),
        caretRect: Rect.fromLTWH(
          anchor.dx,
          anchor.dy,
          0,
          _lineHeight,
        ).shift(origin),
        fieldBounds: origin & size,
        currentLineBoundaries: Rect.fromLTWH(
          0,
          anchor.dy,
          size.width,
          _lineHeight,
        ).shift(origin),
      );
    }
    if (magnifierNotifier.value == info) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) magnifierNotifier.value = info;
    });
  }
}

enum _HandleCorner { topLeft, topRight }
