import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension BuildContextExtension on BuildContext {
  CommonScaffoldState? get commonScaffoldState {
    return findAncestorStateOfType<CommonScaffoldState>();
  }

  bool get isMobileView {
    return ProviderScope.containerOf(
      this,
      listen: false,
    ).read(isMobileViewProvider);
  }

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

  /// How far a page's app bar reaches over the top of its body.
  ///
  /// Where a page builds the body it hands its scaffold, outside that body,
  /// this is where the bar will end: a toolbar below the status bar.
  double get appBarInset =>
      FloatingBarScope.of(this) ??
      (isInBottomSheet
          ? sheetAppBarHeight
          : MediaQuery.paddingOf(this).top + pageToolbarHeight);

  /// Where a scaffold body's content starts: a gap clear of the bar; a bottom
  /// sheet's header already trails its own gap.
  double get contentTopPadding =>
      TopInsetScope.of(this) ??
      (isInBottomSheet ? sheetAppBarHeight : appBarInset + 12);

  void showNotifier(
    String text, {
    MessageLevel level = MessageLevel.info,
    MessageActionState? actionState,
  }) {
    return findAncestorStateOfType<StatusManagerState>()?.message(
      text,
      level: level,
      actionState: actionState,
    );
  }

  void showSnackBar(String message, {SnackBarAction? action}) {
    final width = MediaQuery.sizeOf(this).width;
    EdgeInsets margin;
    if (width < 600) {
      margin = const EdgeInsets.only(bottom: 16, right: 16, left: 16);
    } else {
      margin = EdgeInsets.only(bottom: 16, left: 16, right: width - 316);
    }
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        action: action,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        margin: margin,
      ),
    );
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get disableAnimations => MediaQuery.disableAnimationsOf(this);

  Duration motionDuration(Duration duration) =>
      disableAnimations ? Duration.zero : duration;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppLocalizations get appLocalizations => AppLocalizations.of(this);

  T? findLastStateOfType<T extends State>() {
    T? state;

    void visitor(Element element) {
      if (!element.mounted) {
        return;
      }
      if (element is StatefulElement) {
        if (element.state is T) {
          state = element.state as T;
        }
      }
      element.visitChildren(visitor);
    }

    visitor(this as Element);
    return state;
  }
}
