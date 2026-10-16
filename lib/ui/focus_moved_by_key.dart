part of 'focus.dart';

/// Whether focus last moved by key, the focus `.agents/surfaces.md` rings.
class FocusMovedByKey extends ChangeNotifier implements ValueListenable<bool> {
  FocusMovedByKey._();

  static final instance = FocusMovedByKey._();

  static final _arrowKeys = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
  };

  int _adapters = 0;
  bool _value = false;

  @override
  bool get value => _value;

  set _moved(bool value) {
    if (_value == value) {
      return;
    }
    _value = value;
    notifyListeners();
  }

  void _attach() {
    if (_adapters++ > 0) {
      return;
    }
    HardwareKeyboard.instance.addHandler(_handleKey);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointer);
  }

  void _detach() {
    if (--_adapters > 0) {
      return;
    }
    HardwareKeyboard.instance.removeHandler(_handleKey);
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handlePointer);
    _value = false;
  }

  static bool get _arrowsMoveCaret =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() !=
      null;

  bool _handleKey(KeyEvent event) {
    if (_value || event is KeyUpEvent) {
      return false;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.tab ||
        remoteSelectKeys.contains(key) ||
        (_arrowKeys.contains(key) && !_arrowsMoveCaret)) {
      _moved = true;
    }
    return false;
  }

  void _handlePointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      _moved = false;
    }
  }
}
