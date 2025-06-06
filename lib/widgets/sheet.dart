import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

import 'scaffold.dart';
import 'side_sheet.dart';

@immutable
class SheetProps {
  final double? maxWidth;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool useSafeArea;
  final bool blur;

  const SheetProps({
    this.maxWidth,
    this.maxHeight,
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

enum SheetType {
  page,
  bottomSheet,
  sideSheet,
}

typedef SheetBuilder = Widget Function(BuildContext context, SheetType type);

Future<T?> showSheet<T>({
  required BuildContext context,
  required SheetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = globalState.appState.viewMode == ViewMode.mobile;
  return switch (isMobile) {
    true => showModalBottomSheet<T>(
        context: context,
        isScrollControlled: props.isScrollControlled,
        builder: (_) {
          return SafeArea(
            child: builder(context, SheetType.bottomSheet),
          );
        },
        showDragHandle: false,
        useSafeArea: props.useSafeArea,
      ),
    false => showModalSideSheet<T>(
        useSafeArea: props.useSafeArea,
        isScrollControlled: props.isScrollControlled,
        context: context,
        constraints: BoxConstraints(
          maxWidth: props.maxWidth ?? 360,
        ),
        filter: props.blur ? commonFilter : null,
        builder: (_) {
          return builder(context, SheetType.sideSheet);
        },
      ),
  };
}

Future<T?> showExtend<T>(
  BuildContext context, {
  required SheetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  final isMobile = globalState.appState.viewMode == ViewMode.mobile;
  return switch (isMobile || props.forceFull) {
    true => BaseNavigator.push(
        context,
        builder(context, SheetType.page),
      ),
    false => showModalSideSheet<T>(
        useSafeArea: props.useSafeArea,
        context: context,
        constraints: BoxConstraints(
          maxWidth: props.maxWidth ?? 360,
        ),
        filter: props.blur ? commonFilter : null,
        builder: (context) {
          return builder(context, SheetType.sideSheet);
        },
      ),
  };
}

class AdaptiveSheetScaffold extends StatefulWidget {
  final SheetType type;
  final Widget body;
  final String title;
  final List<Widget> actions;

  const AdaptiveSheetScaffold({
    super.key,
    required this.type,
    required this.body,
    required this.title,
    this.actions = const [],
  });

  @override
  State<AdaptiveSheetScaffold> createState() => _AdaptiveSheetScaffoldState();
}

class _AdaptiveSheetScaffoldState extends State<AdaptiveSheetScaffold> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colorScheme.surface;
    final bottomSheet = widget.type == SheetType.bottomSheet;
    final sideSheet = widget.type == SheetType.sideSheet;
    final appBar = AppBar(
      forceMaterialTransparency: bottomSheet ? true : false,
      automaticallyImplyLeading: bottomSheet
          ? false
          : widget.actions.isEmpty && sideSheet
              ? false
              : true,
      centerTitle: bottomSheet,
      backgroundColor: backgroundColor,
      title: Text(
        widget.title,
      ),
      actions: genActions([
        if (widget.actions.isEmpty && sideSheet) CloseButton(),
        ...widget.actions,
      ]),
    );
    if (bottomSheet) {
      final handleSize = Size(32, 4);
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Container(
                alignment: Alignment.center,
                height: handleSize.height,
                width: handleSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(handleSize.height / 2),
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            appBar,
            Flexible(
              flex: 1,
              child: widget.body,
            )
          ],
        ),
      );
    }
    return CommonScaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: widget.body,
    );
  }
}
