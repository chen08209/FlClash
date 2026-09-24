import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class PageFocusScope extends StatefulWidget {
  final Widget child;

  const PageFocusScope({super.key, required this.child});

  @override
  State<PageFocusScope> createState() => _PageFocusScopeState();
}

class _PageFocusScopeState extends State<PageFocusScope> {
  final FocusScopeNode _node = FocusScopeNode()
    ..traversalEdgeBehavior = TraversalEdgeBehavior.parentScope
    ..directionalTraversalEdgeBehavior = TraversalEdgeBehavior.parentScope;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope.withExternalFocusNode(
      focusScopeNode: _node,
      child: widget.child,
    );
  }
}

/// Once a page has no target in a direction, the search continues among the
/// nodes outside the page (sidebar, navigation bar) from the focused control's
/// own rect, so left lands on the sidebar item beside it instead of wrapping.
class PageTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    if (super.inDirection(currentNode, direction)) {
      return true;
    }
    if (scope == null) {
      return false;
    }
    final found = _findOutside(scope, currentNode.rect, direction);
    if (found == null) {
      return false;
    }
    requestFocusCallback(
      found,
      alignmentPolicy: switch (direction) {
        TraversalDirection.up || TraversalDirection.left =>
          ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        TraversalDirection.down || TraversalDirection.right =>
          ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      },
    );
    return true;
  }

  FocusNode? _findOutside(
    FocusScopeNode scope,
    Rect from,
    TraversalDirection direction,
  ) {
    final root = FocusManager.instance.rootScope;
    for (
      var parent = scope.enclosingScope;
      parent != null && parent != root;
      parent = parent.enclosingScope
    ) {
      final candidates = parent.traversalDescendants.where(
        (node) => node != scope && !node.ancestors.contains(scope),
      );
      final found = _nearestInDirection(from, candidates, direction);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  static FocusNode? _nearestInDirection(
    Rect from,
    Iterable<FocusNode> nodes,
    TraversalDirection direction,
  ) {
    final vertical =
        direction == TraversalDirection.up ||
        direction == TraversalDirection.down;
    bool ahead(Rect rect) => switch (direction) {
      TraversalDirection.up => rect.center.dy <= from.top,
      TraversalDirection.down => rect.center.dy >= from.bottom,
      TraversalDirection.left => rect.center.dx <= from.left,
      TraversalDirection.right => rect.center.dx >= from.right,
    };
    bool inBand(Rect rect) => vertical
        ? rect.right > from.left && rect.left < from.right
        : rect.bottom > from.top && rect.top < from.bottom;
    double along(Rect rect) => math.max(switch (direction) {
      TraversalDirection.up => from.top - rect.bottom,
      TraversalDirection.down => rect.top - from.bottom,
      TraversalDirection.left => from.left - rect.right,
      TraversalDirection.right => rect.left - from.right,
    }, 0);
    double across(Rect rect) => vertical
        ? (rect.center.dx - from.center.dx).abs()
        : (rect.center.dy - from.center.dy).abs();

    final aheadNodes = nodes.where((node) => ahead(node.rect)).toList();
    final banded = aheadNodes.where((node) => inBand(node.rect)).toList();
    if (banded.isNotEmpty) {
      banded.sort((a, b) {
        final primary = along(a.rect).compareTo(along(b.rect));
        return primary != 0
            ? primary
            : across(a.rect).compareTo(across(b.rect));
      });
      return banded.first;
    }
    if (vertical || aheadNodes.isEmpty) {
      return null;
    }
    aheadNodes.sort((a, b) {
      final primary = across(a.rect).compareTo(across(b.rect));
      return primary != 0 ? primary : along(a.rect).compareTo(along(b.rect));
    });
    return aheadNodes.first;
  }
}

/// D-pad behaviour a remote-driven screen expects: a route that opens with
/// focus on its scope moves it to the first control, and arrows at the edge of
/// a text field leave the field instead of stalling the caret.
class RemoteFocusAdapter extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const RemoteFocusAdapter({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  State<RemoteFocusAdapter> createState() => _RemoteFocusAdapterState();
}

class _RemoteFocusAdapterState extends State<RemoteFocusAdapter> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      FocusManager.instance.addListener(_handleFocusChange);
    }
  }

  @override
  void didUpdateWidget(RemoteFocusAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled == widget.enabled) {
      return;
    }
    if (widget.enabled) {
      FocusManager.instance.addListener(_handleFocusChange);
    } else {
      FocusManager.instance.removeListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      FocusManager.instance.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus is FocusScopeNode && focus.focusedChild == null) {
      focus.nextFocus();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is KeyUpEvent) {
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
    final editable = focus?.context
        ?.findAncestorStateOfType<EditableTextState>();
    if (focus == null ||
        editable == null ||
        !_caretAtEdge(editable, direction)) {
      return KeyEventResult.ignored;
    }
    return focus.focusInDirection(direction)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

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
