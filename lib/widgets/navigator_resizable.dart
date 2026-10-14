/*
Adapted from navigator_resizable 3.1.0,
https://github.com/fujidaiti/navigator_resizable

The MIT License (MIT)

Copyright (c) 2024 Daichi Fujita

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import 'package:fl_clash/widgets/drag_back.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

const Curve _sizeCurve = Curves.easeInOutCubic;

/// Sizes itself to the content of the current route of the [Navigator] below
/// it, and follows the routes' transitions from one size to the next.
class NavigatorResizable extends StatefulWidget {
  const NavigatorResizable({super.key, required this.child});

  final Widget child;

  @override
  State<NavigatorResizable> createState() => _NavigatorResizableState();
}

class _NavigatorResizableState extends State<NavigatorResizable> {
  final _sizes = _RouteSizes();

  @override
  void dispose() {
    _sizes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RouteSizesScope(
      sizes: _sizes,
      child: _ResizableBox(preferredSize: _sizes, child: widget.child),
    );
  }
}

class _RouteSizesScope extends InheritedWidget {
  const _RouteSizesScope({required this.sizes, required super.child});

  final _RouteSizes sizes;

  static _RouteSizes? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_RouteSizesScope>()?.sizes;

  @override
  bool updateShouldNotify(_RouteSizesScope oldWidget) =>
      sizes != oldWidget.sizes;
}

/// A route the [NavigatorResizable] above its navigator sizes to.
mixin ResizableNavigatorRouteMixin<T> on DragBackRouteMixin<T> {
  _RouteSizes? _sizes;

  /// Wraps the page the navigator sizes to while this route is current.
  Widget resizableContent(Widget child) {
    return _ContentBoundary(route: this, child: child);
  }

  @override
  void install() {
    super.install();
    _sizes = _RouteSizesScope.of(navigator!.context)?.._didInstall(this);
  }

  @override
  void dispose() {
    _sizes?._didDispose(this);
    _sizes = null;
    super.dispose();
  }

  @override
  void didAdd() {
    super.didAdd();
    _sizes?._didAdd(this);
  }

  @override
  TickerFuture didPush() {
    final result = super.didPush();
    _sizes?._didPush(this);
    return result;
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    super.didReplace(oldRoute);
    _sizes?._didReplace(this, oldRoute);
  }

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    _sizes?._previousRouteOf[this] = previousRoute;
  }

  @override
  void didChangeNext(Route<dynamic>? nextRoute) {
    super.didChangeNext(nextRoute);
    _sizes?._didChangeNext(this, nextRoute);
  }

  @override
  void didPopNext(Route<dynamic> nextRoute) {
    super.didPopNext(nextRoute);
    _sizes?._uncover(this, nextRoute);
  }

  @override
  void didStartDragBack() {
    super.didStartDragBack();
    _sizes?._didStartDragBack(this);
  }

  @override
  void didEndDragBack() {
    super.didEndDragBack();
    _sizes?._didEndDragBack(this);
  }
}

class _RouteSizes extends ChangeNotifier implements ValueListenable<Size> {
  final _contentSizes = <Route<dynamic>, Size>{};
  final _previousRouteOf = <Route<dynamic>, Route<dynamic>?>{};
  final _nextRouteOf = <Route<dynamic>, Route<dynamic>?>{};
  Route<dynamic>? _settledRoute;
  Animation<Size?>? _interpolation;
  ({Route<dynamic> route, Animation<Size?> interpolation})? _drag;
  Size? _lastValidSize;

  @override
  Size get value {
    final size = _interpolation == null
        ? _contentSizes[_settledRoute]
        : _interpolation!.value;
    if (size != null && size.isFinite) {
      return _lastValidSize = size;
    }
    return _lastValidSize ?? Size.infinite;
  }

  @override
  void dispose() {
    _interpolation?.removeListener(notifyListeners);
    super.dispose();
  }

  void _interpolate(Animation<Size?> interpolation) {
    _interpolation?.removeListener(notifyListeners);
    _interpolation = interpolation..addListener(notifyListeners);
  }

  void _settle(Route<dynamic>? route) {
    final oldSize = value;
    _interpolation?.removeListener(notifyListeners);
    _interpolation = null;
    _settledRoute = route;
    if (value != oldSize) {
      notifyListeners();
    }
  }

  void _didChangeContentSize(Route<dynamic> route, Size size) {
    assert(_contentSizes.containsKey(route));
    final oldSize = value;
    _contentSizes[route] = size;
    if (value != oldSize) {
      notifyListeners();
    }
  }

  void _didInstall(Route<dynamic> route) {
    _contentSizes[route] = Size.infinite;
  }

  void _didDispose(Route<dynamic> route) {
    _contentSizes.remove(route);
    _previousRouteOf.remove(route);
    _nextRouteOf.remove(route);
    if (_drag?.route == route) {
      _drag = null;
    }
    if (_settledRoute == route) {
      _settledRoute = null;
    }
  }

  void _didAdd(Route<dynamic> route) {
    if (route.isCurrent) {
      _settle(route);
    }
  }

  void _didPush(ModalRoute<dynamic> route) {
    final animation = route.animation!;
    if (animation.isCompleted) {
      _settle(route);
      return;
    }
    final from = value;
    _interpolate(
      _LazySizeTween(start: () => from, end: () => _contentSizes[route])
          .chain(CurveTween(curve: _sizeCurve))
          .animate(_TransitionProgress(route)),
    );

    void handleStatus(AnimationStatus status) {
      switch (status) {
        case AnimationStatus.completed when !route.offstage:
          animation.removeStatusListener(handleStatus);
          if (route.isCurrent) {
            _settle(route);
          }
        case AnimationStatus.dismissed:
          animation.removeStatusListener(handleStatus);
        case _:
      }
    }

    animation.addStatusListener(handleStatus);
  }

  void _didReplace(Route<dynamic> route, Route<dynamic>? oldRoute) {
    if (oldRoute == _settledRoute) {
      _settle(route);
    }
  }

  void _didChangeNext(Route<dynamic> route, Route<dynamic>? nextRoute) {
    final lostNext =
        nextRoute == null && _nextRouteOf[route] != null && route.isCurrent;
    // Of the routes that were above, the top one still animating out drives
    // the way back; one removed without a transition leaves nothing to follow.
    Route<dynamic>? exiting;
    if (lostNext) {
      for (
        var above = _nextRouteOf[route];
        above != null;
        above = _nextRouteOf[above]
      ) {
        if (above is TransitionRoute<dynamic> &&
            above.animation!.status == AnimationStatus.reverse) {
          exiting = above;
        }
      }
    }
    _nextRouteOf[route] = nextRoute;
    if (lostNext) {
      _uncover(route, exiting);
    }
  }

  void _uncover(Route<dynamic> route, Route<dynamic>? exiting) {
    if (exiting != null && exiting == _drag?.route) {
      return;
    }
    if (!route.isCurrent) {
      return;
    }
    if (exiting is! TransitionRoute<dynamic> ||
        exiting.animation!.isDismissed) {
      _settle(route);
      return;
    }
    final animation = exiting.animation!;
    final progress = animation.value;
    final from = value;
    final Animatable<Size?> tween = progress == 1
        ? _LazySizeTween(
            start: () => _contentSizes[route],
            end: () => from,
          ).chain(CurveTween(curve: _sizeCurve))
        // Popped mid-transition: run linearly from where the size is now.
        : _LazySizeTween(
            start: () => _contentSizes[route],
            end: () => _lerpEndSize(_contentSizes[route]!, from, progress),
          );
    _interpolate(tween.animate(_TransitionProgress(exiting)));

    void handleStatus(AnimationStatus status) {
      if (!status.isDismissed) {
        return;
      }
      animation.removeStatusListener(handleStatus);
      if (route.isCurrent) {
        _settle(route);
      }
    }

    animation.addStatusListener(handleStatus);
  }

  void _didStartDragBack(ModalRoute<dynamic> route) {
    final target = _previousRouteOf[route];
    if (target == null) {
      return;
    }
    final from = value;
    _interpolate(
      _LazySizeTween(
        start: () => _contentSizes[target],
        end: () => from,
      ).animate(route.animation!),
    );
    _drag = (route: route, interpolation: _interpolation!);
  }

  void _didEndDragBack(Route<dynamic> route) {
    final drag = _drag;
    if (drag?.route != route) {
      return;
    }
    _drag = null;
    // A push or pop since the drag runs its own transition and settles it.
    if (_interpolation == drag!.interpolation) {
      _settle(_contentSizes.keys.where((it) => it.isCurrent).firstOrNull);
    }
  }
}

class _TransitionProgress extends Animation<double>
    with AnimationWithParentMixin<double> {
  _TransitionProgress(this.route);

  final TransitionRoute<dynamic> route;

  @override
  Animation<double> get parent => route.animation!;

  // A pushed route's first frame is built offstage with its animation at 1.
  @override
  double get value => switch (route) {
    ModalRoute<dynamic>(offstage: true) => 0.0,
    _ => parent.value,
  };
}

class _LazySizeTween extends Animatable<Size?> {
  _LazySizeTween({required this.start, required this.end});

  final ValueGetter<Size?> start;
  final ValueGetter<Size?> end;

  @override
  Size? transform(double t) {
    final start = this.start();
    if (start?.isFinite != true) {
      return null;
    }
    final end = this.end();
    if (end?.isFinite != true) {
      return null;
    }
    return Size.lerp(start, end, t);
  }
}

/// The size a linear run toward [start] would have begun at, given it is at
/// [current] when [t] of it remains.
Size _lerpEndSize(Size start, Size current, double t) {
  assert(0 < t && t <= 1);
  return Size(
    (current.width - (1 - t) * start.width) / t,
    (current.height - (1 - t) * start.height) / t,
  );
}

class _ResizableBox extends SingleChildRenderObjectWidget {
  const _ResizableBox({required this.preferredSize, required super.child});

  final ValueListenable<Size> preferredSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderResizableBox(preferredSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderResizableBox renderObject,
  ) {
    renderObject.preferredSize = preferredSize;
  }
}

class _RenderResizableBox extends RenderAligningShiftedBox {
  _RenderResizableBox(this._preferredSize)
    : super(alignment: Alignment.topLeft, textDirection: null) {
    _preferredSize.addListener(_handlePreferredSizeChange);
  }

  ValueListenable<Size> _preferredSize;
  bool _disposed = false;

  // ignore: avoid_setters_without_getters
  set preferredSize(ValueListenable<Size> value) {
    if (value == _preferredSize) {
      return;
    }
    _preferredSize.removeListener(_handlePreferredSizeChange);
    _preferredSize = value..addListener(_handlePreferredSizeChange);
    markNeedsLayout();
  }

  // A page reports its size from its own layout, which runs after this box's
  // in the same frame, so the new size waits for the next one.
  void _handlePreferredSizeChange() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        if (!_disposed) {
          markNeedsLayout();
        }
      });
      return;
    }
    markNeedsLayout();
  }

  @override
  void dispose() {
    _preferredSize.removeListener(_handlePreferredSizeChange);
    _disposed = true;
    super.dispose();
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.constrain(_preferredSize.value);
  }

  @override
  void performLayout() {
    assert(
      !constraints.isTight,
      'NavigatorResizable sizes itself to its route, so it needs loose '
      'constraints, but got $constraints from ${parent.runtimeType}.',
    );
    assert(
      constraints.hasBoundedWidth && constraints.hasBoundedHeight,
      'NavigatorResizable lays its routes out within its own constraints, so '
      'they must be bounded, but got $constraints from ${parent.runtimeType}.',
    );
    // The navigator gets all the room and may overflow this box.
    child!.layout(constraints, parentUsesSize: true);
    size = computeDryLayout(constraints);
    alignChild();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      oldLayer: layer as ClipRectLayer?,
    );
  }
}

class _ContentBoundary extends SingleChildRenderObjectWidget {
  const _ContentBoundary({required this.route, required super.child});

  final ResizableNavigatorRouteMixin<dynamic> route;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderContentBoundary(route);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderContentBoundary renderObject,
  ) {
    renderObject.route = route;
  }
}

class _RenderContentBoundary extends RenderPositionedBox {
  _RenderContentBoundary(this.route) : super(alignment: Alignment.topLeft);

  ResizableNavigatorRouteMixin<dynamic> route;

  @override
  void performLayout() {
    super.performLayout();
    if (child?.size case final size?) {
      // A debug build's size holds on to the render box it came from.
      route._sizes?._didChangeContentSize(route, Size.copy(size));
    }
  }
}
