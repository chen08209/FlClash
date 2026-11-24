import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The rows of a group under its header, in one structure whether they are
/// unfolding, settled or folding, so that neither end of the motion builds
/// them again. While [motion] runs, the card behind them grows with it from
/// [reach] behind the header's rounded bottom corners to [unfoldingExtent],
/// the screen of rows the unfolding shows, and clips them.
class UnfoldSliver extends SingleChildRenderObjectWidget {
  const UnfoldSliver({
    super.key,
    required this.motion,
    required this.unfoldingExtent,
    required this.reach,
    required this.decoration,
    required Widget sliver,
  }) : super(child: sliver);

  final Animation<double> motion;
  final double unfoldingExtent;
  final double reach;
  final Decoration decoration;

  @override
  RenderUnfoldSliver createRenderObject(BuildContext context) =>
      RenderUnfoldSliver(
        motion: motion,
        unfoldingExtent: unfoldingExtent,
        reach: reach,
        decoration: decoration,
        configuration: createLocalImageConfiguration(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderUnfoldSliver renderObject,
  ) {
    renderObject
      ..motion = motion
      ..unfoldingExtent = unfoldingExtent
      ..reach = reach
      ..decoration = decoration
      ..configuration = createLocalImageConfiguration(context);
  }
}

class RenderUnfoldSliver extends RenderProxySliver {
  RenderUnfoldSliver({
    required Animation<double> motion,
    required double unfoldingExtent,
    required double reach,
    required Decoration decoration,
    required ImageConfiguration configuration,
  }) : _motion = motion,
       _unfoldingExtent = unfoldingExtent,
       _reach = reach,
       _decoration = decoration,
       _configuration = configuration;

  final _clipLayer = LayerHandle<ClipRectLayer>();
  BoxPainter? _painter;

  Animation<double> _motion;
  set motion(Animation<double> value) {
    if (value == _motion) {
      return;
    }
    if (attached) {
      _unlisten();
    }
    _motion = value;
    if (attached) {
      _listen();
    }
    markNeedsLayout();
  }

  double _unfoldingExtent;
  set unfoldingExtent(double value) {
    if (value == _unfoldingExtent) {
      return;
    }
    _unfoldingExtent = value;
    markNeedsLayout();
  }

  double _reach;
  set reach(double value) {
    if (value == _reach) {
      return;
    }
    _reach = value;
    markNeedsPaint();
  }

  Decoration _decoration;
  set decoration(Decoration value) {
    if (value == _decoration) {
      return;
    }
    _decoration = value;
    _painter?.dispose();
    _painter = null;
    markNeedsPaint();
  }

  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    if (value == _configuration) {
      return;
    }
    _configuration = value;
    markNeedsPaint();
  }

  double get _shown => _unfoldingExtent * max(_motion.value, 0.0);

  double get _hidden => _motion.isCompleted ? 0 : _unfoldingExtent - _shown;

  void _listen() {
    _motion
      ..addListener(markNeedsLayout)
      ..addStatusListener(_handleStatus);
  }

  void _unlisten() {
    _motion
      ..removeListener(markNeedsLayout)
      ..removeStatusListener(_handleStatus);
  }

  void _handleStatus(AnimationStatus _) => markNeedsLayout();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _listen();
  }

  @override
  void detach() {
    _unlisten();
    super.detach();
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    _painter?.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final constraints = this.constraints;
    (child.parentData! as SliverPhysicalParentData).paintOffset = Offset(
      0,
      -_hidden,
    );
    if (_motion.isCompleted) {
      child.layout(constraints, parentUsesSize: true);
      geometry = child.geometry;
      return;
    }
    // The block stands above its place while it moves, so the rows it shows
    // are laid out even where the viewport ends before their place.
    final needed = max(0.0, _unfoldingExtent - constraints.scrollOffset);
    child.layout(
      constraints.copyWith(
        remainingPaintExtent: max(constraints.remainingPaintExtent, needed),
        remainingCacheExtent: max(
          constraints.remainingCacheExtent,
          needed - constraints.cacheOrigin,
        ),
      ),
      parentUsesSize: true,
    );
    final shown = _shown;
    final paintExtent = calculatePaintOffset(constraints, from: 0, to: shown);
    geometry = SliverGeometry(
      scrollExtent: shown,
      paintExtent: paintExtent,
      maxPaintExtent: shown,
      cacheExtent: calculateCacheOffset(constraints, from: 0, to: shown),
      hasVisualOverflow: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null || !geometry!.visible) {
      return;
    }
    final painter = _painter ??= _decoration.createBoxPainter(markNeedsPaint);
    final top = offset.translate(0, -constraints.scrollOffset);
    final width = constraints.crossAxisExtent;
    if (_motion.isCompleted) {
      _clipLayer.layer = null;
      painter.paint(
        context.canvas,
        top,
        _configuration.copyWith(size: Size(width, geometry!.scrollExtent)),
      );
      context.paintChild(child, offset);
      return;
    }
    final shown = _shown;
    painter.paint(
      context.canvas,
      top.translate(0, -_reach),
      _configuration.copyWith(size: Size(width, shown + _reach)),
    );
    _clipLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Rect.fromLTWH(0, -constraints.scrollOffset, width, shown),
      (context, offset) =>
          context.paintChild(child, offset.translate(0, -_hidden)),
      oldLayer: _clipLayer.layer,
    );
  }

  @override
  double childMainAxisPosition(RenderSliver child) => -_hidden;

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (!_motion.isCompleted &&
        mainAxisPosition + constraints.scrollOffset >= _shown) {
      return false;
    }
    final child = this.child;
    return child != null &&
        child.geometry!.hitTestExtent > 0 &&
        child.hitTest(
          result,
          mainAxisPosition: mainAxisPosition + _hidden,
          crossAxisPosition: crossAxisPosition,
        );
  }
}

/// One card of a group, built once [motion] passes [buildAfter], the share of
/// the unfolding at which its row shows.
class UnfoldRow extends StatefulWidget {
  const UnfoldRow({
    super.key,
    required this.motion,
    required this.buildAfter,
    required this.builder,
  });

  final Animation<double> motion;
  final double buildAfter;
  final WidgetBuilder builder;

  @override
  State<UnfoldRow> createState() => _UnfoldRowState();
}

class _UnfoldRowState extends State<UnfoldRow> {
  late bool _built = _due;

  bool get _due => widget.motion.value > widget.buildAfter;

  @override
  void initState() {
    super.initState();
    widget.motion.addListener(_handleMotion);
  }

  @override
  void didUpdateWidget(UnfoldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.motion != oldWidget.motion) {
      oldWidget.motion.removeListener(_handleMotion);
      widget.motion.addListener(_handleMotion);
    }
    _built = _built || _due;
  }

  @override
  void dispose() {
    widget.motion.removeListener(_handleMotion);
    super.dispose();
  }

  void _handleMotion() {
    if (!_built && _due) {
      setState(() => _built = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _built ? widget.builder(context) : const SizedBox.shrink();
  }
}
