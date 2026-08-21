import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

typedef PopupAnchorResolver = Rect? Function();

typedef PopupOpen = void Function({Offset offset});

const _screenMargin = 16.0;

const _anchorOverlap = 8.0;

const _cardInset = 8.0;

const _cardRadius = 24.0;

const _itemIconSize = 20.0;

const _itemRadius = 12.0;

const _itemPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);

class CommonPopupRoute<T> extends PopupRoute<T> {
  CommonPopupRoute({
    required this.builder,
    required this.anchorOf,
    required this.barrierLabel,
  });

  final WidgetBuilder builder;
  final PopupAnchorResolver anchorOf;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 150);

  void _handleDismiss() {
    if (isCurrent) {
      navigator?.pop();
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const alignment = Alignment.topRight;
    final fade = animation.drive(CurveTween(curve: Curves.easeOut));
    final scale = animation.drive(CurveTween(curve: Curves.easeOutBack));
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: _handleDismiss,
          ),
        ),
        _PopupAnchorTracker(
          anchorOf: anchorOf,
          builder: (anchor, safeInsets, child) => CustomSingleChildLayout(
            delegate: _PopupLayoutDelegate(
              anchor: anchor,
              safeInsets: safeInsets,
            ),
            child: child,
          ),
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              alignment: alignment,
              scale: scale,
              child: SlideTransition(
                position: scale.drive(
                  Tween(begin: const Offset(0, -0.02), end: Offset.zero),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupAnchorTracker extends StatefulWidget {
  const _PopupAnchorTracker({
    required this.anchorOf,
    required this.builder,
    required this.child,
  });

  final PopupAnchorResolver anchorOf;
  final Widget Function(Rect anchor, EdgeInsets safeInsets, Widget child)
  builder;
  final Widget child;

  @override
  State<_PopupAnchorTracker> createState() => _PopupAnchorTrackerState();
}

class _PopupAnchorTrackerState extends State<_PopupAnchorTracker> {
  Rect? _anchor;
  bool _syncScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleSync();
  }

  void _scheduleSync() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) {
        return;
      }
      final anchor = widget.anchorOf();
      if (anchor == null || anchor == _anchor) {
        return;
      }
      setState(() {
        _anchor = anchor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final anchor = _anchor ??= widget.anchorOf() ?? Rect.zero;
    return widget.builder(anchor, padding, widget.child);
  }
}

class _PopupLayoutDelegate extends SingleChildLayoutDelegate {
  const _PopupLayoutDelegate({required this.anchor, required this.safeInsets});

  final Rect anchor;
  final EdgeInsets safeInsets;

  EdgeInsets get _insets => safeInsets + const EdgeInsets.all(_screenMargin);

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final insets = _insets;
    return BoxConstraints.loose(
      Size(
        math.max(0.0, constraints.maxWidth - insets.horizontal),
        math.max(0.0, constraints.maxHeight - insets.vertical),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final insets = _insets;
    final maxX = size.width - insets.right - childSize.width;
    final maxY = size.height - insets.bottom - childSize.height;
    return Offset(
      (anchor.right - childSize.width).clamp(
        insets.left,
        math.max(insets.left, maxX),
      ),
      (anchor.top - _anchorOverlap).clamp(
        insets.top,
        math.max(insets.top, maxY),
      ),
    );
  }

  @override
  bool shouldRelayout(_PopupLayoutDelegate oldDelegate) {
    return oldDelegate.anchor != anchor || oldDelegate.safeInsets != safeInsets;
  }
}

class CommonPopupBox extends StatefulWidget {
  const CommonPopupBox({
    super.key,
    required this.targetBuilder,
    required this.popupBuilder,
  });

  final Widget Function(PopupOpen open) targetBuilder;

  final WidgetBuilder popupBuilder;

  @override
  State<CommonPopupBox> createState() => _CommonPopupBoxState();
}

class _CommonPopupBoxState extends State<CommonPopupBox> {
  Rect? _anchorOf(Offset offset) {
    if (!mounted) {
      return null;
    }
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached || !renderBox.hasSize) {
      return null;
    }
    final navigatorBox =
        Navigator.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    final origin = renderBox.localToGlobal(Offset.zero, ancestor: navigatorBox);
    return (origin & renderBox.size).shift(offset);
  }

  void _open({Offset offset = Offset.zero}) {
    Navigator.of(context).push(
      CommonPopupRoute<void>(
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        builder: (context) => widget.popupBuilder(context),
        anchorOf: () => _anchorOf(offset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.targetBuilder(_open);
  }
}

class _MenuStep {
  const _MenuStep({
    required this.index,
    required this.top,
    required this.ownerWidth,
  });

  final int index;
  final double top;
  final double ownerWidth;
}

class _MenuLevel {
  const _MenuLevel({
    required this.items,
    required this.top,
    required this.fromWidth,
    required this.minWidth,
    required this.maxWidth,
    this.owner,
  });

  final List<CommonPopupMenuItem> items;
  final CommonPopupMenuItem? owner;
  final double top;
  final double fromWidth;
  final double minWidth;
  final double maxWidth;
}

class CommonPopupMenuItem {
  const CommonPopupMenuItem({
    required this.label,
    this.icon,
    this.onPressed,
    this.danger = false,
    this.subItems = const [],
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool danger;
  final List<CommonPopupMenuItem> subItems;
}

class CommonPopupMenu extends StatefulWidget {
  const CommonPopupMenu({
    super.key,
    required this.items,
    this.minWidth = 160,
    this.maxWidth = 280,
  });

  final List<CommonPopupMenuItem> items;
  final double minWidth;
  final double maxWidth;

  @override
  State<CommonPopupMenu> createState() => _CommonPopupMenuState();
}

class _CommonPopupMenuState extends State<CommonPopupMenu>
    with SingleTickerProviderStateMixin {
  static const _levelWidthScale = 1.12;
  static const _levelScaleStep = 0.05;
  static const _levelScrimStep = 0.06;
  static const _activeElevation = 12.0;
  static const _levelElevationStep = 4.0;
  static const _minElevation = 2.0;
  static final _arrowTween = Tween(begin: 0.0, end: 0.25);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );

  late final CurvedAnimation _expand = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInOutCubic,
  );

  late final CurvedAnimation _container = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
    reverseCurve: const Interval(0, 0.4, curve: Curves.easeInOutCubic),
  );

  late final CurvedAnimation _content = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1, curve: Curves.easeOut),
    reverseCurve: const Interval(0.4, 1, curve: Curves.easeInOut),
  );

  final List<_MenuStep> _path = [];
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_handleStatusChanged);
  }

  @override
  void dispose() {
    _expand.dispose();
    _container.dispose();
    _content.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !_closing || _path.isEmpty) {
      return;
    }
    _closing = false;
    setState(() {
      _path.removeLast();
      _controller.value = 1;
    });
  }

  List<_MenuLevel> _resolveLevels() {
    final rootWidth = math.min(widget.minWidth, widget.maxWidth);
    final levels = [
      _MenuLevel(
        items: widget.items,
        top: 0,
        fromWidth: rootWidth,
        minWidth: rootWidth,
        maxWidth: widget.maxWidth,
      ),
    ];
    var items = widget.items;
    for (final step in _path) {
      if (step.index >= items.length) {
        break;
      }
      final item = items[step.index];
      if (item.subItems.isEmpty) {
        break;
      }
      final fromWidth = math.max(step.ownerWidth, levels.last.minWidth);
      final minWidth = fromWidth * _levelWidthScale;
      levels.add(
        _MenuLevel(
          items: item.subItems,
          owner: item,
          top: math.max(0, step.top - _cardInset),
          fromWidth: fromWidth,
          minWidth: minWidth,
          maxWidth: math.max(minWidth, widget.maxWidth),
        ),
      );
      items = item.subItems;
    }
    return levels;
  }

  Animation<double> _progressOf(bool expanding) =>
      expanding ? _expand : kAlwaysCompleteAnimation;

  Animation<double> _containerProgressOf(bool expanding) =>
      expanding ? _container : kAlwaysCompleteAnimation;

  Animation<double> _contentProgressOf(bool expanding) =>
      expanding ? _content : kAlwaysCompleteAnimation;

  double _elevationOf(int depth) {
    return math.max(
      _minElevation,
      _activeElevation - depth * _levelElevationStep,
    );
  }

  void _push(BuildContext itemContext, int index) {
    final itemBox = itemContext.findRenderObject() as RenderBox?;
    final stackBox = context.findRenderObject() as RenderBox?;
    final placed =
        itemBox != null &&
        stackBox != null &&
        itemBox.hasSize &&
        stackBox.hasSize;
    _closing = false;
    setState(() {
      _path.add(
        _MenuStep(
          index: index,
          top: placed
              ? itemBox.localToGlobal(Offset.zero, ancestor: stackBox).dy
              : 0,
          ownerWidth: placed
              ? itemBox.size.width + 2 * _cardInset
              : widget.minWidth,
        ),
      );
    });
    _controller.forward(from: 0);
  }

  void _pop() {
    if (_path.isEmpty || _closing) {
      return;
    }
    _closing = true;
    _controller.reverse();
  }

  void _select(VoidCallback onPressed) {
    Navigator.of(context).pop();
    onPressed();
  }

  Widget _buildRow(
    BuildContext context, {
    required CommonPopupMenuItem item,
    required VoidCallback? onTap,
    Animation<double>? arrowTurns,
  }) {
    final colorScheme = context.colorScheme;
    final enabled = onTap != null;
    final color = item.danger ? colorScheme.error : colorScheme.onSurface;
    final foregroundColor = enabled ? color : color.opacity30;
    Widget? arrow;
    if (item.subItems.isNotEmpty) {
      arrow = Icon(
        Icons.chevron_right,
        size: _itemIconSize,
        color: foregroundColor,
      );
      if (arrowTurns != null) {
        arrow = RotationTransition(turns: arrowTurns, child: arrow);
      }
    }
    final child = InkWell(
      borderRadius: BorderRadius.circular(_itemRadius),
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: item.danger ? colorScheme.error.opacity10 : null,
      child: Padding(
        padding: _itemPadding,
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: _itemIconSize, color: foregroundColor),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),
            if (arrow != null) ...[const SizedBox(width: 8), arrow],
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: ClipRSuperellipse(
        borderRadius: const BorderRadius.all(Radius.circular(_itemRadius)),
        child: child,
      ),
    );
  }

  Widget _buildItem(BuildContext context, CommonPopupMenuItem item, int index) {
    if (item.subItems.isNotEmpty) {
      return Builder(
        builder: (itemContext) => _buildRow(
          itemContext,
          item: item,
          onTap: () => _push(itemContext, index),
        ),
      );
    }
    final onPressed = item.onPressed;
    return _buildRow(
      context,
      item: item,
      onTap: onPressed == null ? null : () => _select(onPressed),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double minWidth,
    required double maxWidth,
    required double elevation,
    required double radius,
    required Widget child,
  }) {
    return Card(
      elevation: elevation,
      margin: EdgeInsets.zero,
      color: context.colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(_cardInset),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: IntrinsicWidth(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    _MenuLevel level, {
    required bool expanding,
  }) {
    final items = [
      for (var index = 0; index < level.items.length; index++)
        _buildItem(context, level.items[index], index),
    ];
    final owner = level.owner;
    if (owner == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      );
    }
    final progress = _progressOf(expanding);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          context,
          item: owner,
          onTap: _pop,
          arrowTurns: progress.drive(_arrowTween),
        ),
        SizeTransition(
          sizeFactor: progress,
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _contentProgressOf(expanding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [const Divider(height: 1, thickness: 1), ...items],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveLevel(BuildContext context, _MenuLevel level) {
    final progress = _containerProgressOf(level.owner != null);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final value = progress.value;
        return _buildCard(
          context,
          minWidth: lerpDouble(level.fromWidth, level.minWidth, value)!,
          maxWidth: lerpDouble(level.fromWidth, level.maxWidth, value)!,
          elevation: _activeElevation * value,
          radius: lerpDouble(_itemRadius + _cardInset, _cardRadius, value)!,
          child: child!,
        );
      },
      child: _buildContent(context, level, expanding: level.owner != null),
    );
  }

  Widget _buildRecedingLevel(
    BuildContext context,
    _MenuLevel level, {
    required int depth,
    required double origin,
  }) {
    final scrim = context.colorScheme.scrim;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final distance = depth - (1 - _controller.value);
            final scale = math.max(0.0, 1 - _levelScaleStep * distance);
            return Transform(
              transform: Matrix4.diagonal3Values(scale, scale, 1),
              alignment: Alignment.topRight,
              origin: Offset(0, origin),
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: ShapeDecoration(
                  color: scrim.withValues(
                    alpha: math.min(1.0, _levelScrimStep * distance),
                  ),
                  shape: const RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(_cardRadius),
                    ),
                  ),
                ),
                child: child,
              ),
            );
          },
          child: RepaintBoundary(
            child: _buildCard(
              context,
              minWidth: level.minWidth,
              maxWidth: level.maxWidth,
              elevation: _elevationOf(depth),
              radius: _cardRadius,
              child: _buildContent(context, level, expanding: false),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levels = _resolveLevels();
    final topIndex = levels.length - 1;
    return PopScope(
      canPop: topIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _pop();
        }
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          for (var index = 0; index <= topIndex; index++)
            Padding(
              key: ValueKey(index),
              padding: EdgeInsets.only(top: levels[index].top),
              child: index == topIndex
                  ? _buildActiveLevel(context, levels[index])
                  : _buildRecedingLevel(
                      context,
                      levels[index],
                      depth: topIndex - index,
                      origin:
                          levels[index + 1].top +
                          _cardInset -
                          levels[index].top,
                    ),
            ),
        ],
      ),
    );
  }
}
