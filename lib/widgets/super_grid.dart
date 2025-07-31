import 'dart:async';
import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/activate_box.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:fl_clash/widgets/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

typedef VoidCallback = void Function();

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
  final ValueNotifier<List<GridItem>> _childrenNotifier = ValueNotifier([]);
  List<GridItem> children = [];

  int get length => _childrenNotifier.value.length;
  List<int> _tempIndexList = [];
  List<BuildContext?> _itemContexts = [];
  Size _containerSize = Size.zero;
  int _targetIndex = -1;
  Offset _targetOffset = Offset.zero;
  List<Size> _sizes = [];
  List<Offset> _offsets = [];
  Offset _parentOffset = Offset.zero;
  EdgeDraggingAutoScroller? _edgeDraggingAutoScroller;
  Map<int, Tween<Offset>> _transformTweenMap = {};

  final ValueNotifier<bool> _animating = ValueNotifier(false);

  final _dragWidgetSizeNotifier = ValueNotifier(Size.zero);

  final _dragIndexNotifier = ValueNotifier(-1);

  late AnimationController _transformController;

  Future<bool> get isTransformCompleter =>
      _transformCompleter?.future ?? Future(() => true);

  Completer<bool>? _transformCompleter;

  Map<int, Animation<Offset>> _transformAnimationMap = {};

  late AnimationController _fakeDragWidgetController;
  Animation<Offset>? _fakeDragWidgetAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Rect _dragRect = Rect.zero;
  Scrollable? _scrollable;

  int get crossCount => widget.crossAxisCount;

  void _onChildrenChange() {
    _tempIndexList = List.generate(length, (index) => index);
    _itemContexts = List.filled(length, null);
  }

  void _preTransformState() {
    _sizes = _itemContexts.map((item) => item!.size!).toList();
    _parentOffset = (context.findRenderObject() as RenderBox).localToGlobal(
      Offset.zero,
    );
    _offsets = _itemContexts
        .map(
          (item) =>
              (item!.findRenderObject() as RenderBox).localToGlobal(
                Offset.zero,
              ) -
              _parentOffset,
        )
        .toList();
    _containerSize = context.size!;
  }

  void _initState() {
    _transformController.value = 0;
    _sizes = List.generate(length, (index) => Size.zero);
    _offsets = [];
    _transformTweenMap.clear();
    _transformAnimationMap.clear();
    _containerSize = Size.zero;
    _dragIndexNotifier.value = -1;
    _dragWidgetSizeNotifier.value = Size.zero;
    _targetOffset = Offset.zero;
    _parentOffset = Offset.zero;
    _dragRect = Rect.zero;
    _targetIndex = -1;
  }

  @override
  void initState() {
    super.initState();
    _childrenNotifier.addListener(() {
      children = _childrenNotifier.value;
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }
    });

    _childrenNotifier.value = widget.children;

    _fakeDragWidgetController = AnimationController.unbounded(
      vsync: this,
      duration: commonDuration,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 120),
    );

    _shakeAnimation = Tween<double>(begin: -0.012, end: 0.012).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    _transformController = AnimationController(
      vsync: this,
      duration: commonDuration,
    );

    _initState();
  }

  void handleAdd(GridItem gridItem) {
    _childrenNotifier.value = List.from(_childrenNotifier.value)..add(gridItem);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final scrollable = context.findAncestorWidgetOfExactType<Scrollable>();
    if (scrollable == null) {
      return;
    }
    if (_scrollable != scrollable) {
      _edgeDraggingAutoScroller = EdgeDraggingAutoScroller(
        Scrollable.of(context),
        onScrollViewScrolled: () {
          _edgeDraggingAutoScroller?.startAutoScrollIfNecessary(_dragRect);
        },
        velocityScalar: 40,
      );
    }
  }

  Future _transform() async {
    List<Offset> layoutOffsets = [Offset(_containerSize.width, 0)];
    final List<Offset> nextOffsets = [];

    for (final index in _tempIndexList) {
      final size = _sizes[index];
      final offset = _getNextOffset(layoutOffsets, size);
      final layoutOffset = Offset(
        min(
          offset.dx + size.width + widget.crossAxisSpacing,
          _containerSize.width,
        ),
        min(
          offset.dy + size.height + widget.mainAxisSpacing,
          _containerSize.height,
        ),
      );
      final startLayoutOffsetX = offset.dx;
      final endLayoutOffsetX = layoutOffset.dx;
      nextOffsets.add(offset);

      final startIndex = layoutOffsets.indexWhere(
        (i) => i.dx >= startLayoutOffsetX,
      );
      final endIndex = layoutOffsets.indexWhere(
        (i) => i.dx >= endLayoutOffsetX,
      );
      final endOffset = layoutOffsets[endIndex];

      if (startIndex != endIndex) {
        final startOffset = layoutOffsets[startIndex];
        if (startOffset.dx != startLayoutOffsetX) {
          layoutOffsets[startIndex] = Offset(
            startLayoutOffsetX,
            startOffset.dy,
          );
        }
      }
      if (endOffset.dx == endLayoutOffsetX) {
        layoutOffsets[endIndex] = layoutOffset;
      } else {
        layoutOffsets.insert(endIndex, layoutOffset);
      }
      layoutOffsets.removeRange(min(startIndex + 1, endIndex), endIndex);
    }

    final Map<int, Tween<Offset>> transformTweenMap = {};

    for (final index in _tempIndexList) {
      final nextIndex = _tempIndexList.indexWhere((i) => i == index);
      transformTweenMap[index] = Tween(
        begin: _transformTweenMap[index]?.begin ?? Offset.zero,
        end: nextOffsets[nextIndex] - _offsets[index],
      );
    }

    _transformTweenMap = transformTweenMap;

    _transformAnimationMap = transformTweenMap.map((key, value) {
      final preAnimationValue = _transformAnimationMap[key]?.value;
      return MapEntry(
        key,
        Tween(
          begin: preAnimationValue ?? Offset.zero,
          end: value.end,
        ).animate(_transformController),
      );
    });

    if (_targetIndex != -1) {
      _targetOffset = nextOffsets[_targetIndex];
    }
    return _transformController.forward(from: 0);
  }

  void _handleDragStarted(int index) {
    _initState();
    _preTransformState();
    _dragIndexNotifier.value = index;
    _dragWidgetSizeNotifier.value = _sizes[index];
    _targetIndex = index;
    _targetOffset = _offsets[index];
    _dragRect = Rect.fromLTWH(
      _targetOffset.dx + _parentOffset.dx,
      _targetOffset.dy + _parentOffset.dy,
      _sizes[index].width,
      _sizes[index].height,
    );
  }

  Future<void> _handleDragEnd(DraggableDetails details) async {
    final children = List<GridItem>.from(_childrenNotifier.value);
    children.insert(_targetIndex, children.removeAt(_dragIndexNotifier.value));
    this.children = children;
    debouncer.cancel(FunctionTag.handleWill);
    if (_targetIndex == -1) {
      return;
    }
    const spring = SpringDescription(mass: 1, stiffness: 100, damping: 10);
    final simulation = SpringSimulation(spring, 0, 1, 0);
    _fakeDragWidgetAnimation = Tween(
      begin: details.offset - _parentOffset,
      end: _targetOffset,
    ).animate(_fakeDragWidgetController);
    _animating.value = true;

    _transformCompleter = Completer<bool>();
    await _fakeDragWidgetController.animateWith(simulation);
    _transformCompleter?.complete(true);
    _animating.value = false;
    _fakeDragWidgetAnimation = null;
    _transformTweenMap.clear();
    _transformAnimationMap.clear();
    _childrenNotifier.value = children;
    _initState();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragRect = _dragRect.translate(0, details.delta.dy);
    _edgeDraggingAutoScroller?.startAutoScrollIfNecessary(_dragRect);
  }

  Future<void> _handleWill(int index) async {
    final dragIndex = _dragIndexNotifier.value;
    if (dragIndex < 0 || dragIndex > _offsets.length - 1) {
      return;
    }
    final targetIndex = _tempIndexList.indexWhere((i) => i == index);
    if (_targetIndex == targetIndex) {
      return;
    }
    _tempIndexList = List.generate(length, (i) {
      if (i == targetIndex) return _dragIndexNotifier.value;
      if (_targetIndex > targetIndex && i > targetIndex && i <= _targetIndex) {
        return _tempIndexList[i - 1];
      } else if (_targetIndex < targetIndex &&
          i >= _targetIndex &&
          i < targetIndex) {
        return _tempIndexList[i + 1];
      }
      return _tempIndexList[i];
    }).toList();

    _targetIndex = targetIndex;

    await _transform();
  }

  Future<void> _handleDelete(int index) async {
    _preTransformState();
    final indexWhere = _tempIndexList.indexWhere((i) => i == index);
    _tempIndexList.removeAt(indexWhere);
    await _transform();
    final children = List<GridItem>.from(_childrenNotifier.value);
    children.removeAt(index);
    _childrenNotifier.value = children;
    _initState();
  }

  Widget _buildTransform(Widget rawChild, int index) {
    return ValueListenableBuilder(
      valueListenable: _animating,
      builder: (_, animating, child) {
        if (animating && _dragIndexNotifier.value == index) {
          return _buildSizeBox(Container(), index);
        }
        return child!;
      },
      child: AnimatedBuilder(
        builder: (_, child) {
          return Transform.translate(
            offset: _transformAnimationMap[index]?.value ?? Offset.zero,
            child: child,
          );
        },
        animation: _transformController.view,
        child: rawChild,
      ),
    );
  }

  Offset _getNextOffset(List<Offset> offsets, Size size) {
    final length = offsets.length;
    Offset nextOffset = Offset(0, double.infinity);
    for (int i = 0; i < length; i++) {
      final offset = offsets[i];
      if (offset.dy.moreOrEqual(nextOffset.dy)) {
        continue;
      }
      double offsetX = 0;
      double span = 0;
      for (
        int j = 0;
        span < size.width &&
            j < length &&
            _containerSize.width.moreOrEqual(offsetX + size.width);
        j++
      ) {
        final tempOffset = offsets[j];
        if (offset.dy.moreOrEqual(tempOffset.dy)) {
          span = tempOffset.dx - offsetX;
          if (span.moreOrEqual(size.width)) {
            nextOffset = Offset(offsetX, offset.dy);
          }
        } else {
          offsetX = tempOffset.dx;
          span = 0;
        }
      }
    }
    return nextOffset;
  }

  Widget _buildSizeBox(Widget child, int index) {
    return ValueListenableBuilder(
      valueListenable: _dragWidgetSizeNotifier,
      builder: (_, size, child) {
        return SizedBox.fromSize(size: size, child: child!);
      },
      child: child,
    );
  }

  Widget _buildInactivate(Widget child) {
    return ValueListenableBuilder(
      valueListenable: _animating,
      builder: (_, animating, child) {
        if (animating) {
          return ActivateBox(child: child!);
        } else {
          return child!;
        }
      },
      child: child,
    );
  }

  Widget _buildShake(Widget child) {
    final random = 0.7 + Random().nextDouble() * 0.3;
    _shakeController.stop();
    _shakeController.repeat(reverse: true);
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (_, child) {
        return Transform.rotate(
          angle: _shakeAnimation.value * random,
          child: child!,
        );
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
    final target = DragTarget<int>(
      builder: (_, _, _) {
        return AbsorbPointer(child: item);
      },
      onWillAcceptWithDetails: (_) {
        debouncer.call(FunctionTag.handleWill, _handleWill, args: [index]);
        return false;
      },
    );
    final shakeTarget = ValueListenableBuilder(
      valueListenable: _animating,
      builder: (_, animating, child) {
        if (animating) {
          return target;
        } else {
          return child!;
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _dragIndexNotifier,
        builder: (_, dragIndex, child) {
          if (dragIndex == index) {
            return child!;
          }
          return _buildShake(
            _DeletableContainer(
              onDelete: () {
                _handleDelete(index);
              },
              child: child!,
            ),
          );
        },
        child: target,
      ),
    );
    final draggableChild = system.isDesktop
        ? Draggable(
            childWhenDragging: childWhenDragging,
            data: index,
            feedback: feedback,
            onDragStarted: () {
              _handleDragStarted(index);
            },
            onDragUpdate: (details) {
              _handleDragUpdate(details);
            },
            onDragEnd: (details) {
              _handleDragEnd(details);
            },
            child: shakeTarget,
          )
        : LongPressDraggable(
            childWhenDragging: childWhenDragging,
            data: index,
            feedback: feedback,
            onDragStarted: () {
              _handleDragStarted(index);
            },
            onDragUpdate: (details) {
              _handleDragUpdate(details);
            },
            onDragEnd: (details) {
              _handleDragEnd(details);
            },
            child: shakeTarget,
          );
    return draggableChild;
  }

  Widget _builderItem(int index) {
    final girdItem = _childrenNotifier.value[index];
    final child = girdItem.child;
    return GridItem(
      mainAxisCellCount: girdItem.mainAxisCellCount,
      crossAxisCellCount: girdItem.crossAxisCellCount,
      child: Builder(
        builder: (context) {
          _itemContexts[index] = context;
          final childWhenDragging = ActivateBox(
            child: Opacity(
              opacity: 0.6,
              child: _buildSizeBox(CommonCard(child: child), index),
            ),
          );
          final feedback = ActivateBox(
            child: _buildSizeBox(
              CommonCard(child: Material(elevation: 6, child: child)),
              index,
            ),
          );
          return _buildTransform(
            _buildDraggable(
              childWhenDragging: childWhenDragging,
              feedback: feedback,
              item: child,
              index: index,
            ),
            index,
          );
        },
      ),
    );
  }

  Widget _buildFakeTransformWidget() {
    return ValueListenableBuilder<bool>(
      valueListenable: _animating,
      builder: (_, animating, _) {
        final index = _dragIndexNotifier.value;
        if (!animating || _fakeDragWidgetAnimation == null || index == -1) {
          return Container();
        }
        return _buildSizeBox(
          AnimatedBuilder(
            animation: _fakeDragWidgetAnimation!,
            builder: (_, child) {
              return Transform.translate(
                offset: _fakeDragWidgetAnimation!.value,
                child: child!,
              );
            },
            child: ActivateBox(child: _childrenNotifier.value[index].child),
          ),
          index,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollable = null;
    _fakeDragWidgetController.dispose();
    _shakeController.dispose();
    _transformController.dispose();
    _dragIndexNotifier.dispose();
    _animating.dispose();
    _childrenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: Stack(
        children: [
          _buildInactivate(
            ValueListenableBuilder(
              valueListenable: _childrenNotifier,
              builder: (_, children, _) {
                _onChildrenChange();
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
          _buildFakeTransformWidget(),
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
                  iconSize: 20,
                  padding: EdgeInsets.all(2),
                  onPressed: _handleDel,
                  icon: Icon(Icons.close),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
