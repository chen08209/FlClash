import 'package:flutter/material.dart';

class FadePage<T> extends Page<T> {
  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;
  final bool allowSnapshotting;

  const FadePage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return FadePageRoute<T>(page: this);
  }
}

class FadePageRoute<T> extends PageRoute<T> {
  final FadePage page;

  FadePageRoute({
    required this.page,
  }) : super(settings: page);

  FadePage<T> get _page => settings as FadePage<T>;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _page.child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);

  @override
  bool get maintainState => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;
}
