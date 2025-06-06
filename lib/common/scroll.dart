import 'dart:math';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:flutter/material.dart';

class BaseScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        if (system.isDesktop) PointerDeviceKind.mouse,
        PointerDeviceKind.unknown,
      };
}

class HiddenBarScrollBehavior extends BaseScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class ShowBarScrollBehavior extends BaseScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return CommonScrollBar(
      controller: details.controller,
      child: child,
    );
  }
}

class NextClampingScrollPhysics extends ClampingScrollPhysics {
  const NextClampingScrollPhysics({super.parent});

  @override
  NextClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NextClampingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
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

// class CacheScrollPositionController extends ScrollController {
//   final String key;
//
//   CacheScrollPositionController({
//     required this.key,
//     double initialScrollOffset = 0.0,
//     super.keepScrollOffset = true,
//     super.debugLabel,
//     super.onAttach,
//     super.onDetach,
//   });
//
//   @override
//   ScrollPosition createScrollPosition(
//     ScrollPhysics physics,
//     ScrollContext context,
//     ScrollPosition? oldPosition,
//   ) {
//     return ScrollPositionWithSingleContext(
//       physics: physics,
//       context: context,
//       initialPixels:
//           globalState.scrollPositionCache[key] ?? initialScrollOffset,
//       keepScrollOffset: keepScrollOffset,
//       oldPosition: oldPosition,
//       debugLabel: debugLabel,
//     );
//   }
//
//   double? get cacheOffset => globalState.scrollPositionCache[key];
//
//   _handleScroll() {
//     globalState.scrollPositionCache[key] = position.pixels;
//   }
//
//   @override
//   void attach(ScrollPosition position) {
//     super.attach(position);
//     addListener(_handleScroll);
//   }
//
//   @override
//   void detach(ScrollPosition position) {
//     removeListener(_handleScroll);
//     super.detach(position);
//   }
// }

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
