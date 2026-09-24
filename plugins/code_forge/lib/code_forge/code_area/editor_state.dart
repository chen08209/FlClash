part of '../code_area.dart';

class _CodeForgeState extends State<CodeForge>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements CodeForgeView {
  late final ScrollController _hscrollController, _vscrollController;
  late CodeForgeController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _caretBlinkController;
  late final AnimationController _lineHighlightController;
  late CodeSelectionStyle _selectionStyle;
  late GutterStyle _gutterStyle;
  late final ValueNotifier<bool> _selectionActiveNotifier;
  late UndoRedoController _undoRedoController;
  late FindController _findController;
  late bool _ownsUndoController, _ownsFindController;
  late final VoidCallback _controllerListener;
  late final VoidCallback _scrollbarLineNumberListener;
  final ValueNotifier<Rect?> _caretRectNotifier = ValueNotifier(null);
  final ValueNotifier<int> _scrollbarLineNumberIndicator = ValueNotifier(1);
  final ValueNotifier<MagnifierInfo?> _magnifierNotifier = ValueNotifier(null);
  final ValueNotifier<MagnifierInfo> _magnifierInfo = ValueNotifier(
    MagnifierInfo.empty,
  );
  final MagnifierController _magnifierController = MagnifierController();
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  GlobalKey _codeFieldKey = GlobalKey();
  final GlobalKey _editorStackKey = GlobalKey();
  TextInputConnection? _connection;
  bool _isHovering = false;
  double _lastBottomViewInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();
    _hscrollController = ScrollController();
    _vscrollController = ScrollController();
    _selectionActiveNotifier = ValueNotifier(false);
    _magnifierNotifier.addListener(_syncMagnifier);
    _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();

    _gutterStyle = _gutterStyleFor(widget.editorTheme);

    _caretBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _lineHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _focusNode
      ..addListener(_handleFocusChange)
      ..addListener(_resetCursorBlink);

    _controllerListener = () {
      _resetCursorBlink();
      _updateScrollbarLineNumberIndicator();
    };

    _attachController();

    _scrollbarLineNumberListener = _updateScrollbarLineNumberIndicator;
    _vscrollController.addListener(_scrollbarLineNumberListener);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateScrollbarLineNumberIndicator(),
    );
  }

  _CodeFieldRenderer? get _renderer {
    final renderObject = _codeFieldKey.currentContext?.findRenderObject();
    return renderObject is _CodeFieldRenderer ? renderObject : null;
  }

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void resetInput() => _resetImeConnection();

  @override
  Offset? caretOffset() => _renderer?.getCaretOffset();

  @override
  int? textOffsetAt(Offset position) =>
      _renderer?._getTextOffsetFromPosition(position);

  @override
  void toggleFold(int line) => _renderer?._toggleFoldAtLine(line);

  @override
  void scrollToLine(int line) => _renderer?._scrollToLine(line);

  GutterStyle _gutterStyleFor(Map<String, TextStyle> theme) {
    final themeColor = theme['root']?.color;
    return GutterStyle(
      foldIconColor: themeColor,
      backgroundColor: theme['root']?.backgroundColor,
      lineNumberStyle: widget.lineNumberStyle,
    );
  }

  @override
  void didUpdateWidget(covariant CodeForge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.editorTheme, oldWidget.editorTheme) ||
        widget.lineNumberStyle != oldWidget.lineNumberStyle) {
      _gutterStyle = _gutterStyleFor(widget.editorTheme);
    }
    if (widget.selectionStyle != oldWidget.selectionStyle) {
      _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();
    }

    if (!identical(widget.controller, oldWidget.controller)) {
      _detachController();
      _attachController();
      _codeFieldKey = GlobalKey();
      _openImeConnection();
    } else {
      if (!identical(widget.findController, oldWidget.findController)) {
        _detachFindController();
        _attachFindController();
      }
      if (!identical(widget.undoController, oldWidget.undoController)) {
        _detachUndoController();
        _attachUndoController();
      }
    }

    _controller
      ..useSpaceAsTab = widget.useSpaceAsTab
      ..tabSize = widget._tabSize;
    if (widget.readOnly != oldWidget.readOnly) {
      _controller.readOnly = widget.readOnly;
      _resetCursorBlink();
      if (widget.readOnly) {
        _closeImeConnection();
      } else {
        _openImeConnection();
      }
    }
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final bottomInset = View.of(context).viewInsets.bottom;
    final insetGrew = bottomInset > _lastBottomViewInset;
    _lastBottomViewInset = bottomInset;
    if (!insetGrew || !_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderer = _renderer;
      if (renderer != null && renderer.attached) renderer._ensureCaretVisible();
    });
  }

  void _syncMagnifier() {
    final builder = widget.magnifierBuilder;
    final info = _magnifierNotifier.value;
    if (builder == null) return;
    if (info == null) {
      if (_magnifierController.shown) _magnifierController.hide();
      return;
    }
    _magnifierInfo.value = info;
    if (_magnifierController.overlayEntry != null) return;
    _magnifierController.show(
      context: context,
      builder: (context) =>
          builder(context, _magnifierController, _magnifierInfo) ??
          const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vscrollController.removeListener(_scrollbarLineNumberListener);
    _detachController();
    _caretBlinkController.dispose();
    _lineHighlightController.dispose();
    _selectionActiveNotifier.dispose();
    _caretRectNotifier.dispose();
    _magnifierNotifier.dispose();
    _magnifierController.hide();
    _magnifierInfo.dispose();
    _scrollbarLineNumberIndicator.dispose();
    _focusNode.dispose();
    _hscrollController.dispose();
    _vscrollController.dispose();
    super.dispose();
  }

  void _attachController() {
    _controller = widget.controller
      ..attachView(this)
      ..readOnly = widget.readOnly
      ..tabSize = widget._tabSize
      ..useSpaceAsTab = widget.useSpaceAsTab
      ..addListener(_controllerListener);
    _attachFindController();
    _attachUndoController();
  }

  void _attachFindController() {
    _ownsFindController = widget.findController == null;
    _findController = widget.findController ?? FindController(_controller);
  }

  void _attachUndoController() {
    _ownsUndoController = widget.undoController == null;
    _undoRedoController = widget.undoController ?? UndoRedoController();
    _controller.setUndoController(_undoRedoController);
  }

  // A re-keyed editor mounts its replacement on the same controller before
  // this state is disposed, so only hooks still pointing here are cleared.
  void _detachController() {
    _controller.removeListener(_controllerListener);
    _closeImeConnection();
    _detachUndoController();
    _detachFindController();
    _controller.detachView(this);
  }

  void _detachFindController() {
    if (_ownsFindController) _findController.dispose();
  }

  bool get _isControllerView => identical(_controller.focusNode, _focusNode);

  void _detachUndoController() {
    if (_isControllerView &&
        _controller.undoController == _undoRedoController) {
      _controller.setUndoController(null);
    }
    if (_ownsUndoController) _undoRedoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.finderBuilder != null)
          ListenableBuilder(
            listenable: _findController,
            builder: (context, _) {
              if (!_findController.isActive) {
                return const SizedBox.shrink();
              }
              return widget.finderBuilder!(context, _findController);
            },
          ),
        Expanded(
          child: Stack(
            key: _editorStackKey,
            children: [
              _buildVerticalScrollbar(
                context,
                RawScrollbar(
                  thumbVisibility: _isHovering,
                  controller: _hscrollController,
                  child: GestureDetector(
                    onTap: () {
                      if (_isMobile) return;
                      _focusNode.requestFocus();
                    },
                    child: MouseRegion(
                      onEnter: (event) {
                        if (mounted) {
                          setState(() => _isHovering = true);
                        }
                      },
                      onExit: (event) {
                        if (mounted) {
                          setState(() => _isHovering = false);
                        }
                      },
                      child: ValueListenableBuilder(
                        valueListenable: _selectionActiveNotifier,
                        builder: (context, selVal, child) {
                          return TwoDimensionalScrollable(
                            horizontalDetails: ScrollableDetails.horizontal(
                              controller: _hscrollController,
                              physics: selVal
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                            ),
                            verticalDetails: ScrollableDetails.vertical(
                              controller: _vscrollController,
                              physics: selVal
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                            ),
                            viewportBuilder: (_, voffset, hoffset) =>
                                CustomViewport(
                                  verticalOffset: voffset,
                                  verticalAxisDirection: AxisDirection.down,
                                  horizontalOffset: hoffset,
                                  horizontalAxisDirection: AxisDirection.right,
                                  mainAxis: Axis.vertical,
                                  lineWrap: widget.lineWrap,
                                  delegate: TwoDimensionalChildBuilderDelegate(
                                    maxXIndex: 0,
                                    maxYIndex: 0,
                                    builder: (_, vic) {
                                      return Focus(
                                        focusNode: _focusNode,
                                        onKeyEvent: _handleKeyEvent,
                                        child: _CodeField(
                                          key: _codeFieldKey,
                                          controller: _controller,
                                          editorTheme: widget.editorTheme,
                                          language: widget.language,
                                          innerPadding: widget.innerPadding,
                                          vscrollController: _vscrollController,
                                          hscrollController: _hscrollController,
                                          focusNode: _focusNode,
                                          readOnly: _readOnly,
                                          caretBlinkController:
                                              _caretBlinkController,
                                          lineHighlightController:
                                              _lineHighlightController,
                                          textStyle: widget.textStyle,
                                          gutterStyle: _gutterStyle,
                                          selectionStyle: _selectionStyle,
                                          isMobile: _isMobile,
                                          selectionActiveNotifier:
                                              _selectionActiveNotifier,
                                          onContextMenuRequest:
                                              _handleContextMenuRequest,
                                          lineWrap: widget.lineWrap,
                                          caretRectNotifier: _caretRectNotifier,
                                          magnifierNotifier: _magnifierNotifier,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: _caretRectNotifier,
                  builder: (context, caretRect, child) {
                    if (caretRect == null) return const SizedBox.shrink();
                    return ValueListenableBuilder(
                      valueListenable: _controller.suggestionsNotifier,
                      builder: (_, sugg, child) {
                        if (sugg == null || sugg.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ValueListenableBuilder(
                          valueListenable:
                              _controller.selectedSuggestionNotifier,
                          builder: (context, selected, child) =>
                              _buildSuggestionPopup(
                                context,
                                sugg,
                                selected,
                                caretRect,
                              ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
