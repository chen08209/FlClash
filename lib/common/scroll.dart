import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

bool isTouchPlatform(TargetPlatform platform) => switch (platform) {
  TargetPlatform.android ||
  TargetPlatform.iOS ||
  TargetPlatform.fuchsia => true,
  TargetPlatform.linux ||
  TargetPlatform.macOS ||
  TargetPlatform.windows => false,
};

class BaseScrollBehavior extends MaterialScrollBehavior {
  const BaseScrollBehavior({this.scrollbarPadding = EdgeInsets.zero});

  final EdgeInsets scrollbarPadding;

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    if (system.isDesktop) PointerDeviceKind.mouse,
    PointerDeviceKind.unknown,
  };

  bool showScrollbar(BuildContext context) =>
      !isTouchPlatform(getPlatform(context));

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) == Axis.horizontal ||
        !showScrollbar(context)) {
      return child;
    }
    return CommonScrollBar.ambient(
      controller: details.controller,
      padding: scrollbarPadding,
      child: child,
    );
  }

  @override
  bool shouldNotify(covariant BaseScrollBehavior oldDelegate) {
    return oldDelegate.scrollbarPadding != scrollbarPadding;
  }
}

class HiddenBarScrollBehavior extends BaseScrollBehavior {
  const HiddenBarScrollBehavior();

  @override
  bool showScrollbar(BuildContext context) => false;
}

class ShowBarScrollBehavior extends BaseScrollBehavior {
  const ShowBarScrollBehavior({super.scrollbarPadding});

  @override
  bool showScrollbar(BuildContext context) => true;
}

class NextClampingScrollPhysics extends ClampingScrollPhysics {
  const NextClampingScrollPhysics({super.parent});

  @override
  NextClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NextClampingScrollPhysics(parent: buildParent(ancestor));
  }

  // iOS momentum is sized for its friction fling; a clamping one multiplies it.
  @override
  double carriedMomentum(double existingVelocity) => 0;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = toleranceFor(position);
    if (position.outOfRange) {
      double? end;
      if (position.pixels > position.maxScrollExtent) {
        end = position.maxScrollExtent;
      }
      if (position.pixels < position.minScrollExtent) {
        end = position.minScrollExtent;
      }
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        end!,
        end,
        min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}

class FollowEndScrollPhysics extends NextClampingScrollPhysics {
  const FollowEndScrollPhysics({required this.isFollowing, super.parent});

  final ValueGetter<bool> isFollowing;

  static bool isAtEnd(ScrollMetrics metrics) =>
      metrics.pixels >= metrics.maxScrollExtent - precisionErrorTolerance;

  @override
  FollowEndScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FollowEndScrollPhysics(
      isFollowing: isFollowing,
      parent: buildParent(ancestor),
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    if (isFollowing() && isAtEnd(oldPosition)) {
      return newPosition.maxScrollExtent;
    }
    return super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }
}

double zeroDividerExtentEstimation(int? index, double crossAxisExtent) {
  return index != null && index.isEven ? 100 : 0;
}

mixin ScrubbableScrollPosition on ScrollPosition {
  bool isScrubbing = false;
}

/// Drags move the sheet until it opens fully, so a scrollbar hides till then.
mixin SheetScrollController on ScrollController {
  ValueListenable<bool> get sheetOpen;
}

const _stopEpsilon = 1e-3;

/// Settles each scroll on a whole row of [RowSnapScrollController.itemExtent].
class RowSnapScrollPhysics extends ScrollPhysics {
  const RowSnapScrollPhysics({super.parent});

  @override
  RowSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RowSnapScrollPhysics(parent: buildParent(ancestor));
  }

  bool _canSnap(_RowSnapScrollPosition position) =>
      position.itemExtent > 0 &&
      position.maxScrollExtent > position.minScrollExtent;

  // The end is rarely row-aligned, so it replaces the nearest row as a stop.
  int _lastStop(_RowSnapScrollPosition position) => max(
    ((position.maxScrollExtent - position.minScrollExtent) /
            position.itemExtent)
        .round(),
    1,
  );

  double _stopAt(_RowSnapScrollPosition position, double pixels) {
    final lastRow = (_lastStop(position) - 1) * position.itemExtent;
    final offset = pixels - position.minScrollExtent;
    if (offset <= lastRow) {
      return offset / position.itemExtent;
    }
    final range = position.maxScrollExtent - position.minScrollExtent;
    return _lastStop(position) - 1 + (offset - lastRow) / (range - lastRow);
  }

  double _pixelsOf(_RowSnapScrollPosition position, int stop) {
    if (stop >= _lastStop(position)) {
      return position.maxScrollExtent;
    }
    return position.minScrollExtent + max(stop, 0) * position.itemExtent;
  }

  Simulation? _springToStop(
    _RowSnapScrollPosition position,
    double velocity,
    ScrollDirection direction,
  ) {
    final stop = _stopAt(position, position.pixels);
    final target = _pixelsOf(position, switch (direction) {
      ScrollDirection.reverse => (stop - _stopEpsilon).ceil(),
      ScrollDirection.forward => (stop + _stopEpsilon).floor(),
      ScrollDirection.idle => stop.round(),
    });
    if (target == position.pixels) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: toleranceFor(position),
    );
  }

  Simulation? _settleWheel(
    _RowSnapScrollPosition position,
    ScrollDirection direction,
  ) {
    return _canSnap(position) ? _springToStop(position, 0, direction) : null;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position is! _RowSnapScrollPosition ||
        !_canSnap(position) ||
        position.outOfRange ||
        velocity.abs() >= toleranceFor(position).velocity) {
      return super.createBallisticSimulation(position, velocity);
    }
    return _springToStop(position, velocity, ScrollDirection.idle);
  }
}

class RowSnapScrollController extends ScrollController {
  RowSnapScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  double itemExtent = 0;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _RowSnapScrollPosition(
      controller: this,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

const _wheelSettleDelay = Duration(milliseconds: 200);

// Stock wheel handling settles after every tick instead of once it rests.
class _RowSnapScrollPosition extends ScrollPositionWithSingleContext {
  _RowSnapScrollPosition({
    required this.controller,
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  final RowSnapScrollController controller;

  double get itemExtent => controller.itemExtent;

  Timer? _wheelSettle;
  bool _wheeling = false;

  @override
  void pointerScroll(double delta) {
    _wheeling = true;
    try {
      super.pointerScroll(delta);
    } finally {
      _wheeling = false;
    }
  }

  @override
  void goBallistic(double velocity) {
    final physics = this.physics;
    if (!_wheeling || physics is! RowSnapScrollPhysics) {
      super.goBallistic(velocity);
      return;
    }
    final direction = userScrollDirection;
    goIdle();
    _wheelSettle = Timer(_wheelSettleDelay, () {
      final simulation = physics._settleWheel(this, direction);
      if (simulation != null) {
        beginActivity(
          BallisticScrollActivity(
            this,
            simulation,
            context.vsync,
            shouldIgnorePointer,
          ),
        );
      }
    });
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    _wheelSettle?.cancel();
    super.beginActivity(newActivity);
  }

  @override
  void dispose() {
    _wheelSettle?.cancel();
    super.dispose();
  }
}

class ReverseScrollController extends ScrollController {
  ReverseScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return ReverseScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class ReverseScrollPosition extends ScrollPositionWithSingleContext {
  ReverseScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels = 0.0,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  bool _isInit = false;

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    if (!_isInit) {
      correctPixels(maxScrollExtent);
      _isInit = true;
    }
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }
}
