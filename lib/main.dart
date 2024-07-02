import 'dart:async';
import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/plugins/app.dart';
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
  await android?.init();
  await window?.init();
  globalState.packageInfo = await PackageInfo.fromPlatform();
  final config = await preferences.getConfig() ?? Config();
  final clashConfig = await preferences.getClashConfig() ?? ClashConfig();
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
  final config = await preferences.getConfig() ?? Config();
  final clashConfig = await preferences.getClashConfig() ?? ClashConfig();
  final appState = AppState(
    mode: clashConfig.mode,
    isCompatible: config.isCompatible,
    selectedMap: config.currentSelectedMap,
  );
  clashMessage.addListener(
    ClashMessageListenerWithVpn(
      onTun: (Fd fd) async {
        await proxyManager.setProtect(fd.value);
        clashCore.setFdMap(fd.id);
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

  await globalState.init(
    appState: appState,
    config: config,
    clashConfig: clashConfig,
  );

  globalState.applyProfile(
    appState: appState,
    config: config,
    clashConfig: clashConfig,
  );

  final appLocalizations = await AppLocalizations.load(
    other.getLocaleForString(config.locale) ??
        WidgetsBinding.instance.platformDispatcher.locale,
  );

  handleStart() async {
    await app?.tip(appLocalizations.startVpn);
    await globalState.startSystemProxy(
      appState: appState,
      config: config,
      clashConfig: clashConfig,
    );
    globalState.updateTraffic(config: config);
    globalState.updateFunctionLists = [
      () {
        globalState.updateTraffic(config: config);
      }
    ];
  }

  handleStart();

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
}

class ClashMessageListenerWithVpn with ClashMessageListener {
  final Function(Fd fd) _onTun;
  final Function(String) _onLoaded;

  ClashMessageListenerWithVpn({
    required Function(Fd fd) onTun,
    required Function(String) onLoaded,
  })  : _onTun = onTun,
        _onLoaded = onLoaded;

  @override
  void onTun(Fd fd) {
    _onTun(fd);
  }

  @override
  void onLoaded(String groupName) {
    _onLoaded(groupName);
  }
}

class TileListenerWithVpn with TileListener {
  final Function() _onStop;

  TileListenerWithVpn({
    required Function() onStop,
  }) : _onStop = onStop;

  @override
  void onStop() {
    _onStop();
  }
}
