part of '../code_area.dart';

extension _EditorStateKeyboard on _CodeForgeState {
  bool get _readOnly => widget.readOnly;

  void _openImeConnection() {
    if (!_focusNode.hasFocus || _readOnly) return;
    if (_connection == null || !_connection!.attached) {
      _connection = _attachImeConnection();
      _controller.connection = _connection;
    }
    if (!_isMobile) _connection!.show();
    _connection!.setEditingState(
      _controller.currentTextEditingValue ??
          TextEditingValue(
            text: _controller.text,
            selection: _controller.selection,
          ),
    );
  }

  void _closeImeConnection() {
    _connection?.close();
    _connection = null;
    _controller.connection = null;
  }

  TextInputConnection _attachImeConnection() {
    return TextInput.attach(
      _controller,
      TextInputConfiguration(
        readOnly: widget.readOnly,
        enableDeltaModel: true,
        inputType: TextInputType.multiline,
        inputAction: TextInputAction.newline,
        autocorrect: false,
        viewId: View.of(context).viewId,
      ),
    );
  }

  void _resetImeConnection() {
    if (_readOnly || !_focusNode.hasFocus) return;
    final previous = _connection;
    _connection = null;
    _controller.connection = null;
    try {
      previous?.close();
    } catch (_) {}
    final fresh = _attachImeConnection();
    _connection = fresh;
    _controller.connection = fresh;
    fresh.show();
    fresh.setEditingState(
      _controller.currentTextEditingValue ??
          TextEditingValue(
            text: _controller.text,
            selection: _controller.selection,
          ),
    );
  }

  void _resetCursorBlink() {
    if (!mounted) return;
    _caretBlinkController.stop();
    if (!_focusNode.hasFocus || _readOnly) {
      _caretBlinkController.value = 0.0;
      return;
    }
    _caretBlinkController
      ..value = 1.0
      ..repeat(reverse: true);
  }

  void _showFinder({required bool replace}) {
    if (_findController.isActive) {
      _findController.findInputFocusNode.requestFocus();
    }
    _findController.isActive = true;
    _findController.isReplaceMode = replace;
  }

  List<({ShortcutActivator? keys, bool edits, VoidCallback run})>
  _shortcutActions() {
    final shortcuts = CodeForgeKeyboardShortcuts.forPlatform(
      defaultTargetPlatform,
    );
    final controller = _controller;
    final undo = _undoRedoController;
    return [
      (keys: shortcuts.duplicate, edits: true, run: controller.duplicateLine),
      (
        keys: shortcuts.deleteWordBackward,
        edits: true,
        run: controller.deleteWordBackward,
      ),
      (
        keys: shortcuts.deleteWordForward,
        edits: true,
        run: controller.deleteWordForward,
      ),
      (
        keys: shortcuts.moveCursorToPreviousWord,
        edits: false,
        run: controller.moveWordLeft,
      ),
      (
        keys: shortcuts.moveCursorToNextWord,
        edits: false,
        run: controller.moveWordRight,
      ),
      (
        keys: shortcuts.jumpToDocumentStart,
        edits: false,
        run: controller.pressDocumentHomeKey,
      ),
      (
        keys: shortcuts.jumpToDocumentStartAndSelectText,
        edits: false,
        run: () => controller.pressDocumentHomeKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.jumpToDocumentEnd,
        edits: false,
        run: controller.pressDocumentEndKey,
      ),
      (
        keys: shortcuts.jumpToDocumentEndAndSelectText,
        edits: false,
        run: () => controller.pressDocumentEndKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.showFindBar,
        edits: false,
        run: () => _showFinder(replace: false),
      ),
      (
        keys: shortcuts.showFindAndReplaceBar,
        edits: false,
        run: () => _showFinder(replace: !_readOnly),
      ),
      (keys: shortcuts.shiftLineUp, edits: true, run: controller.moveLineUp),
      (
        keys: shortcuts.shiftLineDown,
        edits: true,
        run: controller.moveLineDown,
      ),
      (
        keys: shortcuts.moveSelectionToPreviousWord,
        edits: false,
        run: () => controller.moveWordLeft(extend: true),
      ),
      (
        keys: shortcuts.moveSelectionToNextWord,
        edits: false,
        run: () => controller.moveWordRight(extend: true),
      ),
      (
        keys: shortcuts.moveSelectionForward,
        edits: false,
        run: () => controller.pressRightArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.moveSelectionBackward,
        edits: false,
        run: () => controller.pressLeftArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.moveSelectionUpward,
        edits: false,
        run: () => controller.pressUpArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.moveSelectionDownward,
        edits: false,
        run: () => controller.pressDownArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.selectToLineStart,
        edits: false,
        run: () => controller.pressHomeKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.selectToLineEnd,
        edits: false,
        run: () => controller.pressEndKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.jumpToLineStart,
        edits: false,
        run: controller.pressHomeKey,
      ),
      (
        keys: shortcuts.jumpToLineEnd,
        edits: false,
        run: controller.pressEndKey,
      ),
      (
        keys: shortcuts.deleteToLineStart,
        edits: true,
        run: controller.deleteToLineStart,
      ),
      (keys: shortcuts.copy, edits: false, run: controller.copy),
      (keys: shortcuts.cut, edits: true, run: controller.cut),
      (keys: shortcuts.paste, edits: true, run: controller.paste),
      (keys: shortcuts.selectAll, edits: false, run: controller.selectAll),
      (
        keys: shortcuts.undo,
        edits: true,
        run: () {
          if (undo.canUndo) undo.undo();
        },
      ),
      (
        keys: shortcuts.redo,
        edits: true,
        run: () {
          if (undo.canRedo) undo.redo();
        },
      ),
    ];
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_controller.isComposingActive ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    for (final shortcut in _shortcutActions()) {
      if (!(shortcut.keys?.accepts(event, keyboard) ?? false)) continue;
      if (!shortcut.edits || !_readOnly) {
        shortcut.run();
        _resetCursorBlink();
      }
      return KeyEventResult.handled;
    }
    final key = event.logicalKey;
    if (_handleSuggestionKey(key)) return KeyEventResult.handled;
    final handled = _handleEditingKey(
      key,
      shift: keyboard.isShiftPressed,
      control: keyboard.isControlPressed || keyboard.isMetaPressed,
    );
    if (handled) _resetCursorBlink();
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  bool _handleSuggestionKey(LogicalKeyboardKey key) {
    if (!(_suggestionNotifier.value?.isNotEmpty ?? false)) return false;
    switch (key) {
      case LogicalKeyboardKey.arrowDown:
        _controller.moveSuggestionSelection(1);
      case LogicalKeyboardKey.arrowUp:
        _controller.moveSuggestionSelection(-1);
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.tab:
        _controller.acceptSuggestion();
      case LogicalKeyboardKey.escape:
        _suggestionNotifier.value = null;
      default:
        return false;
    }
    return true;
  }

  bool _handleEditingKey(
    LogicalKeyboardKey key, {
    required bool shift,
    required bool control,
  }) {
    final controller = _controller;
    switch (key) {
      case LogicalKeyboardKey.tab when shift && !control:
        if (!_readOnly && !controller.previousSnippetStop()) {
          controller.unindent();
        }
      case LogicalKeyboardKey.backspace:
        if (_readOnly) return true;
        controller.backspace();
        _suggestionNotifier.value = null;
      case LogicalKeyboardKey.delete:
        if (_readOnly) return true;
        controller.delete();
        _suggestionNotifier.value = null;
      case LogicalKeyboardKey.arrowDown:
        controller.pressDownArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.arrowUp:
        controller.pressUpArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.arrowRight:
        controller.pressRightArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.arrowLeft:
        controller.pressLeftArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.home:
        controller.pressHomeKey(isShiftPressed: shift);
      case LogicalKeyboardKey.end:
        controller.pressEndKey(isShiftPressed: shift);
      case LogicalKeyboardKey.escape:
        if (!_findController.isActive &&
            _suggestionNotifier.value == null &&
            !controller.isSnippetActive) {
          return false;
        }
        controller.endSnippet();
        _findController.isActive = false;
        _findController.isReplaceMode = false;
        _suggestionNotifier.value = null;
      case LogicalKeyboardKey.tab:
        if (!_readOnly &&
            _suggestionNotifier.value == null &&
            !controller.nextSnippetStop()) {
          controller.indent();
        }
      case LogicalKeyboardKey.pageUp:
        _scrollPage(-1);
      case LogicalKeyboardKey.pageDown:
        _scrollPage(1);
      default:
        return false;
    }
    return true;
  }

  void _scrollPage(int direction) {
    _vscrollController.animateTo(
      _vscrollController.offset + direction * 650,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
