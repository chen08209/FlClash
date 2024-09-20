import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppStateManager extends StatefulWidget {
  final Widget child;

  const AppStateManager({
    super.key,
    required this.child,
  });

  @override
  State<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends State<AppStateManager>
    with WidgetsBindingObserver {

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final isPaused = state == AppLifecycleState.paused;
    if (isPaused) {
      await globalState.appController.savePreferences();
    }
  }

  @override
  void didChangePlatformBrightness() {
    globalState.appController.appState.brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  @override
  Widget build(BuildContext context) {
    return _updateNavigationsContainer(
      widget.child,
    );
  }
}
