import 'package:flutter/foundation.dart';
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
