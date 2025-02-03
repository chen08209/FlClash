import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:fl_clash/plugins/vpn.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'application.dart';
import 'clash/core.dart';
import 'clash/lib.dart';
import 'common/common.dart';
import 'l10n/l10n.dart';
import 'models/models.dart';

Future<void> main() async {
  globalState.isService = false;
  WidgetsFlutterBinding.ensureInitialized();
  await clashCore.preload();
  globalState.packageInfo = await PackageInfo.fromPlatform();
  final version = await system.version;
  final config = await preferences.getConfig() ?? Config();
  final clashConfig = await preferences.getClashConfig() ?? ClashConfig();
  await AppLocalizations.load(
    other.getLocaleForString(config.appSetting.locale) ??
        WidgetsBinding.instance.platformDispatcher.locale,
  );
  await android?.init();
  await window?.init(config.windowProps, version);
  final appState = AppState(
    mode: clashConfig.mode,
    version: version,
    selectedMap: config.currentSelectedMap,
  );
  final appFlowingState = AppFlowingState();
  appState.navigationItems = navigation.getItems(
    openLogs: config.appSetting.openLogs,
    hasProxies: false,
  );
  tray.update(
    appState: appState,
    appFlowingState: appFlowingState,
    config: config,
    clashConfig: clashConfig,
  );
  HttpOverrides.global = FlClashHttpOverrides();
  runAppWithPreferences(
    const Application(),
    appState: appState,
    appFlowingState: appFlowingState,
    config: config,
    clashConfig: clashConfig,
  );
}

@pragma('vm:entry-point')
Future<void> _service(List<String> flags) async {
  globalState.isService = true;
  WidgetsFlutterBinding.ensureInitialized();
  final quickStart = flags.contains("quick");
  final clashLibHandler = ClashLibHandler();
  final config = await preferences.getConfig() ?? Config();
  await AppLocalizations.load(
    other.getLocaleForString(config.appSetting.locale) ??
        WidgetsBinding.instance.platformDispatcher.locale,
  );

  tile?.addListener(
    _TileListenerWithService(
      onStop: () async {
        await app?.tip(appLocalizations.stopVpn);
        clashLibHandler.stopListener();
        clashLibHandler.stopTun();
        await vpn?.stop();
        exit(0);
      },
    ),
  );
  if (!quickStart) {
    _handleMainIpc(clashLibHandler);
  } else {
    await ClashCore.initGeo();
    globalState.packageInfo = await PackageInfo.fromPlatform();
    final clashConfig = await preferences.getClashConfig() ?? ClashConfig();
    final homeDirPath = await appPath.homeDirPath;
    await app?.tip(appLocalizations.startVpn);
    clashLibHandler
        .quickStart(
      homeDirPath,
      globalState.getUpdateConfigParams(config, clashConfig, false),
      globalState.getCoreState(config, clashConfig),
    )
        .then(
      (res) async {
        if (res.isNotEmpty) {
          await vpn?.stop();
          exit(0);
        }
        await vpn?.start(
          clashLibHandler.getAndroidVpnOptions(),
        );
        clashLibHandler.startListener();
      },
    );
  }

  vpn?.handleGetStartForegroundParams = () {
    final traffic = clashLibHandler.getTraffic();
    return json.encode({
      "title": clashLibHandler.getCurrentProfileName(),
      "content": "$traffic"
    });
  };

  vpn?.addListener(
    _VpnListenerWithService(
      onStarted: (int fd) {
        clashLibHandler.startTun(fd);
      },
      onDnsChanged: (String dns) {
        clashLibHandler.updateDns(dns);
      },
    ),
  );
  final invokeReceiverPort = ReceivePort();
  clashLibHandler.attachInvokePort(
    invokeReceiverPort.sendPort.nativePort,
  );
  invokeReceiverPort.listen(
    (message) async {
      final invokeMessage = InvokeMessage.fromJson(json.decode(message));
      switch (invokeMessage.type) {
        case InvokeMessageType.protect:
          final fd = Fd.fromJson(invokeMessage.data);
          await vpn?.setProtect(fd.value);
          clashLibHandler.setFdMap(fd.id);
        case InvokeMessageType.process:
          final process = ProcessData.fromJson(invokeMessage.data);
          final processName = await vpn?.resolverProcess(process) ?? "";
          clashLibHandler.setProcessMap(
            ProcessMapItem(
              id: process.id,
              value: processName,
            ),
          );
      }
    },
  );
}

_handleMainIpc(ClashLibHandler clashLibHandler) {
  final sendPort = IsolateNameServer.lookupPortByName(mainIsolate);
  if (sendPort == null) {
    return;
  }
  final serviceReceiverPort = ReceivePort();
  serviceReceiverPort.listen((message) async {
    final res = await clashLibHandler.invokeAction(message);
    sendPort.send(res);
  });
  sendPort.send(serviceReceiverPort.sendPort);
  final messageReceiverPort = ReceivePort();
  clashLibHandler.attachMessagePort(
    messageReceiverPort.sendPort.nativePort,
  );
  messageReceiverPort.listen((message) {
    sendPort.send(message);
  });
}

@immutable
class _TileListenerWithService with TileListener {
  final Function() _onStop;

  const _TileListenerWithService({
    required Function() onStop,
  }) : _onStop = onStop;

  @override
  void onStop() {
    _onStop();
  }
}

@immutable
class _VpnListenerWithService with VpnListener {
  final Function(int fd) _onStarted;
  final Function(String dns) _onDnsChanged;

  const _VpnListenerWithService({
    required Function(int fd) onStarted,
    required Function(String dns) onDnsChanged,
  })  : _onStarted = onStarted,
        _onDnsChanged = onDnsChanged;

  @override
  void onStarted(int fd) {
    super.onStarted(fd);
    _onStarted(fd);
  }

  @override
  void onDnsChanged(String dns) {
    super.onDnsChanged(dns);
    _onDnsChanged(dns);
  }
}
