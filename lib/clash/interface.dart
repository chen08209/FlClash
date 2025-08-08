import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

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
  FutureOr<void> reStart();

  FutureOr<bool> destroy();

  Future<T?> invoke<T>({
    required ActionMethod method,
    String? data,
    Duration? timeout,
  });

  @override
  Future<bool> init(InitParams params) async {
    return await invoke<bool>(
          method: ActionMethod.initClash,
          data: json.encode(params),
        ) ??
        false;
  }

  @override
  Future<bool> setState(CoreState state) async {
    return await invoke<bool>(
          method: ActionMethod.setState,
          data: json.encode(state),
        ) ??
        false;
  }

  @override
  Future<bool> shutdown() async {
    return await invoke<bool>(
          method: ActionMethod.shutdown,
          timeout: Duration(seconds: 1),
        ) ??
        false;
  }

  @override
  Future<bool> get isInit async {
    return await invoke<bool>(
          method: ActionMethod.getIsInit,
        ) ??
        false;
  }

  @override
  Future<bool> forceGc() async {
    return await invoke<bool>(
          method: ActionMethod.forceGc,
        ) ??
        false;
  }

  @override
  Future<String> validateConfig(String data) async {
    return await invoke<String>(
          method: ActionMethod.validateConfig,
          data: data,
        ) ??
        '';
  }

  @override
  Future<String> updateConfig(UpdateParams updateParams) async {
    return await invoke<String>(
          method: ActionMethod.updateConfig,
          data: json.encode(updateParams),
          timeout: Duration(minutes: 2),
        ) ??
        '';
  }

  @override
  Future<Result> getConfig(String path) async {
    return await invoke<Result>(
          method: ActionMethod.getConfig,
          data: path,
          timeout: Duration(minutes: 2),
        ) ??
        Result.success({});
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    final data = await Isolate.run(() => json.encode(setupParams));
    return await invoke<String>(
          method: ActionMethod.setupConfig,
          data: data,
          timeout: Duration(minutes: 2),
        ) ??
        '';
  }

  @override
  Future<bool> crash() async {
    return await invoke<bool>(
          method: ActionMethod.crash,
        ) ??
        false;
  }

  @override
  Future<Map> getProxies() async {
    return await invoke<Map>(
          method: ActionMethod.getProxies,
          timeout: Duration(seconds: 5),
        ) ??
        {};
  }

  @override
  Future<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await invoke<String>(
          method: ActionMethod.changeProxy,
          data: json.encode(changeProxyParams),
        ) ??
        '';
  }

  @override
  Future<String> getExternalProviders() async {
    return await invoke<String>(
          method: ActionMethod.getExternalProviders,
        ) ??
        '';
  }

  @override
  Future<String> getExternalProvider(String externalProviderName) async {
    return await invoke<String>(
          method: ActionMethod.getExternalProvider,
          data: externalProviderName,
        ) ??
        '';
  }

  @override
  Future<String> updateGeoData(UpdateGeoDataParams params) async {
    return await invoke<String>(
          method: ActionMethod.updateGeoData,
          data: json.encode(params),
          timeout: Duration(minutes: 1),
        ) ??
        '';
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) async {
    return await invoke<String>(
          method: ActionMethod.sideLoadExternalProvider,
          data: json.encode({
            'providerName': providerName,
            'data': data,
          }),
        ) ??
        '';
  }

  @override
  Future<String> updateExternalProvider(String providerName) async {
    return await invoke<String>(
          method: ActionMethod.updateExternalProvider,
          data: providerName,
          timeout: Duration(minutes: 1),
        ) ??
        '';
  }

  @override
  Future<String> getConnections() async {
    return await invoke<String>(
          method: ActionMethod.getConnections,
        ) ??
        '';
  }

  @override
  Future<bool> closeConnections() async {
    return await invoke<bool>(
          method: ActionMethod.closeConnections,
        ) ??
        false;
  }

  @override
  Future<bool> resetConnections() async {
    return await invoke<bool>(
          method: ActionMethod.resetConnections,
        ) ??
        false;
  }

  @override
  Future<bool> closeConnection(String id) async {
    return await invoke<bool>(
          method: ActionMethod.closeConnection,
          data: id,
        ) ??
        false;
  }

  @override
  Future<String> getTotalTraffic() async {
    return await invoke<String>(
          method: ActionMethod.getTotalTraffic,
        ) ??
        '';
  }

  @override
  Future<String> getTraffic() async {
    return await invoke<String>(
          method: ActionMethod.getTraffic,
        ) ??
        '';
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
  Future<bool> startListener() async {
    return await invoke<bool>(
          method: ActionMethod.startListener,
        ) ??
        false;
  }

  @override
  Future<bool> stopListener() async {
    return await invoke<bool>(
          method: ActionMethod.stopListener,
        ) ??
        false;
  }

  @override
  Future<String> asyncTestDelay(String url, String proxyName) async {
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': httpTimeoutDuration.inMilliseconds,
      'test-url': url,
    };
    return await invoke<String>(
          method: ActionMethod.asyncTestDelay,
          data: json.encode(delayParams),
          timeout: Duration(
            milliseconds: 6000,
          ),
        ) ??
        json.encode(
          Delay(
            name: proxyName,
            value: -1,
            url: url,
          ),
        );
  }

  @override
  Future<String> getCountryCode(String ip) async {
    return await invoke<String>(
          method: ActionMethod.getCountryCode,
          data: ip,
        ) ??
        '';
  }

  @override
  Future<String> getMemory() async {
    return await invoke<String>(
          method: ActionMethod.getMemory,
        ) ??
        '';
  }
}
