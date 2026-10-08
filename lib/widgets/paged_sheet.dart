import 'dart:async';

import 'package:fl_clash/common/color.dart';
import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/deferred_push.dart';
import 'package:fl_clash/widgets/drag_back.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/navigator_resizable.dart';
import 'package:fl_clash/widgets/page_transition.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_navigator.dart';
import 'package:material_ui/material_ui.dart';

Color _sheetColorOf(BuildContext context) {
  return SheetProvider.of(context)?.type == SheetType.bottomSheet
      ? ColorScheme.of(context).surfaceContainerLow
      : ColorScheme.of(context).surface;
}

bool _stacksPages(BuildContext context) => SheetStackScope.of(context) != null;

class PagedSheetRoute<T> extends PageRoute<T>
    with
        DragBackRouteMixin<T>,
        ResizableNavigatorRouteMixin<T>,
        DeferredPushRouteMixin<T> {
  PagedSheetRoute({
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.requestFocus,
    this.maintainState = true,
    this.duration = SharedXPageTransition.duration,
    this.backgroundColor,
    this.transitionsBuilder,
    required this.builder,
  });

  final WidgetBuilder builder;

  ScrollController? _sheetScroll;
  CurvedAnimation? _stackEntrance;
  CurvedAnimation? _stackCover;

  @override
  final bool maintainState;

  final Duration duration;
  final Color? backgroundColor;
  final RouteTransitionsBuilder? transitionsBuilder;

  /// Whether the page below sat still as this one came in, so it fades out on
  /// this route's animation and leaves only the sheet's surface beneath.
  bool _overSettledPage = false;

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    _overSettledPage =
        previousRoute is PagedSheetRoute &&
        previousRoute.transitionsBuilder == null &&
        previousRoute.animation!.isCompleted &&
        previousRoute.secondaryAnimation!.isDismissed;
  }

  @override
  void dispose() {
    _sheetScroll?.dispose();
    _stackEntrance?.dispose();
    _stackCover?.dispose();
    super.dispose();
  }

  /// A stacked page leaves the one it covers painted, peeking above it.
  @override
  bool get opaque {
    final context = navigator?.context;
    return context == null || !_stacksPages(context);
  }

  double _stackInset(BuildContext context) {
    return _stacksPages(context) && !isFirst ? stackedSheetPeek : 0;
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
    final inset = _stackInset(context);
    final content = sheetScroll == null
        ? page
        : PrimaryScrollController(
            controller: sheetScroll,
            automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
            child: page,
          );
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: resizableContent(
        inset == 0
            ? content
            : Padding(
                padding: EdgeInsets.only(top: inset),
                child: content,
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
    if (transitionsBuilder == null && _stacksPages(context)) {
      return dragBackDetector(
        _buildStackTransitions(
          context,
          animation,
          secondaryAnimation,
          color,
          child,
        ),
      );
    }
    final dragging = isDragBackActive;
    final pageAnimation = dragging ? kAlwaysCompleteAnimation : animation;
    final pageSecondaryAnimation = dragging
        ? kAlwaysDismissedAnimation
        : secondaryAnimation;
    final page = ColoredBox(
      color: dragging ? color : Colors.transparent,
      child: child,
    );
    return dragBackDetector(
      dragBackSlide(context, animation, switch (transitionsBuilder) {
        final builder? => builder(
          context,
          pageAnimation,
          pageSecondaryAnimation,
          page,
        ),
        null => SharedXPageTransition(
          animation: pageAnimation,
          secondaryAnimation: pageSecondaryAnimation,
          color: color,
          slide: SharedXPageTransition.pageSlide,
          overSettledPage: _overSettledPage,
          uncoveredByGesture: navigator!.userGestureInProgress,
          child: page,
        ),
      }),
    );
  }

  Widget _buildStackTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Color color,
    Widget child,
  ) {
    final cover = navigator!.userGestureInProgress
        ? secondaryAnimation.value
        : (_stackCover ??= CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.linearToEaseOut,
            reverseCurve: Curves.easeInToLinear,
          )).value;
    final inset = _stackInset(context);
    final scrim = ColorScheme.of(context).modalScrim;
    final card = Transform.scale(
      scale: 1 - (1 - stackedSheetScale) * cover,
      alignment: Alignment.topCenter,
      origin: Offset(0, inset),
      child: _StackedPageCard(
        inset: inset,
        color: color,
        // Half the scrim under the sheet, so the covered page's edge stays
        // apart from what that scrim dims.
        scrim: scrim.withValues(alpha: scrim.a * cover / 2),
        child: child,
      ),
    );
    final entrance = isDragBackActive
        ? 1.0
        : (_stackEntrance ??= CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          )).value;
    return dragBackSlide(
      context,
      animation,
      FractionalTranslation(translation: Offset(0, 1 - entrance), child: card),
    );
  }
}

/// Paints down to the bottom of the sheet, under content shorter than it.
class _StackedPageCard extends StatelessWidget {
  const _StackedPageCard({
    required this.inset,
    required this.color,
    required this.scrim,
    required this.child,
  });

  final double inset;
  final Color color;
  final Color scrim;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.top(AppCorner.xxl);
    return CustomPaint(
      painter: _StackedPagePainter(inset: inset, radius: radius, color: color),
      foregroundPainter: scrim.a == 0
          ? null
          : _StackedPagePainter(inset: inset, radius: radius, color: scrim),
      child: ClipRSuperellipse(
        clipper: _StackedPageClipper(inset: inset, radius: radius),
        child: child,
      ),
    );
  }
}

RSuperellipse _stackedPageShape(Size size, double inset, BorderRadius radius) {
  return radius.toRSuperellipse(
    Rect.fromLTRB(0, inset, size.width, size.height),
  );
}

class _StackedPagePainter extends CustomPainter {
  const _StackedPagePainter({
    required this.inset,
    required this.radius,
    required this.color,
  });

  final double inset;
  final BorderRadius radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRSuperellipse(
      _stackedPageShape(size, inset, radius),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_StackedPagePainter oldDelegate) =>
      inset != oldDelegate.inset ||
      radius != oldDelegate.radius ||
      color != oldDelegate.color;
}

class _StackedPageClipper extends CustomClipper<RSuperellipse> {
  const _StackedPageClipper({required this.inset, required this.radius});

  final double inset;
  final BorderRadius radius;

  @override
  RSuperellipse getClip(Size size) => _stackedPageShape(size, inset, radius);

  @override
  bool shouldReclip(_StackedPageClipper oldClipper) =>
      inset != oldClipper.inset || radius != oldClipper.radius;
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
    final surface = color ?? _sheetColorOf(context);
    final stacks = _stacksPages(context);
    final sheet = Material(
      animationDuration: Duration.zero,
      color: stacks ? Colors.transparent : surface,
      shape:
          shape ??
          (type == SheetType.bottomSheet
              ? AppShape.top(AppCorner.xxl)
              : AppShape.none),
      clipBehavior: clipBehavior,
      child: NavigatorResizable(child: child),
    );
    if (!stacks) {
      return sheet;
    }
    // The pages paint the surface, so this fills the space a drag past the
    // tallest detent stretches below them.
    return CustomPaint(
      painter: _SkirtPainter(
        color: surface,
        depth: MediaQuery.heightOf(context),
      ),
      child: sheet,
    );
  }
}

class _SkirtPainter extends CustomPainter {
  const _SkirtPainter({required this.color, required this.depth});

  final Color color;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height, size.width, depth),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SkirtPainter oldDelegate) =>
      color != oldDelegate.color || depth != oldDelegate.depth;
}

/// Pushes the page into the sheet [context] is a page of, and opens it with
/// [showExtend] anywhere else.
Future<T?> showSheetPageOrExtend<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(PagedSheetRoute<T>(builder: builder));
  }
  return showExtend<T>(context, builder: builder);
}

/// Pushes the page into the sheet [context] is a page of, and opens a sheet
/// for it anywhere else.
Future<T?> showInSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(PagedSheetRoute<T>(builder: builder));
  }
  return showSheet<T>(context: context, builder: builder);
}

const nestedPagedSheetProps = SheetProps(backgroundColor: Colors.transparent);

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
  ValueNotifier<bool>? _surfaceClaimed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final surfaceClaimed = SheetStackScope.of(context);
    if (!identical(surfaceClaimed, _surfaceClaimed)) {
      _surfaceClaimed?.value = false;
      _surfaceClaimed = surfaceClaimed?..value = true;
    }
    final handler = SheetDismissScope.of(context);
    if (identical(handler, _dismissHandler)) {
      return;
    }
    _releaseDismiss();
    _dismissHandler = handler?..value = _handleDismiss;
  }

  @override
  void dispose() {
    _surfaceClaimed?.value = false;
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
        onClose: _handlePop,
        // A bottom sheet's route takes the taps outside it and the drag away.
        child: sheetProvider.type == SheetType.bottomSheet
            ? sheet
            : SizedBox(
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
