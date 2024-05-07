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

  List<Proxy> _sortOfName(List<Proxy> proxies) {
    return List.of(proxies)
      ..sort(
        (a, b) => Other.sortByChar(a.name, b.name),
      );
  }

  List<Proxy> _sortOfDelay(BuildContext context, List<Proxy> proxies) {
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
    if (proxiesSortType == ProxiesSortType.delay) {
      return _sortOfDelay(context, proxies);
    }
    if (proxiesSortType == ProxiesSortType.name) return _sortOfName(proxies);
    return proxies;
  }

  double _getItemHeight(BuildContext context) {
    final measure = context.appController.measure;
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
    final measure = context.appController.measure;
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
            SizedBox(
              height: measure.labelSmallHeight,
              child: Selector<AppState, int?>(
                selector: (context, appState) => appState.getDelay(proxy.name),
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

  Widget _buildGrid(
    BuildContext context, {
    required List<Proxy> proxies,
    required int columns,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: _getItemHeight(context),
      ),
      itemCount: proxies.length,
      itemBuilder: (_, index) {
        final proxy = proxies[index];
        return Selector<AppState, bool>(
          selector: (_, appState) => proxy.name == appState.currentProxyName,
          builder: (_, isSelected, __) {
            return _card(
              isSelected: isSelected,
              onPressed: () {
                context.appController.config.currentProxyName = proxy.name;
                context.appController.changeProxy();
              },
              proxy: proxy,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DelayTestButtonContainer(
      child: Selector<AppState, bool>(
        selector: (_, appState) => appState.currentLabel == 'proxies',
        builder: (_, isCurrent, child) {
          if (isCurrent) {
            _initActions();
          }
          return child!;
        },
        child: Selector2<AppState, Config, ProxiesSelectorState>(
          selector: (_, appState, config) {
            return ProxiesSelectorState(
              proxiesSortType: config.proxiesSortType,
              sortNum: appState.sortNum,
              group: appState.currentGroup,
            );
          },
          builder: (_, state, __) {
            if (state.group == null) return Container();
            final proxies = _getProxies(
              state.group!.all,
              state.proxiesSortType,
            );
            return Align(
              alignment: Alignment.topCenter,
              child: SlotLayout(
                config: {
                  Breakpoints.small: SlotLayout.from(
                    key: const Key('proxies_grid_small'),
                    builder: (_) => _buildGrid(
                      context,
                      proxies: proxies,
                      columns: 2,
                    ),
                  ),
                  Breakpoints.medium: SlotLayout.from(
                    key: const Key('proxies_grid_medium'),
                    builder: (_) => _buildGrid(
                      context,
                      proxies: proxies,
                      columns: 3,
                    ),
                  ),
                  Breakpoints.large: SlotLayout.from(
                    key: const Key('proxies_grid_large'),
                    builder: (_) => _buildGrid(
                      context,
                      proxies: proxies,
                      columns: 4,
                    ),
                  ),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class DelayTestButtonContainer extends StatefulWidget {
  final Widget child;

  const DelayTestButtonContainer({
    super.key,
    required this.child,
  });

  @override
  State<DelayTestButtonContainer> createState() =>
      _DelayTestButtonContainerState();
}

class _DelayTestButtonContainerState extends State<DelayTestButtonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  _healthcheck() async {
    _controller.forward();
    context.appController.healthcheck();
    await Future.delayed(
      appConstant.httpTimeoutDuration + appConstant.moreDuration,
    );
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return SizedBox(
              width: 56,
              height: 56,
              child: Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: child!,
                ),
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
