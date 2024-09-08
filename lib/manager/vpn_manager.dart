import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/function.dart';

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
  Function? vpnTipDebounce;

  showTip() {
    vpnTipDebounce ??= debounce<Function()>(() async {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final appState = globalState.appController.appState;
        if (appState.isStart) {
          globalState.showSnackBar(
            context,
            message: appLocalizations.vpnTip,
          );
        }
      });
    });
    vpnTipDebounce!();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, VPNState>(
      selector: (_, config) => VPNState(
        accessControl: config.accessControl,
        vpnProps: config.vpnProps,
      ),
      shouldRebuild: (prev,next){
        if(prev != next){
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
