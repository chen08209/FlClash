import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/activate_box.dart';
import 'package:fl_clash/widgets/defer_pointer.dart';
import 'package:fl_clash/widgets/motion_grid.dart';
import 'package:fl_clash/widgets/navigation_dock.dart';
import 'package:fl_clash/widgets/grid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps its own order while the user edits and reports each committed change
/// to [onChanged]; a list from the parent replaces it only when its keys
/// differ.
class SuperGrid extends StatefulWidget {
  final List<GridItem> children;
  final bool editing;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int crossAxisCount;
  final ValueChanged<List<GridItem>>? onChanged;

  /// What the page floats over the viewport's edges, kept clear on reveal.
  final EdgeInsets revealPadding;

  const SuperGrid({
    super.key,
    required this.children,
    this.editing = false,
    this.crossAxisCount = 1,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.onChanged,
    this.revealPadding = EdgeInsets.zero,
  });

  @override
  State<SuperGrid> createState() => SuperGridState();
}

class _Flight {
  final AnimationController controller;
  final Rect from;
  OverlayEntry? entry;
  Rect? lastTarget;

  _Flight(this.controller, this.from);

  void dispose() {
    entry
      ?..remove()
      ..dispose();
    entry = null;
    controller.dispose();
  }
}

class SuperGridState extends State<SuperGrid> with TickerProviderStateMixin {
  static const _shakeDuration = Duration(milliseconds: 3600);
  static const _shakeSwingsPerLoop = [6, 7, 5];
  static const _shakeReach = 2.5;
  static const _hoverDelay = Duration(milliseconds: 120);
  static const _revealDuration = Duration(milliseconds: 300);
  static const _flightSpring = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 18,
  );

  /// Matches the default CommonCard shape, so the lift's shadow traces the card
  /// it is drawn behind.
  static const _cardShape = AppShape.md;

  List<GridItem> _items = [];

  final Map<Key, GlobalKey> _contentKeys = {};

  /// A null flight hides a slot that has not been laid out yet.
  final Map<Key, _Flight?> _flights = {};

  Key? _dragKey;
  final ValueNotifier<Size> _dragSize = ValueNotifier(Size.zero);
  Timer? _hoverTimer;

  EdgeDraggingAutoScroller? _autoScroller;
  Scrollable? _scrollable;
  Rect _dragRect = Rect.zero;

  late final AnimationController _shakeController;

  List<GridItem> get items => List<GridItem>.unmodifiable(_items);

  @override
  void initState() {
    super.initState();
    _items = List<GridItem>.of(widget.children);
    _shakeController = AnimationController(
      vsync: this,
      duration: _shakeDuration,
    );
    _syncShake();
  }

  @override
  void didUpdateWidget(SuperGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameKeys(oldWidget.children, widget.children)) {
      _items = List<GridItem>.of(widget.children);
      if (_dragKey != null && _indexOf(_dragKey!) < 0) {
        _dragKey = null;
      }
    } else if (!identical(oldWidget.children, widget.children)) {
      final latest = {for (final item in widget.children) item.key: item};
      _items = [for (final item in _items) latest[item.key] ?? item];
    }
    if (oldWidget.editing != widget.editing) {
      _dragKey = null;
      _hoverTimer?.cancel();
      _autoScroller?.stopAutoScroll();
      _syncShake();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = context.findAncestorWidgetOfExactType<Scrollable>();
    if (identical(_scrollable, scrollable)) {
      return;
    }
    _autoScroller?.stopAutoScroll();
    _scrollable = scrollable;
    if (scrollable == null) {
      _autoScroller = null;
      return;
    }
    late final EdgeDraggingAutoScroller autoScroller;
    autoScroller = EdgeDraggingAutoScroller(
      Scrollable.of(context),
      onScrollViewScrolled: () {
        if (_dragKey != null && identical(_autoScroller, autoScroller)) {
          autoScroller.startAutoScrollIfNecessary(_dragRect);
        }
      },
      velocityScalar: 40,
    );
    _autoScroller = autoScroller;
  }

  @override
  void dispose() {
    _autoScroller?.stopAutoScroll();
    _hoverTimer?.cancel();
    for (final flight in _flights.values) {
      flight?.dispose();
    }
    _flights.clear();
    _shakeController.dispose();
    _dragSize.dispose();
    super.dispose();
  }

  bool _sameKeys(List<GridItem> a, List<GridItem> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i].key != b[i].key) {
        return false;
      }
    }
    return true;
  }

  int _indexOf(Key key) => _items.indexWhere((item) => item.key == key);

  void _syncShake() {
    if (widget.editing) {
      _shakeController.repeat();
    } else {
      _shakeController.stop();
    }
  }

  void _commit(List<GridItem> items) {
    setState(() {
      _items = items;
    });
    widget.onChanged?.call(List<GridItem>.unmodifiable(items));
  }

  /// Completes once a copy of [item] has flown from the global [from] rect.
  Future<void> addItem(GridItem item, {Rect? from}) {
    final key = item.key!;
    if (_indexOf(key) >= 0) {
      return Future.value();
    }
    final landed = Completer<void>();
    if (from != null) {
      _holdSlot(key);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _revealSlot(key);
        landed.complete(_fly(key, from));
      });
    } else {
      landed.complete();
    }
    _commit([..._items, item]);
    return landed.future;
  }

  void _deleteItem(Key key) {
    if (_dragKey != null) {
      return;
    }
    _contentKeys.remove(key);
    _commit([
      for (final item in _items)
        if (item.key != key) item,
    ]);
  }

  RenderBox? _slotBoxOf(Key key) {
    final box = _contentKeys[key]?.currentContext?.findRenderObject();
    return box is RenderBox && box.attached && box.hasSize ? box : null;
  }

  Rect? _slotRectOf(Key key) {
    final box = _slotBoxOf(key);
    if (box == null) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _revealSlot(Key key) {
    final slotContext = _contentKeys[key]?.currentContext;
    final box = _slotBoxOf(key);
    if (!mounted || slotContext == null || box == null) {
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    final position = Scrollable.maybeOf(slotContext)?.position;
    if (viewport == null || position == null) {
      return;
    }
    final rect = widget.revealPadding.inflateRect(Offset.zero & box.size);
    final leading = viewport.getOffsetToReveal(box, 0, rect: rect).offset;
    final trailing = viewport.getOffsetToReveal(box, 1, rect: rect).offset;
    final target = clampDouble(
      trailing > leading
          ? leading
          : clampDouble(position.pixels, trailing, leading),
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((target - position.pixels).abs() < precisionErrorTolerance) {
      return;
    }
    unawaited(
      position.animateTo(
        target,
        duration: _revealDuration,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _holdSlot(Key key) {
    _flights[key]?.dispose();
    _flights[key] = null;
  }

  Future<void> _fly(Key key, Rect from) async {
    final index = _indexOf(key);
    if (!mounted || index < 0) {
      _flights.remove(key);
      return;
    }
    final item = _items[index];
    final controller = AnimationController.unbounded(vsync: this);
    final flight = _Flight(controller, from);
    _flights[key]?.dispose();
    _flights[key] = flight;
    final overlay = Overlay.of(context, rootOverlay: true);
    flight.entry = OverlayEntry(
      builder: (_) => _FlightView(
        flight: flight,
        overlay: overlay,
        slotRect: () => _slotRectOf(key),
        builder: _buildLiftedSurface,
        child: InheritedTheme.captureAll(
          context,
          ActivateBox(child: item.child),
        ),
      ),
    );
    overlay.insert(flight.entry!);
    try {
      await controller
          .animateWith(
            SpringSimulation(
              _flightSpring,
              0,
              1,
              0,
              tolerance: const Tolerance(distance: 0.001, velocity: 0.01),
            ),
          )
          .orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted || !identical(_flights[key], flight)) {
      return;
    }
    setState(() {
      _flights.remove(key);
    });
    flight.dispose();
  }

  void _handleDragStarted(Key key) {
    final box = _slotBoxOf(key);
    if (box == null) {
      return;
    }
    _dragSize.value = box.size;
    _dragRect = box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      _dragKey = key;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dragKey == null) {
      return;
    }
    _dragRect = _dragRect.shift(details.delta);
    _autoScroller?.startAutoScrollIfNecessary(_dragRect);
  }

  void _handleDragEnd(Key key, DraggableDetails details) {
    _hoverTimer?.cancel();
    _autoScroller?.stopAutoScroll();
    if (_dragKey != key) {
      return;
    }
    _dragKey = null;
    _holdSlot(key);
    _fly(key, details.offset & _dragSize.value);
    if (_sameKeys(_items, widget.children)) {
      setState(() {});
    } else {
      _commit(_items);
    }
  }

  void _scheduleHover(Key key) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(_hoverDelay, () => _handleHover(key));
  }

  void _handleHover(Key key) {
    final dragKey = _dragKey;
    if (!mounted || dragKey == null || dragKey == key) {
      return;
    }
    final from = _indexOf(dragKey);
    final to = _indexOf(key);
    if (from < 0 || to < 0) {
      return;
    }
    final items = List<GridItem>.of(_items);
    items.insert(to, items.removeAt(from));
    setState(() {
      _items = items;
    });
  }

  /// [t] is 1 while the item is held and eases to 0 as it settles, so the drag
  /// feedback and the flight are one surface at two depths.
  Widget _buildLiftedSurface(Widget child, double t) {
    final lift = t.clamp(0.0, 1.0);
    return Transform.scale(
      scale: 1 + 0.03 * lift,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: _cardShape,
          // BoxShadow.lerpList keeps colors opaque, leaving a hard outline.
          shadows: [
            for (final shadow in kElevationToShadow[8]!)
              BoxShadow(
                color: shadow.color.withValues(alpha: shadow.color.a * lift),
                offset: shadow.offset * lift,
                blurRadius: shadow.blurRadius * lift,
                spreadRadius: shadow.spreadRadius * lift,
              ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildShake(Widget child, int index) {
    final cycles = _shakeSwingsPerLoop[index % _shakeSwingsPerLoop.length];
    final phase = index * 1.7;
    return LayoutBuilder(
      builder: (_, constraints) {
        final radius = constraints.biggest.longestSide / 2;
        final maxAngle = radius.isFinite && radius > 0
            ? _shakeReach / radius
            : 0.0;
        return AnimatedBuilder(
          animation: _shakeController,
          builder: (_, child) {
            final turn = _shakeController.value * 2 * pi * cycles + phase;
            return Transform.translate(
              offset: Offset(0, cos(turn) * _shakeReach / 2),
              child: Transform.rotate(
                angle: sin(turn) * maxAngle,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  Widget _buildEditable(GridItem item, Widget content, int index) {
    final key = item.key!;
    // onDragEnd resolves the drop from the live order, so this target never
    // accepts; it only reports which item the pointer is over.
    final target = DragTarget<Key>(
      builder: (_, _, _) => AbsorbPointer(child: content),
      onWillAcceptWithDetails: (details) {
        if (details.data != key) {
          _scheduleHover(key);
        }
        return false;
      },
    );
    final decorated = _dragKey == key
        ? ActivateBox(child: Opacity(opacity: 0.4, child: content))
        : _buildShake(
            _DeletableContainer(
              onDelete: () => _deleteItem(key),
              child: target,
            ),
            index,
          );
    final feedback = ActivateBox(
      child: InheritedTheme.captureAll(
        context,
        ValueListenableBuilder(
          valueListenable: _dragSize,
          builder: (_, size, child) {
            return SizedBox.fromSize(size: size, child: child);
          },
          child: _buildLiftedSurface(item.child, 1),
        ),
      ),
    );
    final draggable = system.isDesktop
        ? Draggable<Key>(
            data: key,
            feedback: feedback,
            onDragStarted: () => _handleDragStarted(key),
            onDragUpdate: _handleDragUpdate,
            onDragEnd: (details) => _handleDragEnd(key, details),
            child: decorated,
          )
        : LongPressDraggable<Key>(
            data: key,
            feedback: feedback,
            onDragStarted: () => _handleDragStarted(key),
            onDragUpdate: _handleDragUpdate,
            onDragEnd: (details) => _handleDragEnd(key, details),
            child: decorated,
          );
    // The shake never stops while editing, and without a boundary here its
    // markNeedsPaint reaches the scroll viewport, so every frame repaints the
    // whole grid instead of one item.
    return RepaintBoundary(child: draggable);
  }

  GridItem _buildItem(GridItem item, int index) {
    final key = item.key!;
    final content = KeyedSubtree(
      key: _contentKeys.putIfAbsent(
        key,
        () => GlobalKey(debugLabel: 'super_grid_$key'),
      ),
      child: item.child,
    );
    return GridItem(
      key: key,
      crossAxisCellCount: item.crossAxisCellCount,
      mainAxisCellCount: item.mainAxisCellCount,
      child: Visibility.maintain(
        visible: !_flights.containsKey(key),
        child: widget.editing ? _buildEditable(item, content, index) : content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grid = MotionGrid(
      crossAxisCount: widget.crossAxisCount,
      crossAxisSpacing: widget.crossAxisSpacing,
      mainAxisSpacing: widget.mainAxisSpacing,
      children: [
        for (var i = 0; i < _items.length; i++) _buildItem(_items[i], i),
      ],
    );
    return DeferredPointerHandler(child: grid);
  }
}

class _FlightView extends StatelessWidget {
  final _Flight flight;
  final OverlayState overlay;
  final Rect? Function() slotRect;
  final Widget Function(Widget child, double lift) builder;
  final Widget child;

  const _FlightView({
    required this.flight,
    required this.overlay,
    required this.slotRect,
    required this.builder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flight.controller,
      builder: (_, child) {
        final overlayBox = overlay.context.findRenderObject();
        final target = flight.lastTarget = slotRect() ?? flight.lastTarget;
        if (target == null || overlayBox is! RenderBox) {
          return const SizedBox.shrink();
        }
        final t = flight.controller.value;
        final rect = Rect.lerp(flight.from, target, t)!;
        final topLeft = overlayBox.globalToLocal(rect.topLeft);
        // Scaled rather than laid out at in-between sizes its content may
        // not fit.
        return Positioned(
          left: topLeft.dx,
          top: topLeft.dy,
          child: Transform.scale(
            scale: rect.width / target.width,
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(
              size: target.size,
              child: builder(child!, 1 - t),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _DeletableContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;

  const _DeletableContainer({required this.child, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: ElasticButton(
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton.filled(
                  tooltip: context.appLocalizations.remove,
                  iconSize: 16,
                  padding: const EdgeInsets.all(4),
                  onPressed: onDelete,
                  icon: const GlyphIcon(AppGlyphs.close, fill: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
