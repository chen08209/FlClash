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
    );
  }

  factory ClashCore() {
    _instance ??= ClashCore._internal();
    return _instance!;
  }

  bool init(String homeDir) {
    final homeDirChar = homeDir.toNativeUtf8().cast<Char>();
    final isInit = clashFFI.initClash(homeDirChar) == 1;
    malloc.free(homeDirChar);
    return isInit;
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
    final dataChar = data.toNativeUtf8().cast<Char>();
    clashFFI.validateConfig(
      dataChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(dataChar);
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
    final paramsChar = params.toNativeUtf8().cast<Char>();
    clashFFI.updateConfig(
      paramsChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(paramsChar);
    return completer.future;
  }

  initMessage() {
    clashFFI.initMessage(
      receiver.sendPort.nativePort,
    );
  }

  Future<List<Group>> getProxiesGroups() {
    final proxiesRaw = clashFFI.getProxies();
    final proxiesRawString = proxiesRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(proxiesRaw);
    return Isolate.run<List<Group>>(() {
      if (proxiesRawString.isEmpty) return [];
      final proxies = (json.decode(proxiesRawString) ?? {}) as Map;
      if (proxies.isEmpty) return [];
      final groupNames = [
        UsedProxy.GLOBAL.name,
        ...(proxies[UsedProxy.GLOBAL.name]["all"] as List).where((e) {
          final proxy = proxies[e] ?? {};
          return GroupTypeExtension.valueList.contains(proxy['type']);
        })
      ];
      final groupsRaw = groupNames.map((groupName) {
        final group = proxies[groupName];
        group["all"] = ((group["all"] ?? []) as List)
            .map(
              (name) => proxies[name],
            )
            .where((proxy) => proxy != null)
            .toList();
        return group;
      }).toList();
      return groupsRaw
          .map(
            (e) => Group.fromJson(e),
          )
          .toList();
    });
  }

  Future<List<ExternalProvider>> getExternalProviders() {
    final externalProvidersRaw = clashFFI.getExternalProviders();
    final externalProvidersRawString =
        externalProvidersRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(externalProvidersRaw);
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

  ExternalProvider? getExternalProvider(String externalProviderName) {
    final externalProviderNameChar =
        externalProviderName.toNativeUtf8().cast<Char>();
    final externalProviderRaw =
        clashFFI.getExternalProvider(externalProviderNameChar);
    malloc.free(externalProviderNameChar);
    final externalProviderRawString =
        externalProviderRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(externalProviderRaw);
    if (externalProviderRawString.isEmpty) return null;
    return ExternalProvider.fromJson(json.decode(externalProviderRawString));
  }

  Future<String> updateGeoData({
    required String geoType,
    required String geoName,
  }) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final geoTypeChar = geoType.toNativeUtf8().cast<Char>();
    final geoNameChar = geoName.toNativeUtf8().cast<Char>();
    clashFFI.updateGeoData(
      geoTypeChar,
      geoNameChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(geoTypeChar);
    malloc.free(geoNameChar);
    return completer.future;
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final providerNameChar = providerName.toNativeUtf8().cast<Char>();
    final dataChar = data.toNativeUtf8().cast<Char>();
    clashFFI.sideLoadExternalProvider(
      providerNameChar,
      dataChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(providerNameChar);
    malloc.free(dataChar);
    return completer.future;
  }

  Future<String> updateExternalProvider({
    required String providerName,
  }) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final providerNameChar = providerName.toNativeUtf8().cast<Char>();
    clashFFI.updateExternalProvider(
      providerNameChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(providerNameChar);
    return completer.future;
  }

  changeProxy(ChangeProxyParams changeProxyParams) {
    final params = json.encode(changeProxyParams);
    final paramsChar = params.toNativeUtf8().cast<Char>();
    clashFFI.changeProxy(paramsChar);
    malloc.free(paramsChar);
  }

  start() {
    clashFFI.start();
  }

  stop() {
    clashFFI.stop();
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
    final delayParamsChar =
        json.encode(delayParams).toNativeUtf8().cast<Char>();
    clashFFI.asyncTestDelay(
      delayParamsChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(delayParamsChar);
    return completer.future;
  }

  clearEffect(String profileId) {
    final profileIdChar = profileId.toNativeUtf8().cast<Char>();
    clashFFI.clearEffect(profileIdChar);
    malloc.free(profileIdChar);
  }

  VersionInfo getVersionInfo() {
    final versionInfoRaw = clashFFI.getVersionInfo();
    final versionInfo = json.decode(versionInfoRaw.cast<Utf8>().toDartString());
    clashFFI.freeCString(versionInfoRaw);
    return VersionInfo.fromJson(versionInfo);
  }

  setState(CoreState state) {
    final stateChar = json.encode(state).toNativeUtf8().cast<Char>();
    clashFFI.setState(stateChar);
    malloc.free(stateChar);
  }

  String getCurrentProfileName() {
    final currentProfileRaw = clashFFI.getCurrentProfileName();
    final currentProfile = currentProfileRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(currentProfileRaw);
    return currentProfile;
  }

  AndroidVpnOptions getAndroidVpnOptions() {
    final vpnOptionsRaw = clashFFI.getAndroidVpnOptions();
    final vpnOptions = json.decode(vpnOptionsRaw.cast<Utf8>().toDartString());
    clashFFI.freeCString(vpnOptionsRaw);
    return AndroidVpnOptions.fromJson(vpnOptions);
  }

  Traffic getTraffic() {
    final trafficRaw = clashFFI.getTraffic();
    final trafficMap = json.decode(trafficRaw.cast<Utf8>().toDartString());
    clashFFI.freeCString(trafficRaw);
    return Traffic.fromMap(trafficMap);
  }

  Traffic getTotalTraffic() {
    final trafficRaw = clashFFI.getTotalTraffic();
    final trafficMap = json.decode(trafficRaw.cast<Utf8>().toDartString());
    clashFFI.freeCString(trafficRaw);
    return Traffic.fromMap(trafficMap);
  }

  void resetTraffic() {
    clashFFI.resetTraffic();
  }

  void startLog() {
    clashFFI.startLog();
  }

  stopLog() {
    clashFFI.stopLog();
  }

  startTun(int fd, int port) {
    if (!Platform.isAndroid) return;
    clashFFI.startTUN(fd, port);
  }

  updateDns(String dns) {
    if (!Platform.isAndroid) return;
    final dnsChar = dns.toNativeUtf8().cast<Char>();
    clashFFI.updateDns(dnsChar);
    malloc.free(dnsChar);
  }

  requestGc() {
    clashFFI.forceGc();
  }

  void stopTun() {
    clashFFI.stopTun();
  }

  void setProcessMap(ProcessMapItem processMapItem) {
    final processMapItemChar =
        json.encode(processMapItem).toNativeUtf8().cast<Char>();
    clashFFI.setProcessMap(processMapItemChar);
    malloc.free(processMapItemChar);
  }

  void setFdMap(int fd) {
    clashFFI.setFdMap(fd);
  }

  DateTime? getRunTime() {
    final runTimeRaw = clashFFI.getRunTime();
    final runTimeString = runTimeRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(runTimeRaw);
    if (runTimeString.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }

  List<Connection> getConnections() {
    final connectionsDataRaw = clashFFI.getConnections();
    final connectionsData =
        json.decode(connectionsDataRaw.cast<Utf8>().toDartString()) as Map;
    clashFFI.freeCString(connectionsDataRaw);
    final connectionsRaw = connectionsData['connections'] as List? ?? [];
    return connectionsRaw.map((e) => Connection.fromJson(e)).toList();
  }

  closeConnection(String id) {
    final idChar = id.toNativeUtf8().cast<Char>();
    clashFFI.closeConnection(idChar);
    malloc.free(idChar);
  }

  closeConnections() {
    clashFFI.closeConnections();
  }
}

final clashCore = ClashCore();
