import 'package:flutter/widgets.dart';

import 'inherited.dart';

typedef _BottomInset = ({double viewInset, double padding});

/// Holds the bottom inset of a page under another route or on an inactive
/// tab, which is still laid out, offstage or not, and would otherwise resize
/// with every frame of a keyboard it cannot use. It catches up once the
/// keyboard comes down to it or the focus moves inside.
class KeyboardInsetHold extends StatefulWidget {
  const KeyboardInsetHold({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardInsetHold> createState() => _KeyboardInsetHoldState();
}

class _KeyboardInsetHoldState extends State<KeyboardInsetHold> {
  _BottomInset? _shown;
  _BottomInset? _held;
  FocusNode? _enclosingFocus;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (_held != null && _hasFocusInside) {
      setState(() {});
    }
  }

  bool get _hasFocusInside {
    final focus = FocusManager.instance.primaryFocus;
    final enclosing = _enclosingFocus;
    return focus != null &&
        enclosing != null &&
        focus is! FocusScopeNode &&
        focus.ancestors.contains(enclosing);
  }

  _BottomInset? _nextHeld(_BottomInset live) {
    if (_hasFocusInside) {
      return null;
    }
    final isShown =
        (ModalRoute.isCurrentOf(context) ?? true) &&
        PageActivityScope.isActiveOf(context);
    final held = _held ?? (isShown ? null : _shown);
    if (held == null || live.viewInset <= held.viewInset) {
      return isShown ? null : live;
    }
    return held;
  }

  @override
  Widget build(BuildContext context) {
    _enclosingFocus = Focus.maybeOf(context, scopeOk: true);
    final data = MediaQuery.of(context);
    final live = (
      viewInset: data.viewInsets.bottom,
      padding: data.padding.bottom,
    );
    final held = _held = _nextHeld(live);
    _shown = held ?? live;
    return MediaQuery(
      data: held == null
          ? data
          : data.copyWith(
              viewInsets: data.viewInsets.copyWith(bottom: held.viewInset),
              padding: data.padding.copyWith(bottom: held.padding),
            ),
      child: widget.child,
    );
  }
}
