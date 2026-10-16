part of 'focus.dart';

/// Arrows at the edge of a text field leave the field instead of stalling the
/// caret, and up or down with no control that way scrolls the text there into
/// reach.
class _RemoteArrowKeys extends StatefulWidget {
  const _RemoteArrowKeys({required this.child});

  final Widget child;

  @override
  State<_RemoteArrowKeys> createState() => _RemoteArrowKeysState();
}

class _RemoteArrowKeysState extends State<_RemoteArrowKeys> {
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => TraversalDirection.up,
      LogicalKeyboardKey.arrowDown => TraversalDirection.down,
      LogicalKeyboardKey.arrowLeft => TraversalDirection.left,
      LogicalKeyboardKey.arrowRight => TraversalDirection.right,
      _ => null,
    };
    if (direction == null) {
      return KeyEventResult.ignored;
    }
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) {
      return KeyEventResult.ignored;
    }
    final editable = focus.context
        ?.findAncestorStateOfType<EditableTextState>();
    if (editable == null) {
      _scrollIfFocusStays(focus, direction);
      return KeyEventResult.ignored;
    }
    if (!_caretAtEdge(editable, direction)) {
      return KeyEventResult.ignored;
    }
    return focus.focusInDirection(direction)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  void _scrollIfFocusStays(FocusNode focus, TraversalDirection direction) {
    if (direction == TraversalDirection.left ||
        direction == TraversalDirection.right) {
      return;
    }
    // The traversal the key goes on to applies its focus change in a
    // microtask, so only a later task can tell whether it found a target.
    Timer.run(() {
      final context = focus.context;
      if (!mounted ||
          context == null ||
          FocusManager.instance.primaryFocus != focus) {
        return;
      }
      final position = _scrollableToward(context, direction);
      if (position == null) {
        return;
      }
      final step = position.viewportDimension / 2;
      final target =
          (position.pixels +
                  (_scrollsForward(position, direction) ? step : -step))
              .clamp(position.minScrollExtent, position.maxScrollExtent);
      final duration = context.motionDuration(commonDuration);
      if (duration == Duration.zero) {
        position.jumpTo(target);
      } else {
        position.animateTo(
          target,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  static bool _scrollsForward(
    ScrollPosition position,
    TraversalDirection direction,
  ) {
    return (direction == TraversalDirection.down) !=
        axisDirectionIsReversed(position.axisDirection);
  }

  static bool _canScroll(
    ScrollPosition position,
    TraversalDirection direction,
  ) {
    if (!position.hasContentDimensions) {
      return false;
    }
    return _scrollsForward(position, direction)
        ? position.pixels < position.maxScrollExtent
        : position.pixels > position.minScrollExtent;
  }

  static ScrollPosition? _scrollableToward(
    BuildContext context,
    TraversalDirection direction,
  ) {
    var scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
    if (scrollable == null) {
      return switch (PrimaryScrollController.maybeOf(context)) {
        final controller?
            when controller.positions.length == 1 &&
                _canScroll(controller.position, direction) &&
                _inSameRegion(context, controller.position) =>
          controller.position,
        _ => null,
      };
    }
    while (scrollable != null) {
      if (_canScroll(scrollable.position, direction)) {
        return scrollable.position;
      }
      scrollable = Scrollable.maybeOf(scrollable.context, axis: Axis.vertical);
    }
    return null;
  }

  // The route's list beside the sidebar belongs to the page; a remote stopped at
  // the sidebar's end is not pointing at it.
  static bool _inSameRegion(BuildContext context, ScrollPosition position) =>
      FocusTraversalGroup.maybeOf(context) ==
      FocusTraversalGroup.maybeOf(position.context.storageContext);

  static bool _caretAtEdge(
    EditableTextState editable,
    TraversalDirection direction,
  ) {
    final value = editable.textEditingValue;
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      return false;
    }
    final length = value.text.length;
    switch (direction) {
      case TraversalDirection.left:
        return selection.baseOffset == 0;
      case TraversalDirection.right:
        return selection.baseOffset == length;
      case TraversalDirection.up:
      case TraversalDirection.down:
        final render = editable.renderEditable;
        final caret = render.getLocalRectForCaret(selection.extent);
        final edge = render.getLocalRectForCaret(
          TextPosition(offset: direction == TraversalDirection.up ? 0 : length),
        );
        return (caret.top - edge.top).abs() < 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
