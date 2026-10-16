part of 'focus.dart';

/// Once a page has no target in a direction, the search continues among the
/// nodes outside the page (sidebar, navigation bar) from the focused control's
/// own rect, so left lands on the sidebar item beside it instead of wrapping.
/// On a remote a row ends at its last control instead of jumping out of band.
class PageTraversalPolicy extends ReadingOrderTraversalPolicy
    with _CrossScopeFocus {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    if (scope == null) {
      return super.inDirection(currentNode, direction);
    }
    final rowEnds =
        !_isVertical(direction) &&
        _isRemote(currentNode) &&
        !_hasTargetInBand(scope, direction);
    if (!rowEnds && super.inDirection(currentNode, direction)) {
      return true;
    }
    final found = _findOutside(scope, currentNode.rect, direction);
    if (found == null) {
      return false;
    }
    _focusAcross(scope, found, direction);
    return true;
  }

  static bool _hasTargetInBand(
    FocusScopeNode scope,
    TraversalDirection direction,
  ) {
    final focused = scope.focusedChild;
    if (focused == null) {
      return true;
    }
    final from = focused.rect;
    return scope.traversalDescendants.any(
      (node) =>
          node != focused &&
          _isAhead(from, node.rect, direction) &&
          _isInBand(from, node.rect, direction) &&
          _isUncovered(node, scope),
    );
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
      final level = parent;
      final candidates = level.traversalDescendants.where(
        (node) => node != scope && _isOutside(node, scope, level),
      );
      final found = _nearestInDirection(from, candidates, direction);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  static bool _isOutside(
    FocusNode node,
    FocusScopeNode scope,
    FocusScopeNode level,
  ) =>
      !node.ancestors.contains(scope) &&
      !scope.ancestors.contains(node) &&
      _isUncovered(node, level);
}

/// What a remote does outside the pages: a row or column ends at its last
/// control, and only a move into another region, as from the sidebar into the
/// page, may leave the row's band, for the nearest control on screen.
class _RemoteTraversalPolicy extends ReadingOrderTraversalPolicy
    with _CrossScopeFocus {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    final focused = scope?.focusedChild;
    if (scope == null || focused == null) {
      return super.inDirection(currentNode, direction);
    }
    final from = focused.rect;
    final own = <FocusNode>[];
    final other = <FocusNode>[];
    for (final node in scope.traversalDescendants) {
      if (node == focused ||
          !_isAhead(from, node.rect, direction) ||
          !_isUncovered(node, scope)) {
        continue;
      }
      if (FocusTraversalGroup.maybeOfNode(node) == this) {
        own.add(node);
      } else if (node is! FocusScopeNode && _isOnScreen(node)) {
        other.add(node);
      }
    }
    final hasOwnTarget = _isVertical(direction)
        ? own.isNotEmpty
        : own.any((node) => _isInBand(from, node.rect, direction));
    if (hasOwnTarget) {
      return super.inDirection(currentNode, direction);
    }
    final target = _nearestInDirection(from, other, direction);
    if (target == null) {
      return false;
    }
    _focusAcross(scope, target, direction);
    return true;
  }
}

mixin _CrossScopeFocus on FocusTraversalPolicy {
  // Each policy keeps a history per scope so that reversing a move returns to
  // where it started; a jump between scopes would leave both histories stale.
  void _focusAcross(
    FocusScopeNode from,
    FocusNode target,
    TraversalDirection direction,
  ) {
    invalidateScopeData(from);
    final targetScope = target.nearestScope;
    if (targetScope != null) {
      FocusTraversalGroup.maybeOfNode(target)?.invalidateScopeData(targetScope);
    }
    requestFocusCallback(
      target,
      alignmentPolicy: switch (direction) {
        TraversalDirection.up || TraversalDirection.left =>
          ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        TraversalDirection.down || TraversalDirection.right =>
          ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      },
    );
  }
}

bool _isRemote(FocusNode node) =>
    node.context?.getInheritedWidgetOfExactType<_RemoteScope>()?.enabled ??
    false;

bool _isVertical(TraversalDirection direction) =>
    direction == TraversalDirection.up || direction == TraversalDirection.down;

bool _isAhead(Rect from, Rect rect, TraversalDirection direction) =>
    switch (direction) {
      TraversalDirection.up => rect.center.dy <= from.top,
      TraversalDirection.down => rect.center.dy >= from.bottom,
      TraversalDirection.left => rect.center.dx <= from.left,
      TraversalDirection.right => rect.center.dx >= from.right,
    };

bool _isInBand(Rect from, Rect rect, TraversalDirection direction) =>
    _isVertical(direction)
    ? rect.right > from.left && rect.left < from.right
    : rect.bottom > from.top && rect.top < from.bottom;

// A covered route's scope is marked skipped; its nodes stay in the tree.
bool _isUncovered(FocusNode node, FocusScopeNode scope) {
  for (final ancestor in node.ancestors) {
    if (ancestor == scope) {
      return true;
    }
    if (ancestor is FocusScopeNode && ancestor.skipTraversal) {
      return false;
    }
  }
  return true;
}

bool _isOnScreen(FocusNode node) {
  final context = node.context;
  for (
    var scrollable = context == null ? null : Scrollable.maybeOf(context);
    scrollable != null;
    scrollable = Scrollable.maybeOf(scrollable.context)
  ) {
    final box = scrollable.context.findRenderObject();
    if (box is RenderBox &&
        box.hasSize &&
        !node.rect.overlaps(
          MatrixUtils.transformRect(
            box.getTransformTo(null),
            Offset.zero & box.size,
          ),
        )) {
      return false;
    }
  }
  return true;
}

FocusNode? _nearestInDirection(
  Rect from,
  Iterable<FocusNode> nodes,
  TraversalDirection direction,
) {
  final vertical = _isVertical(direction);
  double along(Rect rect) => math.max(switch (direction) {
    TraversalDirection.up => from.top - rect.bottom,
    TraversalDirection.down => rect.top - from.bottom,
    TraversalDirection.left => from.left - rect.right,
    TraversalDirection.right => rect.left - from.right,
  }, 0);
  double across(Rect rect) => vertical
      ? (rect.center.dx - from.center.dx).abs()
      : (rect.center.dy - from.center.dy).abs();

  final aheadNodes = nodes
      .where((node) => _isAhead(from, node.rect, direction))
      .toList();
  final banded = aheadNodes
      .where((node) => _isInBand(from, node.rect, direction))
      .toList();
  if (banded.isNotEmpty) {
    banded.sort((a, b) {
      final primary = along(a.rect).compareTo(along(b.rect));
      return primary != 0 ? primary : across(a.rect).compareTo(across(b.rect));
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
