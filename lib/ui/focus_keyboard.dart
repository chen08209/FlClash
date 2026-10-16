part of 'focus.dart';

// Android TV's keyboard covers about the lower 45% of the screen.
const _floatingKeyboardShare = 0.5;
const _maxRevealFrames = 30;

/// A text field the remote focuses opens the keyboard only on select.
class _RemoteKeyboard extends StatefulWidget {
  const _RemoteKeyboard({required this.floatingKeyboard, required this.child});

  final ValueListenable<bool>? floatingKeyboard;
  final Widget child;

  @override
  State<_RemoteKeyboard> createState() => _RemoteKeyboardState();
}

class _RemoteKeyboardState extends State<_RemoteKeyboard> {
  FocusNode? _outgoing;
  bool _usingRemote = false;
  bool _openedKeyboard = false;

  @override
  void initState() {
    super.initState();
    widget.floatingKeyboard?.addListener(_handleFloatingKeyboard);
    FocusManager.instance.addListener(_handleFocusChange);
    _watchOutgoing(FocusManager.instance.primaryFocus);
  }

  @override
  void didUpdateWidget(_RemoteKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.floatingKeyboard != widget.floatingKeyboard) {
      oldWidget.floatingKeyboard?.removeListener(_handleFloatingKeyboard);
      widget.floatingKeyboard?.addListener(_handleFloatingKeyboard);
    }
  }

  @override
  void dispose() {
    widget.floatingKeyboard?.removeListener(_handleFloatingKeyboard);
    FocusManager.instance.removeListener(_handleFocusChange);
    _watchOutgoing(null);
    super.dispose();
  }

  void _handleFocusChange() {
    final focus = FocusManager.instance.primaryFocus;
    _watchOutgoing(focus);
    if (_editableOf(focus) == null) {
      _openedKeyboard = false;
    }
  }

  void _watchOutgoing(FocusNode? node) {
    _outgoing?.removeListener(_holdKeyboard);
    _outgoing = node?..addListener(_holdKeyboard);
  }

  // The node losing primary focus hears of it before the field gaining it, whose
  // own listener opens the keyboard on its token or on an invalid selection.
  void _holdKeyboard() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == _outgoing || !_usingRemote || _keyboardShown) {
      return;
    }
    final editable = _editableOf(focus);
    if (focus == null || editable == null) {
      return;
    }
    focus.consumeKeyboardToken();
    final controller = editable.widget.controller;
    if (!controller.selection.isValid) {
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  bool get _keyboardFloating => widget.floatingKeyboard?.value ?? false;

  bool get _keyboardShown =>
      _openedKeyboard ||
      _keyboardFloating ||
      (View.maybeOf(context)?.viewInsets.bottom ?? 0) > 0;

  void _handleFloatingKeyboard() {
    setState(() {});
    if (_keyboardFloating) {
      _revealFocusedField();
    }
  }

  // Containers ease into a new inset, so reveal the field until they settle.
  void _revealFocusedField([int frame = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editable = _editableOf(FocusManager.instance.primaryFocus);
      if (!mounted || !_keyboardFloating || editable == null) {
        return;
      }
      final box = editable.renderEditable;
      box.showOnScreen(
        rect: editable.widget.scrollPadding.inflateRect(Offset.zero & box.size),
      );
      if (frame < _maxRevealFrames &&
          WidgetsBinding.instance.hasScheduledFrame) {
        _revealFocusedField(frame + 1);
      }
    });
  }

  MediaQueryData _withFloatingKeyboard(MediaQueryData data) {
    if (!_keyboardFloating || data.viewInsets.bottom > 0) {
      return data;
    }
    return data.copyWith(
      viewInsets: data.viewInsets.copyWith(
        bottom: data.size.height * _floatingKeyboardShare,
      ),
    );
  }

  static EditableTextState? _editableOf(FocusNode? focus) {
    final editable = focus?.context
        ?.findAncestorStateOfType<EditableTextState>();
    if (editable == null ||
        editable.widget.focusNode != focus ||
        editable.widget.readOnly) {
      return null;
    }
    return editable;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    _usingRemote = true;
    // The keyboard takes the remote's keys while it is up, so one reaching the
    // app means BACK has closed it.
    _openedKeyboard = false;
    if (!remoteSelectKeys.contains(event.logicalKey) || _keyboardShown) {
      return KeyEventResult.ignored;
    }
    final editable = _editableOf(FocusManager.instance.primaryFocus);
    if (editable == null) {
      return KeyEventResult.ignored;
    }
    editable.requestKeyboard();
    _openedKeyboard = true;
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _usingRemote = false,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: _handleKeyEvent,
        child: MediaQuery(
          data: _withFloatingKeyboard(MediaQuery.of(context)),
          child: widget.child,
        ),
      ),
    );
  }
}
