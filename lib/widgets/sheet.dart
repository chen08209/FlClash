import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sheet_navigator.dart';
import 'side_sheet.dart';
import 'snap_sheet.dart';

@immutable
class SheetProps {
  final double? maxWidth;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool useSafeArea;
  final Color? backgroundColor;

  const SheetProps({
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.useSafeArea = true,
    this.isScrollControlled = false,
  });
}

@immutable
class ExtendProps {
  final double? maxWidth;
  final bool useSafeArea;
  final bool forceFull;

  const ExtendProps({
    this.maxWidth,
    this.useSafeArea = true,
    this.forceFull = false,
  });
}

enum SheetType { page, bottomSheet, sideSheet }

/// Material's cap for a bottom sheet that does not control its own scrolling.
const shortSheetMaxHeight = 9 / 16;

Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = context.isMobileView;
  final barrierColor = context.colorScheme.modalScrim;
  if (isMobile) {
    final navigator = sheetNavigatorOf(context);
    return navigator.push(
      SnapSheetRoute<T>(
        builder: (sheetContext, _) => builder(sheetContext),
        fitMaxHeight: props.isScrollControlled ? 1 : shortSheetMaxHeight,
        sheetBarrierColor: barrierColor,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
      ),
    );
  }
  return showModalSideSheet<T>(
    useSafeArea: props.useSafeArea,
    isScrollControlled: props.isScrollControlled,
    context: context,
    backgroundColor: props.backgroundColor,
    constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
    barrierColor: barrierColor,
    builder: (sheetContext) {
      return SheetProvider(
        type: SheetType.sideSheet,
        child: builder(sheetContext),
      );
    },
  );
}

Future<T?> showExtend<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  final isMobile = context.isMobileView;
  return switch (isMobile || props.forceFull) {
    true => BaseNavigator.push(
      context,
      SheetProvider(type: SheetType.page, child: builder(context)),
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      context: context,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      barrierColor: context.colorScheme.modalScrim,
      builder: (context) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
}

/// Opens a sheet the reader can drag between [detents], starting at the
/// shortest. Where a sheet cannot have detents the
/// content keeps its own scroll controller, [initialScrollOffset] is the
/// caller's own business, and [controller] stays detached.
///
/// The sheet follows the view across the mobile breakpoint: it reopens in the
/// other form, and the result is whichever form the reader closes.
Future<T?> showSnapSheet<T>(
  BuildContext context, {
  required SnapSheetBuilder builder,
  double initialScrollOffset = 0,
  List<double> detents = snapSheetDetents,
  double? collapsedDetent,
  SnapSheetController? controller,
}) {
  final completer = Completer<T?>();

  void open({required bool isMobile}) {
    var crossed = false;
    var popped = false;

    // The mobile layout drops a desktop page's navigator, sheet and all.
    void reopenIfDropped() {
      if (crossed || popped) {
        return;
      }
      crossed = true;
      if (!isMobile) {
        controller?.detachSide();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          open(isMobile: context.isMobileView);
        } else {
          completer.complete();
        }
      });
    }

    Widget home(BuildContext sheetContext, ScrollController? controller) {
      return _SnapSheetHome(
        isMobile: isMobile,
        onCross: () {
          if (crossed || !sheetContext.mounted || !context.mounted) {
            return;
          }
          if (ModalRoute.of(sheetContext)?.isCurrent != true) {
            return;
          }
          crossed = true;
          Navigator.of(sheetContext).pop();
          open(isMobile: !isMobile);
        },
        onDispose: reopenIfDropped,
        child: builder(sheetContext, controller),
      );
    }

    final barrierColor = context.colorScheme.modalScrim;
    final Future<T?> closed;
    if (isMobile) {
      final navigator = sheetNavigatorOf(context);
      closed = navigator.push(
        SnapSheetRoute<T>(
          builder: home,
          detents: detents,
          collapsedDetent: collapsedDetent,
          initialScrollOffset: initialScrollOffset,
          sheetController: controller,
          sheetBarrierColor: barrierColor,
          barrierLabel: MaterialLocalizations.of(
            context,
          ).modalBarrierDismissLabel,
          capturedThemes: InheritedTheme.capture(
            from: context,
            to: navigator.context,
          ),
        ),
      );
    } else {
      controller?.attachSide();
      closed = showModalSideSheet<T>(
        context: context,
        constraints: const BoxConstraints(maxWidth: 360),
        barrierColor: barrierColor,
        aside: controller?.aside,
        builder: (context) {
          return SheetProvider(
            type: SheetType.sideSheet,
            child: home(context, null),
          );
        },
      );
    }
    unawaited(
      closed.then((value) {
        popped = true;
        if (!isMobile) {
          controller?.detachSide();
        }
        if (!crossed) {
          completer.complete(value);
        }
      }),
    );
  }

  open(isMobile: context.isMobileView);
  return completer.future;
}

class _SnapSheetHome extends ConsumerStatefulWidget {
  const _SnapSheetHome({
    required this.isMobile,
    required this.onCross,
    required this.onDispose,
    required this.child,
  });

  final bool isMobile;
  final VoidCallback onCross;
  final VoidCallback onDispose;
  final Widget child;

  @override
  ConsumerState<_SnapSheetHome> createState() => _SnapSheetHomeState();
}

class _SnapSheetHomeState extends ConsumerState<_SnapSheetHome> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(isMobileViewProvider) != widget.isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onCross());
    }
    return widget.child;
  }
}
