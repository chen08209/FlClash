import 'dart:math' as math;

import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/input.dart';
import 'package:fl_clash/ui/liquid_glass.dart';
import 'package:fl_clash/ui/motion.dart';
import 'package:fl_clash/ui/navigation_dock.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

const double _actionGap = 8;
const double _actionInset = 16;
const double _actionHeight = 48;
const double _textInset = 30;
const double _alertWidth = 348;
const double _contentMaxWidth = 300;
// Material 3 sets a filled field's text 4 in past its content padding.
const double _fieldInputGap = 4;
const double _pressGrowth = 4;
const double _pressPull = 3;
const double _pressedFillShare = 0.4;
const double _pressedDarkDefaultShare = 0.5;

// UIAlertController on iOS 27 grows in from 1.2 times its size and only fades
// out, both on one critically damped spring that settles in 0.404 s.
const _alertDuration = Duration(milliseconds: 404);
const double _alertEntryScale = 1.2;
final _alertSpring = SpringCurve(
  SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 275),
  ),
  seconds: _alertDuration.inMicroseconds / Duration.microsecondsPerSecond,
);

Future<T?> showFloatingDialog<T>({
  required BuildContext context,
  required Widget child,
  bool dismissible = true,
}) {
  return Navigator.of(context).push<T>(
    _AlertRoute<T>(
      barrierColor: context.colorScheme.alertScrim,
      barrierDismissible: dismissible,
      barrierLabel: dismissible
          ? MaterialLocalizations.of(context).modalBarrierDismissLabel
          : null,
      builder: (context) => SurfaceScope(
        level: SurfaceLevel.floatingOf(context.colorScheme),
        child: child,
      ),
    ),
  );
}

/// A route whose navigator an alert raised from inside it opens on.
mixin AlertHostRoute<T> on ModalRoute<T> {}

class _AlertRoute<T> extends PopupRoute<T>
    with AlertMotionRouteMixin<T>, AlertHostRoute<T> {
  _AlertRoute({
    required this.barrierColor,
    required this.barrierDismissible,
    required this.barrierLabel,
    required this.builder,
  });

  @override
  final Color barrierColor;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  final WidgetBuilder builder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: SafeArea(child: Builder(builder: builder)),
    );
  }
}

/// Moves a route, and its barrier, as UIKit moves an alert.
mixin AlertMotionRouteMixin<T> on PopupRoute<T> {
  CurvedAnimation? _sprung;

  // The barrier fades on the spring both ways, where `barrierCurve` would
  // replay it backwards on the way out.
  Animation<double> get _spring => _sprung ??= CurvedAnimation(
    parent: animation!,
    curve: _alertSpring,
    reverseCurve: _alertSpring.flipped,
  );

  VoidCallback? get onBarrierDismiss => null;

  @override
  Duration get transitionDuration => _alertDuration;

  @override
  Widget buildModalBarrier() {
    final barrierColor = this.barrierColor;
    if (offstage || barrierColor == null) {
      return ModalBarrier(
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        onDismiss: onBarrierDismiss,
      );
    }
    return AnimatedModalBarrier(
      color: _spring.drive(
        ColorTween(begin: barrierColor.withValues(alpha: 0), end: barrierColor),
      ),
      dismissible: barrierDismissible,
      semanticsLabel: barrierLabel,
      barrierSemanticsDismissible: semanticsDismissible,
      onDismiss: onBarrierDismiss,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _AlertTransition(animation: _spring, child: child);
  }

  @override
  void dispose() {
    _sprung?.dispose();
    super.dispose();
  }
}

class _AlertTransition extends StatefulWidget {
  const _AlertTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  State<_AlertTransition> createState() => _AlertTransitionState();
}

class _AlertTransitionState extends State<_AlertTransition> {
  double? _heldScale;

  double get _scale =>
      _heldScale ??
      _alertEntryScale + (1 - _alertEntryScale) * widget.animation.value;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_handleStatus);
  }

  @override
  void didUpdateWidget(_AlertTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_handleStatus);
      widget.animation.addStatusListener(_handleStatus);
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleStatus);
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    _heldScale = status == AnimationStatus.reverse ? _scale : null;
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassFade(
      opacity: widget.animation,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (_, child) => Transform.scale(scale: _scale, child: child),
        child: widget.child,
      ),
    );
  }
}

RenderPhysicalShape? _surfaceIn(RenderObject node) {
  if (node is RenderPhysicalShape) {
    return node;
  }
  RenderPhysicalShape? surface;
  node.visitChildren((child) => surface ??= _surfaceIn(child));
  return surface;
}

Rect _surfaceRectIn(RenderBox box) {
  final surface = _surfaceIn(box);
  if (surface == null) {
    return Offset.zero & box.size;
  }
  return MatrixUtils.transformRect(
    surface.getTransformTo(box),
    Offset.zero & surface.size,
  );
}

/// An [AlertDialog] takes only a color, so the pane goes where its [Material]
/// lays out its [PhysicalShape].
class _AlertGlass extends SingleChildRenderObjectWidget {
  const _AlertGlass({
    required this.style,
    required this.rim,
    required this.shadows,
    super.child,
  });

  final LiquidGlassStyle style;
  final LiquidGlassRim rim;
  final List<BoxShadow> shadows;

  @override
  _RenderAlertGlass createRenderObject(BuildContext context) {
    return _RenderAlertGlass(style, rim, shadows);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAlertGlass renderObject,
  ) {
    renderObject
      ..style = style
      ..rim = rim
      ..shadows = shadows;
  }
}

class _RenderAlertGlass extends RenderProxyBox {
  _RenderAlertGlass(this._style, this._rim, this._shadows);

  late final _pane = LiquidGlassPane(markNeedsPaint);

  LiquidGlassStyle _style;
  set style(LiquidGlassStyle value) {
    if (value == _style) {
      return;
    }
    _style = value;
    markNeedsPaint();
  }

  LiquidGlassRim _rim;
  set rim(LiquidGlassRim value) {
    if (value == _rim) {
      return;
    }
    _rim = value;
    markNeedsPaint();
  }

  List<BoxShadow> _shadows;
  set shadows(List<BoxShadow> value) {
    if (listEquals(value, _shadows)) {
      return;
    }
    _shadows = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void dispose() {
    _pane.dispose();
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_surfaceIn(this) == null) {
      _pane.clear();
    } else {
      final rect = _surfaceRectIn(this).shift(offset);
      _pane.paint(
        context,
        rect,
        shape: LiquidGlassCorners.circular(AppCorner.alert),
        style: _style,
        shadows: _shadows,
        rim: _rim,
      );
      _rim.paintLine(context.canvas, rect, AppCorner.alert);
    }
    super.paint(context, offset);
  }
}

class CommonDialog extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget? child;

  /// Text buttons, laid out as an iOS alert lays out its own: the last one
  /// is the default action and is filled, and the first one, the cancel action
  /// by convention, ends a stack.
  final List<Widget>? actions;
  final EdgeInsets? padding;

  /// Sets the fields in [child] as an iOS alert does: as wide as its buttons.
  final bool hasFields;

  /// The last action destroys data: red on the plain fill, as in UIKit.
  final bool destructive;

  const CommonDialog({
    super.key,
    required this.title,
    this.trailing,
    this.actions,
    this.child,
    this.padding,
    this.hasFields = false,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final actions = this.actions ?? const <Widget>[];
    final contentInset = hasFields ? _actionInset : _textInset;
    final glass = LiquidGlassScope.of(context);
    final colorScheme = context.colorScheme;
    final fill = glass ? glassFillOf(colorScheme) : null;
    final dialog = AlertDialog(
      backgroundColor: glass ? Colors.transparent : null,
      titleTextStyle: hasFields
          ? AppTextStyle.body.of(context)
          : AppTextStyle.headline.of(context),
      contentTextStyle: AppTextStyle.subheadline
          .of(context)
          .copyWith(
            color: colorScheme.onSurfaceVariant.withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 1 : 0.85,
            ),
          ),
      title: _buildTitle(),
      actions: actions.isEmpty
          ? null
          : [
              AlertActions(
                actions: actions,
                fill: fill,
                destructive: destructive,
              ),
            ],
      actionsPadding: const EdgeInsets.fromLTRB(
        _actionInset,
        0,
        _actionInset,
        _actionInset,
      ),
      titlePadding: const EdgeInsets.fromLTRB(_textInset, 21, _textInset, 0),
      contentPadding:
          padding ??
          EdgeInsets.fromLTRB(
            contentInset,
            hasFields ? 16 : 6,
            contentInset,
            20,
          ),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: padding == null
              ? _alertWidth - contentInset * 2
              : _contentMaxWidth,
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          child: hasFields
              ? FilledInputTheme(
                  fillColor: fill,
                  borderRadius: AppRadius.all(_actionHeight / 2),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: _textInset - _actionInset - _fieldInputGap,
                    vertical: 12,
                  ),
                  child: child ?? const SizedBox.shrink(),
                )
              : child,
        ),
      ),
    );
    return ElasticPress(
      pullPastEdges: true,
      maxGrowth: _pressGrowth,
      maxPull: _pressPull,
      panelOf: _surfaceRectIn,
      child: glass
          ? _AlertGlass(
              style: LiquidGlassStyle.alert(colorScheme),
              rim: LiquidGlassRim.alert(colorScheme),
              shadows: menuShadows(colorScheme),
              child: dialog,
            )
          : dialog,
    );
  }

  Widget _buildTitle() {
    final trailing = this.trailing;
    if (!hasFields) {
      return trailing == null
          ? Text(title)
          : Row(
              children: [
                Expanded(child: Text(title)),
                trailing,
              ],
            );
    }
    final text = Text(title, textAlign: TextAlign.center);
    if (trailing == null) {
      return SizedBox(width: double.infinity, child: text);
    }
    return _CenteredTitle(title: text, trailing: trailing);
  }
}

/// A title centred on its whole width, beside a control at its end.
class _CenteredTitle extends MultiChildRenderObjectWidget {
  _CenteredTitle({required Widget title, required Widget trailing})
    : super(children: [title, trailing]);

  @override
  _RenderCenteredTitle createRenderObject(BuildContext context) {
    return _RenderCenteredTitle(textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCenteredTitle renderObject,
  ) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _RenderCenteredTitle extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  _RenderCenteredTitle({required TextDirection textDirection})
    : _textDirection = textDirection;

  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox get _title => firstChild!;

  RenderBox get _trailing => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _title.getMinIntrinsicWidth(height) +
      _trailing.getMinIntrinsicWidth(height) * 2;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _title.getMaxIntrinsicWidth(height) +
      _trailing.getMaxIntrinsicWidth(height) * 2;

  @override
  double computeMinIntrinsicHeight(double width) => math.max(
    _title.getMinIntrinsicHeight(width),
    _trailing.getMinIntrinsicHeight(width),
  );

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(
    _title.getMaxIntrinsicHeight(width),
    _trailing.getMaxIntrinsicHeight(width),
  );

  double _widthOf(BoxConstraints constraints, double side) =>
      constraints.hasBoundedWidth
      ? constraints.maxWidth
      : _title.getMaxIntrinsicWidth(double.infinity) + side * 2;

  BoxConstraints _titleConstraints(double width, double side) =>
      BoxConstraints.tightFor(width: math.max(0.0, width - side * 2));

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final trailing = _trailing.getDryLayout(constraints.loosen());
    final width = _widthOf(constraints, trailing.width);
    final title = _title.getDryLayout(_titleConstraints(width, trailing.width));
    return constraints.constrain(
      Size(width, math.max(title.height, trailing.height)),
    );
  }

  @override
  void performLayout() {
    _trailing.layout(constraints.loosen(), parentUsesSize: true);
    final side = _trailing.size.width;
    final width = _widthOf(constraints, side);
    _title.layout(_titleConstraints(width, side), parentUsesSize: true);
    size = constraints.constrain(
      Size(width, math.max(_title.size.height, _trailing.size.height)),
    );
    final rtl = _textDirection == TextDirection.rtl;
    (_title.parentData! as MultiChildLayoutParentData).offset = Offset(
      side,
      (size.height - _title.size.height) / 2,
    );
    (_trailing.parentData! as MultiChildLayoutParentData).offset = Offset(
      rtl ? 0 : size.width - side,
      (size.height - _trailing.size.height) / 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Text buttons laid out and filled as [CommonDialog] sets its own.
class AlertActions extends StatelessWidget {
  const AlertActions({
    super.key,
    required this.actions,
    this.fill,
    this.destructive = false,
  });

  final List<Widget> actions;

  /// The plain buttons' fill, in place of the raised surface's.
  final Color? fill;

  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return _AlertActions(
      children: [
        for (final (index, action) in actions.indexed)
          _AlertAction(
            isDefault: !destructive && index == actions.length - 1,
            destructive: destructive && index == actions.length - 1,
            fill: fill,
            child: action,
          ),
      ],
    );
  }
}

class _AlertAction extends StatelessWidget {
  const _AlertAction({
    required this.isDefault,
    required this.destructive,
    required this.fill,
    required this.child,
  });

  final bool isDefault;
  final bool destructive;
  final Color? fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final fill = this.fill ?? context.raisedSurfaceLevel.colorOf(colorScheme);
    final foreground = isDefault
        ? colorScheme.onPrimary
        : destructive
        ? colorScheme.destructive
        : colorScheme.onSurface;
    final background = isDefault ? colorScheme.primary : fill;
    final pressedShare = switch ((isDefault, colorScheme.brightness)) {
      (true, Brightness.dark) => _pressedDarkDefaultShare,
      (false, Brightness.dark) => 1.0,
      _ => _pressedFillShare,
    };
    return TextButtonTheme(
      data: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: foreground,
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
              textStyle: isDefault
                  ? AppTextStyle.body.of(context, emphasized: true)
                  : AppTextStyle.body
                        .of(context)
                        .copyWith(fontWeight: FontWeight.w500),
              minimumSize: const Size(0, _actionHeight),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: AppShape.full,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              splashFactory: NoSplash.splashFactory,
            ).copyWith(
              backgroundColor: WidgetStateProperty<Color?>.fromMap({
                WidgetState.disabled: fill,
                WidgetState.pressed: background.withValues(
                  alpha: background.a * pressedShare,
                ),
                WidgetState.any: background,
              }),
              overlayColor: WidgetStateProperty<Color?>.fromMap({
                WidgetState.focused: foreground.withValues(alpha: 0.1),
                WidgetState.pressed: Colors.transparent,
                WidgetState.hovered: foreground.withValues(alpha: 0.08),
              }),
              side: focusRingStyle(colorScheme, standsOff: isDefault).side,
            ),
      ),
      child: child,
    );
  }
}

/// Two actions side by side when both labels fit half the width; any other
/// count, or labels too long, stacked in order with the first one at the
/// bottom.
class _AlertActions extends MultiChildRenderObjectWidget {
  const _AlertActions({required super.children});

  @override
  _RenderAlertActions createRenderObject(BuildContext context) {
    return _RenderAlertActions(textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAlertActions renderObject,
  ) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _AlertActionsParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderAlertActions extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _AlertActionsParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _AlertActionsParentData> {
  _RenderAlertActions({required TextDirection textDirection})
    : _textDirection = textDirection;

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AlertActionsParentData) {
      child.parentData = _AlertActionsParentData();
    }
  }

  bool _sideBySide(List<RenderBox> children, double width) =>
      children.length == 2 &&
      children.every(
        (child) =>
            child.getMaxIntrinsicWidth(double.infinity) <=
            (width - _actionGap) / 2,
      );

  double _childWidth(bool sideBySide, double width) =>
      sideBySide ? (width - _actionGap) / 2 : width;

  double _widest(double Function(RenderBox child) widthOf) =>
      getChildrenAsList().map(widthOf).fold(0, math.max);

  double _heightFor(
    double width,
    double Function(RenderBox child, double width) heightOf,
  ) {
    final children = getChildrenAsList();
    if (children.isEmpty) {
      return 0;
    }
    final sideBySide = _sideBySide(children, width);
    final heights = children.map(
      (child) => heightOf(child, _childWidth(sideBySide, width)),
    );
    return sideBySide
        ? heights.reduce(math.max)
        : heights.reduce((a, b) => a + b) + _actionGap * (children.length - 1);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _widest((child) => child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _widest((child) => child.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _heightFor(width, (child, width) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _heightFor(width, (child, width) => child.getMaxIntrinsicHeight(width));

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _layout(constraints, ChildLayoutHelper.dryLayoutChild);

  @override
  void performLayout() {
    size = _layout(constraints, ChildLayoutHelper.layoutChild, place: true);
  }

  Size _layout(
    BoxConstraints constraints,
    ChildLayouter layoutChild, {
    bool place = false,
  }) {
    final children = getChildrenAsList();
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : _widest((child) => child.getMaxIntrinsicWidth(double.infinity));
    final sideBySide = _sideBySide(children, width);
    final childConstraints = BoxConstraints.tightFor(
      width: _childWidth(sideBySide, width),
    );
    final sizes = [
      for (final child in children) layoutChild(child, childConstraints),
    ];
    final height = sizes.isEmpty
        ? 0.0
        : sideBySide
        ? math.max(sizes.first.height, sizes.last.height)
        : sizes.fold(0.0, (sum, size) => sum + size.height) +
              _actionGap * (sizes.length - 1);
    if (place) {
      final rtl = _textDirection == TextDirection.rtl;
      var y = 0.0;
      for (var step = 1; step <= children.length; step++) {
        final index = step % children.length;
        final size = sizes[index];
        final parentData =
            children[index].parentData! as _AlertActionsParentData;
        if (sideBySide) {
          final atLeft = (index == 0) != rtl;
          parentData.offset = Offset(
            atLeft ? 0 : width - size.width,
            (height - size.height) / 2,
          );
        } else {
          parentData.offset = Offset(0, y);
          y += size.height + _actionGap;
        }
      }
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
