import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import '../enum/enum.dart';
import '../models/models.dart';
import '../common/common.dart';
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

  bool validateConfig(String data) {
    return clashFFI.validateConfig(
          data.toNativeUtf8().cast(),
        ) ==
        1;
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
          final proxy = proxies[e];
          return GroupTypeExtension.valueList.contains(proxy['type']);
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

  bool changeProxy(ChangeProxyParams changeProxyParams) {
    final params = json.encode(changeProxyParams);
    return clashFFI.changeProxy(params.toNativeUtf8().cast()) == 1;
  }

  Future<Delay> delay(String proxyName) {
    final completer = Completer<Delay>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        final m = Message.fromJson(json.decode(message));
        final delay = Delay.fromJson(m.data);
        completer.complete(delay);
        receiver.close();
      }
    });
    final delayParams = {
      "proxy-name": proxyName,
      "timeout": appConstant.httpTimeoutDuration.inMilliseconds,
    };
    clashFFI.asyncTestDelay(
      json.encode(delayParams).toNativeUtf8().cast(),
      receiver.sendPort.nativePort,
    );
    Future.delayed(appConstant.httpTimeoutDuration + appConstant.moreDuration,
        () {
      if (!completer.isCompleted) {
        receiver.close();
        completer.complete(
          Delay(
            name: proxyName,
            value: -1,
          ),
        );
      }
    });
    return completer.future;
  }

  healthcheck() {
    clashFFI.healthcheck();
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

  void stopTun() {
    clashFFI.stopTun();
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
