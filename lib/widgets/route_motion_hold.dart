import 'dart:async';

import 'package:fl_clash/common/navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Holds list refreshes while the page's route is pushed, popped, covered,
/// uncovered or dragged back, and replays the latest one once it settles.
mixin RouteMotionHoldMixin<T extends StatefulWidget> on State<T> {
  ModalRoute<Object?>? _route;
  ValueListenable<bool>? _userGesture;
  VoidCallback? _heldUpdate;

  bool get _isRouteMoving {
    final route = _route;
    if (route == null) {
      return false;
    }
    return (route.animation?.isAnimating ?? false) ||
        (route.secondaryAnimation?.isAnimating ?? false) ||
        (_userGesture?.value ?? false);
  }

  void updateWhenRouteSettled(VoidCallback update) {
    if (_isRouteMoving) {
      _heldUpdate = update;
      return;
    }
    _heldUpdate = null;
    update();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (identical(route, _route)) {
      return;
    }
    _detach();
    _route = route;
    _userGesture = route?.navigator?.userGestureInProgressNotifier;
    route?.animation?.addStatusListener(_handleStatus);
    route?.secondaryAnimation?.addStatusListener(_handleStatus);
    _userGesture?.addListener(_releaseHeld);
  }

  @override
  void dispose() {
    _detach();
    _heldUpdate = null;
    super.dispose();
  }

  void _detach() {
    _route?.animation?.removeStatusListener(_handleStatus);
    _route?.secondaryAnimation?.removeStatusListener(_handleStatus);
    _userGesture?.removeListener(_releaseHeld);
  }

  void _handleStatus(AnimationStatus _) => _releaseHeld();

  void _releaseHeld() {
    final update = _heldUpdate;
    if (update == null || !mounted || _isRouteMoving) {
      return;
    }
    _heldUpdate = null;
    update();
  }
}

/// Calls [didSettleRoute] once the route that brought the page in has settled.
mixin RouteSettledMixin<T extends StatefulWidget> on State<T> {
  var _settleScheduled = false;
  var _routeSettled = false;

  bool get routeSettled => _routeSettled;

  @protected
  void didSettleRoute();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settleScheduled) {
      return;
    }
    _settleScheduled = true;
    unawaited(_settle());
  }

  Future<void> _settle() async {
    await whenRouteSettled(context);
    if (!mounted) {
      return;
    }
    _routeSettled = true;
    didSettleRoute();
  }
}

ScrollCacheExtent? arrivalScrollCacheExtent(bool routeSettled) {
  return routeSettled ? null : const ScrollCacheExtent.pixels(0);
}
