import 'dart:math' as math;

import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/context.dart';
import 'package:fl_clash/ui/motion.dart';
import 'package:fl_clash/ui/navigation_dock.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:fl_clash/ui/typography.dart';
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
      barrierColor: context.colorScheme.modalScrim,
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
    return FadeTransition(
      opacity: widget.animation,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (_, child) => Transform.scale(scale: _scale, child: child),
        child: widget.child,
      ),
    );
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

  const CommonDialog({
    super.key,
    required this.title,
    this.trailing,
    this.actions,
    this.child,
    this.padding,
    this.hasFields = false,
  });

  @override
  Widget build(BuildContext context) {
    final actions = this.actions ?? const <Widget>[];
    final contentInset = hasFields ? _actionInset : _textInset;
    return AlertDialog(
      titleTextStyle: AppTextStyle.headline.of(context),
      contentTextStyle: AppTextStyle.subheadline
          .of(context)
          .copyWith(color: context.colorScheme.onSurfaceVariant),
      title: trailing == null
          ? Text(title)
          : Row(
              children: [
                Expanded(child: Text(title)),
                trailing!,
              ],
            ),
      actions: actions.isEmpty ? null : [AlertActions(actions: actions)],
      actionsPadding: const EdgeInsets.fromLTRB(
        _actionInset,
        0,
        _actionInset,
        _actionInset,
      ),
      titlePadding: const EdgeInsets.fromLTRB(_textInset, 24, _textInset, 0),
      contentPadding:
          padding ?? EdgeInsets.fromLTRB(contentInset, 16, contentInset, 24),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: padding == null
              ? _alertWidth - contentInset * 2
              : _contentMaxWidth,
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          child: hasFields ? _AlertFieldTheme(child: child) : child,
        ),
      ),
    );
  }
}

class _AlertFieldTheme extends StatelessWidget {
  const _AlertFieldTheme({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final shape = AppShape.input.copyWith(
      borderRadius: AppRadius.all(_actionHeight / 2),
    );
    final none = shape.copyWith(borderSide: BorderSide.none);
    return InputDecorationTheme(
      data: InputDecorationTheme.of(context).copyWith(
        filled: true,
        fillColor: context.raisedSurfaceLevel.colorOf(colorScheme),
        hoverColor: Colors.transparent,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _textInset - _actionInset - _fieldInputGap,
          vertical: 12,
        ),
        border: none,
        enabledBorder: none,
        disabledBorder: none,
        errorBorder: none,
        focusedBorder: shape.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        focusedErrorBorder: shape.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

/// Text buttons laid out and filled as [CommonDialog] sets its own.
class AlertActions extends StatelessWidget {
  const AlertActions({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return _AlertActions(
      children: [
        for (final (index, action) in actions.indexed)
          _AlertAction(isDefault: index == actions.length - 1, child: action),
      ],
    );
  }
}

class _AlertAction extends StatelessWidget {
  const _AlertAction({required this.isDefault, required this.child});

  final bool isDefault;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final fill = context.raisedSurfaceLevel.colorOf(colorScheme);
    final foreground = isDefault
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final child = this.child;
    return TextButtonTheme(
      data: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              backgroundColor: isDefault ? colorScheme.primary : fill,
              foregroundColor: foreground,
              disabledBackgroundColor: fill,
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
              textStyle: AppTextStyle.body.of(context, emphasized: isDefault),
              minimumSize: const Size(0, _actionHeight),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: AppShape.full,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              splashFactory: NoSplash.splashFactory,
            ).copyWith(
              overlayColor: WidgetStateProperty<Color?>.fromMap({
                WidgetState.focused: foreground.withValues(alpha: 0.1),
                WidgetState.pressed: Colors.transparent,
                WidgetState.hovered: foreground.withValues(alpha: 0.08),
              }),
              side: focusRingStyle(colorScheme, standsOff: isDefault).side,
            ),
      ),
      child: ElasticPress(
        enabled: switch (child) {
          ButtonStyleButton(:final enabled) => enabled,
          _ => true,
        },
        child: child,
      ),
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
