import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const double _barHeight = 64;
const double _barPadding = 4;
const double _edgeMargin = 16;
const double _shadowRoom = 8;
const double _fabGap = 8;
const double _iconSize = 24;
const double _trailingIconSize = 28;
const double _labelGap = 2;
const double _labelInset = 2;
const double _minLabelSize = 10;
const double _pressGrowth = 1 / 8;
const double _lensGrowth = 14;
const double _lensMagnify = 0.12;
const double _jellySpeed = 8;
const double _jellyStretch = 0.25;
const double _overdrag = 0.35;
const double _pullLimit = 7 / 32;
const double _pullStretch = 0.5;
const _slotDuration = Duration(milliseconds: 350);
final _trackSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 120),
);
final _liftSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 280),
  bounce: 0.2,
);
final _settleSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 500),
  bounce: 0.32,
);

double _rubberBand(double overshoot, double limit) {
  final pull = 1 - 1 / (overshoot.abs() * 0.55 / limit + 1);
  return limit * pull * overshoot.sign;
}

/// A value that springs toward a target the finger may move every frame.
///
/// [AnimationController.animateWith] restarts its ticker, whose first frame
/// reads no elapsed time, so retargeting it on every pointer move holds the
/// value still for as long as the finger keeps moving.
class _Spring extends ChangeNotifier implements ValueListenable<double> {
  _Spring(TickerProvider vsync, this._value) {
    _ticker = vsync.createTicker(_tick);
  }

  late final Ticker _ticker;
  double _value;
  double _target = 0;
  SpringSimulation? _simulation;
  double _now = 0;
  double _start = 0;

  @override
  double get value => _value;

  double get target => _simulation == null ? _value : _target;

  double get velocity => _simulation?.dx(_now - _start) ?? 0;

  void springTo(double target, SpringDescription spring) {
    _simulation = SpringSimulation(spring, _value, target, velocity);
    _target = target;
    if (_ticker.isActive) {
      _start = _now;
      return;
    }
    _now = _start = 0;
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    _now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final simulation = _simulation!;
    final time = _now - _start;
    if (simulation.isDone(time)) {
      _value = _target;
      _simulation = null;
      _ticker.stop();
    } else {
      _value = simulation.x(time);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

// A soft, wide drop in the manner of iOS rather than a Material elevation.
List<BoxShadow> _dockShadows(ColorScheme colorScheme) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.08 * strength),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.04 * strength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

({double width, double height}) _measureLabel(
  BuildContext context,
  String label,
  TextStyle? style,
) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
    maxLines: 1,
  )..layout();
  final size = (width: painter.width, height: painter.height);
  painter.dispose();
  return size;
}

class NavigationDockDestination {
  const NavigationDockDestination({required this.glyph, required this.label});

  final Glyph glyph;
  final String label;
}

/// Marks a phone's home page, whose foot the navigation dock holds.
class DockedPageScope extends InheritedWidget {
  const DockedPageScope({
    super.key,
    required this.docked,
    required super.child,
  });

  final bool docked;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DockedPageScope>()?.docked ??
      false;

  @override
  bool updateShouldNotify(DockedPageScope oldWidget) =>
      docked != oldWidget.docked;
}

class NavigationDock extends StatelessWidget {
  const NavigationDock({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.trailing,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget? trailing;

  /// Whether [context] sits in the dock's button slot, where a button keeps
  /// to a circle the bar's height instead of growing a label.
  static bool isDocked(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DockedMarker>() != null;

  static double heightOf(BuildContext context) {
    final fontSize = context.textTheme.labelSmall?.fontSize ?? 11;
    return _barHeight +
        MediaQuery.textScalerOf(context).scale(fontSize) -
        fontSize;
  }

  static double _bottomMarginOf(BuildContext context) =>
      math.max(_edgeMargin, MediaQuery.paddingOf(context).bottom);

  /// The room content scrolling under the dock leaves at its foot.
  static double insetOf(BuildContext context) =>
      heightOf(context) + _bottomMarginOf(context);

  @override
  Widget build(BuildContext context) {
    final height = heightOf(context);
    final dock = Padding(
      padding: EdgeInsets.fromLTRB(
        _edgeMargin,
        _shadowRoom,
        _edgeMargin,
        _bottomMarginOf(context),
      ),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FloatingNavigationBar(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              ),
            ),
            _DockTrailing(height: height, child: trailing),
          ],
        ),
      ),
    );
    return RepaintBoundary(child: dock);
  }
}

class _DockedMarker extends InheritedWidget {
  const _DockedMarker({required super.child});

  @override
  bool updateShouldNotify(_DockedMarker oldWidget) => false;
}

class _DockTrailing extends StatelessWidget {
  const _DockTrailing({required this.height, required this.child});

  final double height;
  final Widget? child;

  ThemeData _dockedTheme(ThemeData theme) {
    return theme.copyWith(
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        shape: AppShape.full,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        sizeConstraints: BoxConstraints.tightFor(width: height, height: height),
        iconSize: _trailingIconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = this.child;
    return AnimatedSize(
      duration: _slotDuration,
      curve: Easing.emphasizedDecelerate,
      alignment: AlignmentDirectional.centerEnd,
      clipBehavior: Clip.none,
      child: AnimatedSwitcher(
        duration: _slotDuration,
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [...previous, ?current],
        ),
        child: child == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: _fabGap),
                child: ElasticPress(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: AppShape.full,
                      shadows: _dockShadows(theme.colorScheme),
                    ),
                    child: Theme(
                      data: _dockedTheme(theme),
                      child: _DockedMarker(child: child),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Grows under a press and stretches after a dragging finger, springing back
/// on release, as the bar's lens does.
///
/// The press only paints: layout, hit testing, and anything anchored to the
/// child, such as a popup menu or a tooltip, see it at rest.
class ElasticPress extends StatefulWidget {
  const ElasticPress({super.key, this.enabled = true, required this.child});

  /// Leaves a press on the button inside to the swell alone.
  static const buttonStyle = ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateMapper<Color?>({
      WidgetState.pressed: Colors.transparent,
    }),
  );

  final bool enabled;
  final Widget child;

  @override
  State<ElasticPress> createState() => _ElasticPressState();
}

class _ElasticPressState extends State<ElasticPress>
    with TickerProviderStateMixin {
  late final _Spring _lift = _Spring(this, 0);
  late final _Spring _pullX = _Spring(this, 0);
  late final _Spring _pullY = _Spring(this, 0);
  late final Listenable _motion = Listenable.merge([_lift, _pullX, _pullY]);
  int? _pointer;
  Offset _origin = Offset.zero;

  @override
  void dispose() {
    _lift.dispose();
    _pullX.dispose();
    _pullY.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled ||
        _pointer != null ||
        event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _origin = event.localPosition;
    _lift.springTo(1, _liftSpring);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    final limit = context.size!.shortestSide * _pullLimit;
    final pull = event.localPosition - _origin;
    _pullX.springTo(_rubberBand(pull.dx, limit), _trackSpring);
    _pullY.springTo(_rubberBand(pull.dy, limit), _trackSpring);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    _lift.springTo(0, _settleSpring);
    _pullX.springTo(0, _settleSpring);
    _pullY.springTo(0, _settleSpring);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (_, child) => _PressTransform(
          lift: _lift.value,
          pull: Offset(_pullX.value, _pullY.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class _PressTransform extends SingleChildRenderObjectWidget {
  const _PressTransform({required this.lift, required this.pull, super.child});

  final double lift;
  final Offset pull;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPressTransform(lift: lift, pull: pull);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPressTransform renderObject,
  ) {
    renderObject
      ..lift = lift
      ..pull = pull;
  }
}

class _RenderPressTransform extends RenderProxyBox {
  _RenderPressTransform({required double lift, required Offset pull})
    : _lift = lift,
      _pull = pull;

  double _lift;
  Offset _pull;

  set lift(double value) {
    if (value == _lift) {
      return;
    }
    _lift = value;
    markNeedsPaint();
  }

  set pull(Offset value) {
    if (value == _pull) {
      return;
    }
    _pull = value;
    markNeedsPaint();
  }

  Matrix4 get _transform {
    final growth = size.shortestSide * _pressGrowth * 2 * _lift;
    final scaleX =
        (size.width + growth) /
        size.width *
        (1 + _pull.dx.abs() / size.width * _pullStretch);
    final scaleY =
        (size.height + growth) /
        size.height *
        (1 + _pull.dy.abs() / size.height * _pullStretch);
    final center = size.center(Offset.zero);
    return Matrix4.diagonal3Values(scaleX, scaleY, 1)..setTranslationRaw(
      center.dx * (1 - scaleX) + _pull.dx,
      center.dy * (1 - scaleY) + _pull.dy,
      0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || size.isEmpty || (_lift == 0 && _pull == .zero)) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }
}

/// A floating pill of destinations whose selection is a lens that springs
/// between them. Pressing lifts the lens under the finger, and dragging
/// slides it across the bar, selecting where it is let go.
class FloatingNavigationBar extends StatefulWidget {
  const FloatingNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar>
    with TickerProviderStateMixin {
  late final _Spring _lens = _Spring(this, _selectedIndex.toDouble());
  late final _Spring _lift = _Spring(this, 0);
  late final Listenable _motion = Listenable.merge([_lens, _lift]);
  int? _pointer;
  int? _pressedIndex;
  double _pressX = 0;
  bool _dragging = false;

  int get _lastIndex => math.max(0, widget.destinations.length - 1);

  int get _selectedIndex => widget.selectedIndex.clamp(0, _lastIndex);

  @override
  void didUpdateWidget(covariant FloatingNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pressedIndex == null && _lens.target != _selectedIndex) {
      _lens.springTo(_selectedIndex.toDouble(), _settleSpring);
    }
  }

  @override
  void dispose() {
    _lens.dispose();
    _lift.dispose();
    super.dispose();
  }

  double _positionAt(Offset localPosition) {
    final width = context.size!.width;
    final dx = Directionality.of(context) == TextDirection.ltr
        ? localPosition.dx
        : width - localPosition.dx;
    final extent = (width - _barPadding * 2) / widget.destinations.length;
    final position = (dx - _barPadding) / extent - 0.5;
    if (position < 0) {
      return _rubberBand(position, _overdrag);
    }
    if (position > _lastIndex) {
      return _lastIndex + _rubberBand(position - _lastIndex, _overdrag);
    }
    return position;
  }

  int _indexAt(double position) => position.round().clamp(0, _lastIndex);

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || event.buttons & kPrimaryButton == 0) {
      return;
    }
    _pointer = event.pointer;
    _press(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer == _pointer) {
      _slide(event.localPosition);
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _pointer = null;
    _release(commit: event is PointerUpEvent);
  }

  void _press(Offset localPosition) {
    if (widget.destinations.isEmpty) {
      return;
    }
    final index = _indexAt(_positionAt(localPosition));
    _pressedIndex = index;
    _pressX = localPosition.dx;
    _dragging = false;
    _lift.springTo(1, _liftSpring);
    _lens.springTo(index.toDouble(), _settleSpring);
  }

  void _slide(Offset localPosition) {
    if (_pressedIndex == null) {
      return;
    }
    if (!_dragging) {
      if ((localPosition.dx - _pressX).abs() < kTouchSlop) {
        return;
      }
      _dragging = true;
    }
    final position = _positionAt(localPosition);
    _lens.springTo(position, _trackSpring);
    final index = _indexAt(position);
    if (index != _pressedIndex) {
      HapticFeedback.selectionClick();
      _pressedIndex = index;
    }
  }

  void _release({required bool commit}) {
    final index = _pressedIndex;
    if (index == null) {
      return;
    }
    _pressedIndex = null;
    _dragging = false;
    _lift.springTo(0, _settleSpring);
    if (!commit) {
      _lens.springTo(_selectedIndex.toDouble(), _settleSpring);
      return;
    }
    _lens.springTo(index.toDouble(), _settleSpring);
    if (index != widget.selectedIndex) {
      widget.onSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
    final fontSize = labelStyle?.fontSize ?? _minLabelSize;
    final labels = [
      for (final destination in widget.destinations)
        _measureLabel(context, destination.label, labelStyle),
    ];
    final widest = labels.fold(
      0.0,
      (width, label) => math.max(width, label.width),
    );
    final lineHeight = labels.fold(
      0.0,
      (height, label) => math.max(height, label.height),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.full,
        shadows: _dockShadows(colorScheme),
      ),
      child: Material(
        color: colorScheme.surfaceContainer,
        shape: AppShape.full,
        // Raw pointers rather than recognizers: a drag has nothing to win the
        // arena from, and a tap waiting on one lifts the lens late.
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: Padding(
            padding: const EdgeInsets.all(_barPadding),
            // Above the LayoutBuilder: rebuilding anything under one relays it
            // out, and that repaint would otherwise reach the whole dock.
            child: RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final extent =
                      constraints.maxWidth /
                      math.max(1, widget.destinations.length);
                  final room = extent - _labelInset * 2;
                  final labelScale = widest <= room
                      ? 1.0
                      : math.max(room / widest, _minLabelSize / fontSize);
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.destinations.isNotEmpty)
                        AnimatedBuilder(
                          animation: _motion,
                          builder: (_, _) => _Lens(
                            position: _lens.value,
                            velocity: _lens.velocity,
                            extent: extent,
                            height: constraints.maxHeight,
                            lift: _lift.value,
                          ),
                        ),
                      Row(
                        children: [
                          for (final (index, destination)
                              in widget.destinations.indexed)
                            Expanded(
                              child: _FloatingBarItem(
                                destination: destination,
                                selected: index == _selectedIndex,
                                index: index,
                                lens: _lens,
                                lift: _lift,
                                labelStyle: labelStyle?.copyWith(
                                  fontSize: fontSize * labelScale,
                                ),
                                labelHeight: lineHeight,
                                labelOverflows:
                                    labels[index].width * labelScale > room,
                                onActivate: () => widget.onSelected(index),
                              ),
                            ),
                        ],
                      ),
                    ],
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

class _Lens extends StatelessWidget {
  const _Lens({
    required this.position,
    required this.velocity,
    required this.extent,
    required this.height,
    required this.lift,
  });

  final double position;
  final double velocity;
  final double extent;
  final double height;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final stretch =
        (velocity.abs() / _jellySpeed).clamp(0.0, 1.0) * _jellyStretch;
    final growth = _lensGrowth * 2 * lift;
    final width = (extent + growth) * (1 + stretch);
    final lensHeight = (height + growth) * (1 - stretch / 2);
    return PositionedDirectional(
      start: (position + 0.5) * extent - width / 2,
      top: (height - lensHeight) / 2,
      width: width,
      height: lensHeight,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Color.alphaBlend(
            colorScheme.onSecondaryContainer.withValues(
              alpha: 0.08 * lift.clamp(0.0, 1.0),
            ),
            colorScheme.secondaryContainer,
          ),
          shape: AppShape.full,
        ),
      ),
    );
  }
}

class _FloatingBarItem extends StatefulWidget {
  const _FloatingBarItem({
    required this.destination,
    required this.selected,
    required this.index,
    required this.lens,
    required this.lift,
    required this.labelStyle,
    required this.labelHeight,
    required this.labelOverflows,
    required this.onActivate,
  });

  final NavigationDockDestination destination;
  final bool selected;
  final int index;
  final ValueListenable<double> lens;
  final ValueListenable<double> lift;
  final TextStyle? labelStyle;
  final double labelHeight;
  final bool labelOverflows;
  final VoidCallback onActivate;

  @override
  State<_FloatingBarItem> createState() => _FloatingBarItemState();
}

class _FloatingBarItemState extends State<_FloatingBarItem> {
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onActivate();
        return null;
      },
    ),
  };
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final overlay = _focused
        ? colorScheme.onSurface.withValues(alpha: 0.1)
        : _hovered
        ? colorScheme.onSurface.withValues(alpha: 0.06)
        : Colors.transparent;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: _labelInset),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.lens, widget.lift]),
        builder: (context, _) {
          final emphasis = (1 - (widget.lens.value - widget.index).abs()).clamp(
            0.0,
            1.0,
          );
          final color = Color.lerp(
            colorScheme.onSurfaceVariant,
            colorScheme.primary,
            emphasis,
          )!;
          final column = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlyphIcon(
                widget.destination.glyph,
                size: _iconSize,
                color: color,
                fill: 1,
              ),
              const SizedBox(height: _labelGap),
              SizedBox(
                height: widget.labelHeight,
                child: Center(
                  child: Text(
                    widget.destination.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: widget.labelStyle?.copyWith(color: color),
                  ),
                ),
              ),
            ],
          );
          return Transform.scale(
            scale: 1 + _lensMagnify * emphasis * widget.lift.value,
            child: column,
          );
        },
      ),
    );
    return FocusableActionDetector(
      actions: _actions,
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: Semantics(
        container: true,
        button: true,
        selected: widget.selected,
        label: widget.destination.label,
        excludeSemantics: true,
        onTap: widget.onActivate,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: overlay,
            shape: AppShape.full.copyWith(
              side: _focused
                  ? BorderSide(color: colorScheme.secondary, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: widget.labelOverflows
              ? Tooltip(message: widget.destination.label, child: content)
              : content,
        ),
      ),
    );
  }
}
