import 'dart:async';
import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/proxy.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'application.dart';
import 'l10n/l10n.dart';
import 'models/models.dart';
import 'common/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  clashCore.initMessage();
  globalState.packageInfo = await PackageInfo.fromPlatform();
  final config = await preferences.getConfig() ?? Config();
  final clashConfig = await preferences.getClashConfig() ?? ClashConfig();
  await android?.init();
  await window?.init(config.windowProps);
  final appState = AppState(
    mode: clashConfig.mode,
    isCompatible: config.isCompatible,
    selectedMap: config.currentSelectedMap,
  );
  appState.navigationItems = navigation.getItems(
    openLogs: config.openLogs,
    hasProxies: false,
  );
  await globalState.init(
    appState: appState,
    config: config,
    clashConfig: clashConfig,
  );
  runAppWithPreferences(
    const Application(),
    appState: appState,
    config: config,
    clashConfig: clashConfig,
  );
}

@pragma('vm:entry-point')
Future<void> vpnService() async {
  WidgetsFlutterBinding.ensureInitialized();
  globalState.isVpnService = true;
  final config = await preferences.getConfig() ?? Config();
  final clashConfig = await preferences.getClashConfig() ?? ClashConfig();
  final appState = AppState(
    mode: clashConfig.mode,
    isCompatible: config.isCompatible,
    selectedMap: config.currentSelectedMap,
  );
  await globalState.init(
    appState: appState,
    config: config,
    clashConfig: clashConfig,
  );

  proxy?.setServiceMessageHandler(
    ServiceMessageHandler(
      onProtect: (Fd fd) async {
        await proxy?.setProtect(fd.value);
        clashCore.setFdMap(fd.id);
      },
      onProcess: (Process process) async {
        var packageName = await app?.resolverProcess(process);
        clashCore.setProcessMap(
          ProcessMapItem(
            id: process.id,
            value: packageName ?? "",
          ),
        );
      },
      onStarted: (String runTime) {
        globalState.applyProfile(
          appState: appState,
          config: config,
          clashConfig: clashConfig,
        );
      },
      onLoaded: (String groupName) {
        final currentSelectedMap = config.currentSelectedMap;
        final proxyName = currentSelectedMap[groupName];
        if (proxyName == null) return;
        clashCore.changeProxy(
          ChangeProxyParams(
            groupName: groupName,
            proxyName: proxyName,
          ),
        );
      },
    ),
  );
  final appLocalizations = await AppLocalizations.load(
    other.getLocaleForString(config.locale) ??
        WidgetsBinding.instance.platformDispatcher.locale,
  );
  await app?.tip(appLocalizations.startVpn);
  await globalState.startSystemProxy(
    appState: appState,
    config: config,
    clashConfig: clashConfig,
  );

  tile?.addListener(
    TileListenerWithVpn(
      onStop: () async {
        await app?.tip(appLocalizations.stopVpn);
        await globalState.stopSystemProxy();
        clashCore.shutdown();
        exit(0);
      },
    ),
  );

  globalState.updateTraffic();
  globalState.updateFunctionLists = [
        () {
      globalState.updateTraffic();
    }
  ];
}

@immutable
class ServiceMessageHandler with ServiceMessageListener {
  final Function(Fd fd) _onProtect;
  final Function(Process process) _onProcess;
  final Function(String runTime) _onStarted;
  final Function(String groupName) _onLoaded;

  const ServiceMessageHandler({
    required Function(Fd fd) onProtect,
    required Function(Process process) onProcess,
    required Function(String runTime) onStarted,
    required Function(String groupName) onLoaded,
  })
      : _onProtect = onProtect,
        _onProcess = onProcess,
        _onStarted = onStarted,
        _onLoaded = onLoaded;

  @override
  onProtect(Fd fd) {
    _onProtect(fd);
  }

  @override
  onProcess(Process process) {
    _onProcess(process);
  }

  @override
  onStarted(String runTime) {
    _onStarted(runTime);
  }

  @override
  onLoaded(String groupName) {
    _onLoaded(groupName);
  }
}

@immutable
class TileListenerWithVpn with TileListener {
  final Function() _onStop;

  const TileListenerWithVpn({
    required Function() onStop,
  }) : _onStop = onStop;

  @override
  void onStop() {
    _onStop();
  }
}
