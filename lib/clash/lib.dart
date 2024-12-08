import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/models/models.dart';

import 'generated/clash_ffi.dart';
import 'interface.dart';

class ClashLib with ClashInterface {
  static ClashLib? _instance;
  final receiver = ReceivePort();

  late final ClashFFI clashFFI;

  late final DynamicLibrary lib;

  ClashLib._internal() {
    lib = DynamicLibrary.open("libclash.so");
    clashFFI = ClashFFI(lib);
    clashFFI.initNativeApiBridge(
      NativeApi.initializeApiDLData,
    );
  }

  factory ClashLib() {
    _instance ??= ClashLib._internal();
    return _instance!;
  }

  initMessage() {
    clashFFI.initMessage(
      receiver.sendPort.nativePort,
    );
  }

  @override
  bool init(String homeDir) {
    final homeDirChar = homeDir.toNativeUtf8().cast<Char>();
    final isInit = clashFFI.initClash(homeDirChar) == 1;
    malloc.free(homeDirChar);
    return isInit;
  }

  @override
  shutdown() async {
    clashFFI.shutdownClash();
    lib.close();
  }

  @override
  bool get isInit => clashFFI.getIsInit() == 1;

  @override
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

  @override
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

  @override
  String getProxies() {
    final proxiesRaw = clashFFI.getProxies();
    final proxiesRawString = proxiesRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(proxiesRaw);
    return proxiesRawString;
  }

  @override
  String getExternalProviders() {
    final externalProvidersRaw = clashFFI.getExternalProviders();
    final externalProvidersRawString =
        externalProvidersRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(externalProvidersRaw);
    return externalProvidersRawString;
  }

  @override
  String getExternalProvider(String externalProviderName) {
    final externalProviderNameChar =
        externalProviderName.toNativeUtf8().cast<Char>();
    final externalProviderRaw =
        clashFFI.getExternalProvider(externalProviderNameChar);
    malloc.free(externalProviderNameChar);
    final externalProviderRawString =
        externalProviderRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(externalProviderRaw);
    return externalProviderRawString;
  }

  @override
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

  @override
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

  @override
  Future<String> updateExternalProvider(String providerName) {
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

  @override
  Future<String> changeProxy(ChangeProxyParams changeProxyParams) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final params = json.encode(changeProxyParams);
    final paramsChar = params.toNativeUtf8().cast<Char>();
    clashFFI.changeProxy(
      paramsChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(paramsChar);
    return completer.future;
  }

  @override
  String getConnections() {
    final connectionsDataRaw = clashFFI.getConnections();
    final connectionsString = connectionsDataRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(connectionsDataRaw);
    return connectionsString;
  }

  @override
  closeConnection(String id) {
    final idChar = id.toNativeUtf8().cast<Char>();
    clashFFI.closeConnection(idChar);
    malloc.free(idChar);
    return true;
  }

  @override
  closeConnections() {
    clashFFI.closeConnections();
    return true;
  }

  @override
  startListener() async {
    clashFFI.startListener();
    return true;
  }

  @override
  stopListener() async {
    clashFFI.stopListener();
    return true;
  }

  @override
  Future<String> asyncTestDelay(String proxyName) {
    final delayParams = {
      "proxy-name": proxyName,
      "timeout": httpTimeoutDuration.inMilliseconds,
    };
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
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

  @override
  String getTraffic(bool value) {
    final trafficRaw = clashFFI.getTraffic(value ? 1 : 0);
    final trafficString = trafficRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(trafficRaw);
    return trafficString;
  }

  @override
  String getTotalTraffic(bool value) {
    final trafficRaw = clashFFI.getTotalTraffic(value ? 1 : 0);
    clashFFI.freeCString(trafficRaw);
    return trafficRaw.cast<Utf8>().toDartString();
  }

  @override
  void resetTraffic() {
    clashFFI.resetTraffic();
  }

  @override
  void startLog() {
    clashFFI.startLog();
  }

  @override
  stopLog() {
    clashFFI.stopLog();
  }

  @override
  forceGc() {
    clashFFI.forceGc();
  }

  @override
  FutureOr<String> getCountryCode(String ip) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final ipChar = ip.toNativeUtf8().cast<Char>();
    clashFFI.getCountryCode(
      ipChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(ipChar);
    return completer.future;
  }

  @override
  FutureOr<String> getMemory() {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    clashFFI.getMemory(receiver.sendPort.nativePort);
    return completer.future;
  }

  /// Android

  startTun(int fd, int port) {
    if (!Platform.isAndroid) return;
    clashFFI.startTUN(fd, port);
  }

  stopTun() {
    clashFFI.stopTun();
  }

  updateDns(String dns) {
    if (!Platform.isAndroid) return;
    final dnsChar = dns.toNativeUtf8().cast<Char>();
    clashFFI.updateDns(dnsChar);
    malloc.free(dnsChar);
  }

  setProcessMap(ProcessMapItem processMapItem) {
    final processMapItemChar =
        json.encode(processMapItem).toNativeUtf8().cast<Char>();
    clashFFI.setProcessMap(processMapItemChar);
    malloc.free(processMapItemChar);
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

  setFdMap(int fd) {
    clashFFI.setFdMap(fd);
  }

  DateTime? getRunTime() {
    final runTimeRaw = clashFFI.getRunTime();
    final runTimeString = runTimeRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(runTimeRaw);
    if (runTimeString.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }
}

final clashLib = Platform.isAndroid ? ClashLib() : null;
