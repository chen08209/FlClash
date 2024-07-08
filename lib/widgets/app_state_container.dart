import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppStateContainer extends StatelessWidget {
  final Widget child;

  const AppStateContainer({
    super.key,
    required this.child,
  });

  _updateNavigationsContainer(Widget child) {
    return Selector2<AppState, Config, UpdateNavigationsSelector>(
      selector: (_, appState, config) {
        final group = appState.currentGroups;
        final hasProfile = config.profiles.isNotEmpty;
        return UpdateNavigationsSelector(
          openLogs: config.openLogs,
          hasProxies: group.isNotEmpty && hasProfile,
        );
      },
      builder: (context, state, child) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            globalState.appController.appState.navigationItems =
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
    return _updateNavigationsContainer(
      child,
    );
  }
}
