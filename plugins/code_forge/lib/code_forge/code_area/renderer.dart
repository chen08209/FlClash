part of '../code_area.dart';

class _CodeFieldRenderer extends RenderBox implements MouseTrackerAnnotation {
  final CodeForgeController controller;
  final ScrollController vscrollController, hscrollController;
  final FocusNode focusNode;
  final AnimationController caretBlinkController;
  final AnimationController lineHighlightController;
  final bool isMobile;
  final ValueNotifier<bool> selectionActiveNotifier;
  final ValueNotifier<Rect?> caretRectNotifier;
  final ValueChanged<Offset> onContextMenuRequest;
  final ValueNotifier<List<CodeForgeSuggestion>?> suggestionNotifier;
  final ValueNotifier<MagnifierInfo?> magnifierNotifier;
  final Map<int, double> _lineWidthCache = {};
  final Map<int, String> _lineTextCache = {};
  final Map<int, ({String text, ui.Paragraph paragraph, bool highlighted})>
  _paragraphCache = {};
  final Map<int, FoldRange?> _foldRanges = {};
  final Map<int, int?> _bracketCache = {};
  final Map<
    int,
    List<({int startLine, int endLine, int indentLevel, double guideX})>
  >
  _indentGuideCache = {};
  final Map<
    int,
    ({int lineIndex, int columnIndex, Offset offset, double height})
  >
  _caretInfoCache = {};
  final Map<int, int> _lineIndentCache = {};
  final _dtap = DoubleTapGestureRecognizer();
  final _onetap = TapGestureRecognizer();
  late double _gutterPadding;
  final Paint _caretPainter = Paint();
  final Paint _bracketHighlightPainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  late final ViewLineLayout _layout;
  late double _lineHeight;
  late ui.ParagraphStyle _paragraphStyle;
  late ui.TextStyle _uiTextStyle;
  late SyntaxHighlighter _syntaxHighlighter;
  late double _gutterWidth;
  Map<String, TextStyle> _editorTheme;
  Mode _language;
  EdgeInsets? _innerPadding;
  TextStyle? _textStyle;
  GutterStyle _gutterStyle;
  CodeSelectionStyle _selectionStyle;
  int _cachedCaretOffset = -1, _cachedCaretLine = 0, _cachedCaretLineStart = 0;
  Rect? _lastImeCaretRect;
  Rect? _lastImeComposingRect;
  Size? _lastImeEditableSize;
  double _imeComposingCaretDx = 0.0, _imeComposingWidth = 0.0;
  int? _dragStartOffset;
  late final void Function(int) _scrollCallback = _scrollToLine;
  late final void Function(int) _foldCallback = _toggleFoldAtLine;
  ({int start, int end})? _gutterSelectionAnchor;
  Timer? _selectionTimer;
  Offset? _pointerDownPosition;
  Offset _currentPosition = Offset.zero;
  bool _isFoldToggleInProgress = false, _lineWrap;
  bool _hasActiveFoldsCache = false;
  bool _foldedLineCacheDirty = true;
  bool _asyncFoldComputationPending = false;
  int _asyncFoldsVersion = -1;
  Timer? _foldComputeTimer;
  bool _selectionActive = false, _isDragging = false;
  bool _draggingStartHandle = false, _draggingEndHandle = false;
  bool _showBubble = false, _draggingCHandle = false, _readOnly;
  bool _caretSyncAfterLayoutScheduled = false;
  bool _caretBlinkShown = false;
  Rect? _startHandleRect, _endHandleRect, _normalHandle;
  double _longLineWidth = 0.0, _wrapWidth = double.infinity;
  bool _wrappedRowEstimateStale = true;
  bool _extentUpdateScheduled = false;
  List<int> _paintLines = const [];
  Timer? _resizeTimer;
  Timer? _bracketHighlightResumeTimer;
  int _lastProcessedContentVersion = -1;
  int? _highlightedLine;
  bool _suspendBracketHighlight = false;
  int _cachedLineCount = 0;
  late final CurvedAnimation _lineHighlightCurve;
  late final Animation<double> _lineHighlightAnimation;

  _CodeFieldRenderer({
    required this.controller,
    required this.vscrollController,
    required this.hscrollController,
    required this.focusNode,
    required this.caretBlinkController,
    required this.lineHighlightController,
    required this.isMobile,
    required this.selectionActiveNotifier,
    required this.onContextMenuRequest,
    required this.caretRectNotifier,
    required this.suggestionNotifier,
    required this.magnifierNotifier,
    required this._lineWrap,
    required this._editorTheme,
    required this._language,
    required this._readOnly,
    required this._gutterStyle,
    required this._selectionStyle,
    this._innerPadding,
    this._textStyle,
  }) {
    _applyTextStyle();
    _syntaxHighlighter = SyntaxHighlighter(
      language: _language,
      editorTheme: _editorTheme,
      baseTextStyle: _textStyle,
    );
    _layout = ViewLineLayout(rowHeight: _lineHeight)
      ..reset(controller.lineCount);

    _updateGutterWidth();
    _cachedLineCount = controller.lineCount;
    _lastProcessedContentVersion = controller.contentVersion;
    controller.documentReplaced = false;
    controller.clearDirtyRegion();

    vscrollController.addListener(_onVerticalScroll);
    hscrollController.addListener(_onHorizontalScroll);
    caretBlinkController.addListener(_onCaretBlink);
    controller.addListener(_onControllerChange);

    _lineHighlightCurve = CurvedAnimation(
      parent: lineHighlightController,
      curve: Curves.easeOut,
    );
    _lineHighlightAnimation = Tween<double>(
      begin: 0.55,
      end: 0.0,
    ).animate(_lineHighlightCurve)..addListener(markNeedsPaint);

    controller.setFoldCallback(_foldCallback);
    if (controller.lineCount > 10000) {
      _scheduleAsyncFoldComputation();
    }

    controller.setScrollCallback(_scrollCallback);
  }

  Map<String, TextStyle> get editorTheme => _editorTheme;
  Mode get language => _language;
  TextStyle? get textStyle => _textStyle;
  EdgeInsets? get innerPadding => _innerPadding;
  bool get readOnly => _readOnly;
  bool get lineWrap => _lineWrap;
  GutterStyle get gutterStyle => _gutterStyle;
  CodeSelectionStyle get selectionStyle => _selectionStyle;

  set editorTheme(Map<String, TextStyle> theme) {
    if (identical(theme, _editorTheme)) return;
    _editorTheme = theme;
    _applyColors();
    _rebuildHighlighter();
  }

  set language(Mode lang) {
    if (identical(lang, _language)) return;
    _language = lang;
    _rebuildHighlighter();
  }

  set textStyle(TextStyle? style) {
    if (identical(style, _textStyle)) return;
    _textStyle = style;
    _applyTextStyle();
    _updateGutterWidth();
    _rebuildHighlighter(layout: true);
  }

  set innerPadding(EdgeInsets? padding) {
    if (identical(padding, _innerPadding)) return;
    _innerPadding = padding;
    markNeedsLayout();
    markNeedsPaint();
  }

  set readOnly(bool value) {
    if (_readOnly == value) return;
    _readOnly = value;
    markNeedsPaint();
  }

  set lineWrap(bool value) {
    if (_lineWrap == value) return;
    _lineWrap = value;
    _invalidateAll(layout: true);
    markNeedsLayout();
    markNeedsPaint();
  }

  set gutterStyle(GutterStyle style) {
    if (identical(style, _gutterStyle)) return;
    _gutterStyle = style;
    _updateGutterWidth();
    markNeedsLayout();
    markNeedsPaint();
  }

  set selectionStyle(CodeSelectionStyle style) {
    if (identical(style, _selectionStyle)) return;
    _selectionStyle = style;
    _applyColors();
    markNeedsPaint();
  }

  // The caret only shows or hides as the blink crosses the midpoint, so the
  // ticks in between leave the painted field untouched.
  void _onCaretBlink() {
    final shown = caretBlinkController.value > 0.5;
    if (shown == _caretBlinkShown) return;
    _caretBlinkShown = shown;
    markNeedsPaint();
  }

  void _onVerticalScroll() {
    if (suggestionNotifier.value != null) _publishCaretRect();
    markNeedsPaint();
  }

  void _onHorizontalScroll() {
    if (suggestionNotifier.value != null) _publishCaretRect();
    markNeedsPaint();
  }

  void _onControllerChange() {
    if (controller.documentReplaced) {
      _resetForReplacedDocument();
      return;
    }

    if (controller.searchHighlightsChanged) {
      controller.searchHighlightsChanged = false;
      markNeedsPaint();
      return;
    }

    if (controller.imeCompositionChanged) {
      controller.imeCompositionChanged = false;
      _caretInfoCache.clear();
      if (!_isFoldToggleInProgress) {
        _ensureCaretVisible();
      }
      if (controller.contentVersion == _lastProcessedContentVersion) {
        markNeedsPaint();
        return;
      }
      controller.selectionOnly = false;
      controller.bufferNeedsRepaint = false;
    }

    if (controller.selectionOnly) {
      controller.selectionOnly = false;
      if (!_isFoldToggleInProgress) {
        _ensureCaretVisible();
      }

      if (isMobile && controller.selection.isCollapsed) {
        _showBubble = true;
      }

      markNeedsPaint();
      return;
    }

    if (controller.bufferNeedsRepaint) {
      controller.bufferNeedsRepaint = false;
      if (!_isFoldToggleInProgress) {
        _ensureCaretVisible();
      }
      markNeedsPaint();
      return;
    }

    final currentContentVersion = controller.contentVersion;
    if (currentContentVersion == _lastProcessedContentVersion) {
      return;
    }

    if (_showBubble && isMobile) {
      _showBubble = false;
    }

    _lastProcessedContentVersion = currentContentVersion;
    _invalidateCaret();
    _pauseBracketHighlightDuringTyping();

    final newLineCount = controller.lineCount;
    final lineCountChanged = newLineCount != _cachedLineCount;

    final edit = controller.lineEdit;
    if (edit != null) {
      _syntaxHighlighter.applyDocumentEdit(edit.line);
      _invalidateFrom(edit.line);
      if (_spliceLayout(edit)) _foldedLineCacheDirty = true;
      _applyLineEditToFolds(edit);
    }

    final affectedLine = controller.dirtyLine;
    if (affectedLine != null) {
      _lineWidthCache.remove(affectedLine);
      _lineTextCache.remove(affectedLine);
      _paragraphCache.remove(affectedLine);
      _layout.invalidate(affectedLine);
      _syntaxHighlighter.invalidateLines({affectedLine});
    }
    controller.clearDirtyRegion();

    if (lineCountChanged) {
      _cachedLineCount = newLineCount;
      _longLineWidth = 0.0;

      _updateGutterWidth();

      markNeedsLayout();
      markNeedsPaint();
      _scheduleCaretSyncAfterLayout();
    } else if (affectedLine != null) {
      final newLineWidth = _getLineWidth(affectedLine);
      final currentContentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      if (newLineWidth > currentContentWidth || newLineWidth > _longLineWidth) {
        _longLineWidth = newLineWidth;
        markNeedsLayout();
      } else {
        markNeedsPaint();
      }
    } else {
      markNeedsPaint();
    }

    if (focusNode.hasFocus && !_isFoldToggleInProgress) {
      _ensureCaretVisible();
    }
  }

  void _updateGutterWidth() {
    final digits = controller.lineCount.toString().length;
    _gutterWidth =
        digits * _gutterPadding * 0.6 + _foldIconStripWidth + _gutterPadding;
  }

  double get _foldIconStripWidth => _gutterPadding + 4;

  void _resetForReplacedDocument() {
    controller.documentReplaced = false;
    controller.selectionOnly = false;
    controller.bufferNeedsRepaint = false;
    controller.imeCompositionChanged = false;
    controller.clearDirtyRegion();

    _lastProcessedContentVersion = controller.contentVersion;
    _cachedLineCount = controller.lineCount;
    _showBubble = false;

    _syntaxHighlighter.invalidateAll();
    _layout.reset(_cachedLineCount);
    _invalidateAll(layout: true);
    _updateGutterWidth();

    _invalidateFoldRanges();

    markNeedsLayout();
    markNeedsPaint();
    if (focusNode.hasFocus) _scheduleCaretSyncAfterLayout();
  }

  @override
  void detach() {
    _bracketHighlightResumeTimer?.cancel();
    _resizeTimer?.cancel();
    _foldComputeTimer?.cancel();
    _selectionTimer?.cancel();
    super.detach();
  }

  @override
  void performLayout() {
    if (lineWrap) {
      final newWrapWidth =
          constraints.maxWidth - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final clampedWrapWidth = newWrapWidth < 100 ? 100.0 : newWrapWidth;

      if (_wrapWidth == double.infinity) {
        _resizeTimer?.cancel();
        _wrapWidth = clampedWrapWidth;
      } else if ((_wrapWidth - clampedWrapWidth).abs() > 1) {
        _resizeTimer?.cancel();
        _resizeTimer = Timer(const Duration(milliseconds: 150), () {
          _wrapWidth = clampedWrapWidth;
          _invalidateAll(layout: true);
          markNeedsLayout();
        });
      }
      _estimateWrappedRows();
    } else {
      _wrapWidth = double.infinity;
      _updateLongLineWidth(controller.lineCount);
    }

    final computedContentHeight = _lines.totalHeight + (innerPadding?.top ?? 0);
    final computedWidth = lineWrap
        ? constraints.maxWidth
        : _longLineWidth + (innerPadding?.left ?? 0) + _gutterWidth;

    size = constraints.constrain(
      Size(
        computedWidth + (innerPadding?.right ?? 0),
        computedContentHeight + (innerPadding?.bottom ?? 0),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final viewTop = _paintViewTop;
    final viewBottom = viewTop + vscrollController.position.viewportDimension;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.white;
    final textColor = textStyle?.color ?? editorTheme['root']!.color!;

    canvas.save();

    canvas.drawPaint(
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );

    final hasActiveFolds = _hasActiveFolds;
    final paintLines = _collectPaintLines(viewTop, viewBottom);
    _paintLines = paintLines;
    final firstVisibleLine = paintLines.first;
    final lastVisibleLine = paintLines.last;

    _pruneViewportCaches(firstVisibleLine, lastVisibleLine);
    var needsSyntaxHighlight = false;
    for (final i in paintLines) {
      if (!_syntaxHighlighter.hasCachedLineSpan(i, _lineText(i))) {
        needsSyntaxHighlight = true;
        break;
      }
    }
    if (needsSyntaxHighlight) {
      unawaited(
        _syntaxHighlighter
            .preHighlightLines(
              firstVisibleLine,
              lastVisibleLine,
              controller.getLineText,
            )
            .then((_) {
              _paragraphCache.removeWhere(
                (line, entry) =>
                    !entry.highlighted &&
                    line >= firstVisibleLine &&
                    line <= lastVisibleLine,
              );
              if (lineWrap && attached) markNeedsLayout();
              if (attached) markNeedsPaint();
            }),
      );
    }

    _drawSearchHighlights(canvas, offset, firstVisibleLine, lastVisibleLine);

    _drawLineHighlight(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      hasActiveFolds,
    );

    _drawFoldedLineHighlights(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      hasActiveFolds,
    );

    _drawSelection(canvas, offset, firstVisibleLine, lastVisibleLine);

    if ((lastVisibleLine - firstVisibleLine) < 200) {
      _drawIndentGuides(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        textColor,
      );
    }

    for (final i in paintLines) {
      final contentTop = _lineTop(i);
      final paragraph = _paragraphFor(i);

      final foldRange = _getFoldRangeAtLine(i);
      final isFoldStart =
          foldRange != null && foldRange.endIndex > foldRange.startIndex;

      final screenY = _screenY(offset, contentTop);
      canvas.drawParagraph(paragraph, Offset(_screenX(offset, 0), screenY));

      if (isFoldStart && foldRange.isFolded) {
        canvas.drawParagraph(
          _buildParagraph(' ...'),
          Offset(_screenX(offset, paragraph.longestLine), screenY),
        );
      }
    }

    _drawGutter(canvas, offset, bgColor, textStyle);

    canvas.save();
    if (!lineWrap && hscrollController.offset > 0) {
      canvas.clipRect(
        Rect.fromLTRB(
          offset.dx + _gutterWidth,
          offset.dy,
          offset.dx + size.width,
          offset.dy + size.height,
        ),
      );
    }

    if (focusNode.hasFocus) {
      _drawBracketHighlight(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        hasActiveFolds,
        textColor,
      );
    }

    _drawImeComposition(canvas, offset, hasActiveFolds);

    if (!_readOnly &&
        focusNode.hasFocus &&
        caretBlinkController.value > 0.5 &&
        controller.imeComposition == null) {
      final caretInfo = _getCaretInfo();
      canvas.drawRect(
        Rect.fromLTWH(
          _screenX(offset, caretInfo.offset.dx),
          _screenY(offset, caretInfo.offset.dy),
          1.5,
          caretInfo.height,
        ),
        _caretPainter,
      );
    }
    canvas.restore();

    if (isMobile) _paintMobileHandles(canvas, offset);
    _publishMagnifier();

    canvas.restore();

    _updateImeGeometry();
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    vscrollController.removeListener(_onVerticalScroll);
    hscrollController.removeListener(_onHorizontalScroll);
    caretBlinkController.removeListener(_onCaretBlink);
    _lineHighlightAnimation.removeListener(markNeedsPaint);
    _lineHighlightCurve.dispose();
    controller.releaseCallbacks(_scrollCallback, _foldCallback);
    _syntaxHighlighter.dispose();
    _dtap.dispose();
    _onetap.dispose();
    super.dispose();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final isHit =
        size.contains(position) ||
        (_startHandleRect?.contains(position) ?? false) ||
        (_endHandleRect?.contains(position) ?? false) ||
        _hitsCaretHandle(position);
    if (isHit) result.add(BoxHitTestEntry(this, position));
    return isHit;
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    final localPosition = event.localPosition;
    _currentPosition = localPosition;
    final contentPosition = _toContent(localPosition);
    late final textOffset = _getTextOffsetFromPosition(contentPosition);

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _gutterSelectionAnchor = null;
    }

    if ((event is PointerDownEvent && event.buttons == kSecondaryButton) ||
        (event is PointerUpEvent &&
            isMobile &&
            _selectionActive &&
            controller.selection.start != controller.selection.end)) {
      _draggingStartHandle = false;
      _draggingEndHandle = false;
      _draggingCHandle = false;
      _isDragging = false;
      onContextMenuRequest(localPosition);
      markNeedsPaint();
      return;
    }

    if (event is PointerDownEvent && event.buttons == kPrimaryButton) {
      if (controller.connection == null ||
          !controller.connection!.attached ||
          !focusNode.hasFocus) {
        focusNode.requestFocus();
        final connection = controller.connection;
        if (focusNode.hasFocus && (connection?.attached ?? false)) {
          connection!.setEditingState(
            TextEditingValue(
              text: controller.text,
              selection: controller.selection,
            ),
          );
        }
      }
      _onetap.addPointer(event);
      try {
        suggestionNotifier.value = null;
      } catch (e) {
        debugPrint(e.toString());
      }

      if (localPosition.dx < _gutterWidth) {
        final line = _lineAtY(contentPosition.dy);
        final fold = _foldIconAt(localPosition, line);
        if (fold != null) {
          _toggleFold(fold);
        } else {
          _selectLinesFromGutter(line);
        }
        return;
      }

      if (isMobile) {
        _dtap.addPointer(event);
        _draggingCHandle = false;
        _draggingStartHandle = false;
        _draggingEndHandle = false;

        _dtap.onDoubleTap = () {
          _selectWordAtOffset(textOffset);
          onContextMenuRequest(localPosition);
        };

        if (controller.selection.start != controller.selection.end) {
          if (_startHandleRect?.contains(localPosition) ?? false) {
            _draggingStartHandle = true;
            _selectionActive = selectionActiveNotifier.value = true;
            _pointerDownPosition = localPosition;
            _dragStartOffset = controller.selection.start;
            markNeedsPaint();
            return;
          }
          if (_endHandleRect?.contains(localPosition) ?? false) {
            _draggingEndHandle = true;
            _selectionActive = selectionActiveNotifier.value = true;
            _pointerDownPosition = localPosition;
            _dragStartOffset = controller.selection.end;
            markNeedsPaint();
            return;
          }
        } else if (controller.selection.isCollapsed &&
            _hitsCaretHandle(localPosition)) {
          _draggingCHandle = true;
          _selectionActive = selectionActiveNotifier.value = true;
          _dragStartOffset = textOffset;
          controller.selection = TextSelection.collapsed(offset: textOffset);
          _pointerDownPosition = localPosition;
          return;
        }

        _dragStartOffset = textOffset;
        _isDragging = false;
        _pointerDownPosition = localPosition;
        _selectionActive = false;
        selectionActiveNotifier.value = false;

        _selectionTimer?.cancel();
        _selectionTimer = Timer(const Duration(milliseconds: 500), () {
          _selectWordAtOffset(textOffset);
        });
      } else {
        controller.focusNode?.requestFocus();
        _dtap.addPointer(event);
        _dtap.onDoubleTap = () {
          _selectWordAtOffset(textOffset);
        };

        _dragStartOffset = textOffset;
        _onetap.onTap = () {
          if (suggestionNotifier.value != null) {
            suggestionNotifier.value = null;
          }
        };

        if (HardwareKeyboard.instance.isShiftPressed) {
          _dragStartOffset = controller.selection.baseOffset;
          controller.selection = TextSelection(
            baseOffset: _dragStartOffset!,
            extentOffset: textOffset,
          );
        } else {
          controller.selection = TextSelection.collapsed(offset: textOffset);
        }
      }
    }

    if (event is PointerMoveEvent && _gutterSelectionAnchor != null) {
      _extendGutterSelection(_lineAtY(contentPosition.dy));
      return;
    }

    if (event is PointerMoveEvent && _dragStartOffset != null) {
      if (isMobile) {
        if (_draggingCHandle) {
          final adjustedTextOffset = _getTextOffsetFromPosition(
            contentPosition.translate(0, -_lineHeight - _handleRadius),
          );
          controller.selection = TextSelection.collapsed(
            offset: adjustedTextOffset,
          );
          _showBubble = true;
          markNeedsLayout();
          markNeedsPaint();
          return;
        }

        if (_draggingStartHandle || _draggingEndHandle) {
          final adjustedTextOffset = _getTextOffsetFromPosition(
            contentPosition.translate(0, -_lineHeight - _handleRadius),
          );
          final base = controller.selection.start;
          final extent = controller.selection.end;

          if (_draggingStartHandle) {
            controller.selection = TextSelection(
              baseOffset: adjustedTextOffset,
              extentOffset: extent,
            );
            if (adjustedTextOffset > extent) {
              _draggingStartHandle = false;
              _draggingEndHandle = true;
            }
          } else {
            controller.selection = TextSelection(
              baseOffset: base,
              extentOffset: adjustedTextOffset,
            );
            if (adjustedTextOffset < base) {
              _draggingEndHandle = false;
              _draggingStartHandle = true;
            }
          }
          markNeedsLayout();
          markNeedsPaint();
          return;
        }

        if ((localPosition - (_pointerDownPosition ?? localPosition)).distance >
            10) {
          _isDragging = true;
          suggestionNotifier.value = null;

          _selectionTimer?.cancel();
        }

        if (_isDragging && !_selectionActive) {
          return;
        }

        if (_selectionActive) {
          controller.selection = TextSelection(
            baseOffset: _dragStartOffset!,
            extentOffset: textOffset,
          );
          markNeedsPaint();
        }
      } else {
        controller.selection = TextSelection(
          baseOffset: _dragStartOffset!,
          extentOffset: textOffset,
        );
      }
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (!_isDragging && isMobile && !_selectionActive) {
        controller.selection = TextSelection.collapsed(offset: textOffset);
        if (controller.connection?.attached ?? false) {
          if (readOnly) return;
          controller.connection?.show();
        }
      }

      _draggingStartHandle = false;
      _draggingEndHandle = false;
      _draggingCHandle = false;
      _pointerDownPosition = null;
      _dragStartOffset = null;
      _selectionTimer?.cancel();

      final wasDragging = _isDragging;
      _isDragging = false;
      _selectionActive = selectionActiveNotifier.value = false;

      markNeedsPaint();

      if (readOnly) return;
      if (!wasDragging) {
        controller.notifyListeners();
      }

      if (isMobile && controller.selection.isCollapsed) {
        _showBubble = true;
      }
    }
  }

  @override
  MouseCursor get cursor {
    final position = _currentPosition;
    if (position.dx < 0 || position.dx >= _gutterWidth) {
      return SystemMouseCursors.text;
    }
    final line = _lineAtY(_toContent(position).dy);
    return _foldIconAt(position, line) != null
        ? SystemMouseCursors.click
        : MouseCursor.defer;
  }

  @override
  PointerEnterEventListener? get onEnter => null;

  @override
  PointerExitEventListener? get onExit => null;

  @override
  bool get validForMouseTracker => true;
}
