import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'generated/clash_ffi.dart';

class ClashCore {
  static ClashCore? _instance;
  static final receiver = ReceivePort();

  late final ClashFFI clashFFI;
  late final DynamicLibrary lib;

  DynamicLibrary _getClashLib() {
    if (Platform.isWindows) {
      return DynamicLibrary.open("libclash.dll");
    }
    if (Platform.isMacOS) {
      return DynamicLibrary.open("libclash.dylib");
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open("libclash.so");
    }
    throw "Platform is not supported";
  }

  ClashCore._internal() {
    lib = _getClashLib();
    clashFFI = ClashFFI(lib);
    clashFFI.initNativeApiBridge(
      NativeApi.initializeApiDLData,
      receiver.sendPort.nativePort,
    );
  }

  factory ClashCore() {
    _instance ??= ClashCore._internal();
    return _instance!;
  }

  bool init(String homeDir) {
    return clashFFI.initClash(
          homeDir.toNativeUtf8().cast(),
        ) ==
        1;
  }

  shutdown() {
    clashFFI.shutdownClash();
    lib.close();
  }

  bool get isInit => clashFFI.getIsInit() == 1;

  Future<String> validateConfig(String data) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    clashFFI.validateConfig(
      data.toNativeUtf8().cast(),
      receiver.sendPort.nativePort,
    );
    return completer.future;
  }

  Future<String> updateConfig(UpdateConfigParams updateConfigParams) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final params = json.encode(updateConfigParams);
    clashFFI.updateConfig(
      params.toNativeUtf8().cast(),
      receiver.sendPort.nativePort,
    );
    return completer.future;
  }

  Future<List<Group>> getProxiesGroups() {
    final proxiesRaw = clashFFI.getProxies();
    final proxiesRawString = proxiesRaw.cast<Utf8>().toDartString();
    return Isolate.run<List<Group>>(() {
      final proxies = json.decode(proxiesRawString);
      final groupNames = [
        UsedProxy.GLOBAL.name,
        ...(proxies[UsedProxy.GLOBAL.name]["all"] as List).where((e) {
          final proxy = proxies[e] ?? {};
          return GroupTypeExtension.valueList.contains(proxy['type']) && proxy['hidden'] != true;
        })
      ];
      final groupsRaw = groupNames.map((groupName) {
        final group = proxies[groupName];
        group["all"] = ((group["all"] ?? []) as List)
            .map(
              (name) => proxies[name],
            )
            .toList();
        return group;
      }).toList();
      return groupsRaw.map((e) => Group.fromJson(e)).toList();
    });
  }

  Future<List<ExternalProvider>> getExternalProviders() {
    final externalProvidersRaw = clashFFI.getExternalProviders();
    final externalProvidersRawString =
        externalProvidersRaw.cast<Utf8>().toDartString();
    return Isolate.run<List<ExternalProvider>>(() {
      final externalProviders =
          (json.decode(externalProvidersRawString) as List<dynamic>)
              .map(
                (item) => ExternalProvider.fromJson(item),
              )
              .toList();
      return externalProviders;
    });
  }

  Future<String> updateExternalProvider({
    required String providerName,
    required String providerType,
  }) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    clashFFI.updateExternalProvider(
      providerName.toNativeUtf8().cast(),
      providerType.toNativeUtf8().cast(),
      receiver.sendPort.nativePort,
    );
    return completer.future;
  }

  bool changeProxy(ChangeProxyParams changeProxyParams) {
    final params = json.encode(changeProxyParams);
    return clashFFI.changeProxy(params.toNativeUtf8().cast()) == 1;
  }

  Future<Delay> getDelay(String proxyName) {
    final delayParams = {
      "proxy-name": proxyName,
      "timeout": httpTimeoutDuration.inMilliseconds,
    };
    final completer = Completer<Delay>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(Delay.fromJson(json.decode(message)));
        receiver.close();
      }
    });
    clashFFI.asyncTestDelay(
      json.encode(delayParams).toNativeUtf8().cast(),
      receiver.sendPort.nativePort,
    );
    Future.delayed(httpTimeoutDuration + moreDuration, () {
      receiver.close();
      completer.complete(
        Delay(name: proxyName, value: -1),
      );
    });
    return completer.future;
  }

  clearEffect(String path) {
    clashFFI.clearEffect(path.toNativeUtf8().cast());
  }

  VersionInfo getVersionInfo() {
    final versionInfoRaw = clashFFI.getVersionInfo();
    final versionInfo = json.decode(versionInfoRaw.cast<Utf8>().toDartString());
    return VersionInfo.fromJson(versionInfo);
  }

  Traffic getTraffic() {
    final trafficRaw = clashFFI.getTraffic();
    final trafficMap = json.decode(trafficRaw.cast<Utf8>().toDartString());
    return Traffic.fromMap(trafficMap);
  }

  void startLog() {
    clashFFI.startLog();
  }

  stopLog() {
    clashFFI.stopLog();
  }

  startTun(int fd) {
    clashFFI.startTUN(fd);
  }

  requestGc() {
    clashFFI.forceGc();
  }

  void stopTun() {
    clashFFI.stopTun();
  }

  void setProcessMap(ProcessMapItem processMapItem) {
    clashFFI.setProcessMap(json.encode(processMapItem).toNativeUtf8().cast());
  }

  DateTime? getRunTime() {
    final runTimeString = clashFFI.getRunTime().cast<Utf8>().toDartString();
    if (runTimeString.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }

  List<Connection> getConnections() {
    final connectionsDataRaw = clashFFI.getConnections();
    final connectionsData =
        json.decode(connectionsDataRaw.cast<Utf8>().toDartString()) as Map;
    final connectionsRaw = connectionsData['connections'] as List? ?? [];
    return connectionsRaw.map((e) => Connection.fromJson(e)).toList();
  }
}

final clashCore = ClashCore();
