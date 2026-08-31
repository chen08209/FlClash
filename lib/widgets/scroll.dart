import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'inherited.dart';

const _thumbThickness = 6.0;
const _fabZoneGap = 8.0;

class CommonScrollBar extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;
  final bool trackVisibility;
  final bool thumbVisibility;

  const CommonScrollBar({
    super.key,
    required this.child,
    required this.controller,
    this.trackVisibility = false,
    this.thumbVisibility = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      thickness: _thumbThickness,
      radius: const Radius.circular(_thumbThickness / 2),
      interactive: true,
      child: child,
    );
  }
}

class FloatingScrollbar extends StatefulWidget {
  final ScrollController controller;
  final String Function(double fraction) hintBuilder;
  final Widget child;

  const FloatingScrollbar({
    super.key,
    required this.controller,
    required this.hintBuilder,
    required this.child,
  });

  @override
  State<FloatingScrollbar> createState() => _FloatingScrollbarState();
}

class _FloatingScrollbarState extends State<FloatingScrollbar> {
  var _shown = false;
  var _pillHeight = 0.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Scroll notifications only fire on scroll activity; lazy lists also
    // refine maxScrollExtent during layout, which moves the thumb without
    // any notification. The position listener covers both.
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
    if (_shown && mounted) {
      setState(() {});
    }
  }

  // Deferred so transient ScrollEndNotifications mid-gesture do not blink
  // the pill off and on.
  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_shown) return;
    _hideTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _shown = false);
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _scheduleHide();
      return false;
    }
    // Only user drags arm the hint; programmatic animateTo must not flash it.
    final isUserDrag = switch (notification) {
      ScrollStartNotification(:final dragDetails) => dragDetails != null,
      ScrollUpdateNotification(:final dragDetails) => dragDetails != null,
      _ => false,
    };
    if (isUserDrag) {
      _hideTimer?.cancel();
      if (!_shown) {
        setState(() => _shown = true);
      }
    }
    return false;
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
    // Material scrollbar defaults: 48px min thumb length, no main-axis
    // margin. Reversed lists place the thumb at (1 - fraction).
    final thumbExtent = max(48.0, track * fractionVisible).clamp(0.0, track);
    return padding.top +
        (1 - fraction) * (track - thumbExtent) +
        thumbExtent / 2;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = BottomInsetScope.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: LayoutBuilder(
        builder: (context, constraints) {
          String? label;
          var top = 0.0;
          if (_shown && widget.controller.hasClients) {
            final metrics = widget.controller.position;
            if (metrics.maxScrollExtent > metrics.minScrollExtent) {
              final scrollableExtent =
                  metrics.maxScrollExtent - metrics.minScrollExtent;
              final fraction =
                  ((metrics.pixels - metrics.minScrollExtent) /
                          scrollableExtent)
                      .clamp(0.0, 1.0);
              // Continuous clamp: the pill stays clear of the FAB zone at any height.
              final half = _pillHeight / 2;
              final limit = (constraints.maxHeight - bottomInset - _fabZoneGap)
                  .clamp(0.0, double.infinity);
              top = _thumbCenter(
                metrics,
                constraints.maxHeight,
                MediaQuery.paddingOf(context),
              ).clamp(half, max(half, limit - half));
              label = widget.hintBuilder(fraction);
            }
          }
          return Stack(
            children: [
              CommonScrollBar(
                controller: widget.controller,
                child: widget.child,
              ),
              if (label != null)
                Positioned(
                  right: 12,
                  top: top,
                  child: FractionalTranslation(
                    translation: const Offset(0, -0.5),
                    child: IgnorePointer(
                      child: _MeasureSize(
                        onChanged: (size) {
                          if (mounted && size.height != _pillHeight) {
                            setState(() => _pillHeight = size.height);
                          }
                        },
                        child: _ScrollbarHintPill(label: label),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ScrollbarHintPill extends StatelessWidget {
  final String label;

  const _ScrollbarHintPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
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
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
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

  const ScrollToEndBox({
    super.key,
    required this.child,
    required this.controller,
    required this.dataSource,
    this.onCancelToEnd,
    this.enable = true,
  });

  @override
  State<ScrollToEndBox<T>> createState() => _ScrollToEndBoxState<T>();
}

class _ScrollToEndBoxState<T> extends State<ScrollToEndBox<T>> {
  bool _isAtEnd(ScrollPosition position) =>
      (position.maxScrollExtent - position.pixels).abs() <
      precisionErrorTolerance;

  void _scheduleScrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_scrollToEnd());
    });
  }

  Future<void> _scrollToEnd() async {
    if (!mounted || !widget.controller.hasClients) {
      return;
    }
    final position = widget.controller.position;
    if (_isAtEnd(position)) {
      return;
    }
    await widget.controller.animateTo(
      position.maxScrollExtent,
      duration: kThemeAnimationDuration,
      curve: Curves.easeOut,
    );
    // Lazy lists refine maxScrollExtent while the animation runs, so the
    // target captured at start can land short of the real end.
    if (mounted &&
        widget.enable &&
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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.forward) {
          widget.onCancelToEnd?.call();
        }
        return false;
      },
      child: widget.child,
    );
  }
}
