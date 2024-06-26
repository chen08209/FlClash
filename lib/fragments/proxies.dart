import 'package:collection/collection.dart';
import 'package:fl_clash/clash/core.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProxiesFragment extends StatefulWidget {
  const ProxiesFragment({super.key});

  @override
  State<ProxiesFragment> createState() => _ProxiesFragmentState();
}

class _ProxiesFragmentState extends State<ProxiesFragment> {
  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      final items = [
        CommonPopupMenuItem(
          action: ProxiesSortType.none,
          label: appLocalizations.defaultSort,
          iconData: Icons.reorder,
        ),
        CommonPopupMenuItem(
          action: ProxiesSortType.delay,
          label: appLocalizations.delaySort,
          iconData: Icons.network_ping,
        ),
        CommonPopupMenuItem(
          action: ProxiesSortType.name,
          label: appLocalizations.nameSort,
          iconData: Icons.sort_by_alpha,
        ),
      ];
      commonScaffoldState?.actions = [
        Selector<Config, ProxiesType>(
          selector: (_, config) => config.proxiesType,
          builder: (_, proxiesType, __) {
            return IconButton(
              icon: Icon(
                switch (proxiesType) {
                  ProxiesType.tab => Icons.view_list,
                  ProxiesType.expansion => Icons.view_carousel,
                },
              ),
              onPressed: () {
                final config = globalState.appController.config;
                config.proxiesType = config.proxiesType == ProxiesType.tab
                    ? ProxiesType.expansion
                    : ProxiesType.tab;
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.view_column,
          ),
          onPressed: () {
            globalState.appController.changeColumns();
          },
        ),
        IconButton(
          icon: const Icon(Icons.transform_sharp),
          onPressed: () {
            final config = globalState.appController.config;
            config.proxyCardType = config.proxyCardType == ProxyCardType.expand
                ? ProxyCardType.shrink
                : ProxyCardType.expand;
          },
        ),
        Selector<Config, ProxiesSortType>(
          selector: (_, config) => config.proxiesSortType,
          builder: (_, proxiesSortType, __) {
            return CommonPopupMenu<ProxiesSortType>.radio(
              items: items,
              icon: const Icon(Icons.sort_sharp),
              onSelected: (value) {
                final config = context.read<Config>();
                config.proxiesSortType = value;
              },
              selectedValue: proxiesSortType,
            );
          },
        ),
        const SizedBox(
          width: 8,
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.currentLabel == 'proxies',
      builder: (_, isCurrent, child) {
        if (isCurrent) {
          _initActions();
        }
        return child!;
      },
      child: Selector<Config, ProxiesType>(
        selector: (_, config) => config.proxiesType,
        builder: (_, proxiesType, __) {
          return switch (proxiesType) {
            ProxiesType.tab => const ProxiesTabFragment(),
            ProxiesType.expansion => const ProxiesExpansionPanelFragment(),
          };
        },
      ),
    );
  }
}

class ProxiesTabFragment extends StatefulWidget {
  const ProxiesTabFragment({super.key});

  @override
  State<ProxiesTabFragment> createState() => _ProxiesTabFragmentState();
}

class _ProxiesTabFragmentState extends State<ProxiesTabFragment>
    with TickerProviderStateMixin {
  TabController? _tabController;

  _handleTabControllerChange() {
    final indexIsChanging = _tabController?.indexIsChanging ?? false;
    if (indexIsChanging) return;
    final index = _tabController?.index;
    if (index == null) return;
    final appController = globalState.appController;
    final currentGroups = appController.appState.currentGroups;
    if (currentGroups.length > index) {
      appController.config.updateCurrentGroupName(currentGroups[index].name);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxiesSelectorState>(
      selector: (_, appState, config) {
        final currentGroups = appState.currentGroups;
        final groupNames = currentGroups.map((e) => e.name).toList();
        return ProxiesSelectorState(
          groupNames: groupNames,
          currentGroupName: config.currentGroupName,
        );
      },
      shouldRebuild: (prev, next) {
        if (!const ListEquality<String>()
            .equals(prev.groupNames, next.groupNames)) {
          _tabController?.removeListener(_handleTabControllerChange);
          _tabController?.dispose();
          _tabController = null;
          return true;
        }
        return false;
      },
      builder: (_, state, __) {
        final index = state.groupNames.indexWhere(
          (item) => item == state.currentGroupName,
        );
        _tabController ??= TabController(
          length: state.groupNames.length,
          initialIndex: index == -1 ? 0 : index,
          vsync: this,
        )..addListener(_handleTabControllerChange);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              dividerColor: Colors.transparent,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              tabs: [
                for (final groupName in state.groupNames)
                  Tab(
                    text: groupName,
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final groupName in state.groupNames)
                    KeepContainer(
                      key: ObjectKey(groupName),
                      child: ProxyGroupView(
                        groupName: groupName,
                        type: ProxiesType.tab,
                      ),
                    ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class ProxiesExpansionPanelFragment extends StatefulWidget {
  const ProxiesExpansionPanelFragment({super.key});

  @override
  State<ProxiesExpansionPanelFragment> createState() =>
      _ProxiesExpansionPanelFragmentState();
}

class _ProxiesExpansionPanelFragmentState
    extends State<ProxiesExpansionPanelFragment> {
  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxiesSelectorState>(
      selector: (_, appState, config) {
        final currentGroups = appState.currentGroups;
        final groupNames = currentGroups.map((e) => e.name).toList();
        return ProxiesSelectorState(
          groupNames: groupNames,
          currentGroupName: config.currentGroupName,
        );
      },
      builder: (_, state, __) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.groupNames.length,
          itemBuilder: (_, index) {
            final groupName = state.groupNames[index];
            return ProxyGroupView(
              key: Key(groupName),
              groupName: groupName,
              type: ProxiesType.expansion,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 16,
            );
          },
        );
      },
    );
  }
}

class ProxyGroupView extends StatefulWidget {
  final String groupName;
  final ProxiesType type;

  const ProxyGroupView({
    super.key,
    required this.groupName,
    required this.type,
  });

  @override
  State<ProxyGroupView> createState() => _ProxyGroupViewState();
}

class _ProxyGroupViewState extends State<ProxyGroupView> {
  var isLock = false;

  String get groupName => widget.groupName;

  ProxiesType get type => widget.type;

  double _getItemHeight(ProxyCardType proxyCardType) {
    final isExpand = proxyCardType == ProxyCardType.expand;
    final measure = globalState.appController.measure;
    final baseHeight =
        12 * 2 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8;
    return isExpand ? baseHeight + measure.labelSmallHeight + 8 : baseHeight;
  }

  _delayTest(List<Proxy> proxies) async {
    if (isLock) return;
    isLock = true;
    final appController = globalState.appController;
    for (final proxy in proxies) {
      final proxyName =
          appController.appState.getRealProxyName(proxy.name) ?? proxy.name;
      globalState.appController.setDelay(
        Delay(
          name: proxyName,
          value: 0,
        ),
      );
      clashCore.getDelay(proxyName).then((delay) {
        globalState.appController.setDelay(delay);
      });
    }
    await Future.delayed(httpTimeoutDuration + moreDuration);
    appController.appState.sortNum++;
    isLock = false;
  }

  Widget _currentProxyNameBuilder({
    required Widget Function(String) builder,
  }) {
    return Selector2<AppState, Config, String>(
      selector: (_, appState, config) {
        final group = appState.getGroupWithName(groupName)!;
        return config.currentSelectedMap[groupName] ?? group.now ?? '';
      },
      builder: (_, value, ___) {
        return builder(value);
      },
    );
  }

  Widget _buildTabGroupView({
    required List<Proxy> proxies,
    required int columns,
    required ProxyCardType proxyCardType,
  }) {
    final sortedProxies = globalState.appController.getSortProxies(
      proxies,
    );
    return DelayTestButtonContainer(
      onClick: () async {
        await _delayTest(
          proxies,
        );
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: _getItemHeight(proxyCardType),
          ),
          itemCount: sortedProxies.length,
          itemBuilder: (_, index) {
            final proxy = sortedProxies[index];
            return _currentProxyNameBuilder(builder: (value) {
              return ProxyCard(
                type: proxyCardType,
                key: ValueKey('$groupName.${proxy.name}'),
                isSelected: value == proxy.name,
                proxy: proxy,
                groupName: groupName,
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildExpansionGroupView({
    required List<Proxy> proxies,
    required int columns,
    required ProxyCardType proxyCardType,
  }) {
    final sortedProxies = globalState.appController.getSortProxies(
      proxies,
    );
    return Selector<Config, Set<String>>(
      selector: (_, config) => config.currentUnfoldSet,
      builder: (_, currentUnfoldSet, __) {
        return CommonCard(
          child: ExpansionTile(
            initiallyExpanded: currentUnfoldSet.contains(groupName),
            iconColor: context.colorScheme.onSurfaceVariant,
            onExpansionChanged: (value) {
              final tempUnfoldSet = Set<String>.from(currentUnfoldSet);
              if (value) {
                tempUnfoldSet.add(groupName);
              } else {
                tempUnfoldSet.remove(groupName);
              }
              globalState.appController.config.updateCurrentUnfoldSet(
                tempUnfoldSet,
              );
            },
            controlAffinity: ListTileControlAffinity.trailing,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(groupName),
                      const SizedBox(
                        height: 4,
                      ),
                      Flexible(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              groupName,
                              style: context.textTheme.labelMedium?.toLight,
                            ),
                            Flexible(
                              flex: 1,
                              child: _currentProxyNameBuilder(
                                builder: (value) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (value.isNotEmpty) ...[
                                        Icon(
                                          Icons.arrow_right,
                                          color: context
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Text(
                                            overflow: TextOverflow.ellipsis,
                                            value,
                                            style: context
                                                .textTheme.labelMedium?.toLight,
                                          ),
                                        ),
                                      ]
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.network_ping,
                    size: 20,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _delayTest(sortedProxies);
                  },
                ),
              ],
            ),
            shape: const RoundedRectangleBorder(
              side: BorderSide.none,
            ),
            collapsedShape: const RoundedRectangleBorder(
              side: BorderSide.none,
            ),
            childrenPadding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 8,
              right: 8,
            ),
            children: [
              Grid(
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                crossAxisCount: columns,
                children: [
                  for (final proxy in sortedProxies)
                    _currentProxyNameBuilder(
                      builder: (value) {
                        return ProxyCard(
                          style: CommonCardType.filled,
                          type: proxyCardType,
                          isSelected: value == proxy.name,
                          key: ValueKey('$groupName.${proxy.name}'),
                          proxy: proxy,
                          groupName: groupName,
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxyGroupSelectorState>(
      selector: (_, appState, config) {
        final group = appState.getGroupWithName(groupName)!;
        return ProxyGroupSelectorState(
          proxyCardType: config.proxyCardType,
          proxiesSortType: config.proxiesSortType,
          columns: globalState.appController.columns,
          sortNum: appState.sortNum,
          proxies: group.all,
        );
      },
      builder: (_, state, __) {
        final proxies = state.proxies;
        final columns = state.columns;
        final proxyCardType = state.proxyCardType;
        return switch (type) {
          ProxiesType.tab => _buildTabGroupView(
              proxies: proxies,
              columns: columns,
              proxyCardType: proxyCardType,
            ),
          ProxiesType.expansion => _buildExpansionGroupView(
              proxies: proxies,
              columns: columns,
              proxyCardType: proxyCardType,
            ),
        };
      },
    );
  }
}

class DelayTestButtonContainer extends StatefulWidget {
  final Widget child;
  final Future Function() onClick;

  const DelayTestButtonContainer({
    super.key,
    required this.child,
    required this.onClick,
  });

  @override
  State<DelayTestButtonContainer> createState() =>
      _DelayTestButtonContainerState();
}

class _DelayTestButtonContainerState extends State<DelayTestButtonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  _healthcheck() async {
    _controller.forward();
    await widget.onClick();
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0,
          1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.reverse();
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: AnimatedBuilder(
          animation: _controller.view,
          builder: (_, child) {
            return SizedBox(
              width: 56,
              height: 56,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            );
          },
          child: FloatingActionButton(
            heroTag: null,
            onPressed: _healthcheck,
            child: const Icon(Icons.network_ping),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}

class ProxyCard extends StatelessWidget {
  final String groupName;
  final Proxy proxy;
  final bool isSelected;
  final CommonCardType style;
  final ProxyCardType type;

  const ProxyCard({
    super.key,
    required this.groupName,
    required this.proxy,
    required this.isSelected,
    this.style = CommonCardType.plain,
    required this.type,
  });

  Measure get measure => globalState.appController.measure;

  Widget _buildDelayText() {
    return SizedBox(
      height: measure.labelSmallHeight,
      child: Selector<AppState, int?>(
        selector: (context, appState) => appState.getDelay(
          proxy.name,
        ),
        builder: (context, delay, __) {
          return FadeBox(
            child: Builder(
              builder: (_) {
                if (delay == null) {
                  return Container();
                }
                if (delay == 0) {
                  return SizedBox(
                    height: measure.labelSmallHeight,
                    width: measure.labelSmallHeight,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                }
                return Text(
                  delay > 0 ? '$delay ms' : "Timeout",
                  style: context.textTheme.labelSmall?.copyWith(
                    overflow: TextOverflow.ellipsis,
                    color: other.getDelayColor(
                      delay,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProxyNameText(BuildContext context) {
    return SizedBox(
      height: measure.bodyMediumHeight * 2,
      child: Text(
        proxy.name,
        maxLines: 2,
        style: context.textTheme.bodyMedium?.copyWith(
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  _changeProxy(BuildContext context) {
    final appController = globalState.appController;
    final group = appController.appState.getGroupWithName(groupName)!;
    if (group.type != GroupType.Selector) {
      globalState.showSnackBar(
        context,
        message: appLocalizations.notSelectedTip,
      );
      return;
    }
    globalState.appController.config.updateCurrentSelectedMap(
      groupName,
      proxy.name,
    );
    appController.changeProxy();
  }

  @override
  Widget build(BuildContext context) {
    final measure = globalState.appController.measure;
    final delayText = _buildDelayText();
    final proxyNameText = _buildProxyNameText(context);
    return CommonCard(
      type: style,
      key: key,
      onPressed: () {
        _changeProxy(context);
      },
      isSelected: isSelected,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            proxyNameText,
            const SizedBox(
              height: 8,
            ),
            if (type == ProxyCardType.expand) ...[
              SizedBox(
                height: measure.bodySmallHeight,
                child: Selector<AppState, String>(
                  selector: (context, appState) => appState.getDesc(
                    proxy.type,
                    proxy.name,
                  ),
                  builder: (_, desc, __) {
                    return TooltipText(
                      text: Text(
                        desc,
                        style: context.textTheme.bodySmall?.copyWith(
                          overflow: TextOverflow.ellipsis,
                          color: context.textTheme.bodySmall?.color?.toLight(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              delayText,
            ] else
              SizedBox(
                height: measure.bodySmallHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TooltipText(
                        text: Text(
                          proxy.type,
                          style: context.textTheme.bodySmall?.copyWith(
                            overflow: TextOverflow.ellipsis,
                            color:
                                context.textTheme.bodySmall?.color?.toLight(),
                          ),
                        ),
                      ),
                    ),
                    delayText,
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
