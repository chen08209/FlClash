import 'dart:math' as math;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
part 'tab_segment.dart';
part 'tab_render.dart';

const EdgeInsetsGeometry _kHorizontalItemPadding = EdgeInsets.symmetric(
  vertical: 2,
  horizontal: 3,
);

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
  }) : assert(children.length >= 2),
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
        end: isExpanding ? 1 : _kMinThumbScale,
      ),
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
    _startedOnDisabledSegment = widget.disabledChildren.contains(
      touchDownSegment,
    );
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
        decoration: ShapeDecoration(
          shape: const RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(_kCornerRadius),
          ),
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
