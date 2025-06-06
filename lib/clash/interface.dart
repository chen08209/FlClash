import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

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

  FutureOr<Result> getConfig(String path);

  Future<String> asyncTestDelay(String url, String proxyName);

  FutureOr<String> updateConfig(UpdateParams updateParams);

  FutureOr<String> setupConfig(SetupParams setupParams);

  FutureOr<Map> getProxies();

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

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  Future<bool> crash();

  FutureOr<String> getConnections();

  FutureOr<bool> closeConnection(String id);

  FutureOr<bool> closeConnections();

  FutureOr<bool> resetConnections();

  Future<bool> setState(CoreState state);
}

mixin AndroidClashInterface {
  Future<bool> updateDns(String value);

  Future<AndroidVpnOptions?> getAndroidVpnOptions();

  Future<String> getCurrentProfileName();

  Future<DateTime?> getRunTime();
}

abstract class ClashHandlerInterface with ClashInterface {
  Map<String, Completer> callbackCompleterMap = {};

  Future<void> handleResult(ActionResult result) async {
    final completer = callbackCompleterMap[result.id];
    try {
      switch (result.method) {
        case ActionMethod.message:
          clashMessage.controller.add(result.data);
          completer?.complete(true);
          return;
        case ActionMethod.getConfig:
          completer?.complete(result.toResult);
          return;
        default:
          completer?.complete(result.data);
          return;
      }
    } catch (e) {
      commonPrint.log('${result.id} error $e');
    }
  }

  void sendMessage(String message);

  FutureOr<void> reStart();

  FutureOr<bool> destroy();

  Future<T> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
    FutureOr<T> Function()? onTimeout,
    T? defaultValue,
  }) async {
    final id = '${method.name}#${utils.id}';

    callbackCompleterMap[id] = Completer<T>();

    dynamic mDefaultValue = defaultValue;
    if (mDefaultValue == null) {
      if (T == String) {
        mDefaultValue = '';
      } else if (T == bool) {
        mDefaultValue = false;
      } else if (T == Map) {
        mDefaultValue = {};
      }
    }

    sendMessage(
      json.encode(
        Action(
          id: id,
          method: method,
          data: data,
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
            return mDefaultValue;
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
      timeout: Duration(seconds: 1),
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
  Future<String> updateConfig(UpdateParams updateParams) async {
    return await invoke<String>(
      method: ActionMethod.updateConfig,
      data: json.encode(updateParams),
      timeout: Duration(minutes: 2),
    );
  }

  @override
  Future<Result> getConfig(String path) async {
    final res = await invoke<Result>(
      method: ActionMethod.getConfig,
      data: path,
      timeout: Duration(minutes: 2),
      defaultValue: Result.success({}),
    );
    return res;
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    final data = await Isolate.run(() => json.encode(setupParams));
    return await invoke<String>(
      method: ActionMethod.setupConfig,
      data: data,
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
  Future<Map> getProxies() {
    return invoke<Map>(
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
        'providerName': providerName,
        'data': data,
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
  Future<bool> resetConnections() {
    return invoke<bool>(
      method: ActionMethod.resetConnections,
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
      'proxy-name': proxyName,
      'timeout': httpTimeoutDuration.inMilliseconds,
      'test-url': url,
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
