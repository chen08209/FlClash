import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/scaffold.dart';
import 'package:fl_clash/ui/sheet.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:fl_clash/ui/view_scope.dart';
import 'package:material_ui/material_ui.dart';

extension BuildContextExtension on BuildContext {
  CommonScaffoldState? get commonScaffoldState {
    return findAncestorStateOfType<CommonScaffoldState>();
  }

  bool get isMobileView => ViewScope.isMobileOf(this, listen: false);

  void safeNestedPop<T extends Object?>([T? result]) {
    final nestedPop = SheetProvider.of(this)?.nestedNavigatorPop;
    if (nestedPop != null) {
      return nestedPop(result);
    } else {
      return Navigator.of(this).pop(result);
    }
  }

  bool get isInBottomSheet =>
      SheetProvider.of(this)?.type == SheetType.bottomSheet;

  /// Where a page's app bar ends, for a body built outside the scaffold's.
  double get appBarInset =>
      FloatingBarScope.of(this) ??
      (isInBottomSheet
          ? sheetAppBarHeight
          : MediaQuery.paddingOf(this).top + pageToolbarHeight);

  /// A bottom sheet's header already trails its own gap.
  double get contentTopPadding =>
      TopInsetScope.of(this) ??
      (isInBottomSheet ? sheetAppBarHeight : appBarInset + 12);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get disableAnimations => MediaQuery.disableAnimationsOf(this);

  Duration motionDuration(Duration duration) =>
      disableAnimations ? Duration.zero : duration;

  TextStyle get listTitleStyle =>
      AppTextStyle.body.of(this).copyWith(color: colorScheme.onSurface);

  TextStyle get listSubtitleStyle => AppTextStyle.subheadline
      .of(this)
      .copyWith(color: colorScheme.onSurfaceVariant);

  TextStyle get listCaptionStyle => AppTextStyle.footnote
      .of(this)
      .copyWith(color: colorScheme.onSurfaceVariant);

  TextStyle get cardHeaderStyle => AppTextStyle.subheadline
      .of(this, emphasized: true)
      .copyWith(color: colorScheme.onSurfaceVariant.opacity80);
}
