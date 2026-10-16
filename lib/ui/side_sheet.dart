import 'dart:math' as math;

import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/drag_back.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/sheet_navigator.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

const Duration _sideSheetEnterDuration = Duration(milliseconds: 300);
const Duration _sideSheetExitDuration = Duration(milliseconds: 200);
const Curve _sideSheetCurve = Easing.standardDecelerate;

const double _minWidth = 360;
const double _maxWidth = 560;
const double _widthFactor = 0.4;

double _widthFor(double viewWidth) {
  return (viewWidth * _widthFactor).clamp(_minWidth, _maxWidth);
}

class SideSheet extends StatefulWidget {
  const SideSheet({super.key, this.backgroundColor, required this.builder});

  final WidgetBuilder builder;

  final Color? backgroundColor;

  @override
  State<SideSheet> createState() => _SideSheetState();

  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _sideSheetEnterDuration,
      reverseDuration: _sideSheetExitDuration,
      debugLabel: 'SideSheet',
      vsync: vsync,
    );
  }
}

class _SideSheetState extends State<SideSheet> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'SideSheet child');

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _childKey,
      color:
          widget.backgroundColor ??
          SurfaceLevel.page.colorOf(Theme.of(context).colorScheme),
      shape: AppShape.none,
      child: widget.builder(context),
    );
  }
}

typedef _SizeChangeCallback<Size> = void Function(Size);

class _SideSheetLayoutWithSizeListener extends SingleChildRenderObjectWidget {
  const _SideSheetLayoutWithSizeListener({
    required this.onChildSizeChanged,
    required this.animationValue,
    required this.width,
    super.child,
  });

  final _SizeChangeCallback<Size> onChildSizeChanged;
  final double animationValue;
  final double width;

  @override
  _RenderSideSheetLayoutWithSizeListener createRenderObject(
    BuildContext context,
  ) {
    return _RenderSideSheetLayoutWithSizeListener(
      onChildSizeChanged: onChildSizeChanged,
      animationValue: animationValue,
      width: width,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSideSheetLayoutWithSizeListener renderObject,
  ) {
    renderObject.onChildSizeChanged = onChildSizeChanged;
    renderObject.animationValue = animationValue;
    renderObject.width = width;
  }
}

class _RenderSideSheetLayoutWithSizeListener extends RenderShiftedBox {
  _RenderSideSheetLayoutWithSizeListener({
    RenderBox? child,
    required _SizeChangeCallback<Size> onChildSizeChanged,
    required double animationValue,
    required double width,
  }) : _onChildSizeChanged = onChildSizeChanged,
       _animationValue = animationValue,
       _width = width,
       super(child);

  Size _lastSize = Size.zero;

  _SizeChangeCallback<Size> get onChildSizeChanged => _onChildSizeChanged;
  _SizeChangeCallback<Size> _onChildSizeChanged;

  set onChildSizeChanged(_SizeChangeCallback<Size> newCallback) {
    if (_onChildSizeChanged == newCallback) {
      return;
    }

    _onChildSizeChanged = newCallback;
    markNeedsLayout();
  }

  double get animationValue => _animationValue;
  double _animationValue;

  set animationValue(double newValue) {
    if (_animationValue == newValue) {
      return;
    }

    _animationValue = newValue;
    markNeedsLayout();
  }

  double get width => _width;
  double _width;

  set width(double newValue) {
    if (_width == newValue) {
      return;
    }

    _width = newValue;
    markNeedsLayout();
  }

  Size _getSize(BoxConstraints constraints) {
    return constraints.constrain(constraints.biggest);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final double width = _getSize(
      BoxConstraints.tightForFinite(height: height),
    ).width;
    if (width.isFinite) {
      return width;
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double width = _getSize(
      BoxConstraints.tightForFinite(height: height),
    ).width;
    if (width.isFinite) {
      return width;
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double height = _getSize(
      BoxConstraints.tightForFinite(width: width),
    ).height;
    if (height.isFinite) {
      return height;
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double height = _getSize(
      BoxConstraints.tightForFinite(width: width),
    ).height;
    if (height.isFinite) {
      return height;
    }
    return 0.0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _getSize(constraints);
  }

  BoxConstraints _getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: math.min(width, constraints.maxWidth),
      height: constraints.maxHeight,
    );
  }

  Offset _getPositionForChild(Size size, Size childSize) {
    return Offset(size.width - childSize.width * animationValue, 0.0);
  }

  @override
  void performLayout() {
    size = _getSize(constraints);
    if (child != null) {
      final BoxConstraints childConstraints = _getConstraintsForChild(
        constraints,
      );
      assert(childConstraints.debugAssertIsValid(isAppliedConstraint: true));
      child!.layout(
        childConstraints,
        parentUsesSize: !childConstraints.isTight,
      );
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = _getPositionForChild(
        size,
        childConstraints.isTight ? childConstraints.smallest : child!.size,
      );
      final Size childSize = childConstraints.isTight
          ? childConstraints.smallest
          : child!.size;

      if (_lastSize != childSize) {
        _lastSize = childSize;
        _onChildSizeChanged.call(_lastSize);
      }
    }
  }
}

class _ModalSideSheet<T> extends StatefulWidget {
  const _ModalSideSheet({super.key, required this.route, this.backgroundColor});

  final ModalSideSheetRoute<T> route;
  final Color? backgroundColor;

  @override
  _ModalSideSheetState<T> createState() => _ModalSideSheetState<T>();
}

class _ModalSideSheetState<T> extends State<_ModalSideSheet<T>> {
  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  EdgeInsets _getNewClipDetails(Size topLayerSize) {
    return EdgeInsets.fromLTRB(0, 0, topLayerSize.width, 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String routeLabel = _getRouteLabel(localizations);
    final width = _widthFor(MediaQuery.sizeOf(context).width);

    final route = widget.route;
    return AnimatedBuilder(
      animation: route.animation!,
      child: route.dragBackDetector(
        SideSheet(
          builder: route.builder,
          backgroundColor: widget.backgroundColor,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        final curve = route.isDragBackActive ? Curves.linear : _sideSheetCurve;
        final double animationValue = curve.transform(route.animation!.value);
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: _SideSheetLayoutWithSizeListener(
              onChildSizeChanged: (Size size) {
                widget.route._didChangeBarrierSemanticsClip(
                  _getNewClipDetails(size),
                );
              },
              animationValue: animationValue,
              width: width,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ModalSideSheetRoute<T> extends PopupRoute<T>
    with DragBackRouteMixin<T>, SheetCoverRouteMixin<T> {
  ModalSideSheetRoute({
    required this.builder,
    this.barrierLabel,
    this.barrierOnTapHint,
    this.backgroundColor,
    this.modalBarrierColor,
  });

  final WidgetBuilder builder;

  final Color? backgroundColor;

  final Color? modalBarrierColor;

  final String? barrierOnTapHint;

  final ValueNotifier<EdgeInsets> _clipDetailsNotifier =
      ValueNotifier<EdgeInsets>(EdgeInsets.zero);

  @override
  void dispose() {
    _clipDetailsNotifier.dispose();
    super.dispose();
  }

  bool _didChangeBarrierSemanticsClip(EdgeInsets newClipDetails) {
    if (_clipDetailsNotifier.value == newClipDetails) {
      return false;
    }
    _clipDetailsNotifier.value = newClipDetails;
    return true;
  }

  @override
  Duration get transitionDuration => _sideSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _sideSheetExitDuration;

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  @override
  AnimationController createAnimationController() {
    return SideSheet.createAnimationController(navigator!);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget content = DisplayFeatureSubScreen(
      child: Builder(
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          return _ModalSideSheet<T>(
            route: this,
            backgroundColor:
                backgroundColor ?? SurfaceLevel.page.colorOf(colorScheme),
          );
        },
      ),
    );

    return ElevatedSurfaceTheme(child: content);
  }

  @override
  Widget buildModalBarrier() {
    if (barrierColor.a != 0 && !offstage) {
      assert(barrierColor != barrierColor.opacity0);
      final Animation<Color?> color = animation!.drive(
        ColorTween(
          begin: barrierColor.opacity0,
          end: barrierColor,
        ).chain(CurveTween(curve: barrierCurve)),
      );
      return AnimatedModalBarrier(
        color: color,
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        clipDetailsNotifier: _clipDetailsNotifier,
        semanticsOnTapHint: barrierOnTapHint,
      );
    } else {
      return ModalBarrier(
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
        clipDetailsNotifier: _clipDetailsNotifier,
        semanticsOnTapHint: barrierOnTapHint,
      );
    }
  }
}

Future<T?> showModalSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final navigator = sheetNavigatorOf(context);
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  return navigator.push(
    ModalSideSheetRoute<T>(
      builder: builder,
      barrierLabel: localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      backgroundColor: backgroundColor,
      modalBarrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
    ),
  );
}
