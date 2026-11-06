import 'dart:math' as math;
import 'dart:ui' show clampDouble, lerpDouble;

import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';
import 'package:prism_ui/shapes/shapes.dart';

const double _barHeight = 62;
const double _toolbarPadding = 6;
const double _itemGap = 4;
const double _horizontalMargin = 16;
const double _bottomMargin = 28;
const double _safeAreaClearance = 8;
const double _shadowRoom = 8;
const double _fabGap = 8;
const double _itemMinWidth = 48;
const double _selectedPadding = 16;
const double _iconSize = 22;
const double _labelGap = 6;
const _stateDuration = Duration(milliseconds: 150);
const _motionProbe = Duration(milliseconds: 1);
const _springTolerance = Tolerance(distance: 1e-3, velocity: 1e-2);

final _pillExpandSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 520,
  ratio: 0.78,
);
final _pillCollapseSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 620,
  ratio: 0.96,
);
final _fabShowSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 420,
  ratio: 0.76,
);
final _fabHideSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 560,
  ratio: 0.96,
);
final _morphStartSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 380,
  ratio: 0.72,
);
final _morphStopSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 480,
  ratio: 0.92,
);

final _startMorph = Morph(MaterialShapes.circle, MaterialShapes.cookie9Sided);

Path _morphPath(double progress) => _startMorph.toPath(progress: progress);

double _morphTurn(double progress) => progress * 2 * math.pi / 9;

void _springTo(
  BuildContext context,
  AnimationController controller, {
  required double target,
  required SpringDescription spring,
}) {
  if (context.motionDuration(_motionProbe) == Duration.zero) {
    controller.value = target;
    return;
  }
  if (controller.value == target && controller.velocity == 0) {
    return;
  }
  controller.animateWith(
    SpringSimulation(
      spring,
      controller.value,
      target,
      controller.velocity,
      tolerance: _springTolerance,
      snapToEnd: true,
    ),
  );
}

double _measureLabelWidth(
  String label,
  TextStyle style,
  TextScaler textScaler,
  TextDirection textDirection,
) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textScaler: textScaler,
    textDirection: textDirection,
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

class ExpressiveNavigationAction {
  const ExpressiveNavigationAction({
    required this.visible,
    required this.enabled,
    required this.running,
    required this.suspended,
    required this.label,
    required this.onPressed,
  });

  final bool visible;
  final bool enabled;
  final bool running;
  final bool suspended;
  final String label;
  final VoidCallback onPressed;
}

typedef ExpressiveToolbarColors = ({
  Color container,
  Color indicator,
  Color selectedForeground,
  Color unselectedForeground,
});

typedef ExpressiveFabColors = ({
  Color container,
  Color foreground,
  Color shadow,
});

class ExpressiveNavigationBar extends StatelessWidget {
  const ExpressiveNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.vibrant = false,
    this.action,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool vibrant;
  final ExpressiveNavigationAction? action;

  static ExpressiveToolbarColors colorsOf(
    ColorScheme colorScheme, {
    bool vibrant = false,
  }) {
    if (vibrant) {
      return (
        container: colorScheme.primaryContainer,
        indicator: colorScheme.primary,
        selectedForeground: colorScheme.onPrimary,
        unselectedForeground: colorScheme.onPrimaryContainer,
      );
    }
    final monochrome =
        colorScheme.primary == Colors.black ||
        colorScheme.primary == Colors.white;
    return (
      container: colorScheme.surfaceContainerHigh,
      indicator: monochrome
          ? colorScheme.secondaryContainer
          : colorScheme.primaryContainer,
      selectedForeground: monochrome
          ? colorScheme.onSecondaryContainer
          : colorScheme.onPrimaryContainer,
      unselectedForeground: colorScheme.onSurfaceVariant,
    );
  }

  static ExpressiveFabColors fabColorsOf(
    ColorScheme colorScheme, {
    required bool vibrant,
    required bool enabled,
  }) {
    if (!enabled) {
      return (
        container: colorScheme.surfaceContainerHigh,
        foreground: colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
        shadow: colorScheme.shadow.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.24 : 0.08,
        ),
      );
    }
    if (vibrant) {
      return (
        container: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
        shadow: colorScheme.tertiary.withValues(alpha: 0.28),
      );
    }
    return (
      container: colorScheme.primary,
      foreground: colorScheme.onPrimary,
      shadow: colorScheme.primary.withValues(alpha: 0.3),
    );
  }

  static double heightOf(BuildContext context) {
    final base = AppTextStyle.footnote.size;
    final growth = math.max(
      0.0,
      MediaQuery.textScalerOf(context).scale(base) - base,
    );
    return _barHeight + growth;
  }

  static double _bottomMarginOf(BuildContext context) => math.max(
    _bottomMargin,
    MediaQuery.paddingOf(context).bottom + _safeAreaClearance,
  );

  static double insetOf(BuildContext context) =>
      heightOf(context) + _bottomMarginOf(context);

  @override
  Widget build(BuildContext context) {
    final height = heightOf(context);
    final bottom = _bottomMarginOf(context);
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalMargin,
        _shadowRoom,
        _horizontalMargin,
        bottom,
      ),
      child: _PresenceVisibility(
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: _ExpressiveToolbar(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  vibrant: vibrant,
                  onSelected: onSelected,
                ),
              ),
              _AnimatedFabSlot(
                action: action,
                dimension: height,
                vibrant: vibrant,
              ),
            ],
          ),
        ),
      ),
    );
    return SizedBox(
      width: double.infinity,
      height: _shadowRoom + height + bottom,
      child: RepaintBoundary(child: LayoutBuilder(builder: (_, _) => content)),
    );
  }
}

class _PresenceVisibility extends StatelessWidget {
  const _PresenceVisibility({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final filled = BarItemPresence.filledOf(context);
    if (filled == null) {
      return child;
    }
    return ValueListenableBuilder(
      valueListenable: filled,
      builder: (_, visible, child) => Visibility(
        visible: visible,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: child!,
      ),
      child: child,
    );
  }
}

class _ExpressiveToolbar extends StatefulWidget {
  const _ExpressiveToolbar({
    required this.destinations,
    required this.selectedIndex,
    required this.vibrant,
    required this.onSelected,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final bool vibrant;
  final ValueChanged<int> onSelected;

  @override
  State<_ExpressiveToolbar> createState() => _ExpressiveToolbarState();
}

class _ExpressiveToolbarState extends State<_ExpressiveToolbar>
    with TickerProviderStateMixin {
  late List<AnimationController> _weights;
  late Listenable _animation;
  late int _targetIndex;
  List<String> _measuredLabels = const [];
  TextStyle? _measuredStyle;
  TextScaler? _measuredScaler;
  TextDirection? _measuredDirection;
  List<double> _labelWidths = const [];

  static int _clampIndex(int index, int length) =>
      length == 0 ? 0 : index.clamp(0, length - 1);

  List<AnimationController> _buildWeights(int count, int active) {
    return [
      for (var i = 0; i < count; i++)
        AnimationController.unbounded(vsync: this, value: i == active ? 1 : 0),
    ];
  }

  void _disposeWeights() {
    for (final controller in _weights) {
      controller.dispose();
    }
  }

  List<double> _resolveLabelWidths(BuildContext context, TextStyle style) {
    final labels = [for (final item in widget.destinations) item.label];
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    if (listEquals(labels, _measuredLabels) &&
        style == _measuredStyle &&
        scaler == _measuredScaler &&
        direction == _measuredDirection) {
      return _labelWidths;
    }
    _measuredLabels = labels;
    _measuredStyle = style;
    _measuredScaler = scaler;
    _measuredDirection = direction;
    return _labelWidths = [
      for (final label in labels)
        _measureLabelWidth(label, style, scaler, direction),
    ];
  }

  @override
  void initState() {
    super.initState();
    final count = widget.destinations.length;
    _targetIndex = _clampIndex(widget.selectedIndex, count);
    _weights = _buildWeights(count, _targetIndex);
    _animation = Listenable.merge(_weights);
  }

  @override
  void didUpdateWidget(covariant _ExpressiveToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final count = widget.destinations.length;
    final next = _clampIndex(widget.selectedIndex, count);
    if (oldWidget.destinations.length != count) {
      _disposeWeights();
      _targetIndex = next;
      _weights = _buildWeights(count, next);
      _animation = Listenable.merge(_weights);
      return;
    }
    if (next != _targetIndex) {
      _targetIndex = next;
      for (var i = 0; i < count; i++) {
        final active = i == next;
        _springTo(
          context,
          _weights[i],
          target: active ? 1 : 0,
          spring: active ? _pillExpandSpring : _pillCollapseSpring,
        );
      }
    }
  }

  @override
  void dispose() {
    _disposeWeights();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.destinations.length;
    if (count == 0) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;
    final colors = ExpressiveNavigationBar.colorsOf(
      colorScheme,
      vibrant: widget.vibrant,
    );
    final labelStyle = AppTextStyle.footnote.of(context, emphasized: true);
    final labelWidths = _resolveLabelWidths(
      context,
      labelStyle,
    ).map((width) => width.ceilToDouble()).toList(growable: false);
    final items = [
      for (var i = 0; i < count; i++)
        _ToolbarItem(
          destination: widget.destinations[i],
          selected: i == _targetIndex,
          weight: _weights[i],
          labelWidth: labelWidths[i],
          labelStyle: labelStyle,
          colors: colors,
          onTap: () => widget.onSelected(i),
        ),
    ];
    final gapSpan = (count - 1) * _itemGap;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.container,
        shape: AppShape.full,
        shadows: dockShadows(colorScheme),
      ),
      child: SurfaceScope(
        level: SurfaceLevel.block,
        child: Padding(
          padding: const EdgeInsets.all(_toolbarPadding),
          child: LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final naturalWidths = <double>[
                  for (var i = 0; i < count; i++)
                    lerpDouble(
                      _itemMinWidth,
                      math.max(
                        _itemMinWidth,
                        _selectedPadding * 2 +
                            _iconSize +
                            _labelGap +
                            labelWidths[i],
                      ),
                      math.max(0.0, _weights[i].value),
                    )!,
                ];
                final totalNatural = naturalWidths.fold(
                  0.0,
                  (sum, width) => sum + width,
                );
                final available = math.max(0.0, constraints.maxWidth - gapSpan);
                final scale =
                    constraints.maxWidth.isFinite &&
                        totalNatural > available &&
                        totalNatural > 0
                    ? available / totalNatural
                    : 1.0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _itemGap,
                  children: [
                    for (var i = 0; i < count; i++)
                      SizedBox(
                        width: naturalWidths[i] * scale,
                        child: items[i],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  const _ToolbarItem({
    required this.destination,
    required this.selected,
    required this.weight,
    required this.labelWidth,
    required this.labelStyle,
    required this.colors,
    required this.onTap,
  });

  final NavigationDockDestination destination;
  final bool selected;
  final Animation<double> weight;
  final double labelWidth;
  final TextStyle labelStyle;
  final ExpressiveToolbarColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelSlotWidth = _labelGap + labelWidth;
    final icon = AnimatedGlyph(glyph: destination.glyph, filled: selected);
    final label = Padding(
      padding: const EdgeInsetsDirectional.only(start: _labelGap),
      child: Text(
        destination.label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
      ),
    );
    return Tooltip(
      message: destination.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        excludeSemantics: true,
        child: PressSurface(
          fill: selected
              ? colors.indicator
              : colors.indicator.withValues(alpha: 0),
          shape: AppShape.full,
          foreground: selected
              ? colors.selectedForeground
              : colors.unselectedForeground,
          iconSize: _iconSize,
          textStyle: labelStyle,
          selected: selected,
          childFills: true,
          clipsChild: true,
          onPressed: onTap,
          child: AnimatedBuilder(
            animation: weight,
            builder: (context, _) {
              final clamped = clampDouble(weight.value, 0, 1);
              final labelOpacity = clampDouble((clamped - 0.12) / 0.68, 0, 1);
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: lerpDouble(0, _selectedPadding, clamped)!,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    if (clamped > 0.005)
                      Flexible(
                        child: ConstraintsTransformBox(
                          alignment: AlignmentDirectional.centerStart,
                          clipBehavior: Clip.hardEdge,
                          constraintsTransform:
                              ConstraintsTransformBox.maxWidthUnconstrained,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: clamped,
                            heightFactor: 1,
                            child: SizedBox(
                              width: labelSlotWidth,
                              child: Opacity(
                                opacity: labelOpacity,
                                child: label,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedFabSlot extends StatefulWidget {
  const _AnimatedFabSlot({
    required this.action,
    required this.dimension,
    required this.vibrant,
  });

  final ExpressiveNavigationAction? action;
  final double dimension;
  final bool vibrant;

  @override
  State<_AnimatedFabSlot> createState() => _AnimatedFabSlotState();
}

class _AnimatedFabSlotState extends State<_AnimatedFabSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: (widget.action?.visible ?? false) ? 1 : 0,
  );
  ExpressiveNavigationAction? _lastAction;

  @override
  void initState() {
    super.initState();
    _lastAction = widget.action;
  }

  @override
  void didUpdateWidget(covariant _AnimatedFabSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.action != null) {
      _lastAction = widget.action;
    }
    final wasVisible = oldWidget.action?.visible ?? false;
    final isVisible = widget.action?.visible ?? false;
    if (wasVisible != isVisible) {
      _springTo(
        context,
        _controller,
        target: isVisible ? 1 : 0,
        spring: isVisible ? _fabShowSpring : _fabHideSpring,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final action = widget.action ?? _lastAction;
        final visible = widget.action?.visible ?? false;
        final raw = _controller.value;
        if (action == null ||
            (!visible && !_controller.isAnimating && raw <= 0)) {
          return const SizedBox.shrink();
        }
        final clamped = clampDouble(raw, 0, 1);
        final slotWidth = math.max(0.0, (_fabGap + widget.dimension) * raw);
        return ExcludeSemantics(
          excluding: !visible,
          child: IgnorePointer(
            ignoring: !visible,
            child: SizedBox(
              width: slotWidth,
              height: widget.dimension,
              child: OverflowBox(
                alignment: AlignmentDirectional.centerEnd,
                minWidth: widget.dimension,
                maxWidth: widget.dimension,
                minHeight: widget.dimension,
                maxHeight: widget.dimension,
                child: Opacity(
                  opacity: clamped,
                  child: Transform.scale(
                    scale: math.max(0.0, raw),
                    child: ExpressiveNavigationFab(
                      dimension: widget.dimension,
                      enabled: action.enabled,
                      running: action.running,
                      suspended: action.suspended,
                      vibrant: widget.vibrant,
                      label: action.label,
                      onPressed: action.onPressed,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ExpressiveNavigationFab extends StatefulWidget {
  const ExpressiveNavigationFab({
    super.key,
    required this.dimension,
    required this.enabled,
    required this.running,
    required this.suspended,
    required this.label,
    required this.onPressed,
    this.vibrant = false,
  });

  final double dimension;
  final bool enabled;
  final bool running;
  final bool suspended;
  final String label;
  final VoidCallback onPressed;
  final bool vibrant;

  @override
  State<ExpressiveNavigationFab> createState() =>
      _ExpressiveNavigationFabState();
}

class _ExpressiveNavigationFabState extends State<ExpressiveNavigationFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.running ? 1 : 0,
  );
  var _hovered = false;
  var _focused = false;

  double get _overlay => !widget.enabled
      ? 0
      : _focused
      ? 0.1
      : _hovered
      ? 0.08
      : 0;

  @override
  void didUpdateWidget(covariant ExpressiveNavigationFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.running != widget.running) {
      _springTo(
        context,
        _controller,
        target: widget.running ? 1 : 0,
        spring: widget.running ? _morphStartSpring : _morphStopSpring,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final enabled = widget.enabled;
    final colors = ExpressiveNavigationBar.fabColorsOf(
      colorScheme,
      vibrant: widget.vibrant,
      enabled: enabled,
    );
    final fill = colors.container;
    final ink = colors.foreground;
    final shadow = colors.shadow;
    final stateDuration = context.motionDuration(_stateDuration);
    final iconSize = widget.dimension * 0.36;
    return Tooltip(
      message: widget.label,
      child: Semantics(
        button: true,
        enabled: enabled,
        toggled: widget.running,
        label: widget.label,
        child: PressRegion(
          onTap: enabled ? widget.onPressed : null,
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          child: ElasticPress(
            enabled: enabled,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _overlay),
              duration: stateDuration,
              builder: (_, overlay, _) => AnimatedBuilder(
                animation: _controller,
                builder: (_, _) {
                  final progress = _controller.value;
                  final color = Color.alphaBlend(
                    ink.withValues(alpha: overlay),
                    fill,
                  );
                  return CustomPaint(
                    painter: _FabMorphPainter(
                      progress: progress,
                      color: color,
                      shadow: shadow,
                      ring: _focused
                          ? focusRingSide(colorScheme, standsOff: true)
                          : null,
                    ),
                    child: SizedBox.square(
                      dimension: widget.dimension,
                      child: Center(
                        child: GlyphIcon(
                          widget.suspended
                              ? AppGlyphs.wifiOff
                              : AppGlyphs.playPause(progress),
                          size: iconSize,
                          color: ink,
                          fill: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FabMorphPainter extends CustomPainter {
  const _FabMorphPainter({
    required this.progress,
    required this.color,
    required this.shadow,
    required this.ring,
  });

  static const _shadowOffset = Offset(0, 6);
  static const _shadowBlur = 14.0;

  final double progress;
  final Color color;
  final Color shadow;
  final BorderSide? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _morphPath(progress);
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_morphTurn(progress))
      ..scale(size.width, size.height)
      ..translate(-0.5, -0.5);
    if (shadow.a > 0) {
      canvas
        ..save()
        ..translate(
          _shadowOffset.dx / size.width,
          _shadowOffset.dy / size.height,
        )
        ..drawPath(
          path,
          Paint()
            ..color = shadow
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              _shadowBlur / 2 / size.width,
            ),
        )
        ..restore();
    }
    canvas.drawPath(path, Paint()..color = color);
    if (ring case final ring?) {
      final scale = 1 + ring.width * ring.strokeAlign / size.width;
      canvas
        ..save()
        ..translate(0.5, 0.5)
        ..scale(scale)
        ..translate(-0.5, -0.5)
        ..drawPath(
          path,
          ring.toPaint()..strokeWidth = ring.width / size.width / scale,
        )
        ..restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FabMorphPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.shadow != shadow ||
      oldDelegate.ring != ring;
}
