import 'package:flutter/widgets.dart';

enum ViewScopeAspect { size, isMobile, windowControls }

class ViewScope extends InheritedModel<ViewScopeAspect> {
  const ViewScope({
    super.key,
    required this.size,
    required this.isMobile,
    this.windowControls = Size.zero,
    required super.child,
  });

  final Size size;
  final bool isMobile;

  /// Caption controls the window draws over a page's top trailing corner.
  final Size windowControls;

  static ViewScope _of(BuildContext context, ViewScopeAspect aspect) {
    final scope = InheritedModel.inheritFrom<ViewScope>(
      context,
      aspect: aspect,
    );
    assert(scope != null, 'No ViewScope found above $context.');
    return scope!;
  }

  static Size sizeOf(BuildContext context) =>
      _of(context, ViewScopeAspect.size).size;

  static bool isMobileOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return _of(context, ViewScopeAspect.isMobile).isMobile;
    }
    final scope = context.getInheritedWidgetOfExactType<ViewScope>();
    assert(scope != null, 'No ViewScope found above $context.');
    return scope!.isMobile;
  }

  static Size windowControlsOf(BuildContext context) =>
      _of(context, ViewScopeAspect.windowControls).windowControls;

  @override
  bool updateShouldNotify(ViewScope oldWidget) =>
      size != oldWidget.size ||
      isMobile != oldWidget.isMobile ||
      windowControls != oldWidget.windowControls;

  @override
  bool updateShouldNotifyDependent(
    ViewScope oldWidget,
    Set<ViewScopeAspect> dependencies,
  ) => dependencies.any(
    (aspect) => switch (aspect) {
      ViewScopeAspect.size => size != oldWidget.size,
      ViewScopeAspect.isMobile => isMobile != oldWidget.isMobile,
      ViewScopeAspect.windowControls =>
        windowControls != oldWidget.windowControls,
    },
  );
}
