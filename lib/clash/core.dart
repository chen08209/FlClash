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

  ClashCore._internal() {
    if (Platform.isWindows) {
      lib = DynamicLibrary.open("libclash.dll");
      clashFFI = ClashFFI(lib);
    }
    if (Platform.isMacOS) {
      lib = DynamicLibrary.open("libclash.dylib");
      clashFFI = ClashFFI(lib);
    }
    if (Platform.isAndroid || Platform.isLinux) {
      lib = DynamicLibrary.open("libclash.so");
      clashFFI = ClashFFI(lib);
    }
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

  bool updateConfig(UpdateConfigParams updateConfigParams) {
    final params = json.encode(updateConfigParams);
    return clashFFI.updateConfig(
          params.toNativeUtf8().cast(),
        ) ==
        1;
  }

  List<Group> getProxiesGroups() {
    final proxiesRaw = clashFFI.getProxies();
    final proxies = json.decode(proxiesRaw.cast<Utf8>().toDartString());
    final groupsRaw = List.from(proxies.values).where((e) {
      final excludeName = !UsedProxyExtension.valueList
          .where((element) => element != UsedProxy.GLOBAL.name)
          .contains(e['name']);
      final validType = GroupTypeExtension.valueList.contains(e['type']);
      return excludeName && validType;
    }).map(
          (e) {
        e["all"] = ((e["all"] ?? []) as List)
            .map(
              (name) => proxies[name],
        )
            .toList();
        return e;
      },
    ).toList()
      ..sort(
            (a, b) {
          final aIndex = GroupTypeExtension.getGroupType(a['type'])?.index;
          final bIndex = GroupTypeExtension.getGroupType(b['type'])?.index;
          if (a == null && b == null) {
            return 0;
          }
          if (a == null) {
            return 1;
          }
          if (b == null) {
            return -1;
          }
          return aIndex! - bIndex!;
        },
      );
    final groups = groupsRaw.map((e) => Group.fromJson(e)).toList();
    return groups;
  }

  bool changeProxy(ChangeProxyParams changeProxyParams) {
    final params = json.encode(changeProxyParams);
    return clashFFI.changeProxy(params.toNativeUtf8().cast()) == 1;
  }

  bool delay(String proxyName) {
    final delayParams = {
      "proxy-name": proxyName,
      "timeout": appConstant.httpTimeoutDuration.inMilliseconds,
    };
    clashFFI.asyncTestDelay(json.encode(delayParams).toNativeUtf8().cast());
    return true;
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
