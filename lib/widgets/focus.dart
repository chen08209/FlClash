import 'package:flutter/material.dart';

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

class PageTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    if (super.inDirection(currentNode, direction)) {
      return true;
    }

    final parent = scope?.enclosingScope;
    if (parent == null || parent == FocusManager.instance.rootScope) {
      return false;
    }
    return switch (direction) {
      TraversalDirection.down || TraversalDirection.right => parent.nextFocus(),
      TraversalDirection.up ||
      TraversalDirection.left => parent.previousFocus(),
    };
  }
}
