import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

import 'desktop/model.dart';
import 'method.dart';

mixin CoreInterface {
  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  Future<bool> init(InitParams params);

  Future<bool> get isInit;

  Future<bool> forceGc();

  Future<String> validateConfig(String path);

  Future<String> decryptConfig(String path, String ageSecretKey);

  Future<List<String>> validateProxies(List<Map<String, dynamic>> proxies);

  Future<List<String>> validateFilters(List<String> filters);

  Future<List<Map<String, dynamic>>> convertProxies(String path);

  Future<List<String>> encodeShareLinks(List<Map<String, dynamic>> proxies);

  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(List<String> lines);

  Future<Map<String, dynamic>> getConfig(String path);

  Future<ProfileBase> getProfileBase(String path);

  Future<Map<String, dynamic>> getProfileOutbounds(String path);

  Future<Map<String, dynamic>?> getProxyDefinition(String name);

  Future<String> buildProfile(SetupBase base);

  Future<String> dumpRuleSet(String path);

  Future<RuleSetInfo> compileRuleSet(String name, {String url = ''});

  Future<Delay?> asyncTestDelay(String url, String proxyName, Duration timeout);

  Future<ProbeResult?> probe(ProbeParams params);

  Future<OutboundIpResult?> outboundIp(OutboundIpParams params);

  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params);

  Future<String> updateConfig(UpdateParams updateParams);

  Future<String> setupConfig(SetupParams setupParams);

  Future<ProxiesData> getProxies();

  Future<ChangeProxyResult> changeProxy(ChangeProxyParams changeProxyParams);

  Future<RouteSnapshot?> watchRoute(bool watch);

  Future<RouteCheck?> checkRoutes(CheckRoutesParams params);

  Future<bool> startListener();

  Future<bool> stopListener();

  Future<List<ExternalProvider>> getExternalProviders();

  Future<ExternalProvider?> getExternalProvider(String externalProviderName);

  Future<String> updateGeoData(String type);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String providerName);

  FutureOr<Traffic> getTraffic(bool onlyStatisticsProxy);

  FutureOr<Traffic> getTotalTraffic(bool onlyStatisticsProxy);

  FutureOr<CoreMemoryStats?> getMemoryStats();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  Future<bool> crash();

  FutureOr<List<TrackerInfo>> getConnections();

  FutureOr<int> getConnectionCount();

  FutureOr<bool> closeConnection(String id);

  FutureOr<String> clearEffect(int profileId);

  FutureOr<bool> closeConnections();

  FutureOr<bool> resetConnections();

  FutureOr<bool> clearDnsCache();
}

abstract class CoreHandlerInterface with CoreInterface {
  Future<T?> _invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    return await handleWatch(
      onStart: () {
        commonPrint.log(
          'Invoke method ${method.name} ${DateTime.now()} $arguments',
        );
      },
      function: () async {
        return invokeMethod<T>(
          method: method,
          arguments: arguments,
          timeout: timeout,
        );
      },
      onEnd: (result, elapsedMilliseconds) {
        commonPrint.log(
          'Invoke method ${method.name} completed in ${elapsedMilliseconds}ms',
        );
      },
    );
  }

  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  });

  Future<String> _invokeMessage({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    final message = await _invokeMethod<String>(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
    if (message == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${method.name}',
      );
    }
    return message;
  }

  @override
  Future<bool> init(InitParams params) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.initClash,
          arguments: params.toJson(),
        ) ??
        false;
  }

  @override
  Future<bool> get isInit async {
    return await _invokeMethod<bool>(method: CoreMethod.getIsInit) ?? false;
  }

  @override
  Future<bool> forceGc() async {
    return await _invokeMethod<bool>(method: CoreMethod.forceGc) ?? false;
  }

  @override
  Future<String> validateConfig(String path) async {
    return _invokeMessage(method: CoreMethod.validateConfig, arguments: path);
  }

  @override
  Future<String> decryptConfig(String path, String ageSecretKey) async {
    return _invokeMessage(
      method: CoreMethod.decryptConfig,
      arguments: {'path': path, 'age-secret-key': ageSecretKey},
    );
  }

  @override
  Future<List<String>> validateProxies(
    List<Map<String, dynamic>> proxies,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.validateProxies,
      arguments: proxies,
    );
    if (data == null || data.length != proxies.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.validateProxies.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<List<String>> validateFilters(List<String> filters) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.validateFilters,
      arguments: filters,
    );
    if (data == null || data.length != filters.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.validateFilters.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<List<Map<String, dynamic>>> convertProxies(String path) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.convertProxies,
      arguments: path,
    );
    return [
      for (final item in data ?? const [])
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  @override
  Future<List<String>> encodeShareLinks(
    List<Map<String, dynamic>> proxies,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.encodeShareLinks,
      arguments: proxies,
    );
    if (data == null || data.length != proxies.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.encodeShareLinks.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(
    List<String> lines,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.decodeShareLinks,
      arguments: lines,
    );
    if (data == null || data.length != lines.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.decodeShareLinks.name}',
      );
    }
    return [
      for (final line in data)
        [
          for (final item in line is List ? line : const [])
            if (item is Map) Map<String, dynamic>.from(item),
        ],
    ];
  }

  @override
  Future<String> updateConfig(UpdateParams updateParams) async {
    return _invokeMessage(
      method: CoreMethod.updateConfig,
      arguments: updateParams.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> getConfig(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getConfig,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty config result',
      );
    }
    return result;
  }

  @override
  Future<ProfileBase> getProfileBase(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProfileBase,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty profile base',
      );
    }
    return ProfileBase.fromJson(result);
  }

  @override
  Future<Map<String, dynamic>> getProfileOutbounds(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProfileOutbounds,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned no outbounds',
      );
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getProxyDefinition(String name) {
    return _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProxyDefinition,
      arguments: name,
    );
  }

  @override
  Future<String> buildProfile(SetupBase base) async {
    final result = await _invokeMethod<String>(
      method: CoreMethod.buildProfile,
      arguments: base.toJson(),
    );
    if (result == null || result.isEmpty) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned no built profile',
      );
    }
    return result;
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    return _invokeMessage(
      method: CoreMethod.setupConfig,
      arguments: setupParams.toJson(),
    );
  }

  @override
  Future<String> dumpRuleSet(String path) async {
    return _invokeMessage(method: CoreMethod.dumpRuleSet, arguments: path);
  }

  @override
  Future<RuleSetInfo> compileRuleSet(String name, {String url = ''}) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.compileRuleSet,
      arguments: {'name': name, 'url': url},
    );
    if (data == null) {
      throw const CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer compileRuleSet',
      );
    }
    return (
      behavior: RuleProviderBehavior.values.byName(data['behavior'] as String),
      format: RuleProviderFormat.values.byName(data['format'] as String),
    );
  }

  @override
  Future<bool> crash() async {
    return await _invokeMethod<bool>(method: CoreMethod.crash) ?? false;
  }

  @override
  Future<ProxiesData> getProxies() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProxies,
    );
    return data != null
        ? ProxiesData.fromJson(data)
        : const ProxiesData(proxies: {}, all: []);
  }

  @override
  Future<ChangeProxyResult> changeProxy(
    ChangeProxyParams changeProxyParams,
  ) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.changeProxy,
      arguments: changeProxyParams.toJson(),
    );
    if (data == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.changeProxy.name}',
      );
    }
    return ChangeProxyResult.fromJson(data);
  }

  @override
  Future<RouteSnapshot?> watchRoute(bool watch) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.watchRoute,
      arguments: watch,
    );
    return data == null ? null : RouteSnapshot.fromJson(data);
  }

  @override
  Future<RouteCheck?> checkRoutes(CheckRoutesParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.checkRoutes,
      arguments: params.toJson(),
      timeout: coreGuardFor(probeTimeoutDuration.inMilliseconds),
    );
    return data == null ? null : RouteCheck.fromJson(data);
  }

  @override
  Future<List<ExternalProvider>> getExternalProviders() async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.getExternalProviders,
    );
    return data
            ?.whereType<Map>()
            .map(
              (item) =>
                  ExternalProvider.fromJson(Map<String, Object?>.from(item)),
            )
            .toList() ??
        [];
  }

  @override
  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getExternalProvider,
      arguments: externalProviderName,
    );
    return data == null ? null : ExternalProvider.fromJson(data);
  }

  @override
  Future<String> updateGeoData(String type) async {
    return _invokeMessage(method: CoreMethod.updateGeoData, arguments: type);
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) async {
    return _invokeMessage(
      method: CoreMethod.sideLoadExternalProvider,
      arguments: {'providerName': providerName, 'data': data},
    );
  }

  @override
  Future<String> updateExternalProvider(String providerName) async {
    return _invokeMessage(
      method: CoreMethod.updateExternalProvider,
      arguments: providerName,
    );
  }

  @override
  Future<List<TrackerInfo>> getConnections() async {
    final data = await _invokeMethod<Object>(method: CoreMethod.getConnections);
    return data is List<TrackerInfo> ? data : trackerInfosOf(data);
  }

  @override
  Future<int> getConnectionCount() async {
    return await _invokeMethod<int>(method: CoreMethod.getConnectionCount) ?? 0;
  }

  @override
  Future<bool> closeConnections() async {
    return await _invokeMethod<bool>(method: CoreMethod.closeConnections) ??
        false;
  }

  @override
  Future<bool> resetConnections() async {
    return await _invokeMethod<bool>(method: CoreMethod.resetConnections) ??
        false;
  }

  @override
  Future<bool> clearDnsCache() async {
    return await _invokeMethod<bool>(method: CoreMethod.clearDnsCache) ?? false;
  }

  @override
  Future<bool> closeConnection(String id) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.closeConnection,
          arguments: id,
        ) ??
        false;
  }

  @override
  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getTotalTraffic,
      arguments: onlyStatisticsProxy,
    );
    return data == null ? const Traffic() : Traffic.fromJson(data);
  }

  @override
  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getTraffic,
      arguments: onlyStatisticsProxy,
    );
    return data == null ? const Traffic() : Traffic.fromJson(data);
  }

  @override
  Future<String> clearEffect(int profileId) async {
    return _invokeMessage(method: CoreMethod.clearEffect, arguments: profileId);
  }

  @override
  FutureOr<void> resetTraffic() => _invokeUnobserved(CoreMethod.resetTraffic);

  @override
  FutureOr<void> startLog() => _invokeUnobserved(CoreMethod.startLog);

  @override
  FutureOr<void> stopLog() => _invokeUnobserved(CoreMethod.stopLog);

  /// For calls whose callers never wait on them, so a Core that is gone or
  /// restarting cannot surface as an unhandled asynchronous error.
  Future<void> _invokeUnobserved(CoreMethod method) async {
    try {
      await _invokeMethod<Object?>(method: method);
    } catch (error) {
      commonPrint.log(
        '${method.name} failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  @override
  Future<bool> startListener() async {
    return await _invokeMethod<bool>(method: CoreMethod.startListener) ?? false;
  }

  @override
  Future<bool> stopListener() async {
    return await _invokeMethod<bool>(method: CoreMethod.stopListener) ?? false;
  }

  @override
  Future<Delay?> asyncTestDelay(
    String url,
    String proxyName,
    Duration timeout,
  ) async {
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': timeout.inMilliseconds,
      'test-url': url,
    };
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.asyncTestDelay,
      arguments: delayParams,
      timeout: delayTestGuardDuration,
    );
    return data == null ? null : Delay.fromJson(data);
  }

  @override
  Future<ProbeResult?> probe(ProbeParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.probe,
      arguments: params.toJson(),
      timeout: probeGuardDuration(params),
    );
    return data == null ? null : ProbeResult.fromJson(data);
  }

  @override
  Future<OutboundIpResult?> outboundIp(OutboundIpParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.outboundIp,
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
    return data == null ? null : OutboundIpResult.fromJson(data);
  }

  @override
  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.serviceCheck,
      arguments: params.toJson(),
      timeout: coreGuardFor(
        params.timeout,
        budgetFactor: serviceSweepBudgetFactor,
      ),
    );
    return data == null
        ? const []
        : data
              .map(
                (item) =>
                    ServiceCheckItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
  }

  @override
  Future<CoreMemoryStats?> getMemoryStats() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getMemoryStats,
    );
    return data == null ? null : CoreMemoryStats.fromJson(data);
  }
}
