import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:navigator_resizable/navigator_resizable.dart';

Color _sheetColorOf(BuildContext context) {
  return SheetProvider.of(context)?.type == SheetType.bottomSheet
      ? ColorScheme.of(context).surfaceContainerLow
      : ColorScheme.of(context).surface;
}

/// A route for the [PagedSheet]'s nested navigator.
///
/// Mixes in [ObservableRouteMixin] and wraps its content in a
/// [ResizableNavigatorRouteContentBoundary] so that the enclosing
/// [NavigatorResizable] can size the sheet to the current page and animate
/// the height along with the transition.
class PagedSheetRoute<T> extends PageRoute<T> with ObservableRouteMixin<T> {
  PagedSheetRoute({
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.requestFocus,
    this.maintainState = true,
    this.duration = const Duration(milliseconds: 350),
    this.backgroundColor,
    this.transitionsBuilder,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  final Duration duration;
  final Color? backgroundColor;
  final RouteTransitionsBuilder? transitionsBuilder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is PagedSheetRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is PagedSheetRoute;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ResizableNavigatorRouteContentBoundary(child: builder(context)),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (transitionsBuilder case final builder?) {
      return builder(context, animation, secondaryAnimation, child);
    }
    return FadeForwardsPageTransitionsBuilder(
      backgroundColor: backgroundColor ?? _sheetColorOf(context),
    ).buildTransitions(this, context, animation, secondaryAnimation, child);
  }
}

/// A sheet surface hosting a nested navigator of [PagedSheetRoute]s.
///
/// The sheet shrinks to the height of the current page, so it must be given
/// bounded but non-tight constraints, e.g. by an [Align] that leaves the
/// height loose.
class PagedSheet extends StatelessWidget {
  const PagedSheet({
    super.key,
    this.color,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  final Color? color;
  final ShapeBorder? shape;
  final Clip clipBehavior;

  /// The nested [Navigator] whose current [PagedSheetRoute] drives the height.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final type = SheetProvider.of(context)?.type;
    return Material(
      animationDuration: Duration.zero,
      color: color ?? _sheetColorOf(context),
      shape:
          shape ??
          (type == SheetType.bottomSheet
              ? AppShape.top(AppCorner.xxl)
              : AppShape.none),
      clipBehavior: clipBehavior,
      child: NavigatorResizable(child: child),
    );
  }
}
