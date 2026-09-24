import 'dart:math' as math;
import 'dart:ui' as ui show Image;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

typedef PopupAnchorResolver = Rect? Function();

typedef PopupOpen = void Function({Offset offset});

enum PopupPlacement { overAnchorEnd, belowPoint }

const _screenMargin = 16.0;

const _anchorOverlap = 8.0;

const _avoidGap = 8.0;

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

const _cardElevation = 12.0;

const _maxContentBlur = 8.0;

final _growSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 420),
    bounce: 0.28,
  ),
  seconds: 0.55,
);

final _moveYSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 280),
    bounce: 0.1,
  ),
  seconds: 0.55,
);

final _moveXSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 400),
    bounce: 0.15,
  ),
  seconds: 0.55,
);

class CommonPopupRoute<T> extends PopupRoute<T> {
  CommonPopupRoute({
    required this.builder,
    required this.anchorOf,
    required this.barrierLabel,
    this.placement = PopupPlacement.overAnchorEnd,
    this.anchorShift = Offset.zero,
    this.sourceColor = Colors.transparent,
    this.sourceImage,
    this.modal = true,
    this.avoid,
  }) : super(requestFocus: modal ? null : false);

  final WidgetBuilder builder;

  /// Resolves the rect of the control the popup grows out of.
  final PopupAnchorResolver anchorOf;
  final PopupPlacement placement;

  /// Moves where the popup is placed without moving where it grows from.
  final Offset anchorShift;

  /// The background of the source control, which the platter starts from.
  final Color sourceColor;

  /// A snapshot of the source control, drawn inside the platter while the
  /// control itself is hidden; null while it is still being taken.
  final ValueListenable<ui.Image?>? sourceImage;

  /// Off, focus stays on the page and touches outside pass through to it.
  final bool modal;

  /// A rect the popup keeps clear of when there is room above or below it.
  final Rect? avoid;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 550);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  late final CurvedAnimation _grow = CurvedAnimation(
    parent: animation!,
    curve: _growSpring,
    reverseCurve: Curves.easeInCubic,
  );

  late final CurvedAnimation _moveX = CurvedAnimation(
    parent: animation!,
    curve: _moveXSpring,
    reverseCurve: Curves.easeInOutCubic,
  );

  late final CurvedAnimation _moveY = CurvedAnimation(
    parent: animation!,
    curve: _moveYSpring,
    reverseCurve: Curves.easeOutCubic,
  );

  late final CurvedAnimation _content = CurvedAnimation(
    parent: animation!,
    curve: const Interval(0.08, 0.5, curve: Curves.easeOut),
    reverseCurve: const Interval(0.5, 1, curve: Curves.easeIn),
  );

  @override
  void dispose() {
    _grow.dispose();
    _moveX.dispose();
    _moveY.dispose();
    _content.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (isCurrent) {
      navigator?.pop();
    }
  }

  @override
  Widget buildModalBarrier() {
    return modal ? super.buildModalBarrier() : const SizedBox.shrink();
  }

  Widget _buildDismissLayer() {
    if (modal) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _handleDismiss,
      );
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleDismiss(),
      onPointerPanZoomStart: (_) => _handleDismiss(),
      onPointerSignal: (_) => _handleDismiss(),
    );
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
    final colorScheme = context.colorScheme;
    return Stack(
      children: [
        Positioned.fill(child: _buildDismissLayer()),
        _PopupAnchorTracker(
          anchorOf: anchorOf,
          builder: (anchor, safeInsets, child) => CustomSingleChildLayout(
            delegate: _PopupLayoutDelegate(
              anchor: anchor.shift(anchorShift),
              safeInsets: safeInsets,
              placement: placement,
              avoid: avoid,
            ),
            child: _PopupMorph(
              anchor: anchor,
              animation: animation,
              grow: _grow,
              moveX: _moveX,
              moveY: _moveY,
              content: _content,
              sourceColor: sourceColor,
              sourceImage: sourceImage,
              surfaceColor: colorScheme.surfaceContainer,
              shadowColor: colorScheme.shadow,
              child: child,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _PopupMorph extends SingleChildRenderObjectWidget {
  const _PopupMorph({
    required this.anchor,
    required this.animation,
    required this.grow,
    required this.moveX,
    required this.moveY,
    required this.content,
    required this.sourceColor,
    required this.sourceImage,
    required this.surfaceColor,
    required this.shadowColor,
    super.child,
  });

  final Rect anchor;
  final Animation<double> animation;
  final Animation<double> grow;
  final Animation<double> moveX;
  final Animation<double> moveY;
  final Animation<double> content;
  final Color sourceColor;
  final ValueListenable<ui.Image?>? sourceImage;
  final Color surfaceColor;
  final Color shadowColor;

  @override
  _RenderPopupMorph createRenderObject(BuildContext context) {
    return _RenderPopupMorph(
      anchor: anchor,
      animation: animation,
      grow: grow,
      moveX: moveX,
      moveY: moveY,
      content: content,
      sourceColor: sourceColor,
      sourceImage: sourceImage,
      surfaceColor: surfaceColor,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPopupMorph renderObject,
  ) {
    renderObject
      ..anchor = anchor
      ..animation = animation
      ..grow = grow
      ..moveX = moveX
      ..moveY = moveY
      ..content = content
      ..sourceColor = sourceColor
      ..sourceImage = sourceImage
      ..surfaceColor = surfaceColor
      ..shadowColor = shadowColor;
  }
}

/// Grows the popup out of its anchor the way iOS 26 menus leave their button:
/// a platter flies from the anchor's capsule to the card's center on an arc,
/// growing on its own spring, while the content rides inside it, scaling,
/// fading and sharpening in; closing shrinks it first and flies it back.
class _RenderPopupMorph extends RenderProxyBox {
  _RenderPopupMorph({
    required Rect anchor,
    required Animation<double> animation,
    required this.grow,
    required this.moveX,
    required this.moveY,
    required this.content,
    required Color sourceColor,
    required ValueListenable<ui.Image?>? sourceImage,
    required Color surfaceColor,
    required Color shadowColor,
  }) : _anchor = anchor,
       _animation = animation,
       _sourceColor = sourceColor,
       _sourceImage = sourceImage,
       _surfaceColor = surfaceColor,
       _shadowColor = shadowColor;

  Animation<double> grow;
  Animation<double> moveX;
  Animation<double> moveY;
  Animation<double> content;

  Rect _anchor;

  set anchor(Rect value) {
    if (value == _anchor) {
      return;
    }
    _anchor = value;
    markNeedsPaint();
  }

  Animation<double> _animation;

  set animation(Animation<double> value) {
    if (value == _animation) {
      return;
    }
    if (attached) {
      _animation.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _animation = value;
    markNeedsPaint();
  }

  Color _sourceColor;

  set sourceColor(Color value) {
    if (value == _sourceColor) {
      return;
    }
    _sourceColor = value;
    markNeedsPaint();
  }

  ValueListenable<ui.Image?>? _sourceImage;

  set sourceImage(ValueListenable<ui.Image?>? value) {
    if (value == _sourceImage) {
      return;
    }
    if (attached) {
      _sourceImage?.removeListener(markNeedsPaint);
      value?.addListener(markNeedsPaint);
    }
    _sourceImage = value;
    markNeedsPaint();
  }

  Color _surfaceColor;

  set surfaceColor(Color value) {
    if (value == _surfaceColor) {
      return;
    }
    _surfaceColor = value;
    markNeedsPaint();
  }

  Color _shadowColor;

  set shadowColor(Color value) {
    if (value == _shadowColor) {
      return;
    }
    _shadowColor = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
    _sourceImage?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    _sourceImage?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  bool get _closing => _animation.status == AnimationStatus.reverse;

  // While closing, the content still covers the platter until it fades, and
  // an open sub menu does not fill the platter's bounding shape.
  double get _fillOpacity =>
      _closing ? (2 * (1 - content.value)).clamp(0.0, 1.0) : 1.0;

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) {
      return;
    }
    if (_animation.isCompleted) {
      context.paintChild(child, offset);
      return;
    }
    // The anchor comes in the coordinates of the layout box that places this
    // one, so the placement offset turns it local.
    final placement = (parentData! as BoxParentData).offset;
    final from = _anchor.shift(-placement);
    final bounds = Offset.zero & size;
    final progress = grow.value;
    final extent = Size.lerp(from.size, bounds.size, progress)!;
    final rect = Rect.fromCenter(
      center: Offset(
        lerpDouble(from.center.dx, bounds.center.dx, moveX.value)!,
        lerpDouble(from.center.dy, bounds.center.dy, moveY.value)!,
      ),
      width: math.max(0.0, extent.width),
      height: math.max(0.0, extent.height),
    );
    final radius = lerpDouble(from.shortestSide / 2, _cardRadius, progress)!;
    final clip = AppShape.all(math.max(0.0, radius)).getOuterPath(rect);
    final sourceImage = _sourceImage;
    final image = sourceImage?.value;
    // The source control stays visible until its snapshot exists, so the
    // platter would only cover it.
    if (sourceImage != null && image == null && !_closing) {
      return;
    }
    final settled = progress.clamp(0.0, 1.0);
    final reveal = content.value;
    final path = clip.shift(offset);
    final canvas = context.canvas
      ..drawShadow(
        path,
        _shadowColor.withValues(alpha: _shadowColor.a * settled),
        _cardElevation * settled,
        false,
      );
    final fill = Color.lerp(_sourceColor, _surfaceColor, settled)!;
    canvas.drawPath(
      path,
      Paint()..color = fill.withValues(alpha: fill.a * _fillOpacity),
    );
    final glyph = 1 - reveal;
    if (image != null && glyph > 0) {
      final source = from.shift(rect.center - from.center + offset);
      canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        source,
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, glyph)
          ..filterQuality = FilterQuality.medium,
      );
    }
    if (reveal <= 0 || size.isEmpty) {
      return;
    }
    final scale = math.max(rect.width / size.width, rect.height / size.height);
    final transform =
        Matrix4.translationValues(rect.center.dx, rect.center.dy, 0)
          ..scaleByDouble(scale, scale, 1, 1)
          ..translateByDouble(-size.width / 2, -size.height / 2, 0, 1);
    final sigma = _maxContentBlur * (1 - reveal);
    context.pushClipPath(
      needsCompositing,
      offset,
      bounds,
      clip,
      (context, offset) => context.pushOpacity(
        offset,
        Color.getAlphaFromOpacity(reveal),
        (context, offset) => context.pushLayer(
          ImageFilterLayer(
            imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          ),
          (context, offset) => context.pushTransform(
            needsCompositing,
            offset,
            transform,
            (context, offset) => context.paintChild(child, offset),
          ),
          offset,
        ),
      ),
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
    this.avoid,
  });

  final Rect anchor;
  final EdgeInsets safeInsets;
  final PopupPlacement placement;
  final Rect? avoid;

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
      PopupPlacement.belowPoint => (
        anchor.left,
        _yBelowPoint(childSize.height, insets.top, maxY),
      ),
    };
    return Offset(
      x.clamp(insets.left, math.max(insets.left, maxX)),
      y.clamp(insets.top, math.max(insets.top, maxY)),
    );
  }

  double _yBelowPoint(double height, double minY, double maxY) {
    final avoid = this.avoid;
    if (avoid != null) {
      final above = avoid.top - _avoidGap - height;
      if (above >= minY) {
        return above;
      }
      final below = avoid.bottom + _avoidGap;
      if (below <= maxY) {
        return below;
      }
    }
    if (anchor.bottom > maxY && anchor.top - height >= minY) {
      return anchor.top - height;
    }
    return anchor.bottom;
  }

  @override
  bool shouldRelayout(_PopupLayoutDelegate oldDelegate) {
    return oldDelegate.anchor != anchor ||
        oldDelegate.safeInsets != safeInsets ||
        oldDelegate.placement != placement ||
        oldDelegate.avoid != avoid;
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
  final _sourceKey = GlobalKey();
  final _sourceHidden = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _sourceHidden.dispose();
    super.dispose();
  }

  Rect? _sourceRect() {
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
    return origin & renderBox.size;
  }

  Color _sourceColor() {
    Color? color;
    void visit(Element element) {
      if (color != null) {
        return;
      }
      if (element.widget case final Material material) {
        color = material.type == MaterialType.transparency
            ? Colors.transparent
            : material.color ?? Colors.transparent;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    final resolved = color;
    if (resolved == null || resolved.a == 0) {
      return context.colorScheme.surfaceContainer;
    }
    return resolved;
  }

  void _captureSource(
    CommonPopupRoute<void> route,
    ValueNotifier<ui.Image?> snapshot,
  ) {
    if (!mounted || !route.isActive) {
      return;
    }
    final boundary = _sourceKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || !boundary.hasSize) {
      return;
    }
    snapshot.value = boundary.toImageSync(
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    _sourceHidden.value = true;
  }

  void _open({Offset offset = Offset.zero}) {
    final snapshot = ValueNotifier<ui.Image?>(null);
    final route = CommonPopupRoute<void>(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (context) => widget.popupBuilder(context),
      anchorOf: _sourceRect,
      anchorShift: offset,
      sourceColor: _sourceColor(),
      sourceImage: snapshot,
    );
    Navigator.of(context).push(route);
    void reveal() {
      if (mounted) {
        _sourceHidden.value = false;
      }
    }

    route.animation!.addStatusListener((status) {
      if (status.isDismissed) {
        reveal();
      }
    });
    route.completed.whenComplete(() {
      reveal();
      snapshot.value?.dispose();
      snapshot.dispose();
    });
    // The control repaints its ink as it is tapped, so it can only be
    // captured once that frame has been painted.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _captureSource(route, snapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _sourceHidden,
      builder: (_, hidden, child) =>
          Opacity(opacity: hidden ? 0 : 1, child: child),
      child: RepaintBoundary(
        key: _sourceKey,
        child: widget.targetBuilder(_open),
      ),
    );
  }
}

class CommonPopupMenuItem {
  const CommonPopupMenuItem({
    required this.label,
    this.glyph,
    this.onPressed,
    this.danger = false,
    this.checked,
    this.subItems = const [],
  });

  final String label;
  final Glyph? glyph;
  final VoidCallback? onPressed;
  final bool danger;
  final bool? checked;
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
    } else if (item.checked == true) {
      arrow = GlyphIcon(
        AppGlyphs.check,
        size: _submenuArrowSize,
        color: foregroundColor,
      );
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
    return Semantics(
      button: true,
      enabled: enabled,
      checked: item.checked,
      child: child,
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
                      _cardElevation - distance * _levelElevationStep,
                    )
                  : _cardElevation * frame;
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
