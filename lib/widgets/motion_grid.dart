import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/grid.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// A [Grid] whose children glide to their new slot whenever the layout moves
/// them, and fade out in place when they leave.
///
/// Children are matched by key, so every [GridItem] must carry a unique one.
class MotionGrid extends StatefulWidget {
  final List<GridItem> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Duration duration;
  final Curve curve;

  const MotionGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 1,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.duration = const Duration(milliseconds: 420),
    this.curve = const Cubic(0.22, 0.72, 0.24, 1.08),
  });

  @override
  State<MotionGrid> createState() => _MotionGridState();
}

class _GridExit {
  final GridItem item;
  final AnimationController controller;
  final CurvedAnimation _curve;
  late final Animation<double> opacity = Tween(
    begin: 1.0,
    end: 0.0,
  ).animate(_curve);
  late final Animation<double> scale = Tween(
    begin: 1.0,
    end: 0.4,
  ).animate(_curve);

  _GridExit(this.item, this.controller)
    : _curve = CurvedAnimation(parent: controller, curve: Curves.easeIn);

  void dispose() {
    _curve.dispose();
    controller.dispose();
  }
}

class _MotionGridState extends State<MotionGrid> with TickerProviderStateMixin {
  final Map<Key, _GridExit> _exits = {};

  bool _debugHasUniqueKeys(List<GridItem> children) {
    final keys = children.map((item) => item.key).toSet();
    return !keys.contains(null) && keys.length == children.length;
  }

  @override
  void initState() {
    super.initState();
    assert(_debugHasUniqueKeys(widget.children));
  }

  @override
  void didUpdateWidget(MotionGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(_debugHasUniqueKeys(widget.children));
    final keys = {for (final item in widget.children) item.key!};
    for (final key in _exits.keys.where(keys.contains).toList()) {
      _exits.remove(key)!.dispose();
    }
    for (final item in oldWidget.children) {
      final key = item.key!;
      if (keys.contains(key) || _exits.containsKey(key)) {
        continue;
      }
      final controller = AnimationController(
        vsync: this,
        duration: commonDuration,
      );
      _exits[key] = _GridExit(item, controller);
      controller
        ..addStatusListener((status) {
          if (status.isCompleted) {
            _finishExit(key, controller);
          }
        })
        ..forward();
    }
  }

  void _finishExit(Key key, AnimationController controller) {
    if (!mounted || !identical(_exits[key]?.controller, controller)) {
      return;
    }
    setState(() {
      _exits.remove(key)!.dispose();
    });
  }

  @override
  void dispose() {
    for (final exit in _exits.values) {
      exit.dispose();
    }
    _exits.clear();
    super.dispose();
  }

  Widget _buildSlot(GridItem item, _GridExit? exit) {
    return _MotionGridSlot(
      key: item.key,
      exiting: exit != null,
      crossAxisCellCount: item.crossAxisCellCount,
      mainAxisCellCount: item.mainAxisCellCount,
      // The same widgets wrap a child whether or not it is leaving, so the
      // exit never remounts it.
      child: IgnorePointer(
        ignoring: exit != null,
        child: FadeTransition(
          opacity: exit?.opacity ?? kAlwaysCompleteAnimation,
          child: ScaleTransition(
            scale: exit?.scale ?? kAlwaysCompleteAnimation,
            child: item.child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MotionGridLayout(
      vsync: this,
      duration: widget.duration,
      curve: widget.curve,
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      children: [
        // Leaving children come first so the ones sliding in paint over them.
        for (final exit in _exits.values) _buildSlot(exit.item, exit),
        for (final item in widget.children) _buildSlot(item, null),
      ],
    );
  }
}

class _MotionGridSlot extends GridItem {
  final bool exiting;

  const _MotionGridSlot({
    super.key,
    required this.exiting,
    required super.crossAxisCellCount,
    required super.mainAxisCellCount,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    super.applyParentData(renderObject);
    final parentData = renderObject.parentData;
    if (parentData is _MotionGridParentData && parentData.exiting != exiting) {
      parentData.exiting = exiting;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MotionGrid;
}

class _MotionGridLayout extends Grid {
  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;

  const _MotionGridLayout({
    required this.vsync,
    required this.duration,
    required this.curve,
    super.crossAxisCount,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMotionGrid(
      vsync: vsync,
      duration: duration,
      curve: curve,
      textDirection: textDirection,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      axisDirection: axisDirection,
      mainAxisExtent: mainAxisExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGrid renderObject) {
    super.updateRenderObject(context, renderObject);
    (renderObject as _RenderMotionGrid)
      ..vsync = vsync
      ..duration = duration
      ..curve = curve;
  }
}

class _MotionGridParentData extends GridParentData {
  bool exiting = false;

  /// Where layout put the child; [offset] is where it is painted.
  Offset? target;

  /// The painted position relative to [target] when the motion started.
  Offset from = Offset.zero;

  Size? exitSize;
}

class _RenderMotionGrid extends RenderGrid {
  _RenderMotionGrid({
    required TickerProvider vsync,
    required Duration duration,
    required Curve curve,
    required super.mainAxisSpacing,
    required super.crossAxisSpacing,
    required super.crossAxisCount,
    required super.axisDirection,
    required super.textDirection,
    super.mainAxisExtent,
  }) : _vsync = vsync,
       _curve = curve {
    _controller = AnimationController(vsync: vsync, duration: duration)
      ..addListener(() {
        _placeChildren();
        markNeedsPaint();
      });
  }

  late final AnimationController _controller;
  BoxConstraints? _lastConstraints;

  TickerProvider _vsync;

  set vsync(TickerProvider value) {
    if (value == _vsync) {
      return;
    }
    _vsync = value;
    _controller.resync(value);
  }

  set duration(Duration value) => _controller.duration = value;

  Curve _curve;

  set curve(Curve value) => _curve = value;

  _MotionGridParentData _parentDataOf(RenderBox child) {
    return child.parentData as _MotionGridParentData;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _MotionGridParentData) {
      child.parentData = _MotionGridParentData();
    }
  }

  @override
  bool participatesInLayout(RenderBox child) => !_parentDataOf(child).exiting;

  @override
  void performLayout() {
    final painted = <RenderBox, Offset>{
      for (final child in getChildrenAsList())
        if (_parentDataOf(child).target != null)
          child: _parentDataOf(child).offset,
    };
    super.performLayout();
    // A new width moves every child at once; follow it instead of trailing.
    final animate = _lastConstraints == constraints;
    _lastConstraints = constraints;
    var moving = false;
    for (final child in getChildrenAsList()) {
      final parentData = _parentDataOf(child);
      final before = painted[child];
      if (parentData.exiting) {
        final exitSize = parentData.exitSize ??= child.hasSize
            ? child.size
            : Size.zero;
        child.layout(BoxConstraints.tight(exitSize));
        parentData
          ..target = before ?? parentData.offset
          ..from = Offset.zero;
        continue;
      }
      parentData.exitSize = null;
      final target = parentData.offset;
      parentData.target = target;
      parentData.from = animate && before != null
          ? before - target
          : Offset.zero;
      if (parentData.from.distanceSquared > precisionErrorTolerance) {
        moving = true;
      }
    }
    if (moving) {
      _controller.forward(from: 0);
    } else {
      _controller.stop();
    }
    _placeChildren();
  }

  void _placeChildren() {
    final remaining = 1 - _curve.transform(_controller.value);
    for (final child in getChildrenAsList()) {
      final parentData = _parentDataOf(child);
      final target = parentData.target;
      if (target != null) {
        parentData.offset = target + parentData.from * remaining;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
