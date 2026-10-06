import 'package:fl_clash/common/interface_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _flingVelocity = 1.0;
const Duration _settleDuration = Duration(milliseconds: 350);

final Animatable<Offset> _slideTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);

/// Lets a press anywhere on the route drag it toward the reading end to pop.
/// A horizontal scrollable, slider or text field under the pointer is deeper
/// in the hit test, so it wins the arena and keeps the drag.
/// [InterfaceStyleTheme.predictiveBack] lets Android's back gesture drive it.
mixin DragBackRouteMixin<T> on ModalRoute<T> {
  bool _dragBackActive = false;

  /// While true the route's own transition should follow the finger linearly,
  /// through the release until the route settles.
  bool get isDragBackActive => _dragBackActive;

  @protected
  void didStartDragBack() {}

  Widget dragBackDetector(Widget child) {
    return _DragBackDetector(route: this, child: child);
  }

  Widget dragBackSlide(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(_slideTween),
      textDirection: Directionality.of(context),
      child: child,
    );
  }

  /// Holds [secondaryAnimation] at rest while a back gesture slides the route
  /// above away, so this route shows whole behind it instead of mid-exit.
  Animation<double> dragBackSecondaryAnimation(
    BuildContext context,
    Animation<double> secondaryAnimation,
  ) {
    if (popGestureInProgress && context.interfaceStyle.predictiveBack) {
      return kAlwaysDismissedAnimation;
    }
    return secondaryAnimation;
  }

  bool get _canDragBack => isCurrent && popGestureEnabled && !_dragBackActive;

  // A dialog over a sheet leaves the pages inside the sheet current.
  bool get _hasNothingAbove {
    for (
      NavigatorState? navigator = this.navigator;
      navigator != null;
      navigator = navigator.context.findAncestorStateOfType<NavigatorState>()
    ) {
      if (ModalRoute.isCurrentOf(navigator.context) == false) {
        return false;
      }
    }
    return true;
  }

  void _startDragBack() {
    _dragBackActive = true;
    didStartDragBack();
    navigator!.didStartUserGesture();
  }

  void _updateDragBack(double delta) {
    controller!.value -= delta;
  }

  void _followBackGesture(double progress) {
    if (isCurrent) {
      controller!.value = 1.0 - progress;
    }
  }

  void _endDragBack(double velocity) {
    _settleDragBack(
      pop: velocity.abs() >= _flingVelocity
          ? velocity > 0
          : controller!.value <= 0.5,
    );
  }

  void _settleDragBack({required bool pop}) {
    final controller = this.controller!;
    final navigator = this.navigator!;
    final settleForward = isCurrent ? !pop : isActive;
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
    navigator.didStopUserGesture();
  }

  void _abortDragBack() {
    final navigator = this.navigator;
    if (!_dragBackActive || navigator == null) {
      return;
    }
    _dragBackActive = false;
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

class _DragBackDetectorState extends State<_DragBackDetector>
    with WidgetsBindingObserver {
  late final _DragBackGestureRecognizer _recognizer;
  bool _dragging = false;
  bool _followingBackGesture = false;

  @override
  void initState() {
    super.initState();
    _recognizer = _DragBackGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recognizer.dispose();
    if (_dragging || _followingBackGesture) {
      widget.route._abortDragBack();
    }
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    final route = widget.route;
    if (backEvent.isButtonEvent ||
        !route._canDragBack ||
        !context.interfaceStyle.predictiveBack ||
        !TickerMode.getValuesNotifier(context).value.enabled ||
        !route._hasNothingAbove) {
      return false;
    }
    _followingBackGesture = true;
    route
      .._startDragBack()
      .._followBackGesture(backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    widget.route._followBackGesture(backEvent.progress);
  }

  @override
  void handleCommitBackGesture() => _endBackGesture(pop: true);

  @override
  void handleCancelBackGesture() => _endBackGesture(pop: false);

  void _endBackGesture({required bool pop}) {
    if (!_followingBackGesture) {
      return;
    }
    _followingBackGesture = false;
    widget.route._settleDragBack(pop: pop);
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
    if (widget.route.isDragBackActive) {
      return;
    }
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
