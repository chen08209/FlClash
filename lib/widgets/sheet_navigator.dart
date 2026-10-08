import 'package:material_ui/material_ui.dart';

/// A sheet's own navigator, which holds only the pages of that sheet.
class SheetPagesNavigator extends Navigator {
  const SheetPagesNavigator({super.key, super.onGenerateInitialRoutes});
}

bool isSheetPage(BuildContext context) =>
    Navigator.maybeOf(context)?.widget is SheetPagesNavigator;

/// A sheet opened from inside another sheet goes over it, sized by the space
/// that sheet is shown in rather than squeezed among its pages.
NavigatorState sheetNavigatorOf(BuildContext context) {
  var navigator = Navigator.of(context);
  while (navigator.widget is SheetPagesNavigator) {
    navigator = navigator.context.findAncestorStateOfType<NavigatorState>()!;
  }
  return navigator;
}

final _covers = Expando<ProxyAnimation>();

ProxyAnimation _coverOf(Route<dynamic> route) =>
    _covers[route] ??= ProxyAnimation(kAlwaysDismissedAnimation);

/// Hands the route below the sheet's entrance, for it to step back behind.
mixin SheetCoverRouteMixin<T> on TransitionRoute<T> {
  ProxyAnimation? _covered;

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    _uncover();
    if (previousRoute != null) {
      _covered = _coverOf(previousRoute)..parent = animation;
    }
  }

  void _uncover() {
    final covered = _covered;
    if (covered != null && covered.parent == animation) {
      covered.parent = kAlwaysDismissedAnimation;
    }
    _covered = null;
  }

  @override
  void dispose() {
    _uncover();
    super.dispose();
  }
}

/// Runs to 1 as a sheet covers the page or sheet that [context] is on.
Animation<double> sheetCoverOf(BuildContext context) {
  var route = ModalRoute.of(context);
  while (route != null) {
    final navigator = route.navigator;
    if (navigator == null || navigator.widget is! SheetPagesNavigator) {
      return _coverOf(route);
    }
    route = ModalRoute.of(navigator.context);
  }
  return kAlwaysDismissedAnimation;
}
