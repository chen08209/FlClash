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
    final extended = viewMode == ViewMode.desktop;
    return NavigationRail(
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
      extended: extended,
      minExtendedWidth: 172,
      selectedIndex: currentIndex,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopContainer(
      child: LayoutBuilder(
        builder: (_, container) {
          final appController = globalState.appController;
          final maxWidth = container.maxWidth;
          if (appController.appState.viewWidth != maxWidth) {
            globalState.appController.updateViewWidth(maxWidth);
          }
          return Selector2<AppState, Config, HomeSelectorState>(
            selector: (_, appState, config) {
              return HomeSelectorState(
                currentLabel: appState.currentLabel,
                navigationItems: appState.currentNavigationItems,
                viewMode: other.getViewMode(maxWidth),
                locale: config.locale,
              );
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
                viewMode: viewMode,
                navigationItems: navigationItems,
                currentIndex: currentIndex,
              );
              final bottomNavigationBar =
                  viewMode == ViewMode.mobile ? navigationBar : null;
              Widget body;
              if (viewMode != ViewMode.mobile) {
                body = Row(
                  children: [
                    navigationBar,
                    Expanded(
                      flex: 1,
                      child: child!,
                    )
                  ],
                );
              } else {
                body = child!;
              }
              return CommonScaffold(
                key: globalState.homeScaffoldKey,
                title: Intl.message(
                  currentLabel,
                ),
                body: body,
                bottomNavigationBar: bottomNavigationBar,
              );
            },
            child: const HomeBody(
              key: Key("home_boy"),
            ),
          );
        },
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  _updatePageIndex(List<NavigationItem> navigationItems) {
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

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, HomeBodySelectorState>(
      selector: (_, appState) => HomeBodySelectorState(
        navigationItems: appState.currentNavigationItems,
      ),
      builder: (_, state, __) {
        final navigationItems = state.navigationItems;
        _updatePageIndex(navigationItems);
        return PageView.builder(
          controller: globalState.pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: navigationItems.length,
          itemBuilder: (_, index) {
            final navigationItem = navigationItems[index];
            return KeepContainer(
              keep: navigationItem.keep,
              key: Key(navigationItem.label),
              child: navigationItem.fragment,
            );
          },
        );
      },
    );
  }
}
