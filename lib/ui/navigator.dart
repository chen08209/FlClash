import 'dart:async';

import 'package:animations/animations.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/deferred_push.dart';
import 'package:fl_clash/ui/drag_back.dart';
import 'package:fl_clash/ui/keyboard_inset_hold.dart';
import 'package:fl_clash/ui/page_transition.dart';
import 'package:fl_clash/ui/sheet_navigator.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class BaseNavigator {
  static PageRoute<T> _routeOf<T>(BuildContext context, Widget child) {
    if (!context.isMobileView) {
      return CommonDesktopRoute(builder: (context) => child);
    }
    return CommonRoute(builder: (context) => child);
  }

  /// The mobile layout drops a home page's navigator, pages and all, so a
  /// desktop page left open reopens in the mobile form while its opener stays.
  static Future<T?> push<T>(BuildContext context, Widget child) {
    final navigator = Navigator.of(context);
    if (context.isMobileView) {
      return navigator.push<T>(_routeOf(context, child));
    }
    final completer = Completer<T?>();
    var popped = false;
    void reopenIfDropped() {
      if (popped) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        completer.complete(context.mounted ? push<T>(context, child) : null);
      });
    }

    final route = CommonDesktopRoute<T>(
      builder: (_) => _DropWatch(onDropped: reopenIfDropped, child: child),
    );
    unawaited(
      navigator.push<T>(route).then((value) {
        popped = true;
        completer.complete(value);
      }),
    );
    return completer.future;
  }

  static Future<T?> pushReplacement<T>(BuildContext context, Widget child) {
    return Navigator.of(
      context,
    ).pushReplacement<T, void>(_routeOf(context, child));
  }
}

class _DropWatch extends StatefulWidget {
  const _DropWatch({required this.onDropped, required this.child});

  final VoidCallback onDropped;
  final Widget child;

  @override
  State<_DropWatch> createState() => _DropWatchState();
}

class _DropWatchState extends State<_DropWatch> {
  @override
  void dispose() {
    widget.onDropped();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The route of the page [context] is on and, for a page in a sheet, the
/// routes of the sheets carrying it.
Iterable<ModalRoute<Object?>> routesCarrying(BuildContext context) sync* {
  var route = ModalRoute.of(context);
  while (route != null) {
    yield route;
    final navigator = route.navigator;
    if (navigator == null ||
        !navigator.mounted ||
        navigator.widget is! SheetPagesNavigator) {
      return;
    }
    route = ModalRoute.of(navigator.context);
  }
}

Future<void> whenRouteSettled(BuildContext context) async {
  final routes = routesCarrying(context).toList();
  for (final route in routes) {
    await _whenSettled(route);
  }
}

bool isRouteArriving(BuildContext context) => routesCarrying(
  context,
).any((route) => route.offstage || (route.animation?.isAnimating ?? false));

Future<void> _whenSettled(ModalRoute<Object?> route) async {
  // HeroController builds a pushed route offstage for its first frame, with
  // the animation pinned to completed, so it only tells the truth after that.
  while (route.offstage && route.isActive) {
    await SchedulerBinding.instance.endOfFrame;
  }
  final animation = route.animation;
  if (animation == null || !animation.isAnimating) {
    return;
  }
  final completer = Completer<void>();
  void handleStatus(AnimationStatus status) {
    if (status.isAnimating) {
      return;
    }
    animation.removeStatusListener(handleStatus);
    completer.complete();
  }

  animation.addStatusListener(handleStatus);
  return completer.future;
}

const commonSharedXPageTransitions = SharedAxisPageTransitionsBuilder(
  transitionType: SharedAxisTransitionType.horizontal,
  fillColor: Colors.transparent,
);

class CommonDesktopRoute<T> extends PageRoute<T>
    with DragBackRouteMixin<T>, DeferredPushRouteMixin<T> {
  final Widget Function(BuildContext context) builder;

  CommonDesktopRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: KeyboardInsetHold(child: builder(context)),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return dragBackDetector(
      isDragBackActive
          ? dragBackSlide(context, animation, child)
          : FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);
}

class CommonRoute<T> extends PageRoute<T>
    with
        DragBackRouteMixin<T>,
        DeferredPushRouteMixin<T>,
        SharedXPageRouteMixin<T> {
  final Widget Function(BuildContext context) builder;

  CommonRoute({required this.builder});

  @override
  bool sharesMotionWith(Route<dynamic>? route) => route is CommonRoute;

  @override
  Color backdropOf(Color surface, {required bool dragging}) =>
      dragging ? Colors.transparent : surface;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: KeyboardInsetHold(child: builder(context)),
    );
  }
}
