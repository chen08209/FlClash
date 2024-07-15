import 'dart:math';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'card.dart';

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
  final scrollController = ScrollController();
  var isEnd = false;

  String get groupName => widget.groupName;

  ProxiesType get type => widget.type;

  double _getItemHeight(ProxyCardType proxyCardType) {
    final measure = globalState.appController.measure;
    final baseHeight =
        12 * 2 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8;
    return switch(proxyCardType){
      ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 8,
      ProxyCardType.shrink => baseHeight,
      ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
    };
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
    final group =
    globalState.appController.appState.getGroupWithName(groupName)!;
    final itemHeight = _getItemHeight(proxyCardType);
    final innerHeight = context.appSize.height - 200;
    final lines = (sortedProxies.length / columns).ceil();
    final minLines =
    innerHeight >= 200 ? (innerHeight / itemHeight).floor() : 3;
    final height = (itemHeight + 8) * min(lines, minLines) - 8;
    return Selector<Config, Set<String>>(
      selector: (_, config) => config.currentUnfoldSet,
      builder: (_, currentUnfoldSet, __) {
        return CommonCard(
          child: ExpansionTile(
            childrenPadding: const EdgeInsets.all(8),
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
                              group.type.name,
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
            children: [
              SizedBox(
                height: height,
                child: GridView.builder(
                  key: widget.key,
                  controller: scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: _getItemHeight(proxyCardType),
                  ),
                  itemCount: sortedProxies.length,
                  itemBuilder: (_, index) {
                    final proxy = sortedProxies[index];
                    return _currentProxyNameBuilder(
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
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
          ProxiesType.list => _buildExpansionGroupView(
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