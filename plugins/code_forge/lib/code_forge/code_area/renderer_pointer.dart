part of '../code_area.dart';

typedef _Press = ({Offset position, int offset});

enum _DraggedHandle { caret, start, end }

extension _RendererPointer on _CodeFieldRenderer {
  void _onPointerDown(PointerDownEvent event) {
    final position = event.localPosition;
    final content = _toContent(position);
    if (event.buttons == kPrimaryButton && _toggleFoldAt(position, content)) {
      _foldTapped = true;
      controller.suggestionsNotifier.value = null;
      return;
    }
    if (_pastCut(content)) _showWholeLines();
    switch (event.buttons) {
      case kSecondaryButton:
        _openContextMenu(position);
      case kPrimaryButton:
        _onPrimaryDown(event, content);
    }
  }

  bool _toggleFoldAt(Offset position, Offset content) {
    final fold = _foldControlAt(position, content);
    return fold != null && _toggleFold(fold);
  }

  FoldRange? _foldControlAt(Offset position, Offset content) {
    if (_isOnTouchHandle(position)) return null;
    if (position.dx >= _gutterWidth) return _foldMarkerAt(position);
    return _foldIconAt(position, _lineAtY(content.dy));
  }

  void _takeFocus() {
    if (!(controller.connection?.attached ?? false) || !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
    controller.suggestionsNotifier.value = null;
  }

  void _onPrimaryDown(PointerDownEvent event, Offset content) {
    _takeFocus();
    _onetap.addPointer(event);

    final position = event.localPosition;
    if (position.dx < _gutterWidth && !_isOnTouchHandle(position)) {
      _selectLinesFromGutter(_lineAtY(content.dy));
      return;
    }

    _dtap
      ..onDoubleTap = () {
        _selectWordAtOffset(_committedOffsetAt(position));
        if (isMobile) onContextMenuRequest(position);
      }
      ..addPointer(event);
    if (isMobile) {
      _onMobileDown(position, _getTextOffsetFromPosition(content));
    } else {
      _onDesktopDown(position, _committedOffsetAt(position));
    }
  }

  // The layout holds the document without a composition in progress, which
  // is only painted over it; a press that places the caret commits it first.
  int _committedOffsetAt(Offset position) {
    controller.commitComposition();
    return _getTextOffsetFromPosition(_toContent(position));
  }

  void _onMobileDown(Offset position, int offset) {
    _press = (position: position, offset: offset);
    final handle = _draggedHandle = _handleAt(position);
    if (handle == null) {
      _isDragging = false;
      _selectionActive = false;
      _selectionTimer?.cancel();
      _selectionTimer = Timer(const Duration(milliseconds: 500), () {
        final word = _committedOffsetAt(position);
        _press = (position: position, offset: word);
        _selectionActive = true;
        _selectWordAtOffset(word);
      });
      return;
    }
    _handleGrip = _textPointOf(handle) - position;
    controller.commitComposition();
    _selectionActive = true;
    markNeedsPaint();
  }

  // The middle of the line at the text position [handle] hangs below, which
  // the finger then moves from wherever on the handle it came down.
  Offset _textPointOf(_DraggedHandle handle) {
    final rise = -_handleRadius - _lineHeight / 2;
    return switch (handle) {
      _DraggedHandle.caret => _normalHandle!.center.translate(0, rise),
      _DraggedHandle.start => _startHandleRect!.center.translate(
        _handleOverhang,
        rise,
      ),
      _DraggedHandle.end => _endHandleRect!.center.translate(
        -_handleOverhang,
        rise,
      ),
    };
  }

  // A handle at the start of a line hangs over the gutter.
  bool _isOnTouchHandle(Offset position) =>
      isMobile &&
      [
        _normalHandle,
        _startHandleRect,
        _endHandleRect,
      ].any((handle) => handle?.contains(position) ?? false);

  _DraggedHandle? _handleAt(Offset position) {
    if (controller.selection.isCollapsed) {
      return _hitsCaretHandle(position) ? _DraggedHandle.caret : null;
    }
    if (_startHandleRect?.contains(position) ?? false) {
      return _DraggedHandle.start;
    }
    if (_endHandleRect?.contains(position) ?? false) return _DraggedHandle.end;
    return null;
  }

  void _onDesktopDown(Offset position, int offset) {
    final base = HardwareKeyboard.instance.isShiftPressed
        ? controller.selection.baseOffset
        : offset;
    _press = (position: position, offset: base);
    controller.selection = TextSelection(
      baseOffset: base,
      extentOffset: offset,
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    final content = _toContent(event.localPosition);
    if (_gutterSelectionAnchor != null) {
      _extendGutterSelection(_lineAtY(content.dy));
    } else if (_press case final press?) {
      if (isMobile) {
        _onMobileMove(event.localPosition, content, press);
      } else {
        _selectFrom(press.offset, content);
      }
    }
  }

  void _onMobileMove(Offset position, Offset content, _Press press) {
    if (_draggedHandle case final handle?) {
      _dragHandle(handle, _getTextOffsetFromPosition(content + _handleGrip));
      return;
    }
    if ((position - press.position).distance > 10) {
      _isDragging = true;
      controller.suggestionsNotifier.value = null;
      _selectionTimer?.cancel();
    }
    if (!_selectionActive) return;
    _selectFrom(press.offset, content);
    markNeedsPaint();
  }

  void _selectFrom(int base, Offset content) {
    controller.selection = TextSelection(
      baseOffset: base,
      extentOffset: _getTextOffsetFromPosition(content),
    );
  }

  void _dragHandle(_DraggedHandle handle, int offset) {
    final selection = controller.selection;
    switch (handle) {
      case _DraggedHandle.caret:
        controller.selection = TextSelection.collapsed(offset: offset);
        _showBubble = true;
      case _DraggedHandle.start:
        controller.selection = TextSelection(
          baseOffset: selection.end,
          extentOffset: offset,
        );
        if (offset > selection.end) _draggedHandle = _DraggedHandle.end;
      case _DraggedHandle.end:
        controller.selection = TextSelection(
          baseOffset: selection.start,
          extentOffset: offset,
        );
        if (offset < selection.start) _draggedHandle = _DraggedHandle.start;
    }
    markNeedsLayout();
    markNeedsPaint();
  }

  void _onPointerUp(PointerEvent event) {
    _gutterSelectionAnchor = null;
    if (_foldTapped) {
      _foldTapped = false;
      return;
    }
    final position = event.localPosition;
    if (isMobile &&
        event is PointerUpEvent &&
        _selectionActive &&
        !controller.selection.isCollapsed) {
      _openContextMenu(position);
      return;
    }
    final wasDragging = _isDragging;
    if (isMobile && !wasDragging && !_selectionActive) {
      controller.selection = TextSelection.collapsed(
        offset: _committedOffsetAt(position),
      );
      if (!readOnly && (controller.connection?.attached ?? false)) {
        controller.connection!.show();
      }
    }
    _endGesture();
    markNeedsPaint();
    if (readOnly) return;
    if (!wasDragging) controller.notifyListeners();
    if (isMobile && controller.selection.isCollapsed) _showBubble = true;
  }

  void _openContextMenu(Offset position) {
    _endGesture();
    onContextMenuRequest(position);
    markNeedsPaint();
  }

  void _endGesture() {
    _press = null;
    _draggedHandle = null;
    _isDragging = false;
    _selectionActive = false;
    _selectionTimer?.cancel();
  }
}
