import 'dart:math' as math;

import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'goo.dart';
import 'liquid_glass.dart';
import 'navigation_dock.dart';

class MoreActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? trailing;

  const MoreActionButton({
    super.key,
    this.onPressed,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CommonCard(
        radius: AppCorner.xl,
        onPressed: onPressed,
        child: ListTile(
          minTileHeight: listRowMinHeight,
          minVerticalPadding: listRowVerticalPadding,
          titleTextStyle: context.listTitleStyle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(label),
          trailing:
              trailing ?? const GlyphIcon(AppGlyphs.chevronForward, size: 18),
        ),
      ),
    );
  }
}

enum TonalButtonSize {
  bar(button: 44, icon: 24),
  docked(button: BottomInsetScope.dockedSearchHeight, icon: 24),
  section(button: 36, icon: 20),
  compact(button: 32, icon: 20);

  const TonalButtonSize({required this.button, required this.icon});

  final double button;
  final double icon;
}

// iOS 27 on iPad marks the button of a group under a pointer with a capsule
// 4 pt inside the group, sliding to the next on this spring and fading in
// place as the pointer comes and goes; the group does not swell.
const _markAlpha = 0.08;
const _markInsets = EdgeInsets.symmetric(horizontal: 2, vertical: 4);
final _markSlide = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 2350,
  ratio: 0.95,
);
final _markFade = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 380),
);

/// Buttons sharing one filled pill, which answers a press on any of them as a
/// single button does and marks the one under a pointer.
class TonalButtonGroup extends StatefulWidget {
  const TonalButtonGroup({
    super.key,
    this.size = TonalButtonSize.bar,
    required this.children,
  });

  final TonalButtonSize size;
  final List<Widget> children;

  @override
  State<TonalButtonGroup> createState() => _TonalButtonGroupState();
}

class _TonalButtonGroupState extends State<TonalButtonGroup>
    with TickerProviderStateMixin {
  final _pointer = ValueNotifier<int?>(null);
  _HoverMark? _mark;

  @override
  void dispose() {
    _pointer.dispose();
    _mark?.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer.value == null && event.buttons & kPrimaryButton != 0) {
      _pointer.value = event.pointer;
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer == _pointer.value) {
      _pointer.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final row = Row(mainAxisSize: MainAxisSize.min, children: widget.children);
    final mark = widget.children.length > 1 ? _mark ??= _HoverMark(this) : null;
    final buttons = TonalButtonTheme(
      grouped: true,
      size: widget.size,
      child: mark == null
          ? row
          : _HoverMarkScope(mark: mark, child: mark.build(context, row)),
    );
    if (GooSurface.of(context)) {
      return ElasticPress(child: GooPane(child: buttons));
    }
    return ElasticPress(
      child: TonalButtonTheme.glassOf(context)
          ? Listener(
              onPointerDown: _handlePointerDown,
              onPointerUp: _handlePointerEnd,
              onPointerCancel: _handlePointerEnd,
              child: ValueListenableBuilder(
                valueListenable: _pointer,
                builder: (_, pointer, child) => LiquidGlass(
                  style: LiquidGlassStyle.regular(colorScheme),
                  pressed: pointer != null,
                  child: child,
                ),
                child: buttons,
              ),
            )
          : DecoratedBox(
              decoration: ShapeDecoration(
                color: context.raisedSurfaceLevel.colorOf(colorScheme),
                shape: AppShape.full,
              ),
              child: buttons,
            ),
    );
  }
}

class _HoverMark {
  _HoverMark(TickerProvider vsync)
    : _travel = AnimationController.unbounded(vsync: vsync, value: 1),
      _shown = AnimationController.unbounded(vsync: vsync);

  final AnimationController _travel;
  final AnimationController _shown;
  late final Listenable _motion = Listenable.merge([_travel, _shown]);
  final _area = GlobalKey();
  Object? _slot;
  RenderBox? _box;
  Rect? _from;
  Rect? _painted;

  bool get _hidden => _shown.value < 0.01;

  void enter(Object slot, RenderBox box) {
    _slot = slot;
    _box = box;
    _from = _hidden ? null : _painted;
    if (_from == null) {
      _travel.value = 1;
    } else {
      _travel.value = 0;
      _springTo(_travel, 1, _markSlide);
    }
    _springTo(_shown, 1, _markFade);
  }

  void leave(Object slot) {
    if (_slot == slot) {
      _slot = null;
      _box = null;
      _from = _painted;
      _springTo(_shown, 0, _markFade);
    }
  }

  static void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    controller.animateWith(
      SpringSimulation(spring, controller.value, target, controller.velocity),
    );
  }

  /// Where the button under the pointer shows in the area now, cut by the
  /// clips between them, as a bar's search narrows its slot.
  Rect? _slotRect() {
    final box = _box;
    final area = _area.currentContext?.findRenderObject();
    if (box == null || !box.attached || area is! RenderBox) {
      return null;
    }
    var rect = MatrixUtils.transformRect(
      box.getTransformTo(area),
      Offset.zero & box.size,
    );
    RenderObject child = box;
    for (var node = box.parent; node != null && node != area;) {
      final clip = node.describeApproximatePaintClip(child);
      if (clip != null) {
        rect = rect.intersect(
          MatrixUtils.transformRect(node.getTransformTo(area), clip),
        );
      }
      child = node;
      node = node.parent;
    }
    return _markInsets.deflateRect(rect);
  }

  Rect? _rect() {
    if (_hidden) {
      return _painted = null;
    }
    final slot = _slotRect();
    final from = _from;
    final rect = slot == null
        ? from
        : from == null
        ? slot
        : Rect.lerp(from, slot, _travel.value);
    return _painted = rect;
  }

  Widget build(BuildContext context, Widget row) {
    return Stack(
      key: _area,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _HoverMarkPainter(
              mark: this,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        row,
      ],
    );
  }

  void dispose() {
    _travel.dispose();
    _shown.dispose();
  }
}

class _HoverMarkPainter extends CustomPainter {
  _HoverMarkPainter({required this.mark, required this.color})
    : super(repaint: mark._motion);

  final _HoverMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = mark._rect();
    if (rect == null || rect.width <= 0 || rect.height <= 0) {
      return;
    }
    canvas.drawPath(
      AppShape.full.getOuterPath(rect),
      Paint()
        ..color = color.withValues(
          alpha: _markAlpha * math.min(mark._shown.value, 1),
        ),
    );
  }

  @override
  bool shouldRepaint(_HoverMarkPainter oldDelegate) =>
      mark != oldDelegate.mark || color != oldDelegate.color;
}

class _HoverMarkScope extends InheritedWidget {
  const _HoverMarkScope({required this.mark, required super.child});

  final _HoverMark mark;

  static _HoverMark? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HoverMarkScope>()?.mark;

  @override
  bool updateShouldNotify(_HoverMarkScope oldWidget) => mark != oldWidget.mark;
}

class _HoverSlot extends StatefulWidget {
  const _HoverSlot({
    required this.mark,
    required this.enabled,
    required this.child,
  });

  final _HoverMark mark;
  final bool enabled;
  final Widget child;

  @override
  State<_HoverSlot> createState() => _HoverSlotState();
}

class _HoverSlotState extends State<_HoverSlot> {
  void _handleEnter(PointerEnterEvent event) {
    if (widget.enabled && event.kind != PointerDeviceKind.touch) {
      widget.mark.enter(this, context.findRenderObject()! as RenderBox);
    }
  }

  void _handleExit(PointerExitEvent event) => widget.mark.leave(this);

  @override
  void didUpdateWidget(_HoverSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled || widget.mark != oldWidget.mark) {
      oldWidget.mark.leave(this);
    }
  }

  @override
  void dispose() {
    widget.mark.leave(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: widget.child,
    );
  }
}

/// A labelled button on the fill of a [TonalButtonGroup], for an action that
/// is not the one a screen is for.
class TonalButton extends StatelessWidget {
  const TonalButton({
    super.key,
    this.size = TonalButtonSize.section,
    this.glyph,
    required this.label,
    required this.onPressed,
  });

  final TonalButtonSize size;
  final Glyph? glyph;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final glyph = this.glyph;
    final label = Text(this.label);
    return ElasticPress(
      enabled: onPressed != null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
          shape: AppShape.full,
        ),
        child: TonalButtonTheme(
          grouped: true,
          size: size,
          child: glyph == null
              ? FilledButton(onPressed: onPressed, child: label)
              : FilledButton.icon(
                  onPressed: onPressed,
                  icon: GlyphIcon(glyph, fill: 1),
                  label: label,
                ),
        ),
      ),
    );
  }
}

/// Fills every button below and, as iOS does, leaves a press to the swell of
/// [ElasticPress]; inside a [TonalButtonGroup] the group is filled. With
/// [glass] the fills are panes of [LiquidGlass], a filled button's tinted;
/// under a [GooSurface] an icon button stands on a pane of it.
class TonalButtonTheme extends StatelessWidget {
  const TonalButtonTheme({
    super.key,
    this.grouped = false,
    this.glass = false,
    this.size = TonalButtonSize.bar,
    required this.child,
  });

  final bool grouped;
  final bool glass;
  final TonalButtonSize size;
  final Widget child;

  /// Whether a button here stands on glass of its own.
  static bool glassOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GlassButtons>()?.glass ??
      false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final goo = !grouped && GooSurface.of(context);
    final paned = glass && !grouped && !goo;
    final fill = grouped || paned || goo
        ? Colors.transparent
        : context.raisedSurfaceLevel.colorOf(colorScheme);
    final foreground = colorScheme.onSurface;
    final disabledForeground = foreground.withValues(alpha: 0.38);
    ButtonStyle? paneOf(bool Function(Set<WidgetState> states) tinted) {
      if (!paned) {
        return null;
      }
      final regularGlass = LiquidGlassStyle.regular(colorScheme);
      final tintedGlass = LiquidGlassStyle.tinted(
        colorScheme,
        colorScheme.primary,
      );
      return LiquidGlass.buttonStyle(
        (states) => tinted(states) ? tintedGlass : regularGlass,
      );
    }

    ButtonStyle feedback(ButtonStyle? pane, {required bool standsOff}) {
      final behind = pane?.backgroundBuilder;
      return ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: pane?.backgroundColor,
        backgroundBuilder: (context, states, child) {
          final content = behind == null
              ? child!
              : behind(context, states, child);
          final mark = _HoverMarkScope.maybeOf(context);
          return mark == null
              ? ElasticHover(child: content)
              : _HoverSlot(
                  mark: mark,
                  enabled: !states.contains(WidgetState.disabled),
                  child: content,
                );
        },
      ).merge(focusRingStyle(colorScheme, standsOff: standsOff));
    }

    final iconPane = goo
        ? GooSurface.buttonStyle
        : paneOf((states) => states.contains(WidgetState.selected));
    final filledPane = paneOf(
      (states) => !states.contains(WidgetState.disabled),
    );
    final filledFeedback = feedback(filledPane, standsOff: !grouped);
    final themed = IconButtonTheme(
      data: IconButtonThemeData(
        style: feedback(iconPane, standsOff: paned).merge(
          IconButton.styleFrom(
            backgroundColor: fill,
            foregroundColor: foreground,
            disabledBackgroundColor: fill,
            disabledForegroundColor: disabledForeground,
            fixedSize: Size.square(size.button),
            minimumSize: Size.square(size.button),
            padding: EdgeInsets.zero,
            iconSize: size.icon,
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: FilledButtonTheme(
        data: FilledButtonThemeData(
          style: filledFeedback.merge(
            FilledButton.styleFrom(
              backgroundColor: grouped ? fill : null,
              foregroundColor: grouped
                  ? foreground
                  : paned
                  ? colorScheme.onPrimary
                  : null,
              disabledBackgroundColor: grouped ? fill : null,
              disabledForegroundColor: grouped ? disabledForeground : null,
              minimumSize: Size.square(size.button),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: AppShape.full,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        child: IconTheme.merge(
          data: const IconThemeData(fill: 1),
          child: child,
        ),
      ),
    );
    return _GlassButtons(glass: paned, child: themed);
  }
}

class _GlassButtons extends InheritedWidget {
  const _GlassButtons({required this.glass, required super.child});

  final bool glass;

  @override
  bool updateShouldNotify(_GlassButtons oldWidget) => glass != oldWidget.glass;
}
