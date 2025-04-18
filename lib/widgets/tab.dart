import 'dart:math' as math;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

const EdgeInsetsGeometry _kHorizontalItemPadding =
    EdgeInsets.symmetric(vertical: 2, horizontal: 3);

const Radius _kCornerRadius = Radius.circular(9);

const Radius _kThumbRadius = Radius.circular(8);

const EdgeInsets _kThumbInsets = EdgeInsets.symmetric(horizontal: 1);

const double _kMinSegmentedControlHeight = 28.0;

const EdgeInsets _kSeparatorInset = EdgeInsets.symmetric(vertical: 5);

const double _kSeparatorWidth = 1;

const double _kMinThumbScale = 0.95;

const double _kSegmentMinPadding = 10;

const double _kTouchYDistanceThreshold = 50.0 * 50.0;

const double _kContentPressedMinOpacity = 0.2;

const double _kFontSize = 13.0;

const FontWeight _kFontWeight = FontWeight.w500;

const FontWeight _kHighlightedFontWeight = FontWeight.w600;

const Color _kDisabledContentColor = Color.fromARGB(115, 122, 122, 122);

final SpringSimulation _kThumbSpringAnimationSimulation = SpringSimulation(
  const SpringDescription(mass: 1, stiffness: 503.551, damping: 44.8799),
  0,
  1,
  0,
);

const Duration _kSpringAnimationDuration = Duration(milliseconds: 412);

const Duration _kOpacityAnimationDuration = Duration(milliseconds: 470);

const Duration _kHighlightAnimationDuration = Duration(milliseconds: 200);

class CommonTabBar<T extends Object> extends StatefulWidget {
  CommonTabBar({
    super.key,
    required this.children,
    required this.onValueChanged,
    this.disabledChildren = const <Never>{},
    this.groupValue,
    required this.thumbColor,
    this.padding = _kHorizontalItemPadding,
    this.backgroundColor,
    this.proportionalWidth = false,
  })  : assert(children.length >= 2),
        assert(
          groupValue == null || children.keys.contains(groupValue),
          'The groupValue must be either null or one of the keys in the children map.',
        );
  final Map<T, Widget> children;
  final Set<T> disabledChildren;
  final T? groupValue;
  final ValueChanged<T?> onValueChanged;
  final Color? backgroundColor;
  final Color thumbColor;
  final bool proportionalWidth;
  final EdgeInsetsGeometry padding;

  @override
  State<CommonTabBar<T>> createState() => _CommonTabBarState<T>();
}

class _CommonTabBarState<T extends Object> extends State<CommonTabBar<T>>
    with TickerProviderStateMixin<CommonTabBar<T>> {
  late final AnimationController thumbController = AnimationController(
    duration: _kSpringAnimationDuration,
    value: 0,
    vsync: this,
  );
  Animatable<Rect?>? thumbAnimatable;

  late final AnimationController thumbScaleController = AnimationController(
    duration: _kSpringAnimationDuration,
    value: 0,
    vsync: this,
  );
  late Animation<double> thumbScaleAnimation = thumbScaleController.drive(
    Tween<double>(begin: 1, end: _kMinThumbScale),
  );

  final TapGestureRecognizer tap = TapGestureRecognizer();
  final HorizontalDragGestureRecognizer drag =
      HorizontalDragGestureRecognizer();
  final LongPressGestureRecognizer longPress = LongPressGestureRecognizer();
  final GlobalKey segmentedControlRenderWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final GestureArenaTeam team = GestureArenaTeam();
    longPress.team = team;
    drag.team = team;
    team.captain = drag;

    drag
      ..onDown = onDown
      ..onUpdate = onUpdate
      ..onEnd = onEnd
      ..onCancel = onCancel;

    tap.onTapUp = onTapUp;
    longPress.onLongPress = () {};

    highlighted = widget.groupValue;
  }

  @override
  void didUpdateWidget(CommonTabBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isThumbDragging && highlighted != widget.groupValue) {
      thumbController.animateWith(_kThumbSpringAnimationSimulation);
      thumbAnimatable = null;
      highlighted = widget.groupValue;
    }
  }

  @override
  void dispose() {
    thumbScaleController.dispose();
    thumbController.dispose();

    drag.dispose();
    tap.dispose();
    longPress.dispose();

    super.dispose();
  }

  bool? _startedOnSelectedSegment;
  bool _startedOnDisabledSegment = false;

  bool get isThumbDragging =>
      (_startedOnSelectedSegment ?? false) && !_startedOnDisabledSegment;

  T segmentForXPosition(double dx) {
    final BuildContext currentContext =
        segmentedControlRenderWidgetKey.currentContext!;
    final _RenderSegmentedControl<T> renderBox =
        currentContext.findRenderObject()! as _RenderSegmentedControl<T>;

    final int numOfChildren = widget.children.length;
    assert(renderBox.hasSize);
    assert(numOfChildren >= 2);

    int segmentIndex = renderBox.getClosestSegmentIndex(dx);

    switch (Directionality.of(context)) {
      case TextDirection.ltr:
        break;
      case TextDirection.rtl:
        segmentIndex = numOfChildren - 1 - segmentIndex;
    }
    return widget.children.keys.elementAt(segmentIndex);
  }

  bool _hasDraggedTooFar(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    assert(renderBox.hasSize);
    final Size size = renderBox.size;
    final Offset offCenter =
        details.localPosition - Offset(size.width / 2, size.height / 2);
    final double l2 =
        math.pow(math.max(0.0, offCenter.dx.abs() - size.width / 2), 2) +
                math.pow(math.max(0.0, offCenter.dy.abs() - size.height / 2), 2)
            as double;
    return l2 > _kTouchYDistanceThreshold;
  }

  void _playThumbScaleAnimation({required bool isExpanding}) {
    thumbScaleAnimation = thumbScaleController.drive(
      Tween<double>(
          begin: thumbScaleAnimation.value,
          end: isExpanding ? 1 : _kMinThumbScale),
    );
    thumbScaleController.animateWith(_kThumbSpringAnimationSimulation);
  }

  void onHighlightChangedByGesture(T newValue) {
    if (highlighted == newValue) {
      return;
    }

    setState(() {
      highlighted = newValue;
    });
    thumbController.animateWith(_kThumbSpringAnimationSimulation);
    thumbAnimatable = null;
  }

  void onPressedChangedByGesture(T? newValue) {
    if (pressed != newValue) {
      setState(() {
        pressed = newValue;
      });
    }
  }

  void onTapUp(TapUpDetails details) {
    if (isThumbDragging) {
      return;
    }
    final T segment = segmentForXPosition(details.localPosition.dx);
    onPressedChangedByGesture(null);
    if (segment != widget.groupValue &&
        !widget.disabledChildren.contains(segment)) {
      widget.onValueChanged(segment);
    }
  }

  void onDown(DragDownDetails details) {
    final T touchDownSegment = segmentForXPosition(details.localPosition.dx);
    _startedOnSelectedSegment = touchDownSegment == highlighted;
    _startedOnDisabledSegment =
        widget.disabledChildren.contains(touchDownSegment);
    if (widget.disabledChildren.contains(touchDownSegment)) {
      return;
    }
    onPressedChangedByGesture(touchDownSegment);

    if (isThumbDragging) {
      _playThumbScaleAnimation(isExpanding: false);
    }
  }

  void onUpdate(DragUpdateDetails details) {
    if (_startedOnDisabledSegment) {
      return;
    }
    final T touchDownSegment = segmentForXPosition(details.localPosition.dx);
    if (widget.disabledChildren.contains(touchDownSegment)) {
      return;
    }
    if (isThumbDragging) {
      onPressedChangedByGesture(touchDownSegment);
      onHighlightChangedByGesture(touchDownSegment);
    } else {
      final T? segment = _hasDraggedTooFar(details)
          ? null
          : segmentForXPosition(details.localPosition.dx);
      onPressedChangedByGesture(segment);
    }
  }

  void onEnd(DragEndDetails details) {
    final T? pressed = this.pressed;
    if (isThumbDragging) {
      _playThumbScaleAnimation(isExpanding: true);
      if (highlighted != widget.groupValue) {
        widget.onValueChanged(highlighted);
      }
    } else if (pressed != null) {
      onHighlightChangedByGesture(pressed);
      assert(pressed == highlighted);
      if (highlighted != widget.groupValue) {
        widget.onValueChanged(highlighted);
      }
    }

    onPressedChangedByGesture(null);
    _startedOnSelectedSegment = null;
  }

  void onCancel() {
    if (isThumbDragging) {
      _playThumbScaleAnimation(isExpanding: true);
    }
    onPressedChangedByGesture(null);
    _startedOnSelectedSegment = null;
  }

  T? highlighted;

  T? pressed;

  @override
  Widget build(BuildContext context) {
    assert(widget.children.length >= 2);
    List<Widget> children = <Widget>[];
    bool isPreviousSegmentHighlighted = false;

    int index = 0;
    int? highlightedIndex;
    for (final MapEntry<T, Widget> entry in widget.children.entries) {
      final bool isHighlighted = highlighted == entry.key;
      if (isHighlighted) {
        highlightedIndex = index;
      }

      if (index != 0) {
        children.add(
          _SegmentSeparator(
            key: ValueKey<int>(index),
            highlighted: isPreviousSegmentHighlighted || isHighlighted,
          ),
        );
      }

      final TextDirection textDirection = Directionality.of(context);
      final _SegmentLocation segmentLocation = switch (textDirection) {
        TextDirection.ltr when index == 0 => _SegmentLocation.leftmost,
        TextDirection.ltr when index == widget.children.length - 1 =>
          _SegmentLocation.rightmost,
        TextDirection.rtl when index == widget.children.length - 1 =>
          _SegmentLocation.leftmost,
        TextDirection.rtl when index == 0 => _SegmentLocation.rightmost,
        TextDirection.ltr || TextDirection.rtl => _SegmentLocation.inbetween,
      };
      children.add(
        Semantics(
          button: true,
          onTap: () {
            if (widget.disabledChildren.contains(entry.key)) {
              return;
            }
            widget.onValueChanged(entry.key);
          },
          inMutuallyExclusiveGroup: true,
          selected: widget.groupValue == entry.key,
          child: MouseRegion(
            cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
            child: _Segment<T>(
              key: ValueKey<T>(entry.key),
              highlighted: isHighlighted,
              pressed: pressed == entry.key,
              isDragging: isThumbDragging,
              enabled: !widget.disabledChildren.contains(entry.key),
              segmentLocation: segmentLocation,
              child: entry.value,
            ),
          ),
        ),
      );

      index += 1;
      isPreviousSegmentHighlighted = isHighlighted;
    }

    assert((highlightedIndex == null) == (highlighted == null));

    switch (Directionality.of(context)) {
      case TextDirection.ltr:
        break;
      case TextDirection.rtl:
        children = children.reversed.toList(growable: false);
        if (highlightedIndex != null) {
          highlightedIndex = index - 1 - highlightedIndex;
        }
    }

    return UnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: widget.padding.resolve(Directionality.of(context)),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(_kCornerRadius),
          color: widget.backgroundColor,
        ),
        child: AnimatedBuilder(
          animation: thumbScaleAnimation,
          builder: (BuildContext context, Widget? child) {
            return _CommonTabBarRenderWidget<T>(
              proportionalWidth: widget.proportionalWidth,
              key: segmentedControlRenderWidgetKey,
              highlightedIndex: highlightedIndex,
              thumbColor: widget.thumbColor,
              thumbScale: thumbScaleAnimation.value,
              state: this,
              children: children,
            );
          },
        ),
      ),
    );
  }
}

class _Segment<T> extends StatefulWidget {
  const _Segment({
    required ValueKey<T> key,
    required this.child,
    required this.pressed,
    required this.highlighted,
    required this.isDragging,
    required this.enabled,
    required this.segmentLocation,
  }) : super(key: key);

  final Widget child;

  final bool pressed;
  final bool highlighted;
  final bool enabled;
  final _SegmentLocation segmentLocation;
  final bool isDragging;

  bool get shouldFadeoutContent => pressed && !highlighted && enabled;

  bool get shouldScaleContent =>
      pressed && highlighted && isDragging && enabled;

  @override
  _SegmentState<T> createState() => _SegmentState<T>();
}

class _SegmentState<T> extends State<_Segment<T>>
    with TickerProviderStateMixin<_Segment<T>> {
  late final AnimationController highlightPressScaleController;
  late Animation<double> highlightPressScaleAnimation;

  @override
  void initState() {
    super.initState();
    highlightPressScaleController = AnimationController(
      duration: _kOpacityAnimationDuration,
      value: widget.shouldScaleContent ? 1 : 0,
      vsync: this,
    );

    highlightPressScaleAnimation = highlightPressScaleController.drive(
      Tween<double>(begin: 1.0, end: _kMinThumbScale),
    );
  }

  @override
  void didUpdateWidget(_Segment<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.key == widget.key);

    if (oldWidget.shouldScaleContent != widget.shouldScaleContent) {
      highlightPressScaleAnimation = highlightPressScaleController.drive(
        Tween<double>(
          begin: highlightPressScaleAnimation.value,
          end: widget.shouldScaleContent ? _kMinThumbScale : 1.0,
        ),
      );
      highlightPressScaleController
          .animateWith(_kThumbSpringAnimationSimulation);
    }
  }

  @override
  void dispose() {
    highlightPressScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Alignment scaleAlignment = switch (widget.segmentLocation) {
      _SegmentLocation.leftmost => Alignment.centerLeft,
      _SegmentLocation.rightmost => Alignment.centerRight,
      _SegmentLocation.inbetween => Alignment.center,
    };

    return MetaData(
      behavior: HitTestBehavior.opaque,
      child: IndexedStack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedOpacity(
            opacity:
                widget.shouldFadeoutContent ? _kContentPressedMinOpacity : 1,
            duration: _kOpacityAnimationDuration,
            curve: Curves.ease,
            child: AnimatedDefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(
                    TextStyle(
                      fontWeight: widget.highlighted
                          ? _kHighlightedFontWeight
                          : _kFontWeight,
                      fontSize: _kFontSize,
                      color: widget.enabled ? null : _kDisabledContentColor,
                    ),
                  ),
              duration: _kHighlightAnimationDuration,
              curve: Curves.ease,
              child: ScaleTransition(
                alignment: scaleAlignment,
                scale: highlightPressScaleAnimation,
                child: widget.child,
              ),
            ),
          ),
          DefaultTextStyle.merge(
            style: const TextStyle(
                fontWeight: _kHighlightedFontWeight, fontSize: _kFontSize),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _SegmentSeparator extends StatefulWidget {
  const _SegmentSeparator({
    required ValueKey<int> key,
    required this.highlighted,
  }) : super(key: key);

  final bool highlighted;

  @override
  _SegmentSeparatorState createState() => _SegmentSeparatorState();
}

class _SegmentSeparatorState extends State<_SegmentSeparator>
    with TickerProviderStateMixin<_SegmentSeparator> {
  late final AnimationController separatorOpacityController;

  @override
  void initState() {
    super.initState();

    separatorOpacityController = AnimationController(
      duration: _kSpringAnimationDuration,
      value: widget.highlighted ? 0 : 1,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_SegmentSeparator oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.key == widget.key);

    if (oldWidget.highlighted != widget.highlighted) {
      separatorOpacityController.animateTo(
        widget.highlighted ? 0 : 1,
        duration: _kSpringAnimationDuration,
        curve: Curves.ease,
      );
    }
  }

  @override
  void dispose() {
    separatorOpacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: separatorOpacityController,
      child: const SizedBox(width: _kSeparatorWidth),
      builder: (BuildContext context, Widget? child) {
        return Padding(
          padding: _kSeparatorInset,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

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
      BuildContext context, _RenderSegmentedControl<T> renderObject) {
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
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  _RenderSegmentedControl({
    required int? highlightedIndex,
    required Color thumbColor,
    required double thumbScale,
    required bool proportionalWidth,
    required this.state,
  })  : _highlightedIndex = highlightedIndex,
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
        childWidth, (constraints.maxWidth - totalSeparatorWidth) / childCount);
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
    final double maxChildHeight =
        _getMaxChildHeight(constraints, constraints.maxWidth);
    return constraints.constrain(
      Size(_getChildWidths(constraints).sum + totalSeparatorWidth,
          maxChildHeight),
    );
  }

  @override
  double? computeDryBaseline(
      covariant BoxConstraints constraints, TextBaseline baseline) {
    final List<double> segmentWidths = _getChildWidths(constraints);
    final double childHeight =
        _getMaxChildHeight(constraints, constraints.maxWidth);

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
      child.layout(index.isEven ? childConstraints : separatorConstraints,
          parentUsesSize: true);
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
          state.thumbAnimatable =
              RectTween(begin: startingRect, end: newThumbRect);
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
      PaintingContext context, Offset offset, RenderBox child) {
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
    // const List<BoxShadow> thumbShadow = <BoxShadow>[
    //   BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: 8),
    //   BoxShadow(color: Color(0x0A000000), offset: Offset(0, 3), blurRadius: 1),
    // ];

    final RRect thumbRRect =
        RRect.fromRectAndRadius(thumbRect.shift(offset), _kThumbRadius);

    // for (final BoxShadow shadow in thumbShadow) {
    //   context.canvas
    //       .drawRRect(thumbRRect.shift(shadow.offset), shadow.toPaint());
    // }

    context.canvas.drawRRect(
        thumbRRect.inflate(0.5), Paint()..color = const Color(0x0A000000));

    context.canvas.drawRRect(thumbRRect, Paint()..color = thumbColor);
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
