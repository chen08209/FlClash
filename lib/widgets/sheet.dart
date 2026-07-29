import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'scaffold.dart';
import 'side_sheet.dart';

@immutable
class SheetProps {
  final double? maxWidth;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool blur;

  const SheetProps({
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.useSafeArea = true,
    this.isScrollControlled = false,
    this.blur = true,
  });
}

@immutable
class ExtendProps {
  final double? maxWidth;
  final bool useSafeArea;
  final bool blur;
  final bool forceFull;

  const ExtendProps({
    this.maxWidth,
    this.useSafeArea = true,
    this.blur = true,
    this.forceFull = false,
  });
}

enum SheetType { page, bottomSheet, sideSheet }

Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = globalState.container.read(isMobileViewProvider);
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
      showDragHandle: false,
      useSafeArea: props.useSafeArea,
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      isScrollControlled: props.isScrollControlled,
      context: context,
      backgroundColor: props.backgroundColor,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
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
  final isMobile = globalState.container.read(isMobileViewProvider);
  return switch (isMobile || props.forceFull) {
    true => BaseNavigator.push(
      context,
      SheetProvider(type: SheetType.page, child: builder(context)),
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      context: context,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (context) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
}

class AdaptiveSheetScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final bool sheetTransparentToolBar;
  final List<IconButtonData> actions;
  final VoidCallback? backAction;

  const AdaptiveSheetScaffold({
    super.key,
    required this.body,
    required this.title,
    this.sheetTransparentToolBar = false,
    this.actions = const [],
    this.backAction,
  });

  @override
  State<AdaptiveSheetScaffold> createState() => _AdaptiveSheetScaffoldState();
}

class _AdaptiveSheetScaffoldState extends State<AdaptiveSheetScaffold> {
  final _isScrolledController = ValueNotifier<bool>(false);

  IconData get backIconData {
    if (kIsWeb) {
      return Icons.arrow_back;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Icons.arrow_back;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.arrow_back_ios_new_rounded;
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveSheetScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backAction != widget.backAction) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isScrolledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetProvider = SheetProvider.of(context);
    final nestedNavigatorPop = sheetProvider?.nestedNavigatorPop;
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final type = sheetProvider?.type ?? SheetType.page;
    final backgroundColor = type == SheetType.bottomSheet
        ? context.colorScheme.surfaceContainerLow
        : context.colorScheme.surface;
    final useCloseIcon =
        type != SheetType.page &&
        (nestedNavigatorPop != null && route?.impliesAppBarDismissal == false ||
            nestedNavigatorPop == null);
    Widget buildIconButton(IconButtonData data) {
      if (type == SheetType.bottomSheet) {
        return IconButton.filledTonal(
          onPressed: data.onPressed,
          style: IconButton.styleFrom(
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(data.icon),
        );
      }
      return IconButton(
        onPressed: data.onPressed,
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(data.icon),
      );
    }

    final actions = widget.actions.map(buildIconButton).toList();

    final popButton = type != SheetType.page
        ? (useCloseIcon
              ? buildIconButton(
                  IconButtonData(
                    icon: Icons.close,
                    onPressed: context.safeNestedPop,
                  ),
                )
              : buildIconButton(
                  IconButtonData(
                    icon: backIconData,
                    onPressed:
                        widget.backAction ??
                        () {
                          Navigator.of(context).pop();
                        },
                  ),
                ))
        : null;

    final suffixPop = type != SheetType.page && actions.isEmpty && useCloseIcon;
    final appBar = AppBar(
      backgroundColor: backgroundColor,
      forceMaterialTransparency: type == SheetType.bottomSheet ? true : false,
      leading: suffixPop ? null : popButton,
      automaticallyImplyLeading: type == SheetType.page ? true : false,
      centerTitle: true,
      toolbarHeight: type == SheetType.bottomSheet ? 48 : null,
      title: Text(widget.title),
      titleTextStyle: type == SheetType.bottomSheet
          ? context.textTheme.titleLarge?.adjustSize(-4)
          : null,
      actions: !suffixPop ? genActions(actions) : genActions([?popButton]),
    );
    if (type == SheetType.bottomSheet) {
      const handleSize = Size(28, 4);
      final sheetAppBar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              alignment: Alignment.center,
              height: handleSize.height,
              width: handleSize.width,
              decoration: ShapeDecoration(
                color: context.colorScheme.onSurfaceVariant,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(handleSize.height / 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: appBar,
          ),
          const SizedBox(height: 6),
        ],
      );
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.sheetTransparentToolBar) ...[
              sheetAppBar,
              Flexible(child: widget.body),
            ] else ...[
              Flexible(
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      child: widget.body,
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          final pixels = notification.metrics.pixels;
                          _isScrolledController.value = pixels > 6;
                        }
                        return false;
                      },
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ValueListenableBuilder(
                        valueListenable: _isScrolledController,
                        builder: (_, isScrolled, child) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            child: BackdropFilter(
                              filter: commonFilter,
                              child: ColoredBox(
                                color: isScrolled
                                    ? backgroundColor.opacity60
                                    : backgroundColor,
                                child: child!,
                              ),
                            ),
                          );
                        },
                        child: sheetAppBar,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      );
    }
    return CommonScaffold(appBar: appBar, body: widget.body);
  }
}
