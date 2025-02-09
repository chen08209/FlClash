import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/state.dart';

import 'generated/clash_ffi.dart';
import 'interface.dart';

class ClashLib extends ClashHandlerInterface with AndroidClashInterface {
  static ClashLib? _instance;
  Completer<bool> _canSendCompleter = Completer();
  SendPort? sendPort;
  final receiverPort = ReceivePort();

  ClashLib._internal() {
    _initService();
  }

  @override
  preload() {
    return _canSendCompleter.future;
  }

  _initService() async {
    await service?.destroy();
    _registerMainPort(receiverPort.sendPort);
    receiverPort.listen((message) {
      if (message is SendPort) {
        if (_canSendCompleter.isCompleted) {
          sendPort = null;
          _canSendCompleter = Completer();
        }
        sendPort = message;
        _canSendCompleter.complete(true);
      } else {
        handleResult(
          ActionResult.fromJson(json.decode(
            message,
          )),
        );
      }
    });
    await service?.init();
  }

  _registerMainPort(SendPort sendPort) {
    IsolateNameServer.removePortNameMapping(mainIsolate);
    IsolateNameServer.registerPortWithName(sendPort, mainIsolate);
  }

  factory ClashLib() {
    _instance ??= ClashLib._internal();
    return _instance!;
  }

  @override
  Future<bool> nextHandleResult(result, completer) async {
    switch (result.method) {
      case ActionMethod.setFdMap:
      case ActionMethod.setProcessMap:
      case ActionMethod.stopTun:
      case ActionMethod.updateDns:
        completer?.complete(result.data as bool);
        return true;
      case ActionMethod.getRunTime:
      case ActionMethod.startTun:
      case ActionMethod.getAndroidVpnOptions:
      case ActionMethod.getCurrentProfileName:
        completer?.complete(result.data as String);
        return true;
      default:
        return false;
    }
  }

  @override
  destroy() async {
    await service?.destroy();
    return true;
  }

  @override
  reStart() {
    _initService();
  }

  @override
  Future<bool> shutdown() async {
    await super.shutdown();
    destroy();
    return true;
  }

  @override
  sendMessage(String message) async {
    await _canSendCompleter.future;
    sendPort?.send(message);
  }

  @override
  Future<bool> setFdMap(int fd) {
    return invoke<bool>(
      method: ActionMethod.setFdMap,
      data: json.encode(fd),
    );
  }

  @override
  Future<bool> setProcessMap(item) {
    return invoke<bool>(
      method: ActionMethod.setProcessMap,
      data: item,
    );
  }

  @override
  Future<DateTime?> startTun(int fd) async {
    final res = await invoke<String>(
      method: ActionMethod.startTun,
      data: json.encode(fd),
    );

    if (res.isEmpty) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(res));
  }

  @override
  Future<bool> stopTun() {
    return invoke<bool>(
      method: ActionMethod.stopTun,
    );
  }

  @override
  Future<AndroidVpnOptions?> getAndroidVpnOptions() async {
    final res = await invoke<String>(
      method: ActionMethod.getAndroidVpnOptions,
    );
    if (res.isEmpty) {
      return null;
    }
    return AndroidVpnOptions.fromJson(json.decode(res));
  }

  @override
  Future<bool> updateDns(String value) {
    return invoke<bool>(
      method: ActionMethod.updateDns,
      data: value,
    );
  }

  @override
  Future<DateTime?> getRunTime() async {
    final runTimeString = await invoke<String>(
      method: ActionMethod.getRunTime,
    );
    if (runTimeString.isEmpty) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }

  @override
  Future<String> getCurrentProfileName() {
    return invoke<String>(
      method: ActionMethod.getCurrentProfileName,
    );
  }
}

class ClashLibHandler {
  static ClashLibHandler? _instance;

  late final ClashFFI clashFFI;

  late final DynamicLibrary lib;

  ClashLibHandler._internal() {
    lib = DynamicLibrary.open("libclash.so");
    clashFFI = ClashFFI(lib);
    clashFFI.initNativeApiBridge(
      NativeApi.initializeApiDLData,
    );
  }

  factory ClashLibHandler() {
    _instance ??= ClashLibHandler._internal();
    return _instance!;
  }

  Future<String> invokeAction(String actionParams) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final actionParamsChar = actionParams.toNativeUtf8().cast<Char>();
    clashFFI.invokeAction(
      actionParamsChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(actionParamsChar);
    return completer.future;
  }

  attachMessagePort(int messagePort) {
    clashFFI.attachMessagePort(
      messagePort,
    );
  }

  attachInvokePort(int invokePort) {
    clashFFI.attachInvokePort(
      invokePort,
    );
  }

  DateTime? startTun(int fd) {
    final runTimeRaw = clashFFI.startTUN(fd);
    final runTimeString = runTimeRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(runTimeRaw);
    if (runTimeString.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }

  stopTun() {
    clashFFI.stopTun();
  }

  updateDns(String dns) {
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

  Traffic getTraffic() {
    final trafficRaw = clashFFI.getTraffic();
    final trafficString = trafficRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(trafficRaw);
    if (trafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromMap(json.decode(trafficString));
  }

  Traffic getTotalTraffic(bool value) {
    final trafficRaw = clashFFI.getTotalTraffic();
    final trafficString = trafficRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(trafficRaw);
    if (trafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromMap(json.decode(trafficString));
  }

  startListener() async {
    clashFFI.startListener();
    return true;
  }

  stopListener() async {
    clashFFI.stopListener();
    return true;
  }

  setFdMap(String id) {
    final idChar = id.toNativeUtf8().cast<Char>();
    clashFFI.setFdMap(idChar);
    malloc.free(idChar);
  }

  Future<String> quickStart(
      String homeDir,
      UpdateConfigParams updateConfigParams,
      CoreState state,
      ) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final params = json.encode(updateConfigParams);
    final stateParams = json.encode(state);
    final homeChar = homeDir.toNativeUtf8().cast<Char>();
    final paramsChar = params.toNativeUtf8().cast<Char>();
    final stateParamsChar = stateParams.toNativeUtf8().cast<Char>();
    clashFFI.quickStart(
      homeChar,
      paramsChar,
      stateParamsChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(homeChar);
    malloc.free(paramsChar);
    malloc.free(stateParamsChar);
    return completer.future;
  }

  DateTime? getRunTime() {
    final runTimeRaw = clashFFI.getRunTime();
    final runTimeString = runTimeRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(runTimeRaw);
    if (runTimeString.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }
}

ClashLib? get clashLib =>
    Platform.isAndroid && !globalState.isService ? ClashLib() : null;
