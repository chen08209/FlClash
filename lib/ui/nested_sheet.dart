import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// Opened from a sheet, moves in as that sheet's next page, which the sheet
/// sizes itself to; elsewhere, pushes [page] as a page of its own.
Future<T?> pushNestedPage<T>(BuildContext context, Widget page) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(PagedSheetRoute<T>(builder: (_) => page));
  }
  return BaseNavigator.push<T>(context, page);
}

/// Opened from a sheet, moves in as that sheet's next page on every layout;
/// elsewhere, opens a sheet that holds the pages opened from it.
Future<T?> showNestedSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  List<double> detents = snapSheetDetents,
}) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(PagedSheetRoute<T>(builder: builder));
  }
  return showSheet<T>(
    context: context,
    props: SheetProps(
      backgroundColor: nestedPagedSheetProps.backgroundColor,
      detents: detents,
    ),
    builder: (_) => NestedPagedSheet(builder: builder),
  );
}

Future<T?> showNestedExtend<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(PagedSheetRoute<T>(builder: builder));
  }
  if (context.isMobileView || props.forceFull) {
    return showExtend<T>(context, props: props, builder: builder);
  }
  return showExtend<T>(
    context,
    props: props,
    builder: (_) => NestedPagedSheet(builder: builder),
  );
}
