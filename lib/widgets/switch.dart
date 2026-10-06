import 'package:fl_clash/common/common.dart';
import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

const _trackSize = Size(49, 28);
const double _thumbRadius = 10;
const double _thumbInset = 4;
const double _thumbTravel = 21;
const double _pressedThumbScale = 1.127;
const _defaultPadding = EdgeInsets.symmetric(horizontal: 4);

final _thumbSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 987,
  ratio: 0.7,
);
final _scaleSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 987,
  ratio: 0.6,
);
final _tintSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 438.6,
  ratio: 0.99,
);

/// The app's switch: Material's own, or the Miuix capsule under that style.
class CommonSwitch extends StatelessWidget {
  const CommonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.padding,
    this.materialTapTargetSize,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry? padding;
  final MaterialTapTargetSize? materialTapTargetSize;

  /// A shrink-wrapped Material switch still lays out 4 above and below its
  /// track; the Miuix capsule lays out only its track.
  static double shrinkWrappedHeightOf(BuildContext context) {
    return context.interfaceStyle.isMiuix
        ? _trackSize.height
        : kMinInteractiveDimension - 8;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.interfaceStyle;
    if (!style.isMiuix) {
      return Switch(
        value: value,
        onChanged: onChanged,
        padding: padding,
        materialTapTargetSize: materialTapTargetSize,
      );
    }
    return _MiuixSwitch(
      value: value,
      onChanged: onChanged,
      monet: style.miuixMonet,
      padding: padding ?? _defaultPadding,
      tapTargetSize:
          materialTapTargetSize ?? Theme.of(context).materialTapTargetSize,
    );
  }
}

class _MiuixSwitch extends StatefulWidget {
  const _MiuixSwitch({
    required this.value,
    required this.onChanged,
    required this.monet,
    required this.padding,
    required this.tapTargetSize,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool monet;
  final EdgeInsetsGeometry padding;
  final MaterialTapTargetSize tapTargetSize;

  @override
  State<_MiuixSwitch> createState() => _MiuixSwitchState();
}

class _MiuixSwitchState extends State<_MiuixSwitch>
    with TickerProviderStateMixin {
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: _target,
  );
  late final AnimationController _tint = AnimationController.unbounded(
    vsync: this,
    value: _target,
  );
  late final AnimationController _scale = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );
  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _toggle()),
  };
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;
  double? _drag;

  double get _target => widget.value ? 1 : 0;

  bool get _enabled => widget.onChanged != null;

  @override
  void didUpdateWidget(_MiuixSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _springTo(_position, _target, _thumbSpring);
      _springTo(_tint, _target, _tintSpring);
    }
    if (oldWidget.onChanged != null && !_enabled) {
      _pressed = false;
      _drag = null;
      _updateScale();
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _tint.dispose();
    _scale.dispose();
    super.dispose();
  }

  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    if (context.disableAnimations) {
      controller.value = target;
      return;
    }
    controller.animateWith(
      SpringSimulation(
        spring,
        controller.value,
        target,
        controller.velocity,
        snapToEnd: true,
      ),
    );
  }

  void _updateScale() {
    final lifted = _enabled && (_pressed || _hovered || _drag != null);
    _springTo(_scale, lifted ? _pressedThumbScale : 1, _scaleSpring);
  }

  void _toggle() {
    widget.onChanged?.call(!widget.value);
  }

  void _setPressed(bool pressed) {
    setState(() => _pressed = pressed);
    _updateScale();
  }

  void _setHovered(bool hovered) {
    setState(() => _hovered = hovered);
    _updateScale();
  }

  void _handleDragStart(DragStartDetails details) {
    _drag = 0;
    _updateScale();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final drag = _drag;
    if (drag == null) {
      return;
    }
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final delta = isRtl ? -details.delta.dx : details.delta.dx;
    final next = (drag + delta).clamp(
      widget.value ? -_thumbTravel : 0.0,
      widget.value ? 0.0 : _thumbTravel,
    );
    _drag = next;
    _position.value = _target + next / _thumbTravel;
  }

  void _handleDragEnd(DragEndDetails details) {
    final flips = (_drag ?? 0).abs() > _thumbTravel / 2;
    _settleDrag();
    if (flips) {
      _toggle();
    }
  }

  void _settleDrag() {
    if (_drag == null) {
      return;
    }
    _drag = null;
    _updateScale();
    _springTo(_position, _target, _thumbSpring);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final overlayAlpha =
        (_hovered ? 0.06 : 0.0) +
        (_focused ? 0.08 : 0.0) +
        (_pressed ? 0.1 : 0.0);
    Widget body = Padding(
      padding: widget.padding,
      child: CustomPaint(
        size: _trackSize,
        painter: _MiuixSwitchPainter(
          position: _position,
          tint: _tint,
          scale: _scale,
          off: miuixSwitchColors(
            colors,
            selected: false,
            monet: widget.monet,
            enabled: _enabled,
          ),
          on: miuixSwitchColors(
            colors,
            selected: true,
            monet: widget.monet,
            enabled: _enabled,
          ),
          overlay: colors.onSurface.withValues(alpha: overlayAlpha),
          textDirection: Directionality.of(context),
        ),
      ),
    );
    if (widget.tapTargetSize == MaterialTapTargetSize.padded) {
      body = SizedBox(
        height: kMinInteractiveDimension,
        child: Center(widthFactor: 1, child: body),
      );
    }
    return Semantics(
      toggled: widget.value,
      enabled: _enabled,
      child: FocusableActionDetector(
        enabled: _enabled,
        actions: _actions,
        mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        onShowHoverHighlight: _setHovered,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: !_enabled,
          onTap: _enabled ? _toggle : null,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onHorizontalDragStart: _enabled ? _handleDragStart : null,
          onHorizontalDragUpdate: _enabled ? _handleDragUpdate : null,
          onHorizontalDragEnd: _enabled ? _handleDragEnd : null,
          onHorizontalDragCancel: _enabled ? _settleDrag : null,
          child: body,
        ),
      ),
    );
  }
}

class _MiuixSwitchPainter extends CustomPainter {
  _MiuixSwitchPainter({
    required this.position,
    required this.tint,
    required this.scale,
    required this.off,
    required this.on,
    required this.overlay,
    required this.textDirection,
  }) : super(repaint: Listenable.merge([position, tint, scale]));

  final Animation<double> position;
  final Animation<double> tint;
  final Animation<double> scale;
  final ({Color track, Color thumb}) off;
  final ({Color track, Color thumb}) on;
  final Color overlay;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RSuperellipse.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    final mix = tint.value.clamp(0.0, 1.0);
    final travel = _thumbInset + _thumbRadius + position.value * _thumbTravel;
    final center = Offset(
      textDirection == TextDirection.rtl ? size.width - travel : travel,
      size.height / 2,
    );
    canvas
      ..save()
      ..clipRSuperellipse(track)
      ..drawRSuperellipse(
        track,
        Paint()..color = Color.lerp(off.track, on.track, mix)!,
      );
    if (overlay.a > 0) {
      canvas.drawRSuperellipse(track, Paint()..color = overlay);
    }
    canvas
      ..drawCircle(
        center,
        _thumbRadius * scale.value,
        Paint()..color = Color.lerp(off.thumb, on.thumb, mix)!,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_MiuixSwitchPainter oldDelegate) {
    return oldDelegate.off != off ||
        oldDelegate.on != on ||
        oldDelegate.overlay != overlay ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.position != position ||
        oldDelegate.tint != tint ||
        oldDelegate.scale != scale;
  }
}
