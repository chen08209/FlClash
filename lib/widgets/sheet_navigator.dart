import 'package:material_ui/material_ui.dart';

/// A sheet's own navigator, which holds only the pages of that sheet.
class SheetPagesNavigator extends Navigator {
  const SheetPagesNavigator({super.key, super.onGenerateInitialRoutes});
}

bool isSheetPage(BuildContext context) =>
    Navigator.maybeOf(context)?.widget is SheetPagesNavigator;

/// A sheet opened from inside another sheet goes over it, sized by the space
/// that sheet is shown in rather than squeezed among its pages.
NavigatorState sheetNavigatorOf(BuildContext context) {
  var navigator = Navigator.of(context);
  while (navigator.widget is SheetPagesNavigator) {
    navigator = navigator.context.findAncestorStateOfType<NavigatorState>()!;
  }
  return navigator;
}
