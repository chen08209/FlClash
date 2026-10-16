import 'dart:async';

import 'package:fl_clash/ui/deferred_push.dart';
import 'package:fl_clash/ui/drag_back.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/ui/navigator_resizable.dart';
import 'package:fl_clash/ui/page_transition.dart';
import 'package:fl_clash/ui/pop_scope.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/sheet.dart';
import 'package:fl_clash/ui/sheet_navigator.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:material_ui/material_ui.dart';

Color _sheetColorOf(BuildContext context) =>
    SurfaceLevel.page.colorOf(ColorScheme.of(context));

class PagedSheetRoute<T> extends PageRoute<T>
    with
        DragBackRouteMixin<T>,
        ResizableNavigatorRouteMixin<T>,
        DeferredPushRouteMixin<T> {
  PagedSheetRoute({required this.builder});

  final WidgetBuilder builder;

  ScrollController? _sheetScroll;

  @override
  bool get maintainState => true;

  /// Whether the page below sat still as this one came in, so it fades out on
  /// this route's animation and leaves only the sheet's surface beneath.
  bool _overSettledPage = false;

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    _overSettledPage =
        previousRoute is PagedSheetRoute &&
        previousRoute.animation!.isCompleted &&
        previousRoute.secondaryAnimation!.isDismissed;
  }

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
  Duration get transitionDuration => SharedXPageTransition.duration;

  @override
  Duration get reverseTransitionDuration => SharedXPageTransition.duration;

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
      child: resizableContent(
        sheetScroll == null
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
    final color = _sheetColorOf(context);
    final dragging = isDragBackActive;
    return dragBackDetector(
      dragBackSlide(
        context,
        animation,
        SharedXPageTransition(
          animation: dragging ? kAlwaysCompleteAnimation : animation,
          secondaryAnimation: dragging
              ? kAlwaysDismissedAnimation
              : secondaryAnimation,
          color: color,
          slide: SharedXPageTransition.pageSlide,
          overSettledPage: _overSettledPage,
          uncoveredByGesture: navigator!.userGestureInProgress,
          child: ColoredBox(
            color: dragging ? color : Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}

class PagedSheet extends StatelessWidget {
  const PagedSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final type = SheetProvider.of(context)?.type;
    return Material(
      animationDuration: Duration.zero,
      color: _sheetColorOf(context),
      shape: type == SheetType.bottomSheet
          ? AppShape.top(AppCorner.xxl)
          : AppShape.none,
      clipBehavior: Clip.antiAlias,
      child: NavigatorResizable(child: child),
    );
  }
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

  void _popSheet([Object? result]) => Navigator.of(context).pop(result);

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
        nestedNavigatorPop: _popSheet,
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
