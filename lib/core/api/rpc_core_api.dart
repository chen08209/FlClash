import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';

import 'core_api.dart';
import 'core_client.dart';
import 'dto.dart';
import 'errors.dart';

JsonMap _profile(String path) => {'path': path};

JsonMap _output(String? file) => file == null
    ? {}
    : {
        'output': {'file': file},
      };

JsonMap _object(Object? value) => value as JsonMap;

/// [CoreApi] over a JSON-RPC session.
final class RpcCoreApi implements CoreApi {
  final CoreClient client;

  RpcCoreApi(this.client);

  Future<T> _call<T>(
    String method,
    Decoder<T> decode, {
    Object? params,
    Duration? timeout,
  }) {
    return client.call<T>(
      method,
      params: params,
      decode: decode,
      timeout: timeout,
    );
  }

  Future<void> _command(String method, {Object? params, Duration? timeout}) =>
      _call<void>(method, (_) {}, params: params, timeout: timeout);

  Future<T?> _find<T>(
    String method,
    Decoder<T> decode, {
    Object? params,
  }) async {
    try {
      return await _call<T>(method, decode, params: params);
    } on CoreMethodException catch (error) {
      if (error.code == 'not_found') {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> init({required String home, int? sdkInt}) {
    return _command('core.init', params: {'home': home, 'sdkInt': ?sdkInt});
  }

  @override
  Future<void> releaseMemory() => _command('core.releaseMemory');

  @override
  Future<CoreStats> stats() =>
      _call('core.stats', (r) => CoreStats.fromJson(_object(r)));

  @override
  Future<CapabilitiesInfo> capabilities() =>
      _call('core.capabilities', (r) => CapabilitiesInfo.fromJson(_object(r)));

  @override
  Future<List<WarningInfo>> lastWarnings() =>
      _call('core.lastWarnings', (r) => warningsOf(_object(r)));

  @override
  Future<void> debugCrash() => _command('debug.crash');

  @override
  Future<EngineStatus> engineStatus() async {
    await client.ready();
    return client.snapshot(
      'engine.state',
      decode: (r) => EngineStatus.fromJson(_object(r)),
    );
  }

  @override
  Stream<EngineStatus> watchEngineStatus() {
    return client
        .watch<EngineStatus, EngineStatus>(
          'engine.state',
          decodeSnapshot: (r) => EngineStatus.fromJson(_object(r)),
          decodeEvent: EngineStatus.fromJson,
        )
        .expand((frame) => [?frame.snapshot, ...frame.events]);
  }

  @override
  Future<void> startEngine() => _command('engine.start');

  @override
  Future<void> stopEngine() => _command('engine.stop');

  @override
  Future<List<WarningInfo>> applyConfig({
    String? profilePath,
    JsonMap? overlay,
    Map<String, String> selection = const {},
    required CoreOptionsArg options,
    JsonMap? host,
  }) {
    return _call(
      'config.apply',
      (r) => warningsOf(_object(r)),
      params: {
        if (profilePath != null) 'profile': _profile(profilePath),
        'overlay': ?overlay,
        'selection': selection,
        'options': options.toJson(),
        'host': ?host,
      },
    );
  }

  @override
  Future<int> patchConfig(ConfigPatch patch) => _call(
    'config.patch',
    (r) => _object(r)['seq'] as int,
    params: patch.toJson(),
  );

  @override
  Future<GeneralStateDto> general() =>
      _call('config.general', (r) => GeneralStateDto.fromJson(_object(r)));

  @override
  Future<List<IssueInfo>> validateConfig(String profilePath) => _call(
    'config.validate',
    (r) => issuesOf(_object(r)),
    params: {'profile': _profile(profilePath)},
  );

  @override
  Future<TextOutput> decryptConfig(
    String profilePath,
    String key, {
    String? outputFile,
  }) => _call(
    'config.decrypt',
    (r) => TextOutput.fromJson(_object(r)),
    params: {
      'profile': _profile(profilePath),
      'key': key,
      ..._output(outputFile),
    },
  );

  @override
  Future<ConfigReadOutput> readConfig(
    String profilePath, {
    String? outputFile,
  }) => _call(
    'config.read',
    (r) => ConfigReadOutput.fromJson(_object(r)),
    params: {'profile': _profile(profilePath), ..._output(outputFile)},
  );

  @override
  Future<ProfileInspect> inspectProfile(String profilePath) => _call(
    'profile.inspect',
    (r) => ProfileInspect.fromJson(_object(r)),
    params: {'profile': _profile(profilePath)},
  );

  @override
  Future<ProfileOutbounds> profileOutbounds(String profilePath) => _call(
    'profile.outbounds',
    (r) => ProfileOutbounds.fromJson(_object(r)),
    params: {'profile': _profile(profilePath)},
  );

  @override
  Future<TextOutput> buildProfile(
    String profilePath,
    JsonMap overlay, {
    String? outputFile,
  }) => _call(
    'profile.build',
    (r) => TextOutput.fromJson(_object(r)),
    params: {
      'profile': _profile(profilePath),
      'overlay': overlay,
      ..._output(outputFile),
    },
  );

  @override
  Future<void> clearEffect(int profileId) =>
      _command('profile.clearEffect', params: {'profileId': profileId});

  @override
  Future<ProxyGroupsDto> proxyGroups() =>
      _call('proxy.groups', (r) => ProxyGroupsDto.fromJson(_object(r)));

  @override
  Stream<ProxyUpdate> watchProxies() {
    return client
        .watch<ProxyGroupsDto, ProxyDelta>(
          'proxy.watch',
          decodeSnapshot: (r) => ProxyGroupsDto.fromJson(_object(r)),
          decodeEvent: ProxyDelta.fromJson,
        )
        .expand(
          (frame) => [
            if (frame.snapshot case final snapshot?) ProxiesReset(snapshot),
            for (final delta in frame.events) ProxiesChanged(delta),
          ],
        );
  }

  @override
  Future<SelectResult> selectProxy(String group, String proxy) => _call(
    'proxy.select',
    (r) => (
      changed: _object(r)['changed'] as bool,
      seq: _object(r)['seq'] as int? ?? 0,
    ),
    params: {'group': group, 'proxy': proxy},
  );

  @override
  Future<JsonMap?> proxyDefinition(String name) => _find(
    'proxy.definition',
    (r) => _object(_object(r)['proxy']),
    params: {'name': name},
  );

  @override
  Future<DelayResult> testDelay(String proxy, {String? url, int? timeout}) =>
      _call(
        'delay.test',
        (r) => DelayResult.fromJson(_object(r)),
        params: {'proxy': proxy, 'url': ?url, 'timeout': ?timeout},
        timeout: delayTestGuardDuration,
      );

  @override
  Stream<DelayRunEvent> runDelays(
    List<String> proxies, {
    String? url,
    int? timeout,
    int? concurrency,
  }) {
    return client
        .watch<Object?, DelayRunEvent>(
          'delay.run',
          params: {
            'proxies': proxies,
            'url': ?url,
            'timeout': ?timeout,
            'concurrency': ?concurrency,
          },
          decodeEvent: DelayRunEvent.fromJson,
          isLast: (event) => event is DelayRunDone,
          maxBatchMs: 100,
        )
        .expand((frame) => frame.events);
  }

  @override
  Future<Map<int, String>> validateProxies(List<JsonMap> proxies) => _call(
    'validate.proxies',
    (r) => indexedIssuesOf(_object(r)),
    params: {'proxies': proxies},
  );

  @override
  Future<Map<int, String>> validateFilters(List<String> filters) => _call(
    'validate.filters',
    (r) => indexedIssuesOf(_object(r)),
    params: {'filters': filters},
  );

  @override
  Future<List<JsonMap>> convertSubscription(String profilePath) => _call(
    'convert.subscription',
    (r) => [for (final item in _object(r)['proxies'] as List) _object(item)],
    params: {'profile': _profile(profilePath)},
  );

  @override
  Future<List<String>> encodeLinks(List<JsonMap> proxies) => _call(
    'convert.encodeLinks',
    (r) => [for (final item in _object(r)['links'] as List) item as String],
    params: {'proxies': proxies},
  );

  @override
  Future<List<List<JsonMap>>> decodeLinks(List<String> lines) => _call(
    'convert.decodeLinks',
    (r) => [
      for (final line in _object(r)['results'] as List)
        [for (final proxy in line as List) _object(proxy)],
    ],
    params: {'lines': lines},
  );

  @override
  Future<List<ProviderInfo>> providers() => _call(
    'provider.list',
    (r) => [
      for (final item in _object(r)['providers'] as List)
        ProviderInfo.fromJson(_object(item)),
    ],
  );

  @override
  Future<ProviderInfo?> provider(String name) => _find(
    'provider.get',
    (r) => ProviderInfo.fromJson(_object(r)),
    params: {'name': name},
  );

  @override
  Future<void> updateProvider(String name) =>
      _command('provider.update', params: {'name': name});

  @override
  Future<void> sideLoadProvider(String name, String data) =>
      _command('provider.sideLoad', params: {'name': name, 'data': data});

  @override
  Future<TextOutput> dumpRuleSet(String profilePath, {String? outputFile}) =>
      _call(
        'ruleSet.dump',
        (r) => TextOutput.fromJson(_object(r)),
        params: {'profile': _profile(profilePath), ..._output(outputFile)},
      );

  @override
  Future<Object?> ruleList() => _call('rule.list', (r) => _object(r));

  @override
  Future<RuleSetInfoDto> compileRuleSet(String name, {String? url}) => _call(
    'ruleSet.compile',
    (r) => RuleSetInfoDto.fromJson(_object(r)),
    params: {'name': name, 'url': ?url},
  );

  @override
  Future<void> updateGeo(String kind) =>
      _command('geo.update', params: {'type': kind});

  @override
  Stream<TrafficSample> watchTraffic({
    int? intervalMs,
    bool onlyProxy = false,
  }) {
    return client
        .watch<TrafficSample, TrafficSample>(
          'traffic.watch',
          params: {'intervalMs': ?intervalMs, 'onlyProxy': onlyProxy},
          decodeSnapshot: (r) => TrafficSample.fromJson(_object(r)),
          decodeEvent: TrafficSample.fromJson,
        )
        .expand((frame) => [?frame.snapshot, ...frame.events]);
  }

  @override
  Future<void> resetTraffic() => _command('traffic.reset');

  @override
  Stream<ConnectionUpdate> watchConnections({
    int? maxBatchMs,
    bool counters = true,
  }) {
    return client
        .watch<ConnectionSnapshot, ConnectionDelta>(
          'connection.watch',
          params: {if (!counters) 'counters': false},
          decodeSnapshot: (r) => ConnectionSnapshot.fromJson(_object(r)),
          decodeEvent: ConnectionDelta.fromJson,
          maxBatchMs: maxBatchMs,
        )
        .expand(
          (frame) => [
            if (frame.snapshot case final snapshot?) ConnectionsReset(snapshot),
            for (final delta in frame.events) ConnectionsChanged(delta),
          ],
        );
  }

  @override
  Future<void> closeConnections({List<int>? ids}) => _command(
    'connection.close',
    params: ids == null ? {'all': true} : {'ids': ids},
  );

  @override
  Future<void> resetNetwork() => _command('network.reset');

  @override
  Future<void> updateNetwork({
    List<String>? dnsServers,
    bool interfaceChanged = false,
  }) => _command(
    'network.update',
    params: {'dnsServers': ?dnsServers, 'interfaceChanged': interfaceChanged},
  );

  @override
  Future<void> clearDnsCache() => _command('dns.clearCache');

  @override
  Stream<List<LogEntry>> watchLogs({LogLevel level = LogLevel.debug}) {
    return client
        .watch<Object?, LogEntry>(
          'log.watch',
          params: {'level': level.name},
          decodeEvent: LogEntry.fromJson,
        )
        .map((frame) => frame.events)
        .where((events) => events.isNotEmpty);
  }

  @override
  Stream<List<DnsEntry>> watchDns() {
    return client
        .watch<Object?, DnsEntry>('dns.watch', decodeEvent: DnsEntry.fromJson)
        .map((frame) => frame.events)
        .where((events) => events.isNotEmpty);
  }

  @override
  Stream<RouteStampDto> watchRoute() {
    return client
        .watch<RouteStampDto, RouteStampDto>(
          'route.watch',
          decodeSnapshot: (r) => RouteStampDto.fromJson(_object(r)),
          decodeEvent: RouteStampDto.fromJson,
        )
        .expand((frame) => [?frame.snapshot, ...frame.events]);
  }

  @override
  Stream<List<CoreEventDto>> watchEvents({
    bool delays = false,
    bool state = false,
  }) {
    return client
        .watch<Object?, CoreEventDto>(
          'events.watch',
          params: {'delays': delays, 'state': state},
          decodeEvent: CoreEventDto.fromJson,
        )
        .map(
          (frame) => [
            if (frame.resynced) const EventsResynced(),
            ...frame.events,
          ],
        )
        .where((events) => events.isNotEmpty);
  }

  @override
  Future<RouteCheckResult> checkRoutes(
    List<List<RouteHitDto>> routes, {
    Duration? timeout,
  }) => _call(
    'route.check',
    (r) => RouteCheckResult.fromJson(_object(r)),
    params: {
      'routes': [
        for (final route in routes) [for (final hit in route) hit.toJson()],
      ],
    },
    timeout: timeout,
  );

  @override
  Future<OutboundIp> outboundIp(
    String proxy,
    List<String> urls, {
    required int timeout,
    Duration? guard,
  }) => _call(
    'probe.outboundIp',
    (r) => OutboundIp.fromJson(_object(r)),
    params: {'proxy': proxy, 'urls': urls, 'timeout': timeout},
    timeout: guard,
  );

  @override
  Future<List<ServiceItem>> checkServices(
    String proxy,
    List<String> names, {
    required int timeout,
    Duration? guard,
  }) => _call(
    'probe.services',
    (r) => [
      for (final item in _object(r)['items'] as List)
        ServiceItem.fromJson(_object(item)),
    ],
    params: {'proxy': proxy, 'names': names, 'timeout': timeout},
    timeout: guard,
  );

  @override
  Future<JsonMap?> mitmCertificate() => _call(
    'mitm.certificate',
    (r) => _object(r)['certificate'] == null
        ? null
        : _object(_object(r)['certificate']),
  );

  @override
  Future<JsonMap> generateMitmCertificate() => _call(
    'mitm.generateCertificate',
    (r) => _object(_object(r)['certificate']),
  );

  @override
  Future<JsonMap> validateMitm(JsonMap config) =>
      _call('mitm.validate', (r) => _object(r), params: {'config': config});

  @override
  Future<String> issueMitmCertificate(String host) => _call(
    'mitm.issueCertificate',
    (r) => _object(r)['pem'] as String,
    params: {'host': host},
  );

  @override
  Future<Object?> runMitmScript(String name, {Duration? guard}) => _call(
    'mitm.runScript',
    _resultOrNull,
    params: {'name': name},
    timeout: guard,
  );

  @override
  Future<Object?> mitmExchanges(int connectionId) => _call(
    'mitm.exchanges',
    _resultOrNull,
    params: {'connection': connectionId},
  );

  @override
  Future<MitmQueryAnswer> mitmQuery({
    MitmFilter filter = const MitmFilter(),
    int? before,
    int? limit,
    int? since,
    bool facets = false,
    int? rateFrom,
  }) => _call(
    'mitm.query',
    (r) => MitmQueryAnswer.fromJson(_object(r)),
    params: {
      'filter': filter.toJson(),
      'before': ?before,
      'limit': ?limit,
      'since': ?since,
      if (facets) 'facets': true,
      'rateFrom': ?rateFrom,
    },
  );

  @override
  Future<Object?> mitmExchange(int id) =>
      _find<Object?>('mitm.exchange', _resultOrNull, params: {'id': id});

  @override
  Future<Object?> mitmBody(int id, {required bool response}) => _find<Object?>(
    'mitm.body',
    _resultOrNull,
    params: {'id': id, 'response': response},
  );

  @override
  Future<JsonMap> readMitmModule(
    String text, {
    Map<String, String> arguments = const {},
    Map<String, String> attachments = const {},
    String language = '',
  }) => _call(
    'mitm.readModule',
    (r) => _object(r),
    params: {
      'text': text,
      'arguments': arguments,
      'attachments': attachments,
      'language': language,
    },
  );

  @override
  Future<JsonMap> mitmModuleStatus() =>
      _call('mitm.moduleStatus', (r) => _object(r));

  @override
  Future<void> fetchMitmModule({String? name}) =>
      _call('mitm.fetchModule', (_) {}, params: {'name': ?name});
}

Object? _resultOrNull(Object? result) => _object(result)['result'];
