import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    if (type == ProxyCardType.min) {
      return SizedBox(
        height: measure.bodyMediumHeight * 1,
        child: Text(
          proxy.name,
          maxLines: 1,
          style: context.textTheme.bodyMedium?.copyWith(
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
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
    globalState.changeProxy(
      config: appController.config,
      groupName: groupName,
      proxyName: proxy.name,
    );
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
              ),
          ],
        ),
      ),
    );
  }
}
