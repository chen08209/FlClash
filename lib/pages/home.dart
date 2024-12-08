import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../enum/enum.dart';
import '../widgets/widgets.dart';

typedef OnSelected = void Function(int index);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  _updatePageController(List<NavigationItem> navigationItems) {
    final currentLabel = globalState.appController.appState.currentLabel;
    final index = navigationItems.lastIndexWhere(
      (element) => element.label == currentLabel,
    );
    final currentIndex = index == -1 ? 0 : index;
    if (globalState.pageController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        globalState.appController.toPage(currentIndex, hasAnimate: true);
      });
    } else {
      globalState.pageController = PageController(
        initialPage: currentIndex,
        keepPage: true,
      );
    }
  }

  Widget _buildPageView() {
    return Selector<AppState, List<NavigationItem>>(
      selector: (_, appState) => appState.currentNavigationItems,
      shouldRebuild: (prev, next) {
        return prev.length != next.length;
      },
      builder: (_, navigationItems, __) {
        _updatePageController(navigationItems);
        return PageView.builder(
          controller: globalState.pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: navigationItems.length,
          itemBuilder: (_, index) {
            final navigationItem = navigationItems[index];
            return KeepScope(
              keep: navigationItem.keep,
              key: Key(navigationItem.label),
              child: navigationItem.fragment,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackScope(
      child: Selector2<AppState, Config, HomeState>(
        selector: (_, appState, config) {
          return HomeState(
            currentLabel: appState.currentLabel,
            navigationItems: appState.currentNavigationItems,
            viewMode: appState.viewMode,
            locale: config.appSetting.locale,
          );
        },
        shouldRebuild: (prev, next) {
          return prev != next;
        },
        builder: (_, state, child) {
          final viewMode = state.viewMode;
          final navigationItems = state.navigationItems;
          final currentLabel = state.currentLabel;
          final index = navigationItems.lastIndexWhere(
            (element) => element.label == currentLabel,
          );
          final currentIndex = index == -1 ? 0 : index;
          final navigationBar = CommonNavigationBar(
            viewMode: viewMode,
            navigationItems: navigationItems,
            currentIndex: currentIndex,
          );
          final bottomNavigationBar =
              viewMode == ViewMode.mobile ? navigationBar : null;
          final sideNavigationBar =
              viewMode != ViewMode.mobile ? navigationBar : null;
          return CommonScaffold(
            key: globalState.homeScaffoldKey,
            title: Intl.message(
              currentLabel,
            ),
            sideNavigationBar: sideNavigationBar,
            body: child!,
            bottomNavigationBar: bottomNavigationBar,
          );
        },
        child: _buildPageView(),
      ),
    );
  }
}

class CommonNavigationBar extends StatelessWidget {
  final ViewMode viewMode;
  final List<NavigationItem> navigationItems;
  final int currentIndex;

  const CommonNavigationBar({
    super.key,
    required this.viewMode,
    required this.navigationItems,
    required this.currentIndex,
  });

  _updateSafeMessageOffset(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (viewMode == ViewMode.mobile) {
        globalState.safeMessageOffsetNotifier.value = Offset(
          0,
          -(size?.height ?? 0),
        );
      } else {
        globalState.safeMessageOffsetNotifier.value = Offset(
          size?.width ?? 0,
          0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateSafeMessageOffset(context);
    if (viewMode == ViewMode.mobile) {
      return NavigationBar(
        destinations: navigationItems
            .map(
              (e) => NavigationDestination(
                icon: e.icon,
                label: Intl.message(e.label),
              ),
            )
            .toList(),
        onDestinationSelected: globalState.appController.toPage,
        selectedIndex: currentIndex,
      );
    }
    return Material(
      color: context.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: IntrinsicHeight(
                  child: Selector<Config, bool>(
                    selector: (_, config) => config.appSetting.showLabel,
                    builder: (_, showLabel, __) {
                      return NavigationRail(
                        backgroundColor: context.colorScheme.surfaceContainer,
                        selectedIconTheme: IconThemeData(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        selectedLabelTextStyle:
                            context.textTheme.labelLarge!.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        unselectedLabelTextStyle:
                            context.textTheme.labelLarge!.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        destinations: navigationItems
                            .map(
                              (e) => NavigationRailDestination(
                                icon: e.icon,
                                label: Text(
                                  Intl.message(e.label),
                                ),
                              ),
                            )
                            .toList(),
                        onDestinationSelected: globalState.appController.toPage,
                        extended: false,
                        selectedIndex: currentIndex,
                        labelType: showLabel
                            ? NavigationRailLabelType.all
                            : NavigationRailLabelType.none,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            IconButton(
              onPressed: () {
                final config = globalState.appController.config;
                final appSetting = config.appSetting;
                config.appSetting = appSetting.copyWith(
                  showLabel: !appSetting.showLabel,
                );
              },
              icon: const Icon(Icons.menu),
            )
          ],
        ),
      ),
    );
  }
}
