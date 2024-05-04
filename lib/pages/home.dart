import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../enum/enum.dart';
import '../widgets/widgets.dart';

typedef OnSelected = void Function(int index);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildBody({
    required List<NavigationItem> navigationItems,
  }) {
    globalState.currentNavigationItems = navigationItems;
    return Selector<AppState, int>(
      selector: (_, appState) {
        final index = navigationItems.lastIndexWhere(
          (element) => element.label == appState.currentLabel,
        );
        return index == -1 ? 0 : index;
      },
      builder: (context, currentIndex, __) {
        if (globalState.pageController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.appController.toPage(currentIndex, hasAnimate: true);
          });
        } else {
          globalState.pageController = PageController(
            initialPage: currentIndex,
            keepPage: true,
          );
        }
        return PageView.builder(
          controller: globalState.pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: navigationItems.length,
          itemBuilder: (_, index) {
            final navigationItem = navigationItems[index];
            return KeepContainer(
              child: navigationItem.fragment,
            );
          },
        );
      },
    );
  }

  _buildNavigationRail({
    required List<NavigationItem> navigationItems,
    bool extended = false,
  }) {
    return Selector2<AppState, Config, HomeNavigationSelectorState>(
      selector: (_, appState, config) {
        final index = navigationItems.lastIndexWhere(
          (element) => element.label == appState.currentLabel,
        );
        return HomeNavigationSelectorState(
          currentIndex: index == -1 ? 0 : index,
          locale: config.locale,
        );
      },
      builder: (context, state, __) {
        return AdaptiveScaffold.standardNavigationRail(
          onDestinationSelected: context.appController.toPage,
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
          extended: extended,
          width: extended ? 160 : 80,
          selectedIndex: state.currentIndex,
          labelType: extended
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.selected,
        );
      },
    );
  }

  _buildBottomNavigationBar({
    required List<NavigationItem> navigationItems,
  }) {
    return Selector2<AppState, Config, HomeNavigationSelectorState>(
      selector: (_, appState, config) {
        final index = navigationItems.lastIndexWhere(
          (element) => element.label == appState.currentLabel,
        );
        return HomeNavigationSelectorState(
          currentIndex: index == -1 ? 0 : index,
          locale: config.locale,
        );
      },
      builder: (context, state, __) {
        final mobileDestinations = navigationItems
            .map(
              (e) => NavigationDestination(
                icon: e.icon,
                label: Intl.message(e.label),
              ),
            )
            .toList();
        return AdaptiveScaffold.standardBottomNavigationBar(
          destinations: mobileDestinations,
          onDestinationSelected: context.appController.toPage,
          currentIndex: state.currentIndex,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopContainer(
      child: Selector2<AppState, Config, HomeCommonScaffoldSelectorState>(
        selector: (_, appState, config) => HomeCommonScaffoldSelectorState(
          currentLabel: appState.currentLabel,
          locale: config.locale,
        ),
        builder: (_, state, child) {
          return CommonScaffold(
            key: globalState.homeScaffoldKey,
            title: Text(
              Intl.message(state.currentLabel),
            ),
            body: child!,
          );
        },
        child: Selector<AppState, List<NavigationItem>>(
          selector: (_, appState) => appState.navigationItems,
          builder: (_, navigationItems, __) {
            final desktopNavigationItems = navigationItems
                .where(
                  (element) =>
                      element.modes.contains(NavigationItemMode.desktop),
                )
                .toList();
            final mobileNavigationItems = navigationItems
                .where(
                  (element) =>
                      element.modes.contains(NavigationItemMode.mobile),
                )
                .toList();
            return AdaptiveLayout(
              transitionDuration: kThemeAnimationDuration,
              primaryNavigation: SlotLayout(
                config: {
                  Breakpoints.medium: SlotLayout.from(
                    key: const Key('primary_navigation_medium'),
                    builder: (_) => _buildNavigationRail(
                      navigationItems: desktopNavigationItems,
                    ),
                  ),
                  Breakpoints.large: SlotLayout.from(
                    key: const Key('primary_navigation_large'),
                    builder: (_) => _buildNavigationRail(
                      navigationItems: desktopNavigationItems,
                      extended: true,
                    ),
                  ),
                },
              ),
              body: SlotLayout(
                config: {
                  Breakpoints.mediumAndUp: SlotLayout.from(
                    key: const Key('body_mediumAndUp'),
                    builder: (_) => _buildBody(
                      navigationItems: desktopNavigationItems,
                    ),
                  ),
                  Breakpoints.small: SlotLayout.from(
                    key: const Key('body_small'),
                    builder: (_) => _buildBody(
                      navigationItems: mobileNavigationItems,
                    ),
                  )
                },
              ),
              bottomNavigation: SlotLayout(
                config: <Breakpoint, SlotLayoutConfig>{
                  Breakpoints.small: SlotLayout.from(
                    key: const Key('bottom_navigation_small'),
                    builder: (_) => _buildBottomNavigationBar(
                      navigationItems: mobileNavigationItems,
                    ),
                  )
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
