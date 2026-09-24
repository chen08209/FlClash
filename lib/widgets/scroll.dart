import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';

const _restThickness = 6.0;
const _activeThickness = 10.0;
const _crossAxisMargin = 2.0;
const _minThumbLength = 48.0;
const _fabZoneGap = 8.0;

// Every band the pointer strays sideways from where it grabbed the thumb
// halves how far the content moves per pixel of thumb travel.
const _scrubBandWidth = 48.0;
const _scrubRates = [1.0, 0.5, 0.25, 0.125];

class CommonScrollBar extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;
  final bool thumbVisibility;
  final EdgeInsets padding;

  /// Reports the scrub rate while the thumb is held, and null on release.
  final ValueChanged<double?>? onScrub;

  final bool _hidesAmbientBar;

  const CommonScrollBar({
    super.key,
    required this.child,
    required this.controller,
    this.thumbVisibility = false,
    this.padding = EdgeInsets.zero,
    this.onScrub,
  }) : _hidesAmbientBar = true;

  /// The bar a scroll behavior adds, which has no other bar to hide.
  const CommonScrollBar.ambient({
    super.key,
    required this.child,
    required this.controller,
    this.padding = EdgeInsets.zero,
  }) : thumbVisibility = false,
       onScrub = null,
       _hidesAmbientBar = false;

  Widget _buildScrollBar(BuildContext context, Widget child) {
    return _AppScrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      onScrub: onScrub,
      child: _hidesAmbientBar
          ? ScrollConfiguration(
              behavior: _OwnBarScrollBehavior(
                ambient: ScrollConfiguration.of(context),
                controller:
                    controller ?? PrimaryScrollController.maybeOf(context),
              ),
              child: child,
            )
          : child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (padding == EdgeInsets.zero) {
      return _buildScrollBar(context, child);
    }
    // Scrollbar insets its track by MediaQuery padding, so the inset reaches it
    // through a MediaQuery of its own and the child keeps the original one.
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(padding: mediaQuery.padding + padding),
      child: _buildScrollBar(
        context,
        MediaQuery(data: mediaQuery, child: child),
      ),
    );
  }
}

/// The ambient behavior less the bar it would stack on the scrollable that
/// [controller] drives, so lists nested inside keep theirs.
class _OwnBarScrollBehavior extends ScrollBehavior {
  const _OwnBarScrollBehavior({
    required this.ambient,
    required this.controller,
  });

  final ScrollBehavior ambient;
  final ScrollController? controller;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (details.controller == controller) {
      return child;
    }
    return ambient.buildScrollbar(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => ambient.buildOverscrollIndicator(context, child, details);

  @override
  Set<PointerDeviceKind> get dragDevices => ambient.dragDevices;

  @override
  Set<LogicalKeyboardKey> get pointerAxisModifiers =>
      ambient.pointerAxisModifiers;

  @override
  MultitouchDragStrategy getMultitouchDragStrategy(BuildContext context) =>
      ambient.getMultitouchDragStrategy(context);

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      ambient.getPlatform(context);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ambient.getScrollPhysics(context);

  @override
  ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(
    BuildContext context,
  ) => ambient.getKeyboardDismissBehavior(context);

  @override
  GestureVelocityTrackerBuilder velocityTrackerBuilder(BuildContext context) =>
      ambient.velocityTrackerBuilder(context);

  @override
  bool shouldNotify(_OwnBarScrollBehavior oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.ambient.runtimeType != ambient.runtimeType ||
      ambient.shouldNotify(oldDelegate.ambient);
}

class _AppScrollbar extends RawScrollbar {
  final ValueChanged<double?>? onScrub;

  const _AppScrollbar({
    required super.child,
    super.controller,
    super.thumbVisibility,
    this.onScrub,
  }) : super(
         interactive: true,
         shape: AppShape.full,
         minThumbLength: _minThumbLength,
         crossAxisMargin: _crossAxisMargin,
         fadeDuration: const Duration(milliseconds: 250),
         // Long enough to let go and grab the thumb again before it fades.
         timeToFade: const Duration(milliseconds: 1200),
       );

  @override
  RawScrollbarState<_AppScrollbar> createState() => _AppScrollbarState();
}

class _AppScrollbarState extends RawScrollbarState<_AppScrollbar> {
  late final AnimationController _emphasis;
  late final CurvedAnimation _emphasisCurve;
  late ColorScheme _colorScheme;
  late TargetPlatform _platform;
  var _hovered = false;
  var _dragging = false;
  Offset? _scrubOrigin;
  Offset? _scrubLast;
  Offset? _scrubPosition;
  var _scrubRate = 1.0;

  @override
  void initState() {
    super.initState();
    _emphasis = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..addListener(updateScrollbarPainter);
    _emphasisCurve = CurvedAnimation(parent: _emphasis, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    final theme = Theme.of(context);
    _colorScheme = theme.colorScheme;
    _platform = theme.platform;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _emphasisCurve.dispose();
    _emphasis.dispose();
    super.dispose();
  }

  void _syncEmphasis() {
    if (_hovered || _dragging) {
      _emphasis.forward();
    } else {
      _emphasis.reverse();
    }
  }

  double _scrubRateFor(double sidewaysDistance) {
    if (!isTouchPlatform(_platform)) {
      return 1.0;
    }
    final band = (sidewaysDistance / _scrubBandWidth).floor();
    return _scrubRates[band.clamp(0, _scrubRates.length - 1)];
  }

  @override
  void updateScrollbarPainter() {
    super.updateScrollbarPainter();
    final t = _emphasisCurve.value;
    final onSurface = _colorScheme.onSurface;
    final isDark = _colorScheme.brightness == Brightness.dark;
    scrollbarPainter
      ..color = Color.lerp(
        onSurface.withValues(alpha: isDark ? 0.35 : 0.25),
        onSurface.withValues(alpha: isDark ? 0.65 : 0.5),
        t,
      )!
      ..thickness = _restThickness + (_activeThickness - _restThickness) * t;
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    if (getScrollbarDirection() == null) {
      return;
    }
    _dragging = true;
    _scrubOrigin = localPosition;
    _scrubLast = localPosition;
    _scrubPosition = localPosition;
    _scrubRate = 1.0;
    _syncEmphasis();
    if (isTouchPlatform(_platform)) {
      HapticFeedback.selectionClick();
    }
    widget.onScrub?.call(_scrubRate);
  }

  // The thumb maps to an absolute offset, so a slowed scrub feeds the base
  // class a virtual pointer that advances by the scaled delta only.
  @override
  void handleThumbPressUpdate(Offset localPosition) {
    final origin = _scrubOrigin;
    final last = _scrubLast;
    final position = _scrubPosition;
    final direction = getScrollbarDirection();
    if (origin == null || last == null || position == null) {
      super.handleThumbPressUpdate(localPosition);
      return;
    }
    final Offset next;
    final double rate;
    switch (direction) {
      case Axis.vertical:
        rate = _scrubRateFor((localPosition.dx - origin.dx).abs());
        next = Offset(
          localPosition.dx,
          position.dy + (localPosition.dy - last.dy) * rate,
        );
      case Axis.horizontal:
        rate = _scrubRateFor((localPosition.dy - origin.dy).abs());
        next = Offset(
          position.dx + (localPosition.dx - last.dx) * rate,
          localPosition.dy,
        );
      case null:
        super.handleThumbPressUpdate(localPosition);
        return;
    }
    _scrubLast = localPosition;
    _scrubPosition = next;
    if (rate != _scrubRate) {
      _scrubRate = rate;
      widget.onScrub?.call(rate);
    }
    super.handleThumbPressUpdate(next);
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    final position = _scrubPosition ?? localPosition;
    final slowed = _scrubRate < 1;
    _dragging = false;
    _scrubOrigin = null;
    _scrubLast = null;
    _scrubPosition = null;
    _scrubRate = 1.0;
    _syncEmphasis();
    // A fling would throw away the precision the slowed scrub just bought.
    super.handleThumbPressEnd(position, slowed ? Velocity.zero : velocity);
    widget.onScrub?.call(null);
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    final hovered = isPointerOverScrollbar(
      event.position,
      event.kind,
      forHover: true,
    );
    if (hovered != _hovered) {
      _hovered = hovered;
      _syncEmphasis();
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    if (_hovered) {
      _hovered = false;
      _syncEmphasis();
    }
  }
}

class FloatingScrollbar extends StatefulWidget {
  final ScrollController controller;
  final String Function(double fraction) hintBuilder;
  final bool thumbVisibility;
  final Widget child;

  const FloatingScrollbar({
    super.key,
    required this.controller,
    required this.hintBuilder,
    this.thumbVisibility = false,
    required this.child,
  });

  @override
  State<FloatingScrollbar> createState() => _FloatingScrollbarState();
}

class _FloatingScrollbarState extends State<FloatingScrollbar> {
  var _hintVisible = false;
  var _hintMounted = false;
  double? _scrubRate;
  var _pillHeight = 0.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Lazy lists also refine maxScrollExtent during layout, which moves the
    // thumb without a scroll notification; the position listener covers both.
    widget.controller.addListener(_syncPosition);
  }

  @override
  void didUpdateWidget(FloatingScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncPosition);
      widget.controller.addListener(_syncPosition);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_syncPosition);
    super.dispose();
  }

  void _syncPosition() {
    if (_hintMounted && mounted) {
      setState(() {});
    }
  }

  void _handleScrub(double? rate) {
    _hideTimer?.cancel();
    if (rate != null) {
      final appearing = !_hintMounted;
      setState(() {
        _scrubRate = rate;
        _hintVisible = !appearing;
        _hintMounted = true;
      });
      if (appearing) {
        // Mounts transparent so AnimatedOpacity has a value to fade from.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _hintMounted) {
            setState(() => _hintVisible = true);
          }
        });
      }
      return;
    }
    setState(() => _scrubRate = null);
    // Lingers so letting go and grabbing again does not blink the hint.
    _hideTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _hintVisible = false);
      }
    });
  }

  double _thumbCenter(
    ScrollMetrics metrics,
    double height,
    EdgeInsets padding,
  ) {
    final track = height - padding.vertical;
    final scrollableExtent = metrics.maxScrollExtent - metrics.minScrollExtent;
    final fraction = scrollableExtent > 0
        ? ((metrics.pixels - metrics.minScrollExtent) / scrollableExtent).clamp(
            0.0,
            1.0,
          )
        : 0.0;
    final totalContent =
        metrics.maxScrollExtent + metrics.viewportDimension - padding.vertical;
    final fractionVisible = totalContent > 0
        ? ((metrics.extentInside - padding.vertical) / totalContent).clamp(
            0.0,
            1.0,
          )
        : 1.0;
    // Reversed lists place the thumb at (1 - fraction).
    final thumbExtent = max(
      _minThumbLength,
      track * fractionVisible,
    ).clamp(0.0, track);
    final thumbFraction = axisDirectionIsReversed(metrics.axisDirection)
        ? 1 - fraction
        : fraction;
    return padding.top +
        thumbFraction * (track - thumbExtent) +
        thumbExtent / 2;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = BottomInsetScope.of(context);
    final behavior = ScrollConfiguration.of(context);
    final barPadding = behavior is BaseScrollBehavior
        ? behavior.scrollbarPadding
        : EdgeInsets.zero;
    // A finger on the thumb covers the bar's edge, so the hint keeps clear.
    final hintGap = isTouchPlatform(Theme.of(context).platform) ? 40.0 : 20.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        String? label;
        var top = 0.0;
        if (_hintMounted && widget.controller.hasClients) {
          final metrics = widget.controller.position;
          if (metrics.maxScrollExtent > metrics.minScrollExtent) {
            final scrollableExtent =
                metrics.maxScrollExtent - metrics.minScrollExtent;
            final fraction =
                ((metrics.pixels - metrics.minScrollExtent) / scrollableExtent)
                    .clamp(0.0, 1.0);
            // Continuous clamp: the pill stays clear of the FAB zone at any height.
            final half = _pillHeight / 2;
            final limit = (constraints.maxHeight - bottomInset - _fabZoneGap)
                .clamp(0.0, double.infinity);
            top = _thumbCenter(
              metrics,
              constraints.maxHeight,
              MediaQuery.paddingOf(context) + barPadding,
            ).clamp(half, max(half, limit - half));
            label = widget.hintBuilder(fraction);
          }
        }
        return Stack(
          children: [
            CommonScrollBar(
              controller: widget.controller,
              thumbVisibility: widget.thumbVisibility,
              padding: barPadding,
              onScrub: _handleScrub,
              child: widget.child,
            ),
            // Outlives the label, so the fade-out still ends and unmounts it.
            if (_hintMounted)
              Positioned(
                right: hintGap,
                top: top,
                child: FractionalTranslation(
                  translation: const Offset(0, -0.5),
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _hintVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      onEnd: () {
                        if (!_hintVisible) {
                          setState(() => _hintMounted = false);
                        }
                      },
                      child: label == null
                          ? const SizedBox.shrink()
                          : _MeasureSize(
                              onChanged: (size) {
                                if (mounted && size.height != _pillHeight) {
                                  setState(() => _pillHeight = size.height);
                                }
                              },
                              child: _ScrollbarHintPill(
                                label: label,
                                scrubRate: _scrubRate,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ScrollbarHintPill extends StatelessWidget {
  final String label;
  final double? scrubRate;

  const _ScrollbarHintPill({required this.label, required this.scrubRate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = context.textTheme.labelMedium;
    final rate = scrubRate;
    return DecoratedBox(
      key: const ValueKey('scrollbarHintPill'),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.sm.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: style?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (rate != null && rate < 1) ...[
              const SizedBox(width: 6),
              Text(
                '×1/${(1 / rate).round()}',
                key: const ValueKey('scrollbarScrubRate'),
                style: style?.copyWith(color: colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChanged;

  const _MeasureSize({required this.onChanged, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChanged = onChanged;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChanged);

  ValueChanged<Size> onChanged;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (_oldSize == size) return;
    _oldSize = size;
    final newSize = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(newSize));
  }
}

class ScrollToEndBox<T> extends StatefulWidget {
  final ScrollController controller;
  final List<T> dataSource;
  final Widget child;
  final bool enable;
  final VoidCallback? onCancelToEnd;
  final VoidCallback? onResumeToEnd;

  const ScrollToEndBox({
    super.key,
    required this.child,
    required this.controller,
    required this.dataSource,
    this.onCancelToEnd,
    this.onResumeToEnd,
    this.enable = true,
  });

  @override
  State<ScrollToEndBox<T>> createState() => _ScrollToEndBoxState<T>();
}

class _ScrollToEndBoxState<T> extends State<ScrollToEndBox<T>> {
  double? _viewportDimension;

  /// Moving the position would end the user's drag or fling under them.
  bool _userScrolling = false;
  bool _followDeferred = false;
  ValueListenable<bool>? _sheetSettling;

  bool get _followPaused => _userScrolling || (_sheetSettling?.value ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settling = SheetSettlingScope.of(context);
    if (settling != _sheetSettling) {
      _sheetSettling?.removeListener(_resumeFollow);
      _sheetSettling = settling?..addListener(_resumeFollow);
    }
  }

  @override
  void dispose() {
    _sheetSettling?.removeListener(_resumeFollow);
    super.dispose();
  }

  void _resumeFollow() {
    if (_followDeferred && !_followPaused) {
      _followDeferred = false;
      _scheduleScrollToEnd();
    }
  }

  bool _isAtEnd(ScrollMetrics metrics) =>
      (metrics.maxScrollExtent - metrics.pixels).abs() <
      precisionErrorTolerance;

  void _scheduleScrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollToEnd());
    });
  }

  void _scheduleJumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enable || !widget.controller.hasClients) {
        return;
      }
      if (_followPaused) {
        _followDeferred = true;
        return;
      }
      final position = widget.controller.position;
      if (!_isAtEnd(position)) {
        widget.controller.jumpTo(position.maxScrollExtent);
      }
    });
  }

  Future<void> _scrollToEnd() async {
    if (!mounted || !widget.enable || !widget.controller.hasClients) {
      return;
    }
    if (_followPaused) {
      _followDeferred = true;
      return;
    }
    final position = widget.controller.position;
    if (_isAtEnd(position)) {
      return;
    }
    if (position.maxScrollExtent - position.pixels >
        position.viewportDimension) {
      widget.controller.jumpTo(position.maxScrollExtent);
      await WidgetsBinding.instance.endOfFrame;
    } else {
      await widget.controller.animateTo(
        position.maxScrollExtent,
        duration: kThemeAnimationDuration,
        curve: Curves.easeOut,
      );
    }
    // Lazy lists refine maxScrollExtent while the animation runs, so the
    // target captured at start can land short of the real end.
    if (mounted &&
        widget.enable &&
        !_followPaused &&
        widget.controller.hasClients &&
        !_isAtEnd(position)) {
      widget.controller.jumpTo(position.maxScrollExtent);
    }
  }

  bool _dataSourceChanged(List<T> oldData, List<T> newData) {
    if (identical(oldData, newData)) {
      return false;
    }
    if (oldData.length != newData.length) {
      return true;
    }
    return oldData.isNotEmpty && oldData.last != newData.last;
  }

  @override
  void didUpdateWidget(ScrollToEndBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enable) {
      return;
    }
    if (!oldWidget.enable ||
        _dataSourceChanged(oldWidget.dataSource, widget.dataSource)) {
      _scheduleScrollToEnd();
    }
  }

  bool _handleMetricsNotification(ScrollMetricsNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    final viewportDimension = notification.metrics.viewportDimension;
    final resized =
        _viewportDimension != null && _viewportDimension != viewportDimension;
    _viewportDimension = viewportDimension;
    if (resized && widget.enable && !_isAtEnd(notification.metrics)) {
      _scheduleJumpToEnd();
    }
    return false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _userScrolling = true;
    }
    if (notification is ScrollEndNotification && _userScrolling) {
      _userScrolling = false;
      _resumeFollow();
    }
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.forward) {
        _followDeferred = false;
        widget.onCancelToEnd?.call();
      }
      return false;
    }
    if (!widget.enable &&
        notification is ScrollEndNotification &&
        _isAtEnd(notification.metrics)) {
      widget.onResumeToEnd?.call();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.child,
      ),
    );
  }
}
