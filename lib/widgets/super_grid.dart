import 'dart:async';
import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/activate_box.dart';
import 'package:fl_clash/widgets/grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';

/// Kept in one notifier so a builder that reads part of it also rebuilds when
/// the rest changes.
typedef _DragState = ({int index, Size size, bool landing});

const _idleDrag = (index: -1, size: Size.zero, landing: false);

class SuperGrid extends StatefulWidget {
  final List<GridItem> children;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int crossAxisCount;
  final VoidCallback? onUpdate;

  const SuperGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 1,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.onUpdate,
  });

  @override
  State<SuperGrid> createState() => SuperGridState();
}

class SuperGridState extends State<SuperGrid> with TickerProviderStateMixin {
  static const _reorderDuration = Duration(milliseconds: 420);
  static const _shakeDuration = Duration(milliseconds: 480);
  static const _reorderCurve = Cubic(0.22, 0.72, 0.24, 1.08);

  /// How long a pointer has to rest over an item before it makes room.
  static const _hoverDelay = Duration(milliseconds: 120);

  /// Matches the default CommonCard shape, so the lift's shadow traces the card
  /// it is drawn behind.
  static const _cardShape = AppShape.md;

  late final ValueNotifier<List<GridItem>> _childrenNotifier;
  List<GridItem> children = [];
  List<GridItem>? _pendingChildren;

  List<GridItem> get snapshotChildren =>
      List<GridItem>.unmodifiable(_pendingChildren ?? children);

  int get length => _childrenNotifier.value.length;
  int get crossCount => widget.crossAxisCount;

  /// Original index of the item occupying each visual slot.
  List<int> _tempIndexList = [];

  /// One stable key per slot, so item elements survive a reorder.
  final List<GlobalKey> _itemKeys = [];

  Size _containerSize = Size.zero;
  int _targetIndex = -1;
  Offset _targetOffset = Offset.zero;
  List<Size> _sizes = [];
  List<Offset> _offsets = [];
  Offset _parentOffset = Offset.zero;

  EdgeDraggingAutoScroller? _edgeDraggingAutoScroller;
  Scrollable? _scrollable;
  Rect _dragRect = Rect.zero;
  bool _isDragging = false;
  Timer? _hoverTimer;

  final ValueNotifier<_DragState> _dragNotifier = ValueNotifier(_idleDrag);

  late AnimationController _transformController;
  Map<int, Animation<Offset>> _transformAnimationMap = {};

  Future<bool> get isTransformCompleter =>
      _transformCompleter?.future ?? Future<bool>.value(true);
  Completer<bool>? _transformCompleter;

  late AnimationController _landingController;
  Animation<Offset>? _landingAnimation;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    children = List<GridItem>.of(widget.children);
    _childrenNotifier = ValueNotifier(children)
      ..addListener(_handleChildrenChanged);
    _tempIndexList = List.generate(length, (index) => index);
    _syncItemKeys();

    _landingController = AnimationController.unbounded(vsync: this);

    _shakeController = AnimationController(
      vsync: this,
      duration: _shakeDuration,
    )..repeat();

    _transformController = AnimationController(
      vsync: this,
      duration: _reorderDuration,
    );
    _resetDragState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final scrollable = context.findAncestorWidgetOfExactType<Scrollable>();
    if (scrollable == null) {
      _stopAutoScroll();
      _scrollable = null;
      _edgeDraggingAutoScroller = null;
      return;
    }
    if (_scrollable == scrollable) {
      return;
    }
    _stopAutoScroll();
    _scrollable = scrollable;
    late final EdgeDraggingAutoScroller autoScroller;
    autoScroller = EdgeDraggingAutoScroller(
      Scrollable.of(context),
      onScrollViewScrolled: () {
        if (!mounted ||
            !_isDragging ||
            !identical(_edgeDraggingAutoScroller, autoScroller)) {
          return;
        }
        autoScroller.startAutoScrollIfNecessary(_dragRect);
      },
      velocityScalar: 40,
    );
    _edgeDraggingAutoScroller = autoScroller;
  }

  @override
  void dispose() {
    _isDragging = false;
    _stopAutoScroll();
    _edgeDraggingAutoScroller = null;
    _scrollable = null;
    _hoverTimer?.cancel();
    _hoverTimer = null;
    final completer = _transformCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    _transformCompleter = null;
    _childrenNotifier.removeListener(_handleChildrenChanged);
    _childrenNotifier.value = const [];
    children = const [];
    _pendingChildren = null;
    _itemKeys.clear();
    _sizes = [];
    _offsets = [];
    _transformAnimationMap.clear();
    _landingAnimation = null;
    _landingController.dispose();
    _shakeController.dispose();
    _transformController.dispose();
    _dragNotifier.dispose();
    _childrenNotifier.dispose();
    super.dispose();
  }

  void handleAdd(GridItem gridItem) {
    _childrenNotifier.value = [..._childrenNotifier.value, gridItem];
  }

  void _stopAutoScroll() {
    _edgeDraggingAutoScroller?.stopAutoScroll();
  }

  void _handleChildrenChanged() {
    children = List<GridItem>.of(_childrenNotifier.value);
    _tempIndexList = List.generate(length, (index) => index);
    _syncItemKeys();
    widget.onUpdate?.call();
  }

  /// Grows or trims [_itemKeys] without replacing existing entries, so a slot
  /// keeps its key across reorders and its element is never rebuilt.
  void _syncItemKeys() {
    while (_itemKeys.length < length) {
      _itemKeys.add(
        GlobalKey(debugLabel: 'super_grid_item_${_itemKeys.length}'),
      );
    }
    if (_itemKeys.length > length) {
      _itemKeys.removeRange(length, _itemKeys.length);
    }
  }

  void _resetDragState() {
    _transformController.value = 0;
    _sizes = List.generate(length, (index) => Size.zero);
    _offsets = [];
    _transformAnimationMap.clear();
    _containerSize = Size.zero;
    _dragNotifier.value = _idleDrag;
    _targetOffset = Offset.zero;
    _parentOffset = Offset.zero;
    _dragRect = Rect.zero;
    _targetIndex = -1;
  }

  /// Snapshots where every item currently sits, or returns false when the tree
  /// is not laid out yet.
  bool _captureLayout() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }
    if (_itemKeys.length != length) {
      return false;
    }
    final parentOffset = renderObject.localToGlobal(Offset.zero);
    final sizes = <Size>[];
    final offsets = <Offset>[];
    for (final key in _itemKeys) {
      final itemRenderObject = key.currentContext?.findRenderObject();
      if (itemRenderObject is! RenderBox || !itemRenderObject.hasSize) {
        return false;
      }
      sizes.add(itemRenderObject.size);
      offsets.add(itemRenderObject.localToGlobal(Offset.zero) - parentOffset);
    }
    _sizes = sizes;
    _offsets = offsets;
    _parentOffset = parentOffset;
    _containerSize = renderObject.size;
    return true;
  }

  /// Animates every item to the slot it would occupy if [_tempIndexList] were
  /// committed.
  Future<bool> _transform() async {
    if (_sizes.length != length ||
        _offsets.length != length ||
        _containerSize.isEmpty) {
      return false;
    }
    final items = _childrenNotifier.value;
    final geometry = packGridSlots(
      crossAxisCellCounts: [
        for (final index in _tempIndexList) items[index].crossAxisCellCount,
      ],
      mainAxisExtents: [
        for (final index in _tempIndexList) _sizes[index].height,
      ],
      crossAxisCount: crossCount,
      crossAxisExtent: _containerSize.width,
      crossAxisSpacing: widget.crossAxisSpacing,
      mainAxisSpacing: widget.mainAxisSpacing,
    );

    final transformCurve = CurvedAnimation(
      parent: _transformController,
      curve: _reorderCurve,
    );
    final transformAnimationMap = <int, Animation<Offset>>{};
    for (var slotIndex = 0; slotIndex < _tempIndexList.length; slotIndex++) {
      final index = _tempIndexList[slotIndex];
      final slot = geometry.slots[slotIndex];
      final nextOffset = Offset(
        slot.crossAxisIndex * geometry.stride,
        slot.mainAxisOffset,
      );
      if (slotIndex == _targetIndex) {
        _targetOffset = nextOffset;
      }
      transformAnimationMap[index] = Tween<Offset>(
        // Continue from where the item is, so an interrupted reorder does not
        // jump back to its resting place.
        begin: _transformAnimationMap[index]?.value ?? Offset.zero,
        end: nextOffset - _offsets[index],
      ).animate(transformCurve);
    }
    _transformAnimationMap = transformAnimationMap;

    try {
      await _transformController.forward(from: 0).orCancel;
      return true;
    } on TickerCanceled {
      return false;
    }
  }

  void _handleDragStarted(int index) {
    _resetDragState();
    if (!_captureLayout()) {
      return;
    }
    _isDragging = true;
    _targetIndex = index;
    _targetOffset = _offsets[index];
    _dragNotifier.value = (index: index, size: _sizes[index], landing: false);
    _dragRect = Rect.fromLTWH(
      _targetOffset.dx + _parentOffset.dx,
      _targetOffset.dy + _parentOffset.dy,
      _sizes[index].width,
      _sizes[index].height,
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) {
      return;
    }
    _dragRect = _dragRect.shift(details.delta);
    _edgeDraggingAutoScroller?.startAutoScrollIfNecessary(_dragRect);
  }

  Future<void> _handleDragEnd(DraggableDetails details) async {
    _isDragging = false;
    _stopAutoScroll();
    _hoverTimer?.cancel();
    final dragIndex = _dragNotifier.value.index;
    if (_targetIndex < 0 ||
        _targetIndex >= length ||
        dragIndex < 0 ||
        dragIndex >= length) {
      _resetDragState();
      return;
    }

    final nextChildren = List<GridItem>.of(_childrenNotifier.value);
    nextChildren.insert(_targetIndex, nextChildren.removeAt(dragIndex));
    children = nextChildren;

    const tolerance = Tolerance(distance: 0.001, velocity: 0.01);
    const spring = SpringDescription(mass: 1, stiffness: 180, damping: 18);
    final simulation = SpringSimulation(spring, 0, 1, 0, tolerance: tolerance);
    _landingAnimation = Tween<Offset>(
      begin: details.offset - _parentOffset,
      end: _targetOffset,
    ).animate(_landingController);
    _dragNotifier.value = (
      index: dragIndex,
      size: _dragNotifier.value.size,
      landing: true,
    );

    final completer = Completer<bool>();
    _transformCompleter = completer;
    try {
      await _landingController.animateWith(simulation).orCancel;
      if (!mounted) {
        return;
      }
      _landingAnimation = null;
      _transformAnimationMap.clear();
      _childrenNotifier.value = nextChildren;
      _resetDragState();
      completer.complete(true);
    } on TickerCanceled {
      if (mounted) {
        _landingAnimation = null;
        _resetDragState();
      }
    } finally {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      if (identical(_transformCompleter, completer)) {
        _transformCompleter = null;
      }
    }
  }

  void _scheduleHover(int index) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(_hoverDelay, () => _handleHover(index));
  }

  /// Makes room for the dragged item at the slot currently held by [index].
  Future<void> _handleHover(int index) async {
    if (!mounted || !_isDragging) {
      return;
    }
    final dragIndex = _dragNotifier.value.index;
    if (dragIndex < 0 || dragIndex >= _offsets.length) {
      return;
    }
    final targetIndex = _tempIndexList.indexOf(index);
    if (targetIndex < 0 || _targetIndex == targetIndex) {
      return;
    }
    _tempIndexList = List.generate(length, (i) {
      if (i == targetIndex) return dragIndex;
      if (_targetIndex > targetIndex && i > targetIndex && i <= _targetIndex) {
        return _tempIndexList[i - 1];
      }
      if (_targetIndex < targetIndex && i >= _targetIndex && i < targetIndex) {
        return _tempIndexList[i + 1];
      }
      return _tempIndexList[i];
    });

    _targetIndex = targetIndex;

    await _transform();
  }

  Future<void> _handleDelete(int index) async {
    // One removal at a time: a second one would overwrite _pendingChildren and
    // cancel the first transform, silently dropping a deletion.
    if (_pendingChildren != null || _isDragging) {
      return;
    }
    if (!_captureLayout()) {
      return;
    }
    final slotIndex = _tempIndexList.indexOf(index);
    if (slotIndex < 0) {
      return;
    }
    _tempIndexList = List<int>.of(_tempIndexList)..removeAt(slotIndex);
    final nextChildren = List<GridItem>.of(_childrenNotifier.value)
      ..removeAt(index);
    _pendingChildren = nextChildren;
    final completed = await _transform();
    if (!completed || !mounted) {
      _pendingChildren = null;
      return;
    }
    _childrenNotifier.value = nextChildren;
    _pendingChildren = null;
    _resetDragState();
  }

  /// Paints the lift: a shadow tracing the card's shape plus a small scale.
  /// [t] is 1 while the item is held and eases to 0 as it settles, so the drag
  /// feedback and the landing widget are one surface at two depths.
  Widget _buildLiftedSurface(Widget child, double t) {
    return Transform.scale(
      scale: 1 + 0.03 * t,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: _cardShape,
          shadows: BoxShadow.lerpList(
            const <BoxShadow>[],
            kElevationToShadow[8]!,
            t.clamp(0.0, 1.0),
          )!,
        ),
        child: child,
      ),
    );
  }

  Widget _buildDragSizeBox(Widget child) {
    return ValueListenableBuilder(
      valueListenable: _dragNotifier,
      builder: (_, drag, child) {
        return SizedBox.fromSize(size: drag.size, child: child!);
      },
      child: child,
    );
  }

  Widget _buildTransform(Widget rawChild, int index) {
    return ValueListenableBuilder(
      valueListenable: _dragNotifier,
      builder: (_, drag, child) {
        // The landing widget paints it on the way home; hold its space open.
        if (drag.landing && drag.index == index) {
          return _buildDragSizeBox(const SizedBox.shrink());
        }
        return child!;
      },
      child: AnimatedBuilder(
        animation: _transformController.view,
        builder: (_, child) {
          return Transform.translate(
            offset: _transformAnimationMap[index]?.value ?? Offset.zero,
            child: child,
          );
        },
        child: rawChild,
      ),
    );
  }

  Widget _buildShake(Widget child, int index) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (_, child) {
        // An irregular phase step keeps neighbours from shaking in unison.
        final phase = index * 1.7;
        final angle = sin(_shakeController.value * 2 * pi + phase) * 0.01;
        return Transform.rotate(angle: angle, child: child!);
      },
      child: child,
    );
  }

  Widget _buildDraggable({
    required Widget childWhenDragging,
    required Widget feedback,
    required Widget item,
    required int index,
  }) {
    // onDragEnd resolves the drop from _targetIndex, so this target never
    // accepts; it only reports which item the pointer is over.
    final target = DragTarget<int>(
      builder: (_, _, _) {
        return AbsorbPointer(child: item);
      },
      onWillAcceptWithDetails: (_) {
        _scheduleHover(index);
        return false;
      },
    );

    final decoratedTarget = ValueListenableBuilder(
      valueListenable: _dragNotifier,
      builder: (_, drag, child) {
        if (drag.landing || drag.index == index) {
          return child!;
        }
        return _buildShake(
          _DeletableContainer(
            onDelete: () {
              _handleDelete(index);
            },
            child: child!,
          ),
          index,
        );
      },
      child: target,
    );

    void onDragStarted() => _handleDragStarted(index);
    void onDragUpdate(DragUpdateDetails details) => _handleDragUpdate(details);
    void onDragEnd(DraggableDetails details) => _handleDragEnd(details);

    return system.isDesktop
        ? Draggable(
            childWhenDragging: childWhenDragging,
            data: index,
            feedback: feedback,
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            child: decoratedTarget,
          )
        : LongPressDraggable(
            childWhenDragging: childWhenDragging,
            data: index,
            feedback: feedback,
            onDragStarted: onDragStarted,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            child: decoratedTarget,
          );
  }

  Widget _builderItem(int index) {
    final gridItem = _childrenNotifier.value[index];
    final child = gridItem.child;
    // The children already render their own CommonCard; do not add a second.
    final childWhenDragging = ActivateBox(
      child: Opacity(opacity: 0.4, child: _buildDragSizeBox(child)),
    );
    final feedback = ActivateBox(
      child: _buildDragSizeBox(_buildLiftedSurface(child, 1)),
    );
    return GridItem(
      mainAxisCellCount: gridItem.mainAxisCellCount,
      crossAxisCellCount: gridItem.crossAxisCellCount,
      child: KeyedSubtree(
        key: _itemKeys[index],
        child: _buildTransform(
          // The shake never stops while edit mode is open, and without a
          // boundary here its markNeedsPaint reaches the scroll viewport, so
          // every frame repaints the whole grid instead of one item.
          RepaintBoundary(
            child: _buildDraggable(
              childWhenDragging: childWhenDragging,
              feedback: feedback,
              item: child,
              index: index,
            ),
          ),
          index,
        ),
      ),
    );
  }

  /// The dragged item springing back into the grid, drawn above it so it can
  /// overlap its neighbours on the way in.
  Widget _buildLandingWidget() {
    return ValueListenableBuilder(
      valueListenable: _dragNotifier,
      builder: (_, drag, _) {
        final animation = _landingAnimation;
        if (!drag.landing || animation == null || drag.index == -1) {
          return const SizedBox.shrink();
        }
        return SizedBox.fromSize(
          size: drag.size,
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) {
              // Fade the lift out on the spring's own curve, so the item
              // settles instead of popping.
              final lift = (1 - _landingController.value).clamp(0.0, 1.0);
              return Transform.translate(
                offset: animation.value,
                child: _buildLiftedSurface(child!, lift),
              );
            },
            child: ActivateBox(
              child: _childrenNotifier.value[drag.index].child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      // Delete buttons sit outside their item's bounds and the landing widget
      // casts a shadow past the grid, so nothing here may be clipped.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ValueListenableBuilder(
            valueListenable: _dragNotifier,
            builder: (_, drag, child) {
              // Freeze interaction with the grid while an item is landing.
              return drag.landing ? ActivateBox(child: child!) : child!;
            },
            child: ValueListenableBuilder(
              valueListenable: _childrenNotifier,
              builder: (_, children, _) {
                return Grid(
                  axisDirection: AxisDirection.down,
                  crossAxisCount: crossCount,
                  crossAxisSpacing: widget.crossAxisSpacing,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  children: [
                    for (int i = 0; i < children.length; i++) _builderItem(i),
                  ],
                );
              },
            ),
          ),
          _buildLandingWidget(),
        ],
      ),
    );
  }
}

class _DeletableContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const _DeletableContainer({required this.child, required this.onDelete});

  @override
  State<_DeletableContainer> createState() => _DeletableContainerState();
}

class _DeletableContainerState extends State<_DeletableContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _deleteButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: commonDuration);
    _scaleAnimation = Tween(
      begin: 1.0,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _fadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(_DeletableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      setState(() {
        _controller.value = 0;
        _deleteButtonVisible = true;
      });
    }
  }

  Future<void> _handleDel() async {
    setState(() {
      _deleteButtonVisible = false;
    });
    await _controller.forward(from: 0);
    widget.onDelete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _controller.view,
          builder: (_, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(opacity: _fadeAnimation.value, child: child!),
            );
          },
          child: widget.child,
        ),
        if (_deleteButtonVisible)
          Positioned(
            top: -8,
            right: -8,
            child: DeferPointer(
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton.filled(
                  tooltip: context.appLocalizations.remove,
                  iconSize: 20,
                  padding: const EdgeInsets.all(2),
                  onPressed: _handleDel,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
