import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

typedef PopupAnchorResolver = Rect? Function();

typedef PopupOpen = void Function({Offset offset});

enum PopupPlacement { overAnchorEnd, belowPoint }

const _screenMargin = 16.0;

const _anchorOverlap = 8.0;

const _cardInset = 8.0;

const _itemRadius = AppCorner.md;

const _cardRadius = _itemRadius + _cardInset;

const _itemIconSize = 20.0;
const _submenuArrowSize = 16.0;

const _itemPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);

const _itemArrowPadding = EdgeInsets.only(
  left: 12,
  top: 12,
  bottom: 12,
  right: 8,
);

const _dividerHeight = _cardInset * 2 + 1;

class CommonPopupRoute<T> extends PopupRoute<T> {
  CommonPopupRoute({
    required this.builder,
    required this.anchorOf,
    required this.barrierLabel,
    this.placement = PopupPlacement.overAnchorEnd,
  });

  final WidgetBuilder builder;
  final PopupAnchorResolver anchorOf;
  final PopupPlacement placement;

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
    final alignment = switch (placement) {
      PopupPlacement.overAnchorEnd => Alignment.topRight,
      PopupPlacement.belowPoint => Alignment.topLeft,
    };
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
              placement: placement,
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
  const _PopupLayoutDelegate({
    required this.anchor,
    required this.safeInsets,
    required this.placement,
  });

  final Rect anchor;
  final EdgeInsets safeInsets;
  final PopupPlacement placement;

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
    final (x, y) = switch (placement) {
      PopupPlacement.overAnchorEnd => (
        anchor.right - childSize.width,
        anchor.top - _anchorOverlap,
      ),
      PopupPlacement.belowPoint => (anchor.left, anchor.bottom),
    };
    return Offset(
      x.clamp(insets.left, math.max(insets.left, maxX)),
      y.clamp(insets.top, math.max(insets.top, maxY)),
    );
  }

  @override
  bool shouldRelayout(_PopupLayoutDelegate oldDelegate) {
    return oldDelegate.anchor != anchor ||
        oldDelegate.safeInsets != safeInsets ||
        oldDelegate.placement != placement;
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

class CommonPopupMenuItem {
  const CommonPopupMenuItem({
    required this.label,
    this.glyph,
    this.onPressed,
    this.danger = false,
    this.subItems = const [],
  });

  final String label;
  final Glyph? glyph;
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

class _MenuStep {
  const _MenuStep({
    required this.index,
    required this.itemTop,
    required this.cardWidth,
  });

  final int index;
  final double itemTop;
  final double cardWidth;
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
    duration: const Duration(milliseconds: 280),
    value: 1,
  );

  late final CurvedAnimation _frame = _segment(0, 0.5);
  late final CurvedAnimation _reveal = _segment(0, 0.6);
  late final CurvedAnimation _unfold = _segment(0, 1);

  final List<_MenuStep> _path = [];
  bool _folding = false;

  CurvedAnimation _segment(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
    reverseCurve: Interval(begin, end, curve: Curves.easeInCubic),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_handleStatusChanged);
  }

  @override
  void dispose() {
    _frame.dispose();
    _reveal.dispose();
    _unfold.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !_folding || _path.isEmpty) {
      return;
    }
    _folding = false;
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
    for (final step in _path) {
      final parent = levels.last;
      if (step.index >= parent.items.length) {
        break;
      }
      final item = parent.items[step.index];
      if (item.subItems.isEmpty) {
        break;
      }
      final fromWidth = math.max(step.cardWidth, parent.minWidth);
      final minWidth = fromWidth * _levelWidthScale;
      levels.add(
        _MenuLevel(
          items: item.subItems,
          owner: item,
          top: math.max(0, step.itemTop - _cardInset),
          fromWidth: fromWidth,
          minWidth: minWidth,
          maxWidth: math.max(minWidth, widget.maxWidth),
        ),
      );
    }
    return levels;
  }

  void _push(BuildContext itemContext, int index) {
    final itemBox = itemContext.findRenderObject() as RenderBox?;
    final stackBox = context.findRenderObject() as RenderBox?;
    final placed =
        itemBox != null &&
        stackBox != null &&
        itemBox.hasSize &&
        stackBox.hasSize;
    _folding = false;
    setState(() {
      _path.add(
        _MenuStep(
          index: index,
          itemTop: placed
              ? itemBox.localToGlobal(Offset.zero, ancestor: stackBox).dy
              : 0,
          cardWidth: placed
              ? itemBox.size.width + 2 * _cardInset
              : widget.minWidth,
        ),
      );
    });
    _controller.forward(from: 0);
  }

  void _pop() {
    if (_path.isEmpty || _folding) {
      return;
    }
    _folding = true;
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
      arrow = GlyphIcon(
        AppGlyphs.chevronForward,
        size: _submenuArrowSize,
        color: foregroundColor,
      );
      if (arrowTurns != null) {
        arrow = RotationTransition(turns: arrowTurns, child: arrow);
      }
    }
    final child = InkWell(
      customBorder: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(_itemRadius)),
      ),
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: item.danger ? colorScheme.error.opacity10 : null,
      child: Padding(
        padding: arrow != null ? _itemArrowPadding : _itemPadding,
        child: Row(
          children: [
            if (item.glyph case final glyph?) ...[
              GlyphIcon(glyph, size: _itemIconSize, color: foregroundColor),
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
    return Semantics(button: true, enabled: enabled, child: child);
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

  Widget _buildContent(
    BuildContext context,
    _MenuLevel level, {
    required bool active,
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
    final unfold = active ? _unfold : kAlwaysCompleteAnimation;
    final reveal = active ? _reveal : kAlwaysCompleteAnimation;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          context,
          item: owner,
          onTap: _pop,
          arrowTurns: unfold.drive(_arrowTween),
        ),
        SizeTransition(
          sizeFactor: unfold,
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: reveal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: _dividerHeight, thickness: 1),
                ...items,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevel(
    BuildContext context,
    _MenuLevel level, {
    required int depth,
    required double pivot,
  }) {
    final receding = depth > 0;
    final colorScheme = context.colorScheme;
    final shape = AppShape.all(_cardRadius);
    return IgnorePointer(
      ignoring: receding,
      child: ExcludeSemantics(
        excluding: receding,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _frame,
            builder: (context, child) {
              final frame = receding ? 1.0 : _frame.value;
              final distance = receding ? depth - 1 + _frame.value : 0.0;
              final scale = math.max(0.0, 1 - _levelScaleStep * distance);
              final elevation = receding
                  ? math.max(
                      _minElevation,
                      _activeElevation - distance * _levelElevationStep,
                    )
                  : _activeElevation * frame;
              return Transform(
                transform: Matrix4.diagonal3Values(scale, scale, 1),
                alignment: Alignment.topRight,
                origin: Offset(0, pivot),
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: ShapeDecoration(
                    color: colorScheme.scrim.withValues(
                      alpha: math.min(1.0, _levelScrimStep * distance),
                    ),
                    shape: shape,
                  ),
                  child: Material(
                    type: MaterialType.card,
                    animationDuration: Duration.zero,
                    elevation: elevation,
                    color: colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    shape: shape,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: lerpDouble(
                          level.fromWidth,
                          level.minWidth,
                          frame,
                        )!,
                        maxWidth: lerpDouble(
                          level.fromWidth,
                          level.maxWidth,
                          frame,
                        )!,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(_cardInset),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: IntrinsicWidth(
                  child: _buildContent(context, level, active: !receding),
                ),
              ),
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
              child: _buildLevel(
                context,
                levels[index],
                depth: topIndex - index,
                pivot: index < topIndex
                    ? _path[index].itemTop - levels[index].top
                    : 0,
              ),
            ),
        ],
      ),
    );
  }
}
