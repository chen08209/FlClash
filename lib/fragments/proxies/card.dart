import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProxyCard extends StatelessWidget {
  final String groupName;
  final Proxy proxy;
  final GroupType groupType;
  final CommonCardType style;
  final ProxyCardType type;

  const ProxyCard({
    super.key,
    required this.groupName,
    required this.proxy,
    required this.groupType,
    this.style = CommonCardType.plain,
    required this.type,
  });

  Measure get measure => globalState.measure;

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
    if (type == ProxyCardType.min) {
      return SizedBox(
        height: measure.bodyMediumHeight * 1,
        child: EmojiText(
          proxy.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
      );
    } else {
      return SizedBox(
        height: measure.bodyMediumHeight * 2,
        child: EmojiText(
          proxy.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
  }

  _changeProxy(BuildContext context) async {
    final appController = globalState.appController;
    final isUrlTest = groupType == GroupType.URLTest;
    final isSelector = groupType == GroupType.Selector;
    if (isUrlTest || isSelector) {
      final currentProxyName =
          appController.config.currentSelectedMap[groupName];
      final nextProxyName = switch (isUrlTest) {
        true => currentProxyName == proxy.name ? "" : proxy.name,
        false => proxy.name,
      };
      appController.config.updateCurrentSelectedMap(
        groupName,
        nextProxyName,
      );
      appController.changeProxy(
        groupName: groupName,
        proxyName: nextProxyName,
      );
      await appController.updateGroupDebounce();
      return;
    }
    globalState.showSnackBar(
      context,
      message: appLocalizations.notSelectedTip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final measure = globalState.measure;
    final delayText = _buildDelayText();
    final proxyNameText = _buildProxyNameText(context);
    return currentGroupProxyNameBuilder(
      groupName: groupName,
      builder: (currentGroupName) {
        return Stack(
          children: [
            CommonCard(
              type: style,
              key: key,
              onPressed: () {
                _changeProxy(context);
              },
              isSelected: currentGroupName == proxy.name,
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
                            return EmojiText(
                              desc,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.textTheme.bodySmall?.color
                                    ?.toLight(),
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
                                    color: context.textTheme.bodySmall?.color
                                        ?.toLight(),
                                  ),
                                ),
                              ),
                            ),
                            delayText,
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (groupType == GroupType.URLTest)
              Selector<Config, String>(
                selector: (_, config) {
                  final selectedProxyName =
                      config.currentSelectedMap[groupName];
                  return selectedProxyName ?? '';
                },
                builder: (_, value, __) {
                  if (value != proxy.name) return Container();
                  return Positioned.fill(
                    child: Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        child: const SelectIcon(),
                      ),
                    ),
                  );
                },
                child: Positioned.fill(
                  child: Container(
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
                ),
              )
          ],
        );
      },
    );
  }
}
