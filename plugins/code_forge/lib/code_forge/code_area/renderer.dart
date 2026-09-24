part of '../code_area.dart';

typedef _LineSlice = ({
  String text,
  int start,
  int end,
  int scalarStart,
  int scalarEnd,
  Offset origin,
  Rect cover,
  ui.Paragraph paragraph,
});

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
  final ValueNotifier<MagnifierInfo?> magnifierNotifier;
  final Map<int, double> _lineWidthCache = {};
  final Map<int, String> _lineTextCache = {};
  final Map<int, ({String text, ui.Paragraph paragraph, bool highlighted})>
  _paragraphCache = {};
  final Map<int, _LineSlice> _lineSlices = {};
  bool _wholeLines = false;
  late TextSelection _seenSelection;
  ({String source, String shown})? _bufferLineCut;
  ui.Paragraph? _cutMarker, _foldMarker;
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
  _Press? _press;
  _DraggedHandle? _draggedHandle;
  Offset _handleGrip = Offset.zero;
  ({int start, int end})? _gutterSelectionAnchor;
  bool _foldTapped = false;
  Timer? _selectionTimer;
  Offset _currentPosition = Offset.zero;
  bool _isFoldToggleInProgress = false, _lineWrap;
  bool _hasActiveFoldsCache = false, _foldLayoutPending = false;
  bool _foldedLineCacheDirty = true;
  bool _asyncFoldComputationPending = false;
  int _asyncFoldsVersion = -1;
  Timer? _foldComputeTimer, _foldCacheRecheckTimer;
  bool _isDragging = false, _showBubble = false, _readOnly;
  bool _caretSyncAfterLayoutScheduled = false;
  bool _caretBlinkShown = false;
  Rect? _startHandleRect, _endHandleRect, _normalHandle;
  double _longLineWidth = 0.0, _wrapWidth = double.infinity;
  bool _wrappedRowEstimateStale = true;
  bool _extentUpdateScheduled = false;
  List<int> _paintLines = const [];
  Timer? _resizeTimer;
  Timer? _bracketHighlightResumeTimer;
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
    controller.takeChange();
    if (!isMobile) {
      _onetap.onTap = () => controller.suggestionsNotifier.value = null;
    }

    vscrollController.addListener(_onScroll);
    hscrollController.addListener(_onScroll);
    caretBlinkController.addListener(_onCaretBlink);
    controller.addListener(_onControllerChange);
    _seenSelection = controller.selection;

    _lineHighlightCurve = CurvedAnimation(
      parent: lineHighlightController,
      curve: Curves.easeOut,
    );
    _lineHighlightAnimation = Tween<double>(
      begin: 0.55,
      end: 0.0,
    ).animate(_lineHighlightCurve)..addListener(markNeedsPaint);

    _adoptControllerFolds();
    if (_foldsInBackground) _scheduleAsyncFoldComputation();
  }

  Map<String, TextStyle> get editorTheme => _editorTheme;
  Mode get language => _language;
  TextStyle? get textStyle => _textStyle;
  EdgeInsets? get innerPadding => _innerPadding;
  bool get readOnly => _readOnly;
  bool get _selectionActive => selectionActiveNotifier.value;
  set _selectionActive(bool value) => selectionActiveNotifier.value = value;
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

  void _onScroll() {
    if (controller.suggestions != null) _publishCaretRect();
    markNeedsPaint();
  }

  void _onControllerChange() {
    final change = controller.takeChange();
    if (change.replaced) {
      _seenSelection = controller.selection;
      _resetForReplacedDocument();
      return;
    }
    final edit = change.lines;
    if (edit != null) _applyEdit(edit);
    _showWholeLinesPastCaret();
    if (change.isEmpty) return;

    final caretMoved = change.selection || change.composition || change.typing;
    if (caretMoved) _revealCaret();
    if (change.composition) _caretInfoCache.clear();
    if (edit == null && change.typing) {
      _invalidateCaret();
      _pauseBracketHighlightDuringTyping();
    } else if (edit == null &&
        change.selection &&
        isMobile &&
        controller.selection.isCollapsed) {
      _showBubble = true;
    }
    markNeedsPaint();

    // An edit from the find panel leaves the view where it is.
    if (!_isFoldToggleInProgress &&
        (caretMoved || (edit != null && focusNode.hasFocus))) {
      _ensureCaretVisible();
    }
  }

  void _applyEdit(({int line, int removed, int inserted}) edit) {
    if (isMobile) _showBubble = false;
    _pauseBracketHighlightDuringTyping();
    _invalidateFrom(edit);
    if (_spliceLayout(edit)) _foldedLineCacheDirty = true;
    _applyLineEditToFolds(edit);

    final lineCount = controller.lineCount;
    if (lineCount != _cachedLineCount) {
      _cachedLineCount = lineCount;
      _longLineWidth = 0.0;
      _updateGutterWidth();
      markNeedsLayout();
      _scheduleCaretSyncAfterLayout();
      return;
    }
    final width = _getLineWidth(edit.line);
    final contentWidth =
        size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    if (width > contentWidth || width > _longLineWidth) {
      _longLineWidth = width;
      markNeedsLayout();
      // The view can follow the caret only once layout has widened it.
      if (focusNode.hasFocus) _scheduleCaretSyncAfterLayout();
    }
  }

  void _updateGutterWidth() {
    final digits = controller.lineCount.toString().length;
    _gutterWidth = digits * _lineNumberFontSize * 0.6 + _foldIconStripWidth * 2;
  }

  double get _lineNumberFontSize =>
      gutterStyle.lineNumberStyle?.fontSize ?? _gutterPadding;

  double get _foldIconSize => _lineNumberFontSize + 4;

  double get _foldIconStripWidth => _foldIconSize + 4;

  void _resetForReplacedDocument() {
    _cachedLineCount = controller.lineCount;
    _showBubble = false;

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
    _foldCacheRecheckTimer?.cancel();
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
    _foldLayoutPending = false;
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
      if (!_syntaxHighlighter.hasLineSpan(_lineText(i))) {
        needsSyntaxHighlight = true;
        break;
      }
    }
    if (needsSyntaxHighlight) {
      unawaited(
        _syntaxHighlighter
            .preHighlightLines(paintLines, controller.getLineText)
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
      _drawLine(canvas, i, paragraph, Offset(_screenX(offset, 0), screenY));

      var lineEnd = paragraph.longestLine;
      if (_isCut(i)) {
        canvas.drawParagraph(
          _cutMarkerParagraph,
          Offset(_screenX(offset, lineEnd), screenY),
        );
        lineEnd += _cutMarkerParagraph.longestLine;
      }
      if (isFoldStart && foldRange.isFolded) {
        canvas.drawParagraph(
          _foldMarkerParagraph,
          Offset(_screenX(offset, lineEnd), screenY),
        );
      }
    }

    _lineSlices.removeWhere(
      (line, _) => line < firstVisibleLine || line > lastVisibleLine,
    );

    _drawGutter(
      canvas,
      offset,
      bgColor,
      gutterStyle.lineNumberStyle ?? textStyle,
    );

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
    vscrollController.removeListener(_onScroll);
    hscrollController.removeListener(_onScroll);
    caretBlinkController.removeListener(_onCaretBlink);
    _lineHighlightAnimation.removeListener(markNeedsPaint);
    _lineHighlightCurve.dispose();
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
    _currentPosition = event.localPosition;
    switch (event) {
      case PointerDownEvent():
        _onPointerDown(event);
      case PointerMoveEvent():
        _onPointerMove(event);
      case PointerUpEvent() || PointerCancelEvent():
        _onPointerUp(event);
    }
  }

  @override
  MouseCursor get cursor {
    final position = _currentPosition;
    if (_foldMarkerAt(position) != null) return SystemMouseCursors.click;
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
