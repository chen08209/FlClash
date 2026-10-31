import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

import 'desktop/model.dart';
import 'method.dart';

/// A method answers its result or throws: a [CoreMethodException] for what the
/// Core reports or a Core out of reach, a [TimeoutException] for no answer.
abstract class CoreHandlerInterface {
  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  Future<Object?> invokeMethod({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  });

  Future<Object?> _call(
    CoreMethod method, {
    Object? arguments,
    Duration? timeout,
  }) async {
    return await handleWatch(
      onStart: () {
        commonPrint.log(
          'Invoke method ${method.wireName} ${DateTime.now()} $arguments',
        );
      },
      function: () =>
          invokeMethod(method: method, arguments: arguments, timeout: timeout),
      onEnd: (result, elapsedMilliseconds) {
        commonPrint.log(
          'Invoke method ${method.wireName} completed in '
          '${elapsedMilliseconds}ms',
        );
      },
    );
  }

  Future<R> _query<R>(
    CoreMethod method,
    R Function(Object data) decode, {
    Object? arguments,
    Duration? timeout,
  }) async {
    final data = await _call(method, arguments: arguments, timeout: timeout);
    if (data == null) {
      throw CoreMethodException(
        code: 'empty_result',
        message: 'Core answered ${method.wireName} with nothing',
      );
    }
    return decode(data);
  }

  Future<R?> _find<R>(
    CoreMethod method,
    R Function(Object data) decode, {
    Object? arguments,
  }) async {
    final data = await _call(method, arguments: arguments);
    return data == null ? null : decode(data);
  }

  Future<void> _command(
    CoreMethod method, {
    Object? arguments,
    Duration? timeout,
  }) async {
    await _call(method, arguments: arguments, timeout: timeout);
  }

  /// For calls whose callers never wait on them, so a Core that is gone or
  /// restarting cannot surface as an unhandled asynchronous error.
  Future<void> _commandUnobserved(CoreMethod method) async {
    try {
      await _call(method);
    } catch (error) {
      commonPrint.log(
        '${method.wireName} failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  Future<void> init(InitParams params) {
    return _command(CoreMethod.coreInit, arguments: params.toJson());
  }

  Future<bool> get isInit => _query(CoreMethod.coreInitialized, _cast<bool>);

  Future<void> forceGc() => _command(CoreMethod.coreGc);

  Future<CoreMemoryStats> getMemoryStats() {
    return _query(CoreMethod.coreMemory, _model(CoreMemoryStats.fromJson));
  }

  Future<void> crash() => _command(CoreMethod.coreCrash);

  Future<void> setupConfig(SetupParams params) {
    return _command(CoreMethod.configSetup, arguments: params.toJson());
  }

  Future<void> updateConfig(UpdateParams params) {
    return _command(CoreMethod.configUpdate, arguments: params.toJson());
  }

  Future<String?> validateConfig(String path) {
    return _find(
      CoreMethod.configValidate,
      _cast<String>,
      arguments: {'path': path},
    );
  }

  Future<String> decryptConfig(String path, String ageSecretKey) {
    return _query(
      CoreMethod.configDecrypt,
      _cast<String>,
      arguments: {'path': path, 'age-secret-key': ageSecretKey},
    );
  }

  Future<Map<String, dynamic>> readConfig(String path) {
    return _query(CoreMethod.configRead, _json, arguments: {'path': path});
  }

  Future<ProfileBase> getProfileBase(String path) {
    return _query(
      CoreMethod.profileBase,
      _model(ProfileBase.fromJson),
      arguments: {'path': path},
    );
  }

  Future<Map<String, dynamic>> getProfileOutbounds(String path) {
    return _query(
      CoreMethod.profileOutbounds,
      _json,
      arguments: {'path': path},
    );
  }

  Future<String> buildProfile(SetupBase base) {
    return _query(
      CoreMethod.profileBuild,
      _cast<String>,
      arguments: base.toJson(),
    );
  }

  Future<void> clearEffect(int profileId) {
    return _command(
      CoreMethod.profileClearEffect,
      arguments: {'profile-id': profileId},
    );
  }

  Future<ProxiesData> getProxies() {
    return _query(CoreMethod.proxyList, _model(ProxiesData.fromJson));
  }

  Future<ChangeProxyResult> changeProxy(ChangeProxyParams params) {
    return _query(
      CoreMethod.proxySelect,
      _model(ChangeProxyResult.fromJson),
      arguments: params.toJson(),
    );
  }

  Future<Map<String, dynamic>?> getProxyDefinition(String name) {
    return _find(CoreMethod.proxyDefinition, _json, arguments: {'name': name});
  }

  Future<Delay> testDelay(TestDelayParams params) {
    return _query(
      CoreMethod.proxyTestDelay,
      _model(Delay.fromJson),
      arguments: params.toJson(),
      timeout: delayTestGuardDuration,
    );
  }

  Future<Map<int, String>> validateProxies(List<Map<String, dynamic>> proxies) {
    return _query(
      CoreMethod.proxyValidate,
      _issues,
      arguments: {'proxies': proxies},
    );
  }

  Future<List<Map<String, dynamic>>> convertProxies(String path) {
    return _query(
      CoreMethod.proxyConvert,
      _jsonList,
      arguments: {'path': path},
    );
  }

  Future<List<String>> encodeShareLinks(List<Map<String, dynamic>> proxies) {
    return _query(
      CoreMethod.shareLinkEncode,
      _strings,
      arguments: {'proxies': proxies},
    );
  }

  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(
    List<String> lines,
  ) {
    return _query(
      CoreMethod.shareLinkDecode,
      (data) => [for (final line in data as List) _jsonList(line)],
      arguments: {'lines': lines},
    );
  }

  Future<Map<int, String>> validateFilters(List<String> filters) {
    return _query(
      CoreMethod.filterValidate,
      _issues,
      arguments: {'filters': filters},
    );
  }

  Future<List<ExternalProvider>> getExternalProviders() {
    return _query(CoreMethod.providerList, _models(ExternalProvider.fromJson));
  }

  Future<ExternalProvider?> getExternalProvider(String name) {
    return _find(
      CoreMethod.providerGet,
      _model(ExternalProvider.fromJson),
      arguments: {'name': name},
    );
  }

  Future<void> updateExternalProvider(String name) {
    return _command(CoreMethod.providerUpdate, arguments: {'name': name});
  }

  Future<void> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return _command(
      CoreMethod.providerSideLoad,
      arguments: {'name': providerName, 'data': data},
    );
  }

  Future<String> dumpRuleSet(String path) {
    return _query(
      CoreMethod.ruleSetDump,
      _cast<String>,
      arguments: {'path': path},
    );
  }

  Future<RuleSetInfo> compileRuleSet(String name, {String url = ''}) {
    return _query(CoreMethod.ruleSetCompile, (data) {
      final info = _json(data);
      return (
        behavior: RuleProviderBehavior.values.byName(
          info['behavior'] as String,
        ),
        format: RuleProviderFormat.values.byName(info['format'] as String),
      );
    }, arguments: {'name': name, 'url': url});
  }

  Future<void> updateGeoData(String type) {
    return _command(CoreMethod.geoUpdate, arguments: {'type': type});
  }

  Future<Traffic> getTraffic(bool onlyProxy) {
    return _query(
      CoreMethod.trafficCurrent,
      _model(Traffic.fromJson),
      arguments: {'only-proxy': onlyProxy},
    );
  }

  Future<Traffic> getTotalTraffic(bool onlyProxy) {
    return _query(
      CoreMethod.trafficTotal,
      _model(Traffic.fromJson),
      arguments: {'only-proxy': onlyProxy},
    );
  }

  Future<void> resetTraffic() => _commandUnobserved(CoreMethod.trafficReset);

  Future<List<TrackerInfo>> getConnections() {
    return _query(
      CoreMethod.connectionList,
      (data) => data is List<TrackerInfo> ? data : trackerInfosOf(data),
    );
  }

  Future<int> getConnectionCount() {
    return _query(CoreMethod.connectionCount, (data) => (data as num).toInt());
  }

  Future<void> closeConnection(String id) {
    return _command(CoreMethod.connectionClose, arguments: {'id': id});
  }

  Future<void> closeConnections() => _command(CoreMethod.connectionCloseAll);

  Future<void> resetConnections() => _command(CoreMethod.connectionReset);

  Future<void> clearDnsCache() => _command(CoreMethod.dnsClearCache);

  Future<void> reportNetworkChange() => _command(CoreMethod.networkChanged);

  Future<void> startLog() => _commandUnobserved(CoreMethod.logStart);

  Future<void> stopLog() => _commandUnobserved(CoreMethod.logStop);

  Future<void> startListener() => _command(CoreMethod.listenerStart);

  Future<void> stopListener() => _command(CoreMethod.listenerStop);

  Future<RouteSnapshot> watchRoute(bool watch) {
    return _query(
      CoreMethod.routeWatch,
      _model(RouteSnapshot.fromJson),
      arguments: {'watch': watch},
    );
  }

  Future<RouteCheck> checkRoutes(CheckRoutesParams params) {
    return _query(
      CoreMethod.routeCheck,
      _model(RouteCheck.fromJson),
      arguments: params.toJson(),
      timeout: coreGuardFor(probeTimeoutDuration.inMilliseconds),
    );
  }

  Future<OutboundIpResult> outboundIp(OutboundIpParams params) {
    return _query(
      CoreMethod.probeOutboundIp,
      _model(OutboundIpResult.fromJson),
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
  }

  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params) {
    return _query(
      CoreMethod.probeServices,
      _models(ServiceCheckItem.fromJson),
      arguments: params.toJson(),
      timeout: coreGuardFor(
        params.timeout,
        budgetFactor: serviceSweepBudgetFactor,
      ),
    );
  }

  Future<MitmCertificate?> getMitmCertificate() {
    return _find(CoreMethod.mitmCertificate, _model(MitmCertificate.fromJson));
  }

  Future<MitmCertificate> generateMitmCertificate() {
    return _query(
      CoreMethod.mitmGenerateCertificate,
      _model(MitmCertificate.fromJson),
    );
  }

  Future<Map<MitmList, Map<int, String>>> validateMitm(MitmRules rules) {
    return _query(CoreMethod.mitmValidate, (data) {
      final lists = _json(data);
      return {
        for (final list in MitmList.values)
          if (lists[list.key] case final Object issues) list: _issues(issues),
      };
    }, arguments: rules.toJson());
  }

  Future<String> issueMitmCertificate(String host) {
    return _query(
      CoreMethod.mitmIssueCertificate,
      _cast<String>,
      arguments: {'host': host},
    );
  }

  Future<MitmExchangeList> getMitmExchanges(String connectionId) {
    return _query(
      CoreMethod.mitmExchanges,
      _model(MitmExchangeList.fromJson),
      arguments: {'id': connectionId},
    );
  }

  /// Null once the Core no longer keeps the request.
  Future<MitmExchange?> getMitmExchange(int id) {
    return _find(
      CoreMethod.mitmExchange,
      _model(MitmExchange.fromJson),
      arguments: {'id': id},
    );
  }

  /// Null once the Core no longer keeps the request.
  Future<MitmBody?> getMitmBody(int id, {required bool response}) {
    return _find(
      CoreMethod.mitmBody,
      _model(MitmBody.fromJson),
      arguments: {'id': id, 'response': response},
    );
  }

  /// The Core holds the run to the script's own timeout, up to an hour.
  Future<MitmScriptOutput> runMitmScript(String name) {
    return _query(
      CoreMethod.mitmRunScript,
      _model(MitmScriptOutput.fromJson),
      arguments: {'name': name},
      timeout: const Duration(hours: 1, minutes: 1),
    );
  }
}

T _cast<T>(Object data) => data as T;

Map<String, dynamic> _json(Object? data) =>
    Map<String, dynamic>.from(data as Map);

List<Map<String, dynamic>> _jsonList(Object? data) => [
  for (final item in data as List) _json(item),
];

List<String> _strings(Object data) => [
  for (final item in data as List) item as String,
];

T Function(Object) _model<T>(T Function(Map<String, dynamic>) fromJson) =>
    (data) => fromJson(_json(data));

List<T> Function(Object) _models<T>(
  T Function(Map<String, dynamic>) fromJson,
) =>
    (data) => [for (final item in data as List) fromJson(_json(item))];

Map<int, String> _issues(Object data) => {
  for (final item in data as List)
    if (item case {'index': final num index, 'message': final String message})
      index.toInt(): message,
};
