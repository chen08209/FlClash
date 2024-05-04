import 'package:fl_clash/clash/clash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:provider/provider.dart';

import '../enum/enum.dart';
import '../models/models.dart';
import '../common/common.dart';
import '../widgets/widgets.dart';

class ProxiesFragment extends StatefulWidget {
  const ProxiesFragment({super.key});

  @override
  State<ProxiesFragment> createState() => _ProxiesFragmentState();
}

class _ProxiesFragmentState extends State<ProxiesFragment>
    with TickerProviderStateMixin {
  TabController? _tabController;

  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      final items = [
        CommonPopupMenuItem(
          action: ProxiesSortType.none,
          label: appLocalizations.defaultSort,
          iconData: Icons.sort,
        ),
        CommonPopupMenuItem(
            action: ProxiesSortType.delay,
            label: appLocalizations.delaySort,
            iconData: Icons.network_ping),
        CommonPopupMenuItem(
            action: ProxiesSortType.name,
            label: appLocalizations.nameSort,
            iconData: Icons.sort_by_alpha),
      ];
      commonScaffoldState?.actions = [
        Selector<Config, ProxiesSortType>(
          selector: (_, config) => config.proxiesSortType,
          builder: (_, proxiesSortType, __) {
            return CommonPopupMenu<ProxiesSortType>.radio(
              items: items,
              onSelected: (value) {
                final config = context.read<Config>();
                config.proxiesSortType = value;
              },
              selectedValue: proxiesSortType,
            );
          },
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
      child: Selector3<AppState, Config, ClashConfig, ProxiesSelectorState>(
        selector: (_, appState, config, clashConfig) {
          final currentGroups = appState.getCurrentGroups(clashConfig.mode);
          final currentProxyName = appState.getCurrentGroupNameWithGroups(
            currentGroups,
            config.currentGroupName,
            clashConfig.mode,
          );
          final currentIndex = currentGroups
              .indexWhere((element) => element.name == currentProxyName);
          return ProxiesSelectorState(
            currentIndex: currentIndex != -1 ? currentIndex : 0,
            groups: currentGroups,
          );
        },
        builder: (_, state, __) {
          if (_tabController != null) {
            _tabController!.dispose();
            _tabController = null;
          }
          _tabController = TabController(
            length: state.groups.length,
            vsync: this,
            initialIndex: state.currentIndex,
          );
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
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                tabs: [
                  for (final group in state.groups)
                    Tab(
                      text: group.name,
                    ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    for (final group in state.groups)
                      KeepContainer(
                        child: ProxiesTabView(
                          group: group,
                        ),
                      ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class ProxiesTabView extends StatefulWidget {
  final Group group;

  const ProxiesTabView({
    super.key,
    required this.group,
  });

  @override
  State<ProxiesTabView> createState() => _ProxiesTabViewState();
}

class _ProxiesTabViewState extends State<ProxiesTabView>
    with SingleTickerProviderStateMixin {
  var lock = false;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

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
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.3,
          curve: Curves.easeIn,
        ),
      ),
    );
    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0,
          1,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Group get group => widget.group;

  get measure => context.appController.measure;

  List<Proxy> _sortOfName(List<Proxy> proxies) {
    return List.of(proxies)
      ..sort(
        (a, b) => Other.sortByChar(a.name, b.name),
      );
  }

  List<Proxy> _sortOfDelay(List<Proxy> proxies) {
    final appState = context.read<AppState>();
    final delayMap = appState.delayMap;
    return proxies = List.of(proxies)
      ..sort(
        (a, b) {
          final aDelay = delayMap[a.name];
          final bDelay = delayMap[b.name];
          if (aDelay == null && bDelay == null) {
            return 0;
          }
          if (aDelay == null || aDelay == -1) {
            return 1;
          }
          if (bDelay == null || bDelay == -1) {
            return -1;
          }
          return aDelay.compareTo(bDelay);
        },
      );
  }

  _getProxies(
    List<Proxy> proxies,
    ProxiesSortType proxiesSortType,
  ) {
    if (proxiesSortType == ProxiesSortType.delay) return _sortOfDelay(proxies);
    if (proxiesSortType == ProxiesSortType.name) return _sortOfName(proxies);
    return proxies;
  }

  _getDelayMap() async {
    if (lock == true) return;
    lock = true;
    _controller.forward();
    for (final proxy in group.all) {
      context.appController.setDelay(
        Delay(
          name: proxy.name,
          value: 0,
        ),
      );
      clashCore.delay(
        proxy.name,
      );
    }
    await Future.delayed(
      appConstant.httpTimeoutDuration + appConstant.moreDuration,
    );
    lock = false;
    _controller.reverse();
    setState(() {});
  }

  double _getItemHeight() {
    return 12 * 2 +
        measure.bodyMediumHeight * 2 +
        measure.bodySmallHeight +
        measure.labelSmallHeight +
        8 * 2;
  }

  _card({
    required void Function() onPressed,
    required bool isSelected,
    required Proxy proxy,
  }) {
    return CommonCard(
      isSelected: isSelected,
      onPressed: onPressed,
      selectWidget: Container(
        alignment: Alignment.topRight,
        margin: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: const SelectIcon(),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: measure.bodyMediumHeight * 2,
              child: Text(
                proxy.name,
                maxLines: 2,
                style: context.textTheme.bodyMedium?.copyWith(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: measure.bodySmallHeight,
              child: Text(
                proxy.type,
                style: context.textTheme.bodySmall?.copyWith(
                  overflow: TextOverflow.ellipsis,
                  color: context.textTheme.bodySmall?.color?.toLight(),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: measure.labelSmallHeight,
              child: Selector<AppState, int?>(
                selector: (context, appState) => appState.delayMap[proxy.name],
                builder: (_, delay, __) {
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
                            color: Other.getDelayColor(
                              delay,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildGrid({
    required ProxiesSortType proxiesSortType,
    required int columns,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Selector3<AppState, Config, ClashConfig, ProxiesCardSelectorState>(
        selector: (_, appState, config, clashConfig) =>
            ProxiesCardSelectorState(
          currentGroupName: appState.getCurrentGroupName(
            config.currentGroupName,
            clashConfig.mode,
          ),
          currentProxyName: appState.getCurrentProxyName(
            config.currentProxyName,
            clashConfig.mode,
          ),
        ),
        builder: (_, state, __) {
          return AnimateGrid<Proxy>(
            items: _getProxies(group.all, proxiesSortType),
            columns: columns,
            itemHeight: _getItemHeight(),
            keyBuilder: (item) {
              return ObjectKey(item);
            },
            builder: (_, proxy) {
              final isSelected = group.type == GroupType.Selector
                  ? group.name == state.currentGroupName &&
                  proxy.name == state.currentProxyName
                  : group.now == proxy.name;
              return _card(
                isSelected: isSelected,
                onPressed: () {
                  if (group.type == GroupType.Selector) {
                    final config = context.read<Config>();
                    config.currentProfile?.groupName = group.name;
                    config.currentProfile?.proxyName = proxy.name;
                    config.update();
                    context.appController.changeProxy();
                  }
                },
                proxy: proxy,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, ProxiesSortType>(
      selector: (_, config) => config.proxiesSortType,
      builder: (_, proxiesSortType, __) {
        return FloatLayout(
          floatingWidget: FloatWrapper(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Transform.scale(
                  scale: _scale.value,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Opacity(
                      opacity: _opacity.value,
                      child: FloatingActionButton(
                        heroTag: null,
                        onPressed: _getDelayMap,
                        child: const Icon(Icons.network_ping),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SlotLayout(
              config: {
                Breakpoints.small: SlotLayout.from(
                  key: const Key('proxies_grid_small'),
                  builder: (_) => _buildGrid(
                    proxiesSortType: proxiesSortType,
                    columns: 2,
                  ),
                ),
                Breakpoints.medium: SlotLayout.from(
                  key: const Key('proxies_grid_medium'),
                  builder: (_) => _buildGrid(
                    proxiesSortType: proxiesSortType,
                    columns: 3,
                  ),
                ),
                Breakpoints.large: SlotLayout.from(
                  key: const Key('proxies_grid_large'),
                  builder: (_) => _buildGrid(
                    proxiesSortType: proxiesSortType,
                    columns: 4,
                  ),
                ),
              },
            ),
          ),
        );
      },
    );
  }
}
