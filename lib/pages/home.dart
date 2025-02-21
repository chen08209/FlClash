import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../enum/enum.dart';
import '../widgets/widgets.dart';

typedef OnSelected = void Function(int index);

class NavigationOffsetNotifier extends ChangeNotifier {
  Offset _offset = Offset.zero;

  Offset get offset => _offset;

  void updateOffset(BuildContext context, ViewMode viewMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      final newOffset = viewMode == ViewMode.mobile
          ? Offset(0, -(size?.height ?? 0))
          : Offset(size?.width ?? 0, 0);

      if (_offset != newOffset) {
        _offset = newOffset;
        notifyListeners();
      }
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _updatePageController(List<NavigationItem> navigationItems) {
    final currentLabel = globalState.appController.appState.currentLabel;
    final index = navigationItems.lastIndexWhere((e) => e.label == currentLabel);
    final currentIndex = index == -1 ? 0 : index;

    if (globalState.pageController?.hasClients != true ||
        globalState.pageController?.initialPage != currentIndex) {
      globalState.pageController ??= PageController(
        initialPage: currentIndex,
        keepPage: true,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        globalState.appController.toPage(currentIndex, hasAnimate: true);
      });
    }
  }

  Widget _buildPageView() {
    return Selector<AppState, List<NavigationItem>>(
      selector: (_, appState) => appState.currentNavigationItems,
      shouldRebuild: (prev, next) => prev.length != next.length,
      builder: (_, navigationItems, __) {
        _updatePageController(navigationItems);
        return PageView.builder(
          controller: globalState.pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: navigationItems.length,
          itemBuilder: (_, index) {
            final item = navigationItems[index];
            return KeepScope(
              keep: item.keep,
              key: Key(item.label),
              child: item.fragment,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationOffsetNotifier(),
      child: BackScope(
        child: Selector2<AppState, Config, HomeState>(
          selector: (_, appState, config) => HomeState(
            currentLabel: appState.currentLabel,
            navigationItems: appState.currentNavigationItems,
            viewMode: appState.viewMode,
            locale: config.appSetting.locale,
          ),
          shouldRebuild: (prev, next) => prev != next,
          builder: (_, state, child) {
            final navigationBar = CommonNavigationBar(
              viewMode: state.viewMode,
              navigationItems: state.navigationItems,
              currentIndex: state.navigationItems.indexWhere(
                (e) => e.label == state.currentLabel,
              ).clamp(0, state.navigationItems.length - 1),
            );

            return CommonScaffold(
              key: globalState.homeScaffoldKey,
              title: Intl.message(state.currentLabel),
              sideNavigationBar: state.viewMode != ViewMode.mobile ? navigationBar : null,
              body: child!,
              bottomNavigationBar: state.viewMode == ViewMode.mobile ? navigationBar : null,
            );
          },
          child: _buildPageView(),
        ),
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

  @override
  Widget build(BuildContext context) {
    context.read<NavigationOffsetNotifier>().updateOffset(context, viewMode);

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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Selector<Config, bool>(
                  selector: (_, config) => config.appSetting.showLabel,
                  builder: (_, showLabel, __) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: NavigationRail(
                        key: ValueKey(currentIndex),
                        backgroundColor: context.colorScheme.surfaceContainer,
                        selectedIconTheme: IconThemeData(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        selectedLabelTextStyle: context.textTheme.labelLarge!.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        unselectedLabelTextStyle: context.textTheme.labelLarge!.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        destinations: navigationItems
                            .map(
                              (e) => NavigationRailDestination(
                                icon: e.icon,
                                label: Text(Intl.message(e.label)),
                              ),
                            )
                            .toList(),
                        onDestinationSelected: globalState.appController.toPage,
                        extended: false,
                        selectedIndex: currentIndex,
                        labelType: showLabel
                            ? NavigationRailLabelType.all
                            : NavigationRailLabelType.none,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Tooltip(
            message: Intl.message('Toggle Labels'),
            child: IconButton(
              onPressed: () {
                final config = globalState.appController.config;
                config.appSetting = config.appSetting.copyWith(
                  showLabel: !config.appSetting.showLabel,
                );
              },
              icon: const Icon(Icons.menu),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
