import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card.dart';

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
            return ProxiesExpansionView(
              key: Key(groupName),
              groupName: groupName,
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

class ProxiesExpansionView extends StatefulWidget {
  final String groupName;

  const ProxiesExpansionView({
    super.key,
    required this.groupName,
  });

  @override
  State<ProxiesExpansionView> createState() => _ProxiesExpansionViewState();
}

class _ProxiesExpansionViewState extends State<ProxiesExpansionView> {
  var isLock = false;

  _delayTest(List<Proxy> proxies) async {
    if (isLock) return;
    isLock = true;
    for (final proxy in proxies) {
      final appController = globalState.appController;
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
    isLock = false;
  }

  get groupName => widget.groupName;

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxyGroupSelectorState>(
      selector: (_, appState, config) {
        final group = appState.getGroupWithName(groupName)!;
        final currentProxyName =
            config.currentSelectedMap[group.name] ?? group.now;
        return ProxyGroupSelectorState(
          proxyCardType: config.proxyCardType,
          proxiesSortType: config.proxiesSortType,
          sortNum: appState.sortNum,
          group: group,
          columns: globalState.appController.columns,
          currentProxyName: currentProxyName ?? '',
        );
      },
      builder: (_, state, __) {
        final group = state.group;
        final proxies = globalState.appController.getSortProxies(
          state.group.all,
        );
        return CommonCard(
          child: ExpansionTile(
            iconColor: context.colorScheme.onSurfaceVariant,
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
                      Text(group.name),
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
                            if (state.currentProxyName.isNotEmpty) ...[
                              Icon(
                                Icons.arrow_right,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  state.currentProxyName,
                                  style: context.textTheme.labelMedium?.toLight,
                                ),
                              ),
                            ]
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
                    _delayTest(group.all);
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
                crossAxisCount: state.columns,
                children: [
                  for (final proxy in proxies)
                    ProxyCard(
                      style: CommonCardType.filled,
                      type: state.proxyCardType,
                      isSelected: state.currentProxyName == proxy.name,
                      key: ValueKey('$groupName.${proxy.name}'),
                      proxy: proxy,
                      groupName: groupName,
                    )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
