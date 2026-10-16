import 'dart:async';

import 'package:fl_clash/ui/dialog.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/ui/sheet.dart';
import 'package:fl_clash/ui/sheet_navigator.dart';
import 'package:fl_clash/ui/shape.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:material_ui/material_ui.dart';

const double _width = 440;
const double _maxHeight = 720;
const double _margin = 40;

/// A form in a card centered over the navigator, moving as a dialog does.
class FormSheetRoute<T> extends PopupRoute<T>
    with SheetCoverRouteMixin<T>, AlertMotionRouteMixin<T>, AlertHostRoute<T> {
  FormSheetRoute({
    required this.builder,
    required this.barrierColor,
    required this.barrierLabel,
    this.backgroundColor,
  });

  final WidgetBuilder builder;
  final Color? backgroundColor;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  final _dismissHandler = ValueNotifier<SheetDismissHandler?>(null);

  @override
  VoidCallback get onBarrierDismiss =>
      () => unawaited(_dismiss());

  Future<void> _dismiss() async {
    final handler = _dismissHandler.value;
    if (handler != null) {
      await handler();
    } else {
      await navigator?.maybePop();
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ElevatedSurfaceTheme(
      child: _FormSheet(
        backgroundColor: backgroundColor,
        dismissHandler: _dismissHandler,
        builder: builder,
      ),
    );
  }

  @override
  void dispose() {
    _dismissHandler.dispose();
    super.dispose();
  }
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.backgroundColor,
    required this.dismissHandler,
    required this.builder,
  });

  final Color? backgroundColor;
  final ValueNotifier<SheetDismissHandler?> dismissHandler;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            _margin,
          ).copyWith(bottom: _margin + keyboard),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _width,
                maxHeight: _maxHeight,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color:
                      backgroundColor ??
                      SurfaceLevel.page.colorOf(theme.colorScheme),
                  shape: theme.dialogTheme.shape ?? AppShape.xxl,
                  clipBehavior: Clip.antiAlias,
                  child: MediaQuery.removeViewInsets(
                    context: context,
                    removeBottom: true,
                    child: SheetProvider(
                      type: SheetType.formSheet,
                      child: SheetDismissScope(
                        handler: dismissHandler,
                        child: Builder(builder: builder),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
