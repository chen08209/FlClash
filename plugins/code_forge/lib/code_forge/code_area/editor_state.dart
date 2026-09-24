part of '../code_area.dart';

class _CodeForgeState extends State<CodeForge>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final ScrollController _hscrollController, _vscrollController;
  late final CodeForgeController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _caretBlinkController;
  late final AnimationController _lineHighlightController;
  late CodeSelectionStyle _selectionStyle;
  late GutterStyle _gutterStyle;
  late final ValueNotifier<List<CodeForgeSuggestion>?> _suggestionNotifier;
  late final ValueNotifier<bool> _selectionActiveNotifier;
  late final UndoRedoController _undoRedoController;
  late final FindController _findController;
  late final bool _ownsUndoController, _ownsFindController;
  late final VoidCallback _controllerListener;
  late final VoidCallback _scrollbarLineNumberListener;
  late final Offset? Function() _floatingCursorStart;
  late final int Function(Offset) _floatingCursorOffset;
  late final VoidCallback _imeReset;
  final ValueNotifier<Rect?> _caretRectNotifier = ValueNotifier(null);
  final ValueNotifier<int> _scrollbarLineNumberIndicator = ValueNotifier(1);
  final ValueNotifier<MagnifierInfo?> _magnifierNotifier = ValueNotifier(null);
  final ValueNotifier<MagnifierInfo> _magnifierInfo = ValueNotifier(
    MagnifierInfo.empty,
  );
  final MagnifierController _magnifierController = MagnifierController();
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final GlobalKey _codeFieldKey = GlobalKey();
  final GlobalKey _editorStackKey = GlobalKey();
  TextInputConnection? _connection;
  bool _isHovering = false;
  double _lastBottomViewInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = widget.controller;

    _floatingCursorStart = () {
      final renderObject = _codeFieldKey.currentContext?.findRenderObject();
      if (renderObject is _CodeFieldRenderer) {
        return renderObject.getCaretOffset();
      }
      return null;
    };
    _controller.getFloatingCursorStartPosition = _floatingCursorStart;

    _floatingCursorOffset = (Offset position) {
      final renderObject = _codeFieldKey.currentContext?.findRenderObject();
      if (renderObject is _CodeFieldRenderer) {
        return renderObject._getTextOffsetFromPosition(position);
      }
      return _controller.selection.baseOffset;
    };
    _controller.getTextOffsetForFloatingCursorPosition = _floatingCursorOffset;

    _ownsFindController = widget.findController == null;
    _findController = widget.findController ?? FindController(_controller);
    _focusNode = FocusNode();
    _controller.focusNode = _focusNode;
    _hscrollController = ScrollController();
    _vscrollController = ScrollController();
    _suggestionNotifier = _controller.suggestionsNotifier;
    _selectionActiveNotifier = ValueNotifier(false);
    _magnifierNotifier.addListener(_syncMagnifier);
    _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();
    _ownsUndoController = widget.undoController == null;
    _undoRedoController = widget.undoController ?? UndoRedoController();
    _controller.setUndoController(_undoRedoController);
    _controller.readOnly = widget.readOnly;

    if (widget._tabSize != _controller.tabSize) {
      _controller.tabSize = widget._tabSize;
    }

    if (widget.useSpaceAsTab != _controller.useSpaceAsTab) {
      _controller.useSpaceAsTab = widget.useSpaceAsTab;
    }

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
      ..addListener(_openImeConnection)
      ..addListener(_resetCursorBlink);

    _imeReset = _resetImeConnection;
    _controller.requestImeReset = _imeReset;

    _controllerListener = () {
      _resetCursorBlink();
      _updateScrollbarLineNumberIndicator();
    };

    _controller.addListener(_controllerListener);

    _scrollbarLineNumberListener = _updateScrollbarLineNumberIndicator;
    _vscrollController.addListener(_scrollbarLineNumberListener);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateScrollbarLineNumberIndicator(),
    );
  }

  GutterStyle _gutterStyleFor(Map<String, TextStyle> theme) {
    final themeColor = theme['root']?.color;
    return GutterStyle(
      foldIconColor: themeColor,
      backgroundColor: theme['root']?.backgroundColor,
    );
  }

  @override
  void didUpdateWidget(covariant CodeForge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.editorTheme, oldWidget.editorTheme)) {
      _gutterStyle = _gutterStyleFor(widget.editorTheme);
    }
    if (widget.selectionStyle != oldWidget.selectionStyle) {
      _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();
    }

    final newTabSize = widget.tabSize ?? (widget.useSpaceAsTab ? 2 : 1);
    _controller.useSpaceAsTab = widget.useSpaceAsTab;
    _controller.tabSize = newTabSize;
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
      final renderObject = _codeFieldKey.currentContext?.findRenderObject();
      if (renderObject is _CodeFieldRenderer && renderObject.attached) {
        renderObject._ensureCaretVisible();
      }
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
    _controller.removeListener(_controllerListener);
    _vscrollController.removeListener(_scrollbarLineNumberListener);
    _connection?.close();
    _releaseController();
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
    if (_ownsFindController) _findController.dispose();
    if (_ownsUndoController) _undoRedoController.dispose();
    super.dispose();
  }

  // A re-keyed editor mounts its replacement on the same controller before
  // this state is disposed, so only hooks still pointing here are cleared.
  void _releaseController() {
    final controller = _controller;
    if (controller.focusNode == _focusNode) controller.focusNode = null;
    if (_connection != null && controller.connection == _connection) {
      controller.connection = null;
    }
    if (controller.requestImeReset == _imeReset) {
      controller.requestImeReset = null;
    }
    if (controller.getFloatingCursorStartPosition == _floatingCursorStart) {
      controller.getFloatingCursorStartPosition = null;
    }
    if (controller.getTextOffsetForFloatingCursorPosition ==
        _floatingCursorOffset) {
      controller.getTextOffsetForFloatingCursorPosition = null;
    }
    if (controller.undoController == _undoRedoController) {
      controller.setUndoController(null);
    }
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
                                          suggestionNotifier:
                                              _suggestionNotifier,
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
                      valueListenable: _suggestionNotifier,
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
