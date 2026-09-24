part of '../code_area.dart';

extension _RendererGutter on _CodeFieldRenderer {
  bool _shouldShortenGuideToPreviousLine(String lineText) {
    final trimmed = lineText.trimRight();
    if (trimmed.endsWith('{') ||
        trimmed.endsWith('(') ||
        trimmed.endsWith('[')) {
      return true;
    }

    return _extractOpeningTagName(trimmed) != null;
  }

  void _drawGutter(
    Canvas canvas,
    Offset offset,
    Color bgColor,
    TextStyle? gutterTextStyle,
  ) {
    final viewportHeight = vscrollController.position.viewportDimension;

    final gutterBgColor = gutterStyle.backgroundColor ?? bgColor;
    final gutterX = offset.dx;
    canvas.drawRect(
      Rect.fromLTWH(gutterX, offset.dy, _gutterWidth, viewportHeight),
      Paint()..color = gutterBgColor,
    );

    final baseLineNumberStyle = (() {
      if (gutterTextStyle == null) {
        return editorTheme['root'];
      } else if (gutterTextStyle.color == null) {
        return gutterTextStyle.copyWith(color: editorTheme['root']?.color);
      } else {
        return gutterTextStyle;
      }
    })();

    final selection = controller.selection;
    final activeFirstLine = controller.getLineAtOffset(selection.start);
    var activeLastLine = controller.getLineAtOffset(selection.end);
    if (activeLastLine > activeFirstLine &&
        controller.getLineStartOffset(activeLastLine) == selection.end) {
      activeLastLine--;
    }

    final activeLineColor = baseLineNumberStyle?.color ?? Colors.white;
    final inactiveLineColor =
        baseLineNumberStyle?.color?.withAlpha(120) ?? Colors.grey;

    for (final i in _paintLines) {
      final contentTop = _lineTop(i);

      final lineNumberStyle = baseLineNumberStyle!.copyWith(
        color: i >= activeFirstLine && i <= activeLastLine
            ? activeLineColor
            : inactiveLineColor,
      );

      final lineNumPara = _buildLineNumberParagraph(
        '${i + 1}',
        lineNumberStyle,
      );
      final numWidth = lineNumPara.longestLine;

      canvas.drawParagraph(
        lineNumPara,
        Offset(
          offset.dx +
              (_gutterWidth - numWidth) / 2 -
              (lineNumberStyle.fontSize ?? 14) / 2,
          _screenY(offset, contentTop),
        ),
      );

      final foldRange = _getFoldRangeAtLine(i);
      if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
        final isInsideFoldedParent = _isLineFolded(i);

        if (!isInsideFoldedParent) {
          final icon = foldRange.isFolded
              ? Icons.chevron_right_outlined
              : Icons.keyboard_arrow_down_outlined;
          final iconColor = gutterStyle.foldIconColor ?? lineNumberStyle.color;

          _drawFoldIcon(
            canvas,
            offset,
            icon,
            iconColor!,
            lineNumberStyle.fontSize ?? 14,
            contentTop,
          );
        }
      }
    }
  }

  ui.Paragraph _buildLineNumberParagraph(String text, TextStyle style) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
            ),
          )
          ..pushStyle(
            ui.TextStyle(
              color: style.color,
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
            ),
          )
          ..addText(text);
    final p = builder.build();
    p.layout(const ui.ParagraphConstraints(width: double.infinity));
    return p;
  }

  void _drawFoldIcon(
    Canvas canvas,
    Offset offset,
    IconData icon,
    Color color,
    double fontSize,
    double contentTop,
  ) {
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    final iconX = offset.dx + _gutterWidth - iconPainter.width - 2;
    iconPainter.paint(
      canvas,
      Offset(
        iconX,
        _screenY(offset, contentTop) + (_lineHeight - iconPainter.height) / 2,
      ),
    );
  }

  void _drawIndentGuides(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    Color textColor,
  ) {
    final viewTop = _paintViewTop;
    final viewBottom = viewTop + vscrollController.position.viewportDimension;
    final tabSize = controller.tabSize;
    final cursorOffset = controller.selection.extentOffset;
    final currentLine = controller.getLineAtOffset(cursorOffset);
    final List<({int startLine, int endLine, int indentLevel, double guideX})>
    blocks = [];

    final scanStart = (firstVisibleLine - 500).clamp(0, firstVisibleLine);
    final visibleLineTexts = controller.getLinesRange(
      scanStart,
      lastVisibleLine + 1,
    );

    String lineTextAt(int lineIndex) {
      final visibleIndex = lineIndex - scanStart;
      if (visibleIndex < 0 || visibleIndex >= visibleLineTexts.length) {
        return controller.getLineText(lineIndex);
      }
      return visibleLineTexts[visibleIndex];
    }

    double measureLeadingIndentWidth(String lineText, int leadingColumns) {
      if (leadingColumns <= 0 || lineText.isEmpty) return 0;

      int consumedColumns = 0;
      int endIndex = 0;

      while (endIndex < lineText.length && consumedColumns < leadingColumns) {
        final ch = lineText[endIndex];
        if (ch == ' ') {
          consumedColumns += 1;
        } else if (ch == '\t') {
          consumedColumns = tabSize <= 0
              ? consumedColumns + 1
              : consumedColumns + (tabSize - (consumedColumns % tabSize));
        } else {
          break;
        }
        endIndex++;
      }

      if (endIndex == 0) return 0;

      final indentString = lineText.substring(0, endIndex);
      final builder = ui.ParagraphBuilder(_paragraphStyle)
        ..pushStyle(_uiTextStyle)
        ..addText(indentString);
      final spacePara = builder.build();
      spacePara.layout(const ui.ParagraphConstraints(width: double.infinity));
      return spacePara.maxIntrinsicWidth;
    }

    void addBlock({
      required int startLine,
      required int endLine,
      required int leadingColumns,
      required int indentLevel,
      required String lineText,
    }) {
      if (endLine <= startLine) return;

      final renderEndLine = max(
        _shouldShortenGuideToPreviousLine(lineText)
            ? (endLine - 1).clamp(startLine + 1, endLine)
            : endLine,
        startLine + 2,
      );

      // Only the guide's x is reused: its end depends on the viewport, since
      // guidesComputeViewport stops scanning just below it.
      final cachedBlocks = _indentGuideCache[startLine];
      final guideX = cachedBlocks != null && cachedBlocks.isNotEmpty
          ? cachedBlocks.first.guideX
          : leadingColumns > 0
          ? measureLeadingIndentWidth(lineText, leadingColumns)
          : 0.0;

      final block = (
        startLine: startLine,
        endLine: renderEndLine,
        indentLevel: indentLevel,
        guideX: guideX,
      );

      _indentGuideCache[startLine] = [block];
      if (renderEndLine >= firstVisibleLine) {
        blocks.add(block);
      }
    }

    final foldedGuideCandidates = <int, FoldRange>{};
    for (
      int i = scanStart;
      i <= lastVisibleLine && i < controller.lineCount;
      i++
    ) {
      final fold = _foldRanges[i];
      if (fold != null) {
        foldedGuideCandidates[i] = fold;
      }
    }

    final rustBlocks = guidesComputeViewport(
      rope: controller.rope.core,
      firstVisible: BigInt.from(firstVisibleLine),
      lastVisible: BigInt.from(lastVisibleLine),
      tabSize: BigInt.from(tabSize),
    );

    for (final b in rustBlocks) {
      final lineText = _lineTextCache[b.startLine] ??= lineTextAt(b.startLine);

      addBlock(
        startLine: b.startLine,
        endLine: b.endLine,
        leadingColumns: b.leadingSpaces,
        indentLevel: b.indentLevel,
        lineText: lineText,
      );
    }

    if (foldedGuideCandidates.isNotEmpty) {
      for (final entry in foldedGuideCandidates.entries) {
        final lineIndex = entry.key;
        final fold = entry.value;

        final lineText = _lineTextCache[lineIndex] ??= lineTextAt(lineIndex);

        final alreadyAdded = blocks.any(
          (block) => block.startLine == lineIndex,
        );
        if (alreadyAdded) {
          continue;
        }

        final leadingColumns = _measureLeadingIndentColumns(lineText);
        final indentLevel = _lineIndentCache.containsKey(lineIndex)
            ? _lineIndentCache[lineIndex]!
            : (tabSize > 0 ? leadingColumns ~/ tabSize : leadingColumns);
        if (!_lineIndentCache.containsKey(lineIndex)) {
          _lineIndentCache[lineIndex] = indentLevel;
        }

        addBlock(
          startLine: lineIndex,
          endLine: fold.endIndex + 1,
          leadingColumns: leadingColumns,
          indentLevel: indentLevel,
          lineText: lineText,
        );
      }
    }

    int? selectedBlockIndex;
    int minBlockSize = 999999;

    for (int idx = 0; idx < blocks.length; idx++) {
      final block = blocks[idx];
      if (currentLine >= block.startLine && currentLine < block.endLine) {
        final blockSize = block.endLine - block.startLine;
        if (blockSize < minBlockSize) {
          minBlockSize = blockSize;
          selectedBlockIndex = idx;
        }
      }
    }

    for (int idx = 0; idx < blocks.length; idx++) {
      final block = blocks[idx];
      final isSelected = selectedBlockIndex == idx;

      final guidePaint = Paint()
        ..color = isSelected ? textColor : textColor.withAlpha(100)
        ..strokeWidth = isSelected ? 1.0 : 0.5
        ..style = PaintingStyle.stroke;

      final screenYTop = _screenY(offset, _lineTop(block.startLine + 1));
      final screenYBottom = _screenY(offset, _lineTop(block.endLine));

      if (screenYBottom < 0 || screenYTop > viewBottom - viewTop) continue;

      final screenGuideX = _screenX(offset, block.guideX);

      if (screenGuideX < offset.dx + _gutterWidth ||
          screenGuideX > offset.dx + size.width) {
        continue;
      }

      final clampedYTop = screenYTop.clamp(0.0, viewBottom - viewTop);
      final clampedYBottom = screenYBottom.clamp(0.0, viewBottom - viewTop);

      canvas.drawLine(
        Offset(screenGuideX, clampedYTop),
        Offset(screenGuideX, clampedYBottom),
        guidePaint,
      );
    }
  }
}
