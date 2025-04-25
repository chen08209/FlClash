import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/clash/message.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

mixin ClashInterface {
  Future<bool> init(InitParams params);

  Future<bool> preload();

  Future<bool> shutdown();

  Future<bool> get isInit;

  Future<bool> forceGc();

  FutureOr<String> validateConfig(String data);

  Future<String> asyncTestDelay(String url, String proxyName);

  FutureOr<String> updateConfig(UpdateConfigParams updateConfigParams);

  FutureOr<String> getProxies();

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams);

  Future<bool> startListener();

  Future<bool> stopListener();

  FutureOr<String> getExternalProviders();

  FutureOr<String>? getExternalProvider(String externalProviderName);

  Future<String> updateGeoData(UpdateGeoDataParams params);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String providerName);

  FutureOr<String> getTraffic();

  FutureOr<String> getTotalTraffic();

  FutureOr<String> getCountryCode(String ip);

  FutureOr<String> getMemory();

  resetTraffic();

  startLog();

  stopLog();

  Future<bool> crash();

  FutureOr<String> getConnections();

  FutureOr<bool> closeConnection(String id);

  FutureOr<bool> closeConnections();

  FutureOr<String> getProfile(String id);

  Future<bool> setState(CoreState state);
}

mixin AndroidClashInterface {
  Future<bool> setFdMap(int fd);

  Future<bool> setProcessMap(ProcessMapItem item);

  // Future<bool> stopTun();

  Future<bool> updateDns(String value);

  Future<AndroidVpnOptions?> getAndroidVpnOptions();

  Future<String> getCurrentProfileName();

  Future<DateTime?> getRunTime();
}

abstract class ClashHandlerInterface with ClashInterface {
  Map<String, Completer> callbackCompleterMap = {};

  Future<bool> nextHandleResult(ActionResult result, Completer? completer) =>
      Future.value(false);

  handleResult(ActionResult result) async {
    final completer = callbackCompleterMap[result.id];
    try {
      switch (result.method) {
        case ActionMethod.initClash:
        case ActionMethod.shutdown:
        case ActionMethod.getIsInit:
        case ActionMethod.startListener:
        case ActionMethod.resetTraffic:
        case ActionMethod.closeConnections:
        case ActionMethod.closeConnection:
        case ActionMethod.stopListener:
        case ActionMethod.setState:
        case ActionMethod.crash:
          completer?.complete(result.data as bool);
          return;
        case ActionMethod.changeProxy:
        case ActionMethod.getProxies:
        case ActionMethod.getTraffic:
        case ActionMethod.getTotalTraffic:
        case ActionMethod.asyncTestDelay:
        case ActionMethod.getConnections:
        case ActionMethod.getExternalProviders:
        case ActionMethod.getExternalProvider:
        case ActionMethod.validateConfig:
        case ActionMethod.updateConfig:
        case ActionMethod.updateGeoData:
        case ActionMethod.updateExternalProvider:
        case ActionMethod.sideLoadExternalProvider:
        case ActionMethod.getCountryCode:
        case ActionMethod.getMemory:
          completer?.complete(result.data as String);
          return;
        case ActionMethod.message:
          clashMessage.controller.add(result.data as String);
          completer?.complete(true);
          return;
        default:
          final isHandled = await nextHandleResult(result, completer);
          if (isHandled) {
            return;
          }
          completer?.complete(result.data);
      }
    } catch (_) {
      commonPrint.log(result.id);
    }
  }

  sendMessage(String message);

  reStart();

  FutureOr<bool> destroy();

  Future<T> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
    FutureOr<T> Function()? onTimeout,
  }) async {
    final id = "${method.name}#${utils.id}";

    callbackCompleterMap[id] = Completer<T>();

    dynamic defaultValue;

    if (T == String) {
      defaultValue = "";
    }
    if (T == bool) {
      defaultValue = false;
    }

    sendMessage(
      json.encode(
        Action(
          id: id,
          method: method,
          data: data,
          defaultValue: defaultValue,
        ),
      ),
    );

    return (callbackCompleterMap[id] as Completer<T>).safeFuture(
      timeout: timeout,
      onLast: () {
        callbackCompleterMap.remove(id);
      },
      onTimeout: onTimeout ??
          () {
            return defaultValue;
          },
      functionName: id,
    );
  }

  @override
  Future<bool> init(InitParams params) {
    return invoke<bool>(
      method: ActionMethod.initClash,
      data: json.encode(params),
    );
  }

  @override
  Future<bool> setState(CoreState state) {
    return invoke<bool>(
      method: ActionMethod.setState,
      data: json.encode(state),
    );
  }

  @override
  shutdown() async {
    return await invoke<bool>(
      method: ActionMethod.shutdown,
    );
  }

  @override
  Future<bool> get isInit {
    return invoke<bool>(
      method: ActionMethod.getIsInit,
    );
  }

  @override
  Future<bool> forceGc() {
    return invoke<bool>(
      method: ActionMethod.forceGc,
    );
  }

  @override
  FutureOr<String> validateConfig(String data) {
    return invoke<String>(
      method: ActionMethod.validateConfig,
      data: data,
    );
  }

  @override
  Future<String> updateConfig(UpdateConfigParams updateConfigParams) async {
    return await invoke<String>(
      method: ActionMethod.updateConfig,
      data: json.encode(updateConfigParams),
      timeout: Duration(minutes: 2),
    );
  }

  @override
  Future<bool> crash() {
    return invoke<bool>(
      method: ActionMethod.crash,
    );
  }

  @override
  Future<String> getProxies() {
    return invoke<String>(
      method: ActionMethod.getProxies,
      timeout: Duration(seconds: 5),
    );
  }

  @override
  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) {
    return invoke<String>(
      method: ActionMethod.changeProxy,
      data: json.encode(changeProxyParams),
    );
  }

  @override
  FutureOr<String> getExternalProviders() {
    return invoke<String>(
      method: ActionMethod.getExternalProviders,
    );
  }

  @override
  FutureOr<String> getExternalProvider(String externalProviderName) {
    return invoke<String>(
      method: ActionMethod.getExternalProvider,
      data: externalProviderName,
    );
  }

  @override
  Future<String> updateGeoData(UpdateGeoDataParams params) {
    return invoke<String>(
        method: ActionMethod.updateGeoData,
        data: json.encode(params),
        timeout: Duration(minutes: 1));
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return invoke<String>(
      method: ActionMethod.sideLoadExternalProvider,
      data: json.encode({
        "providerName": providerName,
        "data": data,
      }),
    );
  }

  @override
  Future<String> updateExternalProvider(String providerName) {
    return invoke<String>(
      method: ActionMethod.updateExternalProvider,
      data: providerName,
      timeout: Duration(minutes: 1),
    );
  }

  @override
  FutureOr<String> getConnections() {
    return invoke<String>(
      method: ActionMethod.getConnections,
    );
  }

  @override
  Future<bool> closeConnections() {
    return invoke<bool>(
      method: ActionMethod.closeConnections,
    );
  }

  @override
  Future<bool> closeConnection(String id) {
    return invoke<bool>(
      method: ActionMethod.closeConnection,
      data: id,
    );
  }

  @override
  Future<String> getProfile(String id) {
    return invoke<String>(
      method: ActionMethod.getProfile,
      data: id,
    );
  }

  @override
  FutureOr<String> getTotalTraffic() {
    return invoke<String>(
      method: ActionMethod.getTotalTraffic,
    );
  }

  @override
  FutureOr<String> getTraffic() {
    return invoke<String>(
      method: ActionMethod.getTraffic,
    );
  }

  @override
  resetTraffic() {
    invoke(method: ActionMethod.resetTraffic);
  }

  @override
  startLog() {
    invoke(method: ActionMethod.startLog);
  }

  @override
  stopLog() {
    invoke<bool>(
      method: ActionMethod.stopLog,
    );
  }

  @override
  Future<bool> startListener() {
    return invoke<bool>(
      method: ActionMethod.startListener,
    );
  }

  @override
  stopListener() {
    return invoke<bool>(
      method: ActionMethod.stopListener,
    );
  }

  @override
  Future<String> asyncTestDelay(String url, String proxyName) {
    final delayParams = {
      "proxy-name": proxyName,
      "timeout": httpTimeoutDuration.inMilliseconds,
      "test-url": url,
    };
    return invoke<String>(
      method: ActionMethod.asyncTestDelay,
      data: json.encode(delayParams),
      timeout: Duration(
        milliseconds: 6000,
      ),
      onTimeout: () {
        return json.encode(
          Delay(
            name: proxyName,
            value: -1,
            url: url,
          ),
        );
      },
    );
  }

  @override
  FutureOr<String> getCountryCode(String ip) {
    return invoke<String>(
      method: ActionMethod.getCountryCode,
      data: ip,
    );
  }

  @override
  FutureOr<String> getMemory() {
    return invoke<String>(
      method: ActionMethod.getMemory,
    );
  }
}
