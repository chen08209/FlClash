import 'package:collection/collection.dart';
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

  _getNavigationBar({
    required BuildContext context,
    required ViewMode viewMode,
    required List<NavigationItem> navigationItems,
    required int currentIndex,
  }) {
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
    return LayoutBuilder(
      builder: (_, container) {
        return Material(
          color: context.colorScheme.surfaceContainer,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            height: container.maxHeight,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: IntrinsicHeight(
                      child: Selector<Config, bool>(
                        selector: (_, config) => config.showLabel,
                        builder: (_, showLabel, __) {
                          return NavigationRail(
                            backgroundColor:
                                context.colorScheme.surfaceContainer,
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
                            onDestinationSelected:
                                globalState.appController.toPage,
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
                    config.showLabel = !config.showLabel;
                  },
                  icon: const Icon(Icons.menu),
                )
              ],
            ),
          ),
        );
      },
    );
  }

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
      child: LayoutBuilder(
        builder: (_, container) {
          final appController = globalState.appController;
          final maxWidth = container.maxWidth;
          if (appController.appState.viewWidth != maxWidth) {
            globalState.appController.updateViewWidth(maxWidth);
          }
          return Selector2<AppState, Config, HomeState>(
            selector: (_, appState, config) {
              return HomeState(
                currentLabel: appState.currentLabel,
                navigationItems: appState.currentNavigationItems,
                viewMode: other.getViewMode(maxWidth),
                locale: config.locale,
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
              final navigationBar = _getNavigationBar(
                context: context,
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
          );
        },
      ),
    );
  }
}
