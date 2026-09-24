part of '../code_area.dart';

extension _EditorStateOverlays on _CodeForgeState {
  void _updateScrollbarLineNumberIndicator() {
    final renderObject = _codeFieldKey.currentContext?.findRenderObject();
    if (renderObject is! _CodeFieldRenderer) return;

    final lineNumber = renderObject.getScrollbarLineNumberAtScrollOffset(
      _vscrollController.hasClients ? _vscrollController.offset : 0.0,
    );
    if (_scrollbarLineNumberIndicator.value != lineNumber) {
      _scrollbarLineNumberIndicator.value = lineNumber;
    }
  }

  void _handleContextMenuRequest(Offset offset) {
    final stack = _editorStackKey.currentContext?.findRenderObject();
    if (stack is! RenderBox || !stack.attached) return;
    final selection = _controller.selection;
    widget.onContextMenu(
      context,
      CodeForgeContextMenuRequest(
        globalPosition: stack.localToGlobal(offset),
        hasSelection: !selection.isCollapsed,
        isAllSelected:
            selection.start == 0 && selection.end == _controller.length,
        readOnly: _readOnly,
        copy: _controller.copy,
        cut: _controller.cut,
        paste: () => _controller.paste(),
        selectAll: _controller.selectAll,
      ),
    );
  }

  Widget _buildVerticalScrollbar(BuildContext context, Widget child) {
    return widget.scrollbarBuilder(
      context,
      CodeForgeScrollbarDetails(
        controller: _vscrollController,
        firstVisibleLine: _scrollbarLineNumberIndicator,
      ),
      child,
    );
  }

  Widget _buildSuggestionPopup(
    BuildContext context,
    List<CodeForgeSuggestion> sugg,
    int? selectedIndex,
    Rect caretRect,
  ) {
    return widget.suggestionPopupBuilder(
      context,
      CodeForgeSuggestionDetails(
        suggestions: sugg,
        selectedIndex: selectedIndex,
        onAccept: _controller.acceptSuggestion,
        caretRect: caretRect,
      ),
    );
  }
}
