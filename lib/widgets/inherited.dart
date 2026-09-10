import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageActivityScope extends InheritedWidget {
  final bool isActive;

  const PageActivityScope({
    super.key,
    required this.isActive,
    required super.child,
  });

  static bool isActiveOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<PageActivityScope>()
            ?.isActive ??
        true;
  }

  @override
  bool updateShouldNotify(PageActivityScope oldWidget) {
    return isActive != oldWidget.isActive;
  }
}

const double _floatingActionButtonHeight = 56;

class BottomInsetScope extends InheritedWidget {
  static const double floatingActionButtonInset =
      kFloatingActionButtonMargin + _floatingActionButtonHeight;

  final double inset;

  const BottomInsetScope({
    super.key,
    required this.inset,
    required super.child,
  });

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<BottomInsetScope>()
            ?.inset ??
        0;
  }

  @override
  bool updateShouldNotify(BottomInsetScope oldWidget) {
    return inset != oldWidget.inset;
  }
}

class CommonScaffoldBackActionProvider extends InheritedWidget {
  final VoidCallback? backAction;

  const CommonScaffoldBackActionProvider({
    super.key,
    required this.backAction,
    required super.child,
  });

  static CommonScaffoldBackActionProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CommonScaffoldBackActionProvider>();
  }

  @override
  bool updateShouldNotify(CommonScaffoldBackActionProvider oldWidget) =>
      backAction != oldWidget.backAction;
}

class CommonScaffoldFabExtendedProvider extends InheritedWidget {
  final bool isExtended;

  const CommonScaffoldFabExtendedProvider({
    super.key,
    required this.isExtended,
    required super.child,
  });

  static CommonScaffoldFabExtendedProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          CommonScaffoldFabExtendedProvider
        >();
  }

  @override
  bool updateShouldNotify(CommonScaffoldFabExtendedProvider oldWidget) =>
      isExtended != oldWidget.isExtended;
}

class ItemPositionProvider extends InheritedWidget {
  final ItemPosition position;

  const ItemPositionProvider({
    super.key,
    required this.position,
    required super.child,
  });

  static ItemPositionProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ItemPositionProvider>();
  }

  @override
  bool updateShouldNotify(ItemPositionProvider oldWidget) =>
      position != oldWidget.position;
}

class ProxyDecoratorProvider extends InheritedWidget {
  final bool isProxyDecorator;

  const ProxyDecoratorProvider({
    super.key,
    required this.isProxyDecorator,
    required super.child,
  });

  static ProxyDecoratorProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProxyDecoratorProvider>();
  }

  @override
  bool updateShouldNotify(ProxyDecoratorProvider oldWidget) =>
      isProxyDecorator != oldWidget.isProxyDecorator;
}

class SheetProvider<T> extends InheritedWidget {
  final SheetType type;
  final void Function([T? result])? nestedNavigatorPop;

  const SheetProvider({
    super.key,
    required super.child,
    required this.type,
    this.nestedNavigatorPop,
  });

  SheetProvider copyWith({
    SheetType? type,
    void Function([T? result])? nestedNavigatorPop,
    required Widget child,
  }) {
    return SheetProvider<T>(
      type: type ?? this.type,
      nestedNavigatorPop: nestedNavigatorPop ?? this.nestedNavigatorPop,
      child: child,
    );
  }

  static SheetProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SheetProvider>();
  }

  @override
  bool updateShouldNotify(SheetProvider oldWidget) =>
      type != oldWidget.type &&
      nestedNavigatorPop != oldWidget.nestedNavigatorPop;
}

extension SheetHeightExt on WidgetRef {
  double sheetHeight(BuildContext context, double factor) {
    final viewHeight = watch(viewHeightProvider);
    if (SheetProvider.of(context)?.type != SheetType.bottomSheet) {
      return double.maxFinite;
    }
    return viewHeight * factor;
  }
}

class ProfileIdProvider extends InheritedWidget {
  final int profileId;

  const ProfileIdProvider({
    super.key,
    required this.profileId,
    required super.child,
  });

  static ProfileIdProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileIdProvider>();
  }

  @override
  bool updateShouldNotify(ProfileIdProvider oldWidget) =>
      profileId != oldWidget.profileId;
}
