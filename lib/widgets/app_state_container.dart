import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppStateContainer extends StatelessWidget {
  final Widget child;

  const AppStateContainer({
    super.key,
    required this.child,
  });

  _autoLaunchContainer(Widget child) {
    return Selector<Config, bool>(
      selector: (_, config) => config.autoLaunch,
      builder: (_, isAutoLaunch, child) {
        autoLaunch?.updateStatus(isAutoLaunch);
        return child!;
      },
      child: child,
    );
  }

  _updateNavigationsContainer(Widget child) {
    return Selector3<AppState, Config, ClashConfig, UpdateNavigationsSelector>(
      selector: (_, appState, config, clashConfig) {
        final hasGroups =
            appState.getCurrentGroups(clashConfig.mode).isNotEmpty;
        final hasProfile = config.profiles.isNotEmpty;
        return UpdateNavigationsSelector(
          openLogs: config.openLogs,
          hasProxies: hasGroups && hasProfile,
        );
      },
      builder: (context, state, child) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            context.appController.appState.navigationItems =
                navigation.getItems(
              openLogs: state.openLogs,
              hasProxies: state.hasProxies,
            );
          },
        );
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _autoLaunchContainer(
      _updateNavigationsContainer(
        child,
      ),
    );
  }
}
