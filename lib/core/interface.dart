import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

mixin CoreInterface {
  Future<bool> init(InitParams params);

  Future<String> preload();

  Future<bool> shutdown();

  Future<bool> get isInit;

  Future<bool> forceGc();

  Future<String> validateConfig(String path);

  Future<Result> getConfig(String path);

  Future<String> asyncTestDelay(String url, String proxyName);

  Future<String> updateConfig(UpdateParams updateParams);

  Future<String> setupConfig(SetupParams setupParams);

  Future<Map> getProxies();

  Future<String> changeProxy(ChangeProxyParams changeProxyParams);

  Future<bool> startListener();

  Future<bool> stopListener();

  Future<String> getExternalProviders();

  Future<String>? getExternalProvider(String externalProviderName);

  Future<String> updateGeoData(UpdateGeoDataParams params);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String providerName);

  FutureOr<String> getTraffic(bool onlyStatisticsProxy);

  FutureOr<String> getTotalTraffic(bool onlyStatisticsProxy);

  FutureOr<String> getCountryCode(String ip);

  FutureOr<String> getMemory();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  Future<bool> crash();

  FutureOr<String> getConnections();

  FutureOr<bool> closeConnection(String id);

  FutureOr<String> deleteFile(String path);

  FutureOr<bool> closeConnections();

  FutureOr<bool> resetConnections();
}

abstract class CoreHandlerInterface with CoreInterface {
  Completer get completer;

  FutureOr<bool> destroy();

  Future<T?> _invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      commonPrint.log(
        'Invoke pre ${method.name} timeout $e',
        logLevel: LogLevel.error,
      );
      return null;
    }
    if (kDebugMode) {
      commonPrint.log('Invoke ${method.name} ${DateTime.now()} $data');
    }

    return utils.handleWatch(
      function: () async {
        return await invoke(method: method, data: data, timeout: timeout);
      },
      onWatch: (data, elapsedMilliseconds) {
        commonPrint.log('Invoke ${method.name} ${elapsedMilliseconds}ms');
      },
    );
  }

  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  });

  Future<T> parasResult<T>(ActionResult result) async {
    return switch (result.method) {
      ActionMethod.getConfig => result.toResult as T,
      _ => result.data as T,
    };
  }

  @override
  Future<bool> init(InitParams params) async {
    return await _invoke<bool>(
          method: ActionMethod.initClash,
          data: json.encode(params),
        ) ??
        false;
  }

  @override
  Future<bool> shutdown();

  @override
  Future<bool> get isInit async {
    return await _invoke<bool>(method: ActionMethod.getIsInit) ?? false;
  }

  @override
  Future<bool> forceGc() async {
    return await _invoke<bool>(method: ActionMethod.forceGc) ?? false;
  }

  @override
  Future<String> validateConfig(String path) async {
    return await _invoke<String>(
          method: ActionMethod.validateConfig,
          data: path,
        ) ??
        '';
  }

  @override
  Future<String> updateConfig(UpdateParams updateParams) async {
    return await _invoke<String>(
          method: ActionMethod.updateConfig,
          data: json.encode(updateParams),
        ) ??
        '';
  }

  @override
  Future<Result> getConfig(String path) async {
    return await _invoke<Result>(method: ActionMethod.getConfig, data: path) ??
        Result.success({});
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    final data = await Isolate.run(() => json.encode(setupParams));
    return await _invoke<String>(
          method: ActionMethod.setupConfig,
          data: data,
        ) ??
        '';
  }

  @override
  Future<bool> crash() async {
    return await _invoke<bool>(method: ActionMethod.crash) ?? false;
  }

  @override
  Future<Map> getProxies() async {
    final map = await _invoke<Map>(method: ActionMethod.getProxies);
    return map ?? {};
  }

  @override
  Future<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await _invoke<String>(
          method: ActionMethod.changeProxy,
          data: json.encode(changeProxyParams),
        ) ??
        '';
  }

  @override
  Future<String> getExternalProviders() async {
    return await _invoke<String>(method: ActionMethod.getExternalProviders) ??
        '';
  }

  @override
  Future<String> getExternalProvider(String externalProviderName) async {
    return await _invoke<String>(
          method: ActionMethod.getExternalProvider,
          data: externalProviderName,
        ) ??
        '';
  }

  @override
  Future<String> updateGeoData(UpdateGeoDataParams params) async {
    return await _invoke<String>(
          method: ActionMethod.updateGeoData,
          data: json.encode(params),
        ) ??
        '';
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) async {
    return await _invoke<String>(
          method: ActionMethod.sideLoadExternalProvider,
          data: json.encode({'providerName': providerName, 'data': data}),
        ) ??
        '';
  }

  @override
  Future<String> updateExternalProvider(String providerName) async {
    return await _invoke<String>(
          method: ActionMethod.updateExternalProvider,
          data: providerName,
        ) ??
        '';
  }

  @override
  Future<String> getConnections() async {
    return await _invoke<String>(method: ActionMethod.getConnections) ?? '';
  }

  @override
  Future<bool> closeConnections() async {
    return await _invoke<bool>(method: ActionMethod.closeConnections) ?? false;
  }

  @override
  Future<bool> resetConnections() async {
    return await _invoke<bool>(method: ActionMethod.resetConnections) ?? false;
  }

  @override
  Future<bool> closeConnection(String id) async {
    return await _invoke<bool>(
          method: ActionMethod.closeConnection,
          data: id,
        ) ??
        false;
  }

  @override
  Future<String> getTotalTraffic(bool onlyStatisticsProxy) async {
    return await _invoke<String>(
          method: ActionMethod.getTotalTraffic,
          data: onlyStatisticsProxy,
        ) ??
        '';
  }

  @override
  Future<String> getTraffic(bool onlyStatisticsProxy) async {
    return await _invoke<String>(
          method: ActionMethod.getTraffic,
          data: onlyStatisticsProxy,
        ) ??
        '';
  }

  @override
  Future<String> deleteFile(String path) async {
    return await _invoke<String>(method: ActionMethod.deleteFile, data: path) ??
        '';
  }

  @override
  resetTraffic() {
    _invoke(method: ActionMethod.resetTraffic);
  }

  @override
  startLog() {
    _invoke(method: ActionMethod.startLog);
  }

  @override
  stopLog() {
    _invoke<bool>(method: ActionMethod.stopLog);
  }

  @override
  Future<bool> startListener() async {
    return await _invoke<bool>(method: ActionMethod.startListener) ?? false;
  }

  @override
  Future<bool> stopListener() async {
    return await _invoke<bool>(method: ActionMethod.stopListener) ?? false;
  }

  @override
  Future<String> asyncTestDelay(String url, String proxyName) async {
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': httpTimeoutDuration.inMilliseconds,
      'test-url': url,
    };
    return await _invoke<String>(
          method: ActionMethod.asyncTestDelay,
          data: json.encode(delayParams),
          timeout: Duration(seconds: 6),
        ) ??
        json.encode(Delay(name: proxyName, value: -1, url: url));
  }

  @override
  Future<String> getCountryCode(String ip) async {
    return await _invoke<String>(
          method: ActionMethod.getCountryCode,
          data: ip,
        ) ??
        '';
  }

  @override
  Future<String> getMemory() async {
    return await _invoke<String>(method: ActionMethod.getMemory) ?? '';
  }
}
