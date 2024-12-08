import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VpnManager extends StatefulWidget {
  final Widget child;

  const VpnManager({
    super.key,
    required this.child,
  });

  @override
  State<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends State<VpnManager> {
  showTip() {
    debouncer.call(
      DebounceTag.vpnTip,
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final appFlowingState = globalState.appController.appFlowingState;
          if (appFlowingState.isStart) {
            globalState.showNotifier(
              appLocalizations.vpnTip,
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<Config, ClashConfig, VPNState>(
      selector: (_, config, clashConfig) => VPNState(
        accessControl: config.accessControl,
        vpnProps: config.vpnProps,
        stack: clashConfig.tun.stack,
      ),
      shouldRebuild: (prev, next) {
        if (prev != next) {
          showTip();
        }
        return prev != next;
      },
      builder: (_, __, child) {
        return child!;
      },
      child: widget.child,
    );
  }
}
