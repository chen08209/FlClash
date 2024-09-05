import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/function.dart';

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
  Function? updateClashConfigDebounce;

  Widget _updateContainer(Widget child) {
    return Selector2<Config,ClashConfig, ClashConfigState>(
      selector: (_,config, clashConfig) => ClashConfigState(
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
      builder: (__, state, child) {
        if (updateClashConfigDebounce == null) {
          updateClashConfigDebounce = debounce<Function()>(() async {
            await globalState.appController.updateClashConfig();
          });
        } else {
          updateClashConfigDebounce!();
        }
        return child!;
      },
      child: child,
    );
  }

  Widget _updateCoreState(Widget child) {
    return Selector2<Config, ClashConfig, CoreState>(
      selector: (_, config, clashConfig) => CoreState(
        accessControl: config.isAccessControl ? config.accessControl : null,
        enable: config.vpnProps.enable,
        allowBypass: config.vpnProps.allowBypass,
        systemProxy: config.vpnProps.systemProxy,
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

  _changeProfile() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (globalState.autoRun) {
        globalState.autoRun = false;
        return;
      }
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
    await globalState.appController.updateGroupDebounce();
  }

  @override
  void onLog(Log log) {
    globalState.appController.appState.addLog(log);
    if (log.logLevel == LogLevel.error) {
      globalState.appController.showSnackBar(log.payload ?? '');
    }
    // debugPrint("$log");
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
}
