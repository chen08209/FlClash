import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/models/widget.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  CommonScaffoldState? get commonScaffoldState {
    return findAncestorStateOfType<CommonScaffoldState>();
  }

  void showNotifier(String text, {MessageActionState? actionState}) {
    return findAncestorStateOfType<StatusManagerState>()?.message(
      text,
      actionState: actionState,
    );
  }

  void showSnackBar(String message, {SnackBarAction? action}) {
    final width = viewWidth;
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

  Size get appSize {
    return MediaQuery.of(this).size;
  }

  double get viewWidth {
    return appSize.width;
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppLocalizations get appLocalizations => AppLocalizations.of(this);

  T? findLastStateOfType<T extends State>() {
    T? state;

    visitor(Element element) {
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

class BackHandleInherited extends InheritedWidget {
  final Function handleBack;

  const BackHandleInherited({
    super.key,
    required this.handleBack,
    required super.child,
  });

  static BackHandleInherited? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackHandleInherited>();

  @override
  bool updateShouldNotify(BackHandleInherited oldWidget) {
    return handleBack != oldWidget.handleBack;
  }
}
