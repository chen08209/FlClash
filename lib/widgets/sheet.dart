import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = context.isMobileView;
  final barrierColor = context.colorScheme.modalScrim;
  return switch (isMobile) {
    true => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: props.isScrollControlled,
      builder: (_) {
        return SheetProvider(
          type: SheetType.bottomSheet,
          child: builder(context),
        );
      },
      backgroundColor: props.backgroundColor,
      barrierColor: barrierColor,
      showDragHandle: false,
      useSafeArea: props.useSafeArea,
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      isScrollControlled: props.isScrollControlled,
      context: context,
      backgroundColor: props.backgroundColor,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      barrierColor: barrierColor,
      builder: (_) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
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

/// Opens a sheet the reader can drag between [snapSheetDetents]. Where a
/// sheet cannot have detents the content keeps its own scroll controller and
/// [initialScrollOffset] is the caller's own business.
///
/// The sheet follows the view across the mobile breakpoint: it reopens in the
/// other form, and the result is whichever form the reader closes.
Future<T?> showSnapSheet<T>(
  BuildContext context, {
  required SnapSheetBuilder builder,
  double initialScrollOffset = 0,
}) {
  final completer = Completer<T?>();

  void open({required bool isMobile}) {
    var crossed = false;
    Widget home(BuildContext sheetContext, ScrollController? controller) {
      return _SnapSheetHome(
        isMobile: isMobile,
        onCross: () {
          final route = ModalRoute.of(sheetContext);
          if (crossed || route?.isCurrent != true || !context.mounted) {
            return;
          }
          crossed = true;
          Navigator.of(sheetContext).pop();
          open(isMobile: !isMobile);
        },
        child: builder(sheetContext, controller),
      );
    }

    final barrierColor = context.colorScheme.modalScrim;
    final Future<T?> closed;
    if (isMobile) {
      final navigator = Navigator.of(context);
      closed = navigator.push(
        SnapSheetRoute<T>(
          builder: home,
          initialScrollOffset: initialScrollOffset,
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
      closed = showModalSideSheet<T>(
        context: context,
        constraints: const BoxConstraints(maxWidth: 360),
        barrierColor: barrierColor,
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
        if (!crossed) {
          completer.complete(value);
        }
      }),
    );
  }

  open(isMobile: context.isMobileView);
  return completer.future;
}

class _SnapSheetHome extends ConsumerWidget {
  const _SnapSheetHome({
    required this.isMobile,
    required this.onCross,
    required this.child,
  });

  final bool isMobile;
  final VoidCallback onCross;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isMobileViewProvider) != isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onCross());
    }
    return child;
  }
}
