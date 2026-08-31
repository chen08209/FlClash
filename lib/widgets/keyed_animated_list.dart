import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

const _defaultDuration = Duration(milliseconds: 300);

/// A lazily built vertical list that diffs [items] by key: removed items
/// collapse out, inserted items grow in, and items whose key survives slide
/// from their previous slot to the new one.
class KeyedAnimatedList<T> extends StatefulWidget {
  final List<T> items;
  final Object Function(T item) keyOf;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? separator;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Duration duration;

  const KeyedAnimatedList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    this.separator,
    this.controller,
    this.padding,
    this.duration = _defaultDuration,
  });

  @override
  State<KeyedAnimatedList<T>> createState() => _KeyedAnimatedListState<T>();
}

class _Entry<T> {
  final Object key;
  T item;
  AnimationController? controller;
  bool removing = false;

  _Entry(this.key, this.item);
}

class _KeyedAnimatedListState<T> extends State<KeyedAnimatedList<T>>
    with TickerProviderStateMixin {
  List<_Entry<T>> _entries = [];
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _entries = [
      for (final item in widget.items) _Entry(widget.keyOf(item), item),
    ];
  }

  @override
  void didUpdateWidget(covariant KeyedAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) {
      _applyItems(widget.items);
    }
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller?.dispose();
    }
    super.dispose();
  }

  AnimationController _createController(
    _Entry<T> entry, {
    required double from,
  }) {
    final controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: from,
    );
    controller.addStatusListener((status) {
      if (!mounted) {
        return;
      }
      if (!status.isAnimating) {
        setState(() {
          entry.controller = null;
          if (status.isDismissed) {
            _entries.remove(entry);
          }
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          controller.dispose();
        });
      }
    });
    return controller;
  }

  void _applyItems(List<T> items) {
    final oldByKey = {for (final entry in _entries) entry.key: entry};
    final newKeys = {for (final item in items) widget.keyOf(item)};

    final removedBefore = <Object, List<_Entry<T>>>{};
    var pending = <_Entry<T>>[];
    for (final entry in _entries) {
      if (newKeys.contains(entry.key)) {
        if (pending.isNotEmpty) {
          removedBefore[entry.key] = pending;
          pending = [];
        }
      } else {
        pending.add(entry);
        if (!entry.removing) {
          entry.removing = true;
          final controller =
              entry.controller ?? _createController(entry, from: 1);
          entry.controller = controller;
          controller.reverse();
        }
      }
    }

    final next = <_Entry<T>>[];
    for (final item in items) {
      final key = widget.keyOf(item);
      next.addAll(removedBefore[key] ?? const []);
      final existing = oldByKey[key];
      if (existing == null) {
        final entry = _Entry(key, item);
        entry.controller = _createController(entry, from: 0)..forward();
        next.add(entry);
        continue;
      }
      existing.item = item;
      if (existing.removing) {
        existing.removing = false;
        existing.controller?.forward();
      }
      next.add(existing);
    }
    next.addAll(pending);

    setState(() {
      _entries = next;
      _generation++;
    });
  }

  Widget _buildRow(BuildContext context, int index) {
    final entry = _entries[index];
    final separator = widget.separator;
    Widget row = widget.itemBuilder(context, entry.item);
    if (separator != null && index < _entries.length - 1) {
      row = Column(mainAxisSize: MainAxisSize.min, children: [row, separator]);
    }
    final controller = entry.controller;
    if (controller != null) {
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      row = SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: animation, child: row),
      );
    }
    return _SlideOnMove(
      key: ValueKey(entry.key),
      generation: _generation,
      duration: widget.duration,
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    final indexByKey = {
      for (final (index, entry) in _entries.indexed) entry.key: index,
    };
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      itemCount: _entries.length,
      addRepaintBoundaries: false,
      findChildIndexCallback: (key) =>
          key is ValueKey<Object> ? indexByKey[key.value] : null,
      itemBuilder: _buildRow,
    );
  }
}

class _SlideOnMove extends StatefulWidget {
  final int generation;
  final Duration duration;
  final Widget child;

  const _SlideOnMove({
    super.key,
    required this.generation,
    required this.duration,
    required this.child,
  });

  @override
  State<_SlideOnMove> createState() => _SlideOnMoveState();
}

class _SlideOnMoveState extends State<_SlideOnMove>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didUpdateWidget(covariant _SlideOnMove oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SlideOnMoveRenderWidget(
      generation: widget.generation,
      controller: _controller,
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class _SlideOnMoveRenderWidget extends SingleChildRenderObjectWidget {
  final int generation;
  final AnimationController controller;

  const _SlideOnMoveRenderWidget({
    required this.generation,
    required this.controller,
    required super.child,
  });

  @override
  _RenderSlideOnMove createRenderObject(BuildContext context) {
    return _RenderSlideOnMove(generation: generation, controller: controller);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSlideOnMove renderObject,
  ) {
    renderObject
      ..controller = controller
      ..generation = generation;
  }
}

/// Tracks the child's scroll-content offset on every paint; when the list
/// generation changes the last painted offset becomes the slide origin, since
/// the sliver clears a moved child's layoutOffset before it can be read.
/// Sits above its own [RepaintBoundary] so paint runs on every frame while the
/// row content stays cached.
class _RenderSlideOnMove extends RenderProxyBox {
  int _generation;
  AnimationController _controller;
  double? _lastOffset;
  double? _previousOffset;
  double _delta = 0;
  bool _startPending = false;

  _RenderSlideOnMove({
    required int generation,
    required AnimationController controller,
  }) : _generation = generation,
       _controller = controller;

  set controller(AnimationController value) {
    if (identical(value, _controller)) {
      return;
    }
    _controller.removeListener(markNeedsPaint);
    _controller = value..addListener(markNeedsPaint);
  }

  set generation(int value) {
    if (value == _generation) {
      return;
    }
    _generation = value;
    _previousOffset = _lastOffset;
    markNeedsPaint();
  }

  double? _contentOffset() {
    if (!attached || !hasSize) {
      return null;
    }
    final viewport = RenderAbstractViewport.maybeOf(this);
    if (viewport == null) {
      return null;
    }
    return viewport.getOffsetToReveal(this, 0).offset;
  }

  @override
  void detach() {
    _controller.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(markNeedsPaint);
  }

  void _settlePendingMove(double? current) {
    final previous = _previousOffset;
    _previousOffset = null;
    if (previous == null || current == null) {
      return;
    }
    final delta = previous - current + _translation;
    if (delta.abs() < 1) {
      return;
    }
    _delta = delta;
    _startPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startPending = false;
      if (attached) {
        _controller.forward(from: 0);
      }
    });
  }

  double get _translation {
    if (_startPending) {
      return _delta;
    }
    if (!_controller.isAnimating) {
      return 0;
    }
    return _delta * (1 - Curves.easeOutCubic.transform(_controller.value));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final current = _contentOffset();
    _settlePendingMove(current);
    _lastOffset = current;
    final translation = _translation;
    if (translation.abs() < 0.5) {
      super.paint(context, offset);
      return;
    }
    context.pushTransform(
      needsCompositing,
      offset,
      Matrix4.translationValues(0, translation, 0),
      super.paint,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(0, _translation, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final translation = _translation;
    if (translation.abs() < 0.5) {
      return super.hitTestChildren(result, position: position);
    }
    return result.addWithPaintTransform(
      transform: Matrix4.translationValues(0, translation, 0),
      position: position,
      hitTest: (result, position) =>
          super.hitTestChildren(result, position: position),
    );
  }
}
