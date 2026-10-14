import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const double _flingVelocity = 1.0;
const Duration _settleDuration = Duration(milliseconds: 350);
const double _dragEdge = 1e-6;

final Animatable<Offset> _slideTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);
const Animation<Offset> _noSlide = AlwaysStoppedAnimation(Offset.zero);

/// Lets a press anywhere on the route drag it toward the reading end to pop.
/// A horizontal scrollable, slider or text field under the pointer is deeper
/// in the hit test, so it wins the arena and keeps the drag.
mixin DragBackRouteMixin<T> on ModalRoute<T> {
  bool _dragBackActive = false;

  /// While true the route's own transition should follow the finger linearly,
  /// through the release until the route settles.
  bool get isDragBackActive => _dragBackActive;

  @protected
  void didStartDragBack() {}

  /// Called once the route has settled after a drag back, popped or not.
  @protected
  void didEndDragBack() {}

  Widget dragBackDetector(Widget child) {
    return _DragBackDetector(route: this, child: child);
  }

  /// Follows the finger while a drag back is active and stays still
  /// otherwise. A route keeps it in its tree either way: wrapping the page
  /// only once the drag starts would move the page to a new parent, which
  /// rebuilds all of it.
  Widget dragBackSlide(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: _dragBackActive ? animation.drive(_slideTween) : _noSlide,
      textDirection: Directionality.of(context),
      child: child,
    );
  }

  // popGestureEnabled no longer waits for the route to be fully uncovered or
  // for another drag back to settle, and NavigatorResizable would settle on
  // a pop still running under the drag.
  bool get _canDragBack =>
      isCurrent &&
      popGestureEnabled &&
      secondaryAnimation!.isDismissed &&
      !popGestureInProgress;

  void _startDragBack() {
    _dragBackActive = true;
    didStartDragBack();
    navigator!.didStartUserGesture();
  }

  // Either end reached mid-drag would flip the animation's status, which
  // routes take for a finished transition: TransitionRoute turns the route
  // opaque and OpenContainer hides or returns its tile. The release settles
  // the last bit.
  void _updateDragBack(double delta) {
    final controller = this.controller!;
    controller.value = clampDouble(
      controller.value - delta,
      _dragEdge,
      1 - _dragEdge,
    );
  }

  void _endDragBack(double velocity) {
    final controller = this.controller!;
    final navigator = this.navigator!;
    final bool settleForward;
    if (!isCurrent) {
      settleForward = isActive;
    } else if (velocity.abs() >= _flingVelocity) {
      settleForward = velocity <= 0;
    } else {
      settleForward = controller.value > 0.5;
    }
    if (settleForward) {
      controller.animateTo(
        1.0,
        duration: _settleDuration,
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      if (isCurrent) {
        navigator.pop();
      }
      if (controller.isAnimating) {
        controller.animateBack(
          0.0,
          duration: _settleDuration,
          curve: Curves.fastEaseInToSlowEaseOut,
        );
      }
    }
    if (!controller.isAnimating) {
      _finishDragBack(navigator);
      return;
    }
    void handleStatus(AnimationStatus status) {
      if (status.isAnimating) {
        return;
      }
      controller.removeStatusListener(handleStatus);
      _finishDragBack(navigator);
    }

    controller.addStatusListener(handleStatus);
  }

  void _finishDragBack(NavigatorState navigator) {
    if (!_dragBackActive) {
      return;
    }
    _dragBackActive = false;
    didEndDragBack();
    navigator.didStopUserGesture();
  }

  void _abortDragBack() {
    final navigator = this.navigator;
    if (!_dragBackActive || navigator == null) {
      return;
    }
    _dragBackActive = false;
    didEndDragBack();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted) {
        navigator.didStopUserGesture();
      }
    });
  }
}

class _DragBackDetector extends StatefulWidget {
  const _DragBackDetector({required this.route, required this.child});

  final DragBackRouteMixin<dynamic> route;
  final Widget child;

  @override
  State<_DragBackDetector> createState() => _DragBackDetectorState();
}

class _DragBackDetectorState extends State<_DragBackDetector> {
  late final _DragBackGestureRecognizer _recognizer;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _recognizer = _DragBackGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    if (_dragging) {
      widget.route._abortDragBack();
    }
    super.dispose();
  }

  double _toLogical(double value) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => -value,
      TextDirection.ltr => value,
    };
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.route._canDragBack) {
      _recognizer.addPointer(event);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    widget.route._startDragBack();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging) {
      return;
    }
    widget.route._updateDragBack(
      _toLogical(details.primaryDelta! / context.size!.width),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    widget.route._endDragBack(
      _toLogical(details.velocity.pixelsPerSecond.dx / context.size!.width),
    );
  }

  void _handleDragCancel() {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    widget.route._endDragBack(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

// Desktop text fields select with a pan, which accepts past the pan slop.
class _DragBackGestureRecognizer extends HorizontalDragGestureRecognizer {
  _DragBackGestureRecognizer({super.debugOwner});

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows =>
        globalDistanceMoved.abs() >
            computePanSlop(pointerDeviceKind, gestureSettings),
      _ => super.hasSufficientGlobalDistanceToAccept(
        pointerDeviceKind,
        deviceTouchSlop,
      ),
    };
  }
}
