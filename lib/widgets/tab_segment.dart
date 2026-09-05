part of 'tab.dart';

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
      highlightPressScaleController.animateWith(
        _kThumbSpringAnimationSimulation,
      );
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
            opacity: widget.shouldFadeoutContent
                ? _kContentPressedMinOpacity
                : 1,
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
              fontWeight: _kHighlightedFontWeight,
              fontSize: _kFontSize,
            ),
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
        return Padding(padding: _kSeparatorInset, child: child);
      },
    );
  }
}
