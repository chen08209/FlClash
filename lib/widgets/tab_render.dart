part of 'tab.dart';

class _CommonTabBarRenderWidget<T extends Object>
    extends MultiChildRenderObjectWidget {
  const _CommonTabBarRenderWidget({
    super.key,
    super.children,
    required this.highlightedIndex,
    required this.thumbColor,
    required this.thumbScale,
    required this.state,
    required this.proportionalWidth,
  });

  final int? highlightedIndex;
  final Color thumbColor;
  final double thumbScale;
  final bool proportionalWidth;
  final _CommonTabBarState<T> state;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSegmentedControl<T>(
      highlightedIndex: highlightedIndex,
      thumbColor: thumbColor,
      thumbScale: thumbScale,
      proportionalWidth: proportionalWidth,
      state: state,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSegmentedControl<T> renderObject,
  ) {
    assert(renderObject.state == state);
    renderObject
      ..thumbColor = thumbColor
      ..thumbScale = thumbScale
      ..highlightedIndex = highlightedIndex
      ..proportionalWidth = proportionalWidth;
  }
}

class _SegmentedControlContainerBoxParentData
    extends ContainerBoxParentData<RenderBox> {}

enum _SegmentLocation { leftmost, rightmost, inbetween }

class _RenderSegmentedControl<T extends Object> extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _RenderSegmentedControl({
    required int? highlightedIndex,
    required Color thumbColor,
    required double thumbScale,
    required bool proportionalWidth,
    required this.state,
  }) : _highlightedIndex = highlightedIndex,
       _thumbColor = thumbColor,
       _thumbScale = thumbScale,
       _proportionalWidth = proportionalWidth;

  final _CommonTabBarState<T> state;

  Rect? currentThumbRect;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    state.thumbController.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    state.thumbController.removeListener(markNeedsPaint);
    super.detach();
  }

  double get thumbScale => _thumbScale;
  double _thumbScale;

  set thumbScale(double value) {
    if (_thumbScale == value) {
      return;
    }

    _thumbScale = value;
    if (state.highlighted != null) {
      markNeedsPaint();
    }
  }

  int? get highlightedIndex => _highlightedIndex;
  int? _highlightedIndex;

  set highlightedIndex(int? value) {
    if (_highlightedIndex == value) {
      return;
    }

    _highlightedIndex = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbColor;
  Color _thumbColor;

  set thumbColor(Color value) {
    if (_thumbColor == value) {
      return;
    }
    _thumbColor = value;
    markNeedsPaint();
  }

  bool get proportionalWidth => _proportionalWidth;
  bool _proportionalWidth;

  set proportionalWidth(bool value) {
    if (_proportionalWidth == value) {
      return;
    }
    _proportionalWidth = value;
    markNeedsLayout();
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && !state.isThumbDragging) {
      state.tap.addPointer(event);
      state.longPress.addPointer(event);
      state.drag.addPointer(event);
    }
  }

  double get separatorWidth => _kSeparatorInset.horizontal + _kSeparatorWidth;

  double get totalSeparatorWidth => separatorWidth * (childCount ~/ 2);

  int getClosestSegmentIndex(double dx) {
    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final _SegmentedControlContainerBoxParentData childParentData =
          child.parentData! as _SegmentedControlContainerBoxParentData;
      final double clampX = clampDouble(
        dx,
        childParentData.offset.dx,
        child.size.width + childParentData.offset.dx,
      );

      if (dx <= clampX) {
        break;
      }

      index++;
      child = nonSeparatorChildAfter(child);
    }

    final int segmentCount = childCount ~/ 2 + 1;
    return min(index, segmentCount - 1);
  }

  RenderBox? nonSeparatorChildAfter(RenderBox child) {
    final RenderBox? nextChild = childAfter(child);
    return nextChild == null ? null : childAfter(nextChild);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final int childCount = this.childCount ~/ 2 + 1;
    RenderBox? child = firstChild;
    double maxMinChildWidth = 0;
    while (child != null) {
      final double childWidth = child.getMinIntrinsicWidth(height);
      maxMinChildWidth = math.max(maxMinChildWidth, childWidth);
      child = nonSeparatorChildAfter(child);
    }
    return (maxMinChildWidth + 2 * _kSegmentMinPadding) * childCount +
        totalSeparatorWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final int childCount = this.childCount ~/ 2 + 1;
    RenderBox? child = firstChild;
    double maxMaxChildWidth = 0;
    while (child != null) {
      final double childWidth = child.getMaxIntrinsicWidth(height);
      maxMaxChildWidth = math.max(maxMaxChildWidth, childWidth);
      child = nonSeparatorChildAfter(child);
    }
    return (maxMaxChildWidth + 2 * _kSegmentMinPadding) * childCount +
        totalSeparatorWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    RenderBox? child = firstChild;
    double maxMinChildHeight = _kMinSegmentedControlHeight;
    while (child != null) {
      final double childHeight = child.getMinIntrinsicHeight(width);
      maxMinChildHeight = math.max(maxMinChildHeight, childHeight);
      child = nonSeparatorChildAfter(child);
    }
    return maxMinChildHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    RenderBox? child = firstChild;
    double maxMaxChildHeight = _kMinSegmentedControlHeight;
    while (child != null) {
      final double childHeight = child.getMaxIntrinsicHeight(width);
      maxMaxChildHeight = math.max(maxMaxChildHeight, childHeight);
      child = nonSeparatorChildAfter(child);
    }
    return maxMaxChildHeight;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SegmentedControlContainerBoxParentData) {
      child.parentData = _SegmentedControlContainerBoxParentData();
    }
  }

  double _getMaxChildHeight(BoxConstraints constraints, double childWidth) {
    double maxHeight = _kMinSegmentedControlHeight;
    RenderBox? child = firstChild;
    while (child != null) {
      final double boxHeight = child.getMaxIntrinsicHeight(childWidth);
      maxHeight = math.max(maxHeight, boxHeight);
      child = nonSeparatorChildAfter(child);
    }
    return maxHeight;
  }

  double _getMaxChildWidth(BoxConstraints constraints) {
    final int childCount = this.childCount ~/ 2 + 1;
    double childWidth =
        (constraints.minWidth - totalSeparatorWidth) / childCount;
    RenderBox? child = firstChild;
    while (child != null) {
      childWidth = math.max(
        childWidth,
        child.getMaxIntrinsicWidth(double.infinity) + 2 * _kSegmentMinPadding,
      );
      child = nonSeparatorChildAfter(child);
    }
    return math.min(
      childWidth,
      (constraints.maxWidth - totalSeparatorWidth) / childCount,
    );
  }

  List<double> _getChildWidths(BoxConstraints constraints) {
    if (!proportionalWidth) {
      final double maxChildWidth = _getMaxChildWidth(constraints);
      final int segmentCount = childCount ~/ 2 + 1;
      return List<double>.filled(segmentCount, maxChildWidth);
    }

    final List<double> segmentWidths = <double>[];
    RenderBox? child = firstChild;
    while (child != null) {
      final double childWidth =
          child.getMaxIntrinsicWidth(double.infinity) + 2 * _kSegmentMinPadding;
      child = nonSeparatorChildAfter(child);
      segmentWidths.add(childWidth);
    }

    final double totalWidth = segmentWidths.sum;
    final double allowedMaxWidth = constraints.maxWidth - totalSeparatorWidth;
    final double allowedMinWidth = constraints.minWidth - totalSeparatorWidth;

    final double scale =
        clampDouble(totalWidth, allowedMinWidth, allowedMaxWidth) / totalWidth;
    if (scale != 1) {
      for (int i = 0; i < segmentWidths.length; i++) {
        segmentWidths[i] = segmentWidths[i] * scale;
      }
    }
    return segmentWidths;
  }

  Size _computeOverallSize(BoxConstraints constraints) {
    final double maxChildHeight = _getMaxChildHeight(
      constraints,
      constraints.maxWidth,
    );
    return constraints.constrain(
      Size(
        _getChildWidths(constraints).sum + totalSeparatorWidth,
        maxChildHeight,
      ),
    );
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final List<double> segmentWidths = _getChildWidths(constraints);
    final double childHeight = _getMaxChildHeight(
      constraints,
      constraints.maxWidth,
    );

    int index = 0;
    BaselineOffset baselineOffset = BaselineOffset.noBaseline;
    RenderBox? child = firstChild;
    while (child != null) {
      final BoxConstraints childConstraints = BoxConstraints.tight(
        Size(segmentWidths[index], childHeight),
      );
      baselineOffset = baselineOffset.minOf(
        BaselineOffset(child.getDryBaseline(childConstraints, baseline)),
      );

      child = nonSeparatorChildAfter(child);
      index++;
    }

    return baselineOffset.offset;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeOverallSize(constraints);
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final List<double> segmentWidths = _getChildWidths(constraints);

    final double childHeight = _getMaxChildHeight(constraints, double.infinity);
    final BoxConstraints separatorConstraints = BoxConstraints(
      minHeight: childHeight,
      maxHeight: childHeight,
    );
    RenderBox? child = firstChild;
    int index = 0;
    double start = 0;
    while (child != null) {
      final BoxConstraints childConstraints = BoxConstraints.tight(
        Size(segmentWidths[index ~/ 2], childHeight),
      );
      child.layout(
        index.isEven ? childConstraints : separatorConstraints,
        parentUsesSize: true,
      );
      final _SegmentedControlContainerBoxParentData childParentData =
          child.parentData! as _SegmentedControlContainerBoxParentData;
      final Offset childOffset = Offset(start, 0);
      childParentData.offset = childOffset;
      start += child.size.width;
      assert(
        index.isEven ||
            child.size.width == _kSeparatorWidth + _kSeparatorInset.horizontal,
        '${child.size.width} != ${_kSeparatorWidth + _kSeparatorInset.horizontal}',
      );
      child = childAfter(child);
      index += 1;
    }
    size = _computeOverallSize(constraints);
  }

  Rect? moveThumbRectInBound(Rect? thumbRect, List<RenderBox> children) {
    assert(hasSize);
    assert(children.length >= 2);
    if (thumbRect == null) {
      return null;
    }

    final Offset firstChildOffset =
        (children.first.parentData! as _SegmentedControlContainerBoxParentData)
            .offset;
    final double leftMost = firstChildOffset.dx;
    final double rightMost =
        (children.last.parentData! as _SegmentedControlContainerBoxParentData)
            .offset
            .dx +
        children.last.size.width;
    assert(rightMost > leftMost);
    return Rect.fromLTRB(
      math.max(thumbRect.left, leftMost - _kThumbInsets.left),
      firstChildOffset.dy - _kThumbInsets.top,
      math.min(thumbRect.right, rightMost + _kThumbInsets.right),
      firstChildOffset.dy + children.first.size.height + _kThumbInsets.bottom,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final List<RenderBox> children = getChildrenAsList();
    for (int index = 1; index < childCount; index += 2) {
      _paintSeparator(context, offset, children[index]);
    }

    final int? highlightedChildIndex = highlightedIndex;
    if (highlightedChildIndex != null) {
      final RenderBox selectedChild = children[highlightedChildIndex * 2];

      final _SegmentedControlContainerBoxParentData childParentData =
          selectedChild.parentData! as _SegmentedControlContainerBoxParentData;
      final Rect newThumbRect = _kThumbInsets.inflateRect(
        childParentData.offset & selectedChild.size,
      );
      if (state.thumbController.isAnimating) {
        final Animatable<Rect?>? thumbTween = state.thumbAnimatable;
        if (thumbTween == null) {
          final Rect startingRect =
              moveThumbRectInBound(currentThumbRect, children) ?? newThumbRect;
          state.thumbAnimatable = RectTween(
            begin: startingRect,
            end: newThumbRect,
          );
        } else if (newThumbRect != thumbTween.transform(1)) {
          final Rect startingRect =
              moveThumbRectInBound(currentThumbRect, children) ?? newThumbRect;
          state.thumbAnimatable = RectTween(
            begin: startingRect,
            end: newThumbRect,
          ).chain(CurveTween(curve: Interval(state.thumbController.value, 1)));
        }
      } else {
        state.thumbAnimatable = null;
      }

      final Rect unscaledThumbRect =
          state.thumbAnimatable?.evaluate(state.thumbController) ??
          newThumbRect;
      currentThumbRect = unscaledThumbRect;

      final _SegmentLocation childLocation;
      if (highlightedChildIndex == 0) {
        childLocation = _SegmentLocation.leftmost;
      } else if (highlightedChildIndex == children.length ~/ 2) {
        childLocation = _SegmentLocation.rightmost;
      } else {
        childLocation = _SegmentLocation.inbetween;
      }
      final double delta = switch (childLocation) {
        _SegmentLocation.leftmost =>
          unscaledThumbRect.width - unscaledThumbRect.width * thumbScale,
        _SegmentLocation.rightmost =>
          unscaledThumbRect.width * thumbScale - unscaledThumbRect.width,
        _SegmentLocation.inbetween => 0,
      };
      final Rect thumbRect = Rect.fromCenter(
        center: unscaledThumbRect.center - Offset(delta / 2, 0),
        width: unscaledThumbRect.width * thumbScale,
        height: unscaledThumbRect.height * thumbScale,
      );

      _paintThumb(context, offset, thumbRect);
    } else {
      currentThumbRect = null;
    }

    for (int index = 0; index < children.length; index += 2) {
      _paintChild(context, offset, children[index]);
    }
  }

  final Paint separatorPaint = Paint();

  void _paintSeparator(
    PaintingContext context,
    Offset offset,
    RenderBox child,
  ) {
    final _SegmentedControlContainerBoxParentData childParentData =
        child.parentData! as _SegmentedControlContainerBoxParentData;
    context.paintChild(child, offset + childParentData.offset);
  }

  void _paintChild(PaintingContext context, Offset offset, RenderBox child) {
    final _SegmentedControlContainerBoxParentData childParentData =
        child.parentData! as _SegmentedControlContainerBoxParentData;
    context.paintChild(child, childParentData.offset + offset);
  }

  void _paintThumb(PaintingContext context, Offset offset, Rect thumbRect) {
    final RSuperellipse thumbRSuperellipse = RSuperellipse.fromRectAndRadius(
      thumbRect.shift(offset),
      _kThumbRadius,
    );

    context.canvas.drawRSuperellipse(
      thumbRSuperellipse.inflate(0.5),
      Paint()..color = const Color(0x0A000000),
    );

    context.canvas.drawRSuperellipse(
      thumbRSuperellipse,
      Paint()..color = thumbColor,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final _SegmentedControlContainerBoxParentData childParentData =
          child.parentData! as _SegmentedControlContainerBoxParentData;
      if ((childParentData.offset & child.size).contains(position)) {
        return result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset localOffset) {
            assert(localOffset == position - childParentData.offset);
            return child!.hitTest(result, position: localOffset);
          },
        );
      }
      child = childParentData.previousSibling;
    }
    return false;
  }
}
