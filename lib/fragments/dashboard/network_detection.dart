import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkDetection extends StatefulWidget {
  const NetworkDetection({super.key});

  @override
  State<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends State<NetworkDetection> {
  Widget _buildDescription(String? currentProxyName, int? delay) {
    if (currentProxyName == null) {
      return TooltipText(
        text: Text(
          appLocalizations.noProxyDesc,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (delay == 0 || delay == null) {
      return const AspectRatio(
        aspectRatio: 1,
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
        ),
      );
    }
    if (delay > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TooltipText(
            text: Text(
              "$delay",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.textTheme.titleLarge
                  ?.copyWith(
                    color: context.colorScheme.primary,
                  )
                  .toSoftBold(),
            ),
          ),
          const Flexible(
            child: SizedBox(
              width: 4,
            ),
          ),
          Flexible(
            flex: 0,
            child: Text(
              'ms',
              style: Theme.of(context).textTheme.bodyMedium?.toLight(),
            ),
          ),
        ],
      );
    }
    return Text(
      "Timeout",
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.red,
          ),
    );
  }

  _updateCurrentDelay(
    String? currentProxyName,
    int? delay,
    bool isCurrent,
    bool isInit,
  ) {
    if (!isCurrent || currentProxyName == null || !isInit) return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (delay == null) {
        globalState.appController.setDelay(
          Delay(
            name: currentProxyName,
            value: 0,
          ),
        );
        globalState.updateCurrentDelay(
          currentProxyName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      info: Info(
        iconData: Icons.network_check,
        label: appLocalizations.networkDetection,
      ),
      child: Selector<AppState, NetworkDetectionSelectorState>(
        selector: (_, appState) {
          return NetworkDetectionSelectorState(
            currentProxyName: appState.showProxyName,
            delay: appState.getDelay(
              appState.showProxyName,
            ),
          );
        },
        builder: (_, state, __) {
          return Container(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 0,
                  child: TooltipText(
                    text: Text(
                      state.currentProxyName ?? appLocalizations.noProxy,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.toSoftBold(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: Container(
                    height: globalState.appController.measure.titleLargeHeight,
                    alignment: Alignment.centerLeft,
                    child: FadeBox(
                      child: _buildDescription(
                        state.currentProxyName,
                        state.delay,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
