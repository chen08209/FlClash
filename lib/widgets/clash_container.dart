import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClashContainer extends StatefulWidget {
  final Widget child;

  const ClashContainer({
    super.key,
    required this.child,
  });

  @override
  State<ClashContainer> createState() => _ClashContainerState();
}

class _ClashContainerState extends State<ClashContainer>
    with AppMessageListener {
  Widget _updateCoreState(Widget child) {
    return Selector2<Config, ClashConfig, CoreState>(
      selector: (_, config, clashConfig) => CoreState(
        accessControl: config.isAccessControl ? config.accessControl : null,
        allowBypass: config.allowBypass,
        systemProxy: config.systemProxy,
        mixedPort: clashConfig.mixedPort,
        onlyProxy: config.onlyProxy,
        currentProfileName:
            config.currentProfile?.label ?? config.currentProfileId ?? "",
      ),
      builder: (__, state, child) {
        clashCore.setState(state);
        return child!;
      },
      child: child,
    );
  }

  _changeProfileHandle() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appController = globalState.appController;
      appController.appState.delayMap = {};
      await appController.applyProfile();
    });
  }

  Widget _changeProfileContainer(Widget child) {
    return Selector<Config, String?>(
      selector: (_, config) => config.currentProfileId,
      builder: (__, state, child) {
        _changeProfileHandle();
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _changeProfileContainer(
      _updateCoreState(
        widget.child,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
  }

  @override
  Future<void> dispose() async {
    clashMessage.removeListener(this);
    super.dispose();
  }

  @override
  void onDelay(Delay delay) {
    final appController = globalState.appController;
    appController.setDelay(delay);
    super.onDelay(delay);
  }

  @override
  void onLog(Log log) {
    globalState.appController.appState.addLog(log);
    super.onLog(log);
  }

  @override
  void onRequest(Connection connection) async {
    globalState.appController.appState.addRequest(connection);
    super.onRequest(connection);
  }

  @override
  void onLoaded(String providerName) {
    final appController = globalState.appController;
    appController.appState.setProvider(
      clashCore.getExternalProvider(
        providerName,
      ),
    );
    appController.addCheckIpNumDebounce();
    super.onLoaded(providerName);
  }

  @override
  Future<void> onStarted(String runTime) async {
    super.onStarted(runTime);
    proxy?.updateStartTime();
    final appController = globalState.appController;
    await appController.applyProfile(isPrue: true);
    appController.addCheckIpNumDebounce();
  }
}
