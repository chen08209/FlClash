import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'card.dart';
import 'common.dart';

typedef GroupNameKeyMap = Map<String, GlobalObjectKey<ProxyGroupViewState>>;

class ProxiesTabFragment extends StatefulWidget {
  const ProxiesTabFragment({super.key});

  @override
  State<ProxiesTabFragment> createState() => ProxiesTabFragmentState();
}

class ProxiesTabFragmentState extends State<ProxiesTabFragment>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final _hasMoreButtonNotifier = ValueNotifier<bool>(false);
  GroupNameKeyMap _keyMap = {};

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  scrollToGroupSelected() {
    final currentGroupName = globalState.appController.config.currentGroupName;
    _keyMap[currentGroupName]?.currentState?.scrollToSelected();
  }

  _buildMoreButton() {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.viewMode == ViewMode.mobile,
      builder: (_, value, ___) {
        return IconButton(
          onPressed: _showMoreMenu,
          icon: value
              ? const Icon(
                  Icons.expand_more,
                )
              : const Icon(
                  Icons.chevron_right,
                ),
        );
      },
    );
  }

  _showMoreMenu() {
    showSheet(
      context: context,
      width: 380,
      isScrollControlled: false,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Selector2<AppState, Config, ProxiesSelectorState>(
            selector: (_, appState, config) {
              final currentGroups = appState.currentGroups;
              final groupNames = currentGroups.map((e) => e.name).toList();
              return ProxiesSelectorState(
                groupNames: groupNames,
                currentGroupName: config.currentGroupName,
              );
            },
            builder: (_, state, __) {
              return SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final groupName in state.groupNames)
                      SettingTextCard(
                        groupName,
                        onPressed: () {
                          final index = state.groupNames
                              .indexWhere((item) => item == groupName);
                          if (index == -1) return;
                          _tabController?.animateTo(index);
                          globalState.appController.config
                              .updateCurrentGroupName(
                            groupName,
                          );
                          Navigator.of(context).pop();
                        },
                        isSelected: groupName == state.currentGroupName,
                      )
                  ],
                ),
              );
            },
          ),
        );
      },
      title: appLocalizations.proxyGroup,
    );
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
        );
        GroupNameKeyMap keyMap = {};
        final children = state.groupNames.map((groupName) {
          keyMap[groupName] = GlobalObjectKey(groupName);
          return KeepScope(
            child: ProxyGroupView(
              key: keyMap[groupName],
              groupName: groupName,
            ),
          );
        }).toList();
        _keyMap = keyMap;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationListener<ScrollMetricsNotification>(
              onNotification: (scrollNotification) {
                _hasMoreButtonNotifier.value =
                    scrollNotification.metrics.maxScrollExtent > 0;
                return true;
              },
              child: ValueListenableBuilder(
                valueListenable: _hasMoreButtonNotifier,
                builder: (_, value, child) {
                  return Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      TabBar(
                        controller: _tabController,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16 + (value ? 16 : 0),
                        ),
                        onTap: (index) {
                          final appController = globalState.appController;
                          final currentGroups =
                              appController.appState.currentGroups;
                          if (currentGroups.length > index) {
                            appController.config.updateCurrentGroupName(
                              currentGroups[index].name,
                            );
                          }
                        },
                        dividerColor: Colors.transparent,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        overlayColor:
                            const WidgetStatePropertyAll(Colors.transparent),
                        tabs: [
                          for (final groupName in state.groupNames)
                            Tab(
                              text: groupName,
                            ),
                        ],
                      ),
                      if (value)
                        Positioned(
                          right: 0,
                          child: child!,
                        ),
                    ],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          context.colorScheme.surface.withOpacity(0.1),
                          context.colorScheme.surface,
                        ],
                        stops: const [
                          0.0,
                          0.1
                        ]),
                  ),
                  child: _buildMoreButton(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: children,
              ),
            )
          ],
        );
      },
    );
  }
}

class ProxyGroupView extends StatefulWidget {
  final String groupName;

  const ProxyGroupView({
    super.key,
    required this.groupName,
  });

  @override
  State<ProxyGroupView> createState() => ProxyGroupViewState();
}

class ProxyGroupViewState extends State<ProxyGroupView> {
  var isLock = false;
  final _controller = ScrollController();
  List<Proxy> _lastProxies = [];

  String get groupName => widget.groupName;

  _delayTest(List<Proxy> proxies) async {
    if (isLock) return;
    isLock = true;
    await delayTest(proxies);
    isLock = false;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  scrollToSelected() {
    if (_controller.position.maxScrollExtent == 0) {
      return;
    }
    _controller.animateTo(
      min(
        16 +
            getScrollToSelectedOffset(
              groupName: groupName,
              proxies: _lastProxies,
            ),
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
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
          columns: other.getProxiesColumns(
            appState.viewWidth,
            config.proxiesLayout,
          ),
          sortNum: appState.sortNum,
          proxies: group.all,
          groupType: group.type,
        );
      },
      builder: (_, state, __) {
        final proxies = state.proxies;
        final columns = state.columns;
        final proxyCardType = state.proxyCardType;
        final sortedProxies = globalState.appController.getSortProxies(
          proxies,
        );
        _lastProxies = sortedProxies;
        return DelayTestButtonContainer(
          onClick: () async {
            await _delayTest(
              proxies,
            );
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: ScaleBuilder(
              builder: (_) => GridView.builder(
                controller: _controller,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 96,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: getItemHeight(proxyCardType),
                ),
                itemCount: sortedProxies.length,
                itemBuilder: (_, index) {
                  final proxy = sortedProxies[index];
                  return ProxyCard(
                    groupType: state.groupType,
                    type: proxyCardType,
                    key: ValueKey('$groupName.${proxy.name}'),
                    proxy: proxy,
                    groupName: groupName,
                  );
                },
              ),
            ),
          ),
        );
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
