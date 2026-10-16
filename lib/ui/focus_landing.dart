part of 'focus.dart';

/// A route that opens with focus on its scope moves it to the first control,
/// and focus handed to a route that another covers moves to the one on top.
class _RemoteFocusLanding extends StatefulWidget {
  const _RemoteFocusLanding({required this.child});

  final Widget child;

  @override
  State<_RemoteFocusLanding> createState() => _RemoteFocusLandingState();
}

class _RemoteFocusLandingState extends State<_RemoteFocusLanding> {
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
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) {
      return;
    }
    if (_navigatorOfCoveredRoute(focus) case final navigator?) {
      _topRouteScope(navigator)?.requestFocus();
      return;
    }
    if (focus is FocusScopeNode && focus.focusedChild == null) {
      focus.nextFocus();
    }
  }

  // Flutter hands focus to a covered route too: the first route of a navigator
  // built inside one asks for the enclosing scope from Route.didAdd.
  static NavigatorState? _navigatorOfCoveredRoute(FocusNode focus) {
    for (final node in [focus, ...focus.ancestors]) {
      final context = node.context;
      if (node is FocusScopeNode &&
          context != null &&
          ModalRoute.isCurrentOf(context) == false) {
        return Navigator.maybeOf(context);
      }
    }
    return null;
  }

  static FocusScopeNode? _topRouteScope(NavigatorState navigator) {
    Iterable<FocusScopeNode> childScopes(FocusNode node) sync* {
      for (final child in node.children) {
        if (child is FocusScopeNode) {
          yield child;
        } else {
          yield* childScopes(child);
        }
      }
    }

    final parent = navigator.focusNode.enclosingScope;
    if (parent == null) {
      return null;
    }
    for (final scope in childScopes(parent)) {
      final context = scope.context;
      final route = context == null ? null : ModalRoute.of(context);
      if (route != null &&
          route.navigator == navigator &&
          route.isCurrent &&
          route.requestFocus) {
        return scope;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
