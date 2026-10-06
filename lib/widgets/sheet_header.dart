import 'dart:ui' show ImageFilter;

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'inherited.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  static const height = _topPadding + _thickness;

  static const _topPadding = 6.0;
  static const _thickness = 4.0;
  static const _width = 28.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _topPadding),
      child: Container(
        alignment: Alignment.center,
        height: _thickness,
        width: _width,
        decoration: ShapeDecoration(
          color: context.colorScheme.onSurfaceVariant,
          shape: AppShape.all(_thickness / 2),
        ),
      ),
    );
  }
}

/// A drag handle over [appBar], together exactly [sheetAppBarHeight] tall.
class SheetToolBar extends StatelessWidget {
  const SheetToolBar({super.key, required this.appBar});

  static const _trailing =
      sheetAppBarHeight - SheetDragHandle.height - sheetToolbarHeight;

  final Widget appBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetDragHandle(),
        appBar,
        const SizedBox(height: _trailing),
      ],
    );
  }
}

/// Fades the surface behind [child] toward its foot so content reads through,
/// easing out over [overhang] past the foot so the fade shows no edge; with
/// [blur], blurs what scrolls under [child] instead.
class FloatingHeader extends StatelessWidget {
  const FloatingHeader({
    super.key,
    required this.backgroundColor,
    this.fadeStart = 0.5,
    this.overhang = 0,
    this.blur = false,
    required this.child,
  });

  static const _alpha = 0.9;
  static const _fadeSteps = 8;

  final Color backgroundColor;
  final double fadeStart;
  final double overhang;
  final bool blur;
  final Widget child;

  Gradient _scrimOf(double height) {
    final start = (height - overhang) * fadeStart / height;
    final stops = <double>[0];
    final colors = <Color>[backgroundColor.withValues(alpha: _alpha)];
    for (var i = 0; i <= _fadeSteps; i++) {
      final t = i / _fadeSteps;
      stops.add(start + (1 - start) * t);
      colors.add(
        backgroundColor.withValues(
          alpha: _alpha * (1 - Curves.easeInOut.transform(t)),
        ),
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: stops,
      colors: colors,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (blur) {
      return Stack(
        children: [
          Positioned.fill(child: _BarBlur(color: backgroundColor)),
          child,
        ],
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -overhang,
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (_, constraints) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _scrimOf(constraints.maxHeight),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Miuix's bar blur: 25dp of blur, sigma 0.45 of it, under the surface at 87%.
class _BarBlur extends StatelessWidget {
  const _BarBlur({required this.color});

  static const _sigma = 11.25;
  static const _tint = 0.87;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
        child: ColoredBox(color: color.withValues(alpha: _tint)),
      ),
    );
  }
}

final _smallTitleShowSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 438.6,
  ratio: 1,
);
final _smallTitleHideSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 1754.6,
  ratio: 1,
);

/// Miuix's large title bar: [title] stands large below [barBuilder]'s row
/// and rises into it as [collapse] runs to 1, gone by a third of the way,
/// where the row's own small title springs in.
class LargeTitleHeader extends StatefulWidget {
  const LargeTitleHeader({
    super.key,
    required this.collapse,
    required this.backgroundColor,
    required this.blur,
    required this.title,
    required this.barBuilder,
    this.bottom,
  });

  static const barHeight = 52.0;
  static const _titleGap = 4.0;
  static const _titleInset = 26.0;
  static const _titleSize = 32.0;
  static const _titleLineHeight = 1.25;
  static const _smallTitleSize = 20.0;
  static const _smallTitleDropPixels = 20.0;

  final ValueListenable<double> collapse;
  final Color backgroundColor;
  final bool blur;
  final Widget title;
  final Widget Function(Widget smallTitle) barBuilder;
  final Widget? bottom;

  /// How far the large title reaches below the row, the distance the page
  /// scrolls to collapse it.
  static double titleExtentOf(BuildContext context) =>
      _titleExtentFor(MediaQuery.textScalerOf(context));

  static double expandedHeightOf(BuildContext context) =>
      expandedHeightFor(MediaQuery.textScalerOf(context));

  static double expandedHeightFor(TextScaler textScaler) =>
      barHeight + _titleExtentFor(textScaler) + _titleGap;

  static double _titleExtentFor(TextScaler textScaler) =>
      textScaler.scale(_titleSize) * _titleLineHeight;

  @override
  State<LargeTitleHeader> createState() => _LargeTitleHeaderState();
}

class _LargeTitleHeaderState extends State<LargeTitleHeader>
    with SingleTickerProviderStateMixin {
  late bool _showsSmallTitle;
  late final AnimationController _smallTitle;

  bool get _collapsedPastTitle => widget.collapse.value * 3 >= 1;

  @override
  void initState() {
    super.initState();
    _showsSmallTitle = _collapsedPastTitle;
    _smallTitle = AnimationController(
      vsync: this,
      value: _showsSmallTitle ? 1 : 0,
    );
    widget.collapse.addListener(_handleCollapse);
  }

  @override
  void didUpdateWidget(LargeTitleHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapse != widget.collapse) {
      oldWidget.collapse.removeListener(_handleCollapse);
      widget.collapse.addListener(_handleCollapse);
      _handleCollapse();
    }
  }

  @override
  void dispose() {
    widget.collapse.removeListener(_handleCollapse);
    _smallTitle.dispose();
    super.dispose();
  }

  void _handleCollapse() {
    final shows = _collapsedPastTitle;
    if (shows == _showsSmallTitle) {
      return;
    }
    _showsSmallTitle = shows;
    final target = shows ? 1.0 : 0.0;
    if (context.disableAnimations) {
      _smallTitle.value = target;
      return;
    }
    _smallTitle.animateWith(
      SpringSimulation(
        shows ? _smallTitleShowSpring : _smallTitleHideSpring,
        _smallTitle.value,
        target,
        _smallTitle.velocity,
        snapToEnd: true,
      ),
    );
  }

  Widget _buildSmallTitle() {
    return AnimatedBuilder(
      animation: _smallTitle,
      builder: (context, child) {
        final shown = _smallTitle.value;
        final drop =
            LargeTitleHeader._smallTitleDropPixels /
            MediaQuery.devicePixelRatioOf(context);
        return Opacity(
          opacity: shown,
          alwaysIncludeSemantics: true,
          child: Transform.translate(
            offset: Offset(0, (1 - shown) * drop),
            child: child,
          ),
        );
      },
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: LargeTitleHeader._smallTitleSize,
          fontWeight: FontWeight.w500,
        ),
        child: widget.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final extent = LargeTitleHeader.titleExtentOf(context);
    final background = widget.blur
        ? _BarBlur(color: widget.backgroundColor)
        : ColoredBox(color: widget.backgroundColor);
    final largeTitle = ExcludeSemantics(
      child: DefaultTextStyle(
        style: context.textTheme.headlineLarge!.copyWith(
          fontSize: LargeTitleHeader._titleSize,
          height: LargeTitleHeader._titleLineHeight,
          fontWeight: FontWeight.w400,
          color: context.colorScheme.onSurface,
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: widget.title,
      ),
    );
    final bar = widget.barBuilder(_buildSmallTitle());
    return ValueListenableBuilder<double>(
      valueListenable: widget.collapse,
      builder: (_, collapse, _) {
        final rise = extent * collapse;
        final rowBottom = top + LargeTitleHeader.barHeight;
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: rowBottom + extent - rise + LargeTitleHeader._titleGap,
              child: AbsorbPointer(
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned.fill(child: background),
                      Positioned(
                        top: rowBottom - rise,
                        left: LargeTitleHeader._titleInset,
                        right: LargeTitleHeader._titleInset,
                        child: Opacity(
                          opacity: 1 - (collapse * 3).clamp(0.0, 1.0),
                          child: largeTitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: rowBottom,
              child: bar,
            ),
            if (widget.bottom case final bottom?)
              Positioned(left: 0, right: 0, bottom: rise, child: bottom),
          ],
        );
      },
    );
  }
}

/// Floats [header] over [body], fading it out so content reads through it
/// as it scrolls past; [footer] sits on its own surface.
class FloatingHeaderBody extends StatelessWidget {
  const FloatingHeaderBody({
    super.key,
    required this.backgroundColor,
    required this.header,
    required this.body,
    this.footer,
  });

  final Color backgroundColor;
  final Widget header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: const ShowBarScrollBehavior(
            scrollbarPadding: EdgeInsets.only(top: sheetAppBarHeight),
          ),
          child: body,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FloatingHeader(
            backgroundColor: backgroundColor,
            child: header,
          ),
        ),
        if (footer != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SheetOverhangLift(
              child: Material(type: MaterialType.transparency, child: footer),
            ),
          ),
      ],
    );
  }
}

/// Holds its child clear of the part of the sheet that hangs below the screen
/// while the sheet is dragged below its shortest detent.
class SheetOverhangLift extends SingleChildRenderObjectWidget {
  const SheetOverhangLift({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSheetOverhangLift(overhang: SheetOverhangScope.of(context));
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderSheetOverhangLift).overhang = SheetOverhangScope.of(
      context,
    );
  }
}

class _RenderSheetOverhangLift extends RenderTransform {
  _RenderSheetOverhangLift({required ValueListenable<double>? overhang})
    : _overhang = overhang,
      super(transform: Matrix4.identity(), transformHitTests: true) {
    _overhang?.addListener(_syncTransform);
  }

  ValueListenable<double>? _overhang;

  set overhang(ValueListenable<double>? value) {
    if (_overhang == value) {
      return;
    }
    _overhang?.removeListener(_syncTransform);
    _overhang = value;
    _overhang?.addListener(_syncTransform);
    _syncTransform();
  }

  @override
  void performLayout() {
    super.performLayout();
    _syncTransform();
  }

  @override
  void dispose() {
    _overhang?.removeListener(_syncTransform);
    super.dispose();
  }

  void _syncTransform() {
    transform = Matrix4.translationValues(0, -(_overhang?.value ?? 0), 0);
  }
}
