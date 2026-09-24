import 'dart:async';

import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/drag_back.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_navigator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:navigator_resizable/navigator_resizable.dart';

Color _sheetColorOf(BuildContext context) {
  return SheetProvider.of(context)?.type == SheetType.bottomSheet
      ? ColorScheme.of(context).surfaceContainerLow
      : ColorScheme.of(context).surface;
}

class PagedSheetRoute<T> extends PageRoute<T>
    with ObservableRouteMixin<T>, DragBackRouteMixin<T> {
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

  ScrollController? _sheetScroll;

  @override
  final bool maintainState;

  final Duration duration;
  final Color? backgroundColor;
  final RouteTransitionsBuilder? transitionsBuilder;

  @override
  void dispose() {
    _sheetScroll?.dispose();
    super.dispose();
  }

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
    final createSheetScroll = SheetScrollScope.of(context);
    if (createSheetScroll != null) {
      _sheetScroll ??= createSheetScroll();
    }
    final sheetScroll = _sheetScroll;
    final page = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ResizableNavigatorRouteContentBoundary(
        child: sheetScroll == null
            ? page
            : PrimaryScrollController(
                controller: sheetScroll,
                automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
                child: page,
              ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final color = backgroundColor ?? _sheetColorOf(context);
    return dragBackDetector(switch (transitionsBuilder) {
      _ when isDragBackActive => dragBackSlide(
        context,
        animation,
        ColoredBox(color: color, child: child),
      ),
      final builder? => builder(context, animation, secondaryAnimation, child),
      null => FadeForwardsPageTransitionsBuilder(
        backgroundColor: color,
      ).buildTransitions(this, context, animation, secondaryAnimation, child),
    });
  }
}

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

const nestedPagedSheetProps = SheetProps(
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  maxWidth: double.maxFinite,
);

/// Opened with [nestedPagedSheetProps]. [onDismiss] is told whether a page is
/// pushed over the root; with no callbacks, back on the root and a tap outside
/// close the sheet.
class NestedPagedSheet extends StatefulWidget {
  const NestedPagedSheet({
    super.key,
    required this.builder,
    this.onExit,
    this.onDismiss,
  });

  final WidgetBuilder builder;
  final VoidCallback? onExit;
  final FutureOr<void> Function(bool hasPushedPages)? onDismiss;

  @override
  State<NestedPagedSheet> createState() => _NestedPagedSheetState();
}

class _NestedPagedSheetState extends State<NestedPagedSheet> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  ValueNotifier<SheetDismissHandler?>? _dismissHandler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final handler = SheetDismissScope.of(context);
    if (identical(handler, _dismissHandler)) {
      return;
    }
    _releaseDismiss();
    _dismissHandler = handler?..value = _handleDismiss;
  }

  @override
  void dispose() {
    _releaseDismiss();
    super.dispose();
  }

  void _releaseDismiss() {
    final handler = _dismissHandler;
    if (handler != null && handler.value == _handleDismiss) {
      handler.value = null;
    }
    _dismissHandler = null;
  }

  bool get _hasPushedPages => _navigatorKey.currentState?.canPop() ?? false;

  void _close() => Navigator.of(context).pop();

  void _handlePop() {
    if (_hasPushedPages) {
      _navigatorKey.currentState!.pop();
      return;
    }
    (widget.onExit ?? _close)();
  }

  Future<void> _handleDismiss() async {
    final onDismiss = widget.onDismiss;
    if (onDismiss == null) {
      _close();
      return;
    }
    await onDismiss(_hasPushedPages);
  }

  @override
  Widget build(BuildContext context) {
    final sheetProvider = SheetProvider.of(context)!;
    final sheet = PagedSheet(
      child: SheetPagesNavigator(
        key: _navigatorKey,
        onGenerateInitialRoutes: (_, _) => [
          PagedSheetRoute(builder: widget.builder),
        ],
      ),
    );
    return CommonPopScope(
      onPop: (_) async {
        _handlePop();
        return false;
      },
      child: sheetProvider.copyWith(
        nestedNavigatorPop: ([data]) => Navigator.of(context).pop(data),
        // A bottom sheet's route takes the taps outside it and the drag away.
        child: sheetProvider.type == SheetType.bottomSheet
            ? sheet
            : SizedBox(
                width: sheetProvider.type == SheetType.sideSheet ? 400 : null,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => unawaited(_handleDismiss()),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: sheet,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
