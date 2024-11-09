import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/function.dart';

class ClashManager extends StatefulWidget {
  final Widget child;

  const ClashManager({
    super.key,
    required this.child,
  });

  @override
  State<ClashManager> createState() => _ClashContainerState();
}

class _ClashContainerState extends State<ClashManager> with AppMessageListener {
  Function? updateDelayDebounce;

  Widget _updateContainer(Widget child) {
    return Selector2<Config, ClashConfig, ClashConfigState>(
      selector: (_, config, clashConfig) => ClashConfigState(
        overrideDns: config.overrideDns,
        mixedPort: clashConfig.mixedPort,
        allowLan: clashConfig.allowLan,
        ipv6: clashConfig.ipv6,
        logLevel: clashConfig.logLevel,
        geodataLoader: clashConfig.geodataLoader,
        externalController: clashConfig.externalController,
        mode: clashConfig.mode,
        findProcessMode: clashConfig.findProcessMode,
        keepAliveInterval: clashConfig.keepAliveInterval,
        unifiedDelay: clashConfig.unifiedDelay,
        tcpConcurrent: clashConfig.tcpConcurrent,
        tun: clashConfig.tun,
        dns: clashConfig.dns,
        hosts: clashConfig.hosts,
        geoXUrl: clashConfig.geoXUrl,
        rules: clashConfig.rules,
        globalRealUa: clashConfig.globalRealUa,
      ),
      shouldRebuild: (prev, next) {
        if (prev != next) {
          globalState.appController.updateClashConfigDebounce();
        }
        return prev != next;
      },
      builder: (__, state, child) {
        return child!;
      },
      child: child,
    );
  }

  Widget _updateCoreState(Widget child) {
    return Selector2<Config, ClashConfig, CoreState>(
      selector: (_, config, clashConfig) => CoreState(
        enable: config.vpnProps.enable,
        accessControl: config.isAccessControl ? config.accessControl : null,
        ipv6: config.vpnProps.ipv6,
        allowBypass: config.vpnProps.allowBypass,
        bypassDomain: config.networkProps.bypassDomain,
        systemProxy: config.vpnProps.systemProxy,
        onlyProxy: config.appSetting.onlyProxy,
        currentProfileName:
            config.currentProfile?.label ?? config.currentProfileId ?? "",
        routeAddress: clashConfig.routeAddress,
      ),
      builder: (__, state, child) {
        clashCore.setState(state);
        return child!;
      },
      child: child,
    );
  }

  _changeProfile() async {
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
        _changeProfile();
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _changeProfileContainer(
      _updateCoreState(
        _updateContainer(
          widget.child,
        ),
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
  Future<void> onDelay(Delay delay) async {
    final appController = globalState.appController;
    appController.setDelay(delay);
    super.onDelay(delay);
    updateDelayDebounce ??= debounce(() async {
      await appController.updateGroupDebounce();
      await appController.addCheckIpNumDebounce();
    }, milliseconds: 5000);
    updateDelayDebounce!();
  }

  @override
  void onLog(Log log) {
    globalState.appController.appFlowingState.addLog(log);
    if (log.logLevel == LogLevel.error) {
      globalState.appController.showSnackBar(log.payload ?? '');
    }
    super.onLog(log);
  }

  @override
  void onStarted(String runTime) {
    super.onStarted(runTime);
    globalState.appController.applyProfileDebounce();
  }

  @override
  void onRequest(Connection connection) async {
    globalState.appController.appState.addRequest(connection);
    super.onRequest(connection);
  }

  @override
  Future<void> onLoaded(String providerName) async {
    final appController = globalState.appController;
    appController.appState.setProvider(
      clashCore.getExternalProvider(
        providerName,
      ),
    );
    await appController.updateGroupDebounce();
    super.onLoaded(providerName);
  }
}
