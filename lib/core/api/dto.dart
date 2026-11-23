import 'package:flutter/foundation.dart';

part 'mitm_query_dto.dart';
part 'module_dto.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap _map(Object? value) =>
    value is JsonMap ? value : Map<String, Object?>.from(value as Map);

List<String> _strings(Object? value) => [
  for (final item in value as List? ?? const []) item as String,
];

List<T> _list<T>(Object? value, T Function(JsonMap json) decode) => [
  for (final item in value as List? ?? const []) decode(_map(item)),
];

JsonMap? _optionalMap(Object? value) => value == null ? null : _map(value);

T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}

enum EngineState {
  created,
  initialized,
  configured,
  running,
  failed,
  unknown;

  static EngineState parse(Object? name) =>
      _enum(values, name, EngineState.unknown);
}

enum FaultService {
  mixed,
  http,
  socks,
  redir,
  tproxy,
  tun,
  dns,
  unknown;

  static FaultService parse(Object? name) =>
      _enum(values, name, FaultService.unknown);
}

enum FaultReason {
  addressInUse('address_in_use'),
  addressNotAvailable('address_not_available'),
  permissionDenied('permission_denied'),
  other('other');

  final String wire;

  const FaultReason(this.wire);

  static FaultReason parse(Object? wire) => values.firstWhere(
    (reason) => reason.wire == wire,
    orElse: () => FaultReason.other,
  );
}

@immutable
class ServiceFault {
  final FaultService service;
  final String address;
  final FaultReason reason;
  final String message;

  const ServiceFault({
    required this.service,
    this.address = '',
    required this.reason,
    required this.message,
  });

  factory ServiceFault.fromJson(JsonMap json) => ServiceFault(
    service: FaultService.parse(json['service']),
    address: json['address'] as String? ?? '',
    reason: FaultReason.parse(json['reason']),
    message: json['message'] as String,
  );

  @override
  bool operator ==(Object other) =>
      other is ServiceFault &&
      other.service == service &&
      other.address == address &&
      other.reason == reason &&
      other.message == message;

  @override
  int get hashCode => Object.hash(service, address, reason, message);
}

@immutable
class EngineStatus {
  final EngineState state;
  final String? kind;
  final List<ServiceFault> faults;

  const EngineStatus({required this.state, this.kind, this.faults = const []});

  factory EngineStatus.fromJson(JsonMap json) => EngineStatus(
    state: EngineState.parse(json['state']),
    kind: json['kind'] as String?,
    faults: _list(json['faults'], ServiceFault.fromJson),
  );

  @override
  bool operator ==(Object other) =>
      other is EngineStatus &&
      other.state == state &&
      other.kind == kind &&
      listEquals(other.faults, faults);

  @override
  int get hashCode => Object.hash(state, kind, Object.hashAll(faults));
}

@immutable
class Features {
  final bool mitm;
  final bool ech;

  const Features({this.mitm = false, this.ech = false});

  factory Features.fromJson(JsonMap json) => Features(
    mitm: json['mitm'] as bool? ?? false,
    ech: json['ech'] as bool? ?? false,
  );
}

@immutable
class HelloResult {
  final int protocol;
  final String implementation;
  final String version;
  final String build;
  final String os;
  final bool privileged;
  final List<String> platformCapabilities;
  final int maxMessage;
  final int maxBatchBytes;
  final List<String> methods;
  final Features features;
  final EngineStatus engine;

  const HelloResult({
    required this.protocol,
    required this.implementation,
    required this.version,
    required this.build,
    required this.os,
    required this.privileged,
    required this.platformCapabilities,
    required this.maxMessage,
    required this.maxBatchBytes,
    required this.methods,
    required this.features,
    required this.engine,
  });

  factory HelloResult.fromJson(JsonMap json) {
    final server = _map(json['server']);
    final platform = _map(json['platform']);
    final limits = _map(json['limits']);
    return HelloResult(
      protocol: json['protocol'] as int,
      implementation: server['implementation'] as String,
      version: server['version'] as String,
      build: server['build'] as String,
      os: platform['os'] as String,
      privileged: platform['privileged'] as bool,
      platformCapabilities: _strings(platform['capabilities']),
      maxMessage: limits['maxMessage'] as int,
      maxBatchBytes: limits['maxBatchBytes'] as int,
      methods: _strings(json['methods']),
      features: Features.fromJson(_map(json['features'])),
      engine: EngineStatus.fromJson(_map(json['engine'])),
    );
  }
}

@immutable
class CoreStats {
  final int rss;

  const CoreStats({required this.rss});

  factory CoreStats.fromJson(JsonMap json) =>
      CoreStats(rss: json['rss'] as int);
}

@immutable
class CapabilitiesInfo {
  final String implementation;
  final String version;
  final List<String> proxyTypes;
  final List<String> transports;
  final List<String> ruleTypes;
  final List<String> ssPlugins;
  final List<String> congestionControllers;
  final Features features;

  const CapabilitiesInfo({
    required this.implementation,
    required this.version,
    required this.proxyTypes,
    required this.transports,
    required this.ruleTypes,
    required this.ssPlugins,
    required this.congestionControllers,
    required this.features,
  });

  factory CapabilitiesInfo.fromJson(JsonMap json) => CapabilitiesInfo(
    implementation: json['implementation'] as String,
    version: json['version'] as String,
    proxyTypes: _strings(json['proxyTypes']),
    transports: _strings(json['transports']),
    ruleTypes: _strings(json['ruleTypes']),
    ssPlugins: _strings(json['ssPlugins']),
    congestionControllers: _strings(json['congestionControllers']),
    features: Features.fromJson(_map(json['features'])),
  );
}

@immutable
class WarningInfo {
  final String level;
  final String path;
  final String message;

  const WarningInfo({
    required this.level,
    required this.path,
    required this.message,
  });

  factory WarningInfo.fromJson(JsonMap json) => WarningInfo(
    level: json['level'] as String,
    path: json['path'] as String,
    message: json['message'] as String,
  );
}

List<WarningInfo> warningsOf(JsonMap json) =>
    _list(json['warnings'], WarningInfo.fromJson);

@immutable
class IssueInfo {
  final String? path;
  final int? line;
  final int? column;
  final String message;

  const IssueInfo({this.path, this.line, this.column, required this.message});

  factory IssueInfo.fromJson(JsonMap json) => IssueInfo(
    path: json['path'] as String?,
    line: json['line'] as int?,
    column: json['column'] as int?,
    message: json['message'] as String,
  );
}

List<IssueInfo> issuesOf(JsonMap json) =>
    _list(json['issues'], IssueInfo.fromJson);

Map<int, String> indexedIssuesOf(JsonMap json) => {
  for (final item in json['issues'] as List? ?? const [])
    (item as Map)['index'] as int: item['message'] as String,
};

@immutable
class TextOutput {
  final String? text;
  final String? file;
  final int? size;

  const TextOutput({this.text, this.file, this.size});

  factory TextOutput.fromJson(JsonMap json) => TextOutput(
    text: json['text'] as String?,
    file: json['file'] as String?,
    size: json['size'] as int?,
  );
}

@immutable
class ConfigReadOutput {
  final JsonMap? config;
  final String? file;
  final int? size;

  const ConfigReadOutput({this.config, this.file, this.size});

  factory ConfigReadOutput.fromJson(JsonMap json) => ConfigReadOutput(
    config: _optionalMap(json['config']),
    file: json['file'] as String?,
    size: json['size'] as int?,
  );
}

@immutable
class ProfileInspect {
  final JsonMap config;
  final String digest;
  final List<String> matchRules;
  final int proxies;
  final int proxyGroups;
  final int rules;

  const ProfileInspect({
    required this.config,
    required this.digest,
    required this.matchRules,
    required this.proxies,
    required this.proxyGroups,
    required this.rules,
  });

  factory ProfileInspect.fromJson(JsonMap json) => ProfileInspect(
    config: _map(json['config']),
    digest: json['digest'] as String,
    matchRules: _strings(json['matchRules']),
    proxies: json['proxies'] as int,
    proxyGroups: json['proxyGroups'] as int,
    rules: json['rules'] as int,
  );
}

@immutable
class OutboundRef {
  final String name;
  final String type;

  const OutboundRef({required this.name, required this.type});

  factory OutboundRef.fromJson(JsonMap json) =>
      OutboundRef(name: json['name'] as String, type: json['type'] as String);
}

@immutable
class ProfileOutbounds {
  final List<OutboundRef> proxies;
  final List<OutboundRef> proxyGroups;

  const ProfileOutbounds({required this.proxies, required this.proxyGroups});

  factory ProfileOutbounds.fromJson(JsonMap json) => ProfileOutbounds(
    proxies: _list(json['proxies'], OutboundRef.fromJson),
    proxyGroups: _list(json['proxyGroups'], OutboundRef.fromJson),
  );
}

@immutable
class NodeInfo {
  final String name;
  final String type;
  final String? provider;

  const NodeInfo({required this.name, required this.type, this.provider});

  factory NodeInfo.fromJson(JsonMap json) => NodeInfo(
    name: json['name'] as String,
    type: json['type'] as String,
    provider: json['provider'] as String?,
  );
}

@immutable
class GroupInfo {
  final String name;
  final String type;
  final String? now;
  final List<String>? all;
  final String testUrl;
  final String? expectedStatus;
  final String? fixed;
  final bool hidden;
  final String icon;
  final String emptyFallback;

  const GroupInfo({
    required this.name,
    required this.type,
    this.now,
    this.all,
    required this.testUrl,
    this.expectedStatus,
    this.fixed,
    required this.hidden,
    required this.icon,
    required this.emptyFallback,
  });

  factory GroupInfo.fromJson(JsonMap json) => GroupInfo(
    name: json['name'] as String,
    type: json['type'] as String,
    now: json['now'] as String?,
    all: json['all'] == null ? null : _strings(json['all']),
    testUrl: json['testUrl'] as String,
    expectedStatus: json['expectedStatus'] as String?,
    fixed: json['fixed'] as String?,
    hidden: json['hidden'] as bool,
    icon: json['icon'] as String,
    emptyFallback: json['emptyFallback'] as String,
  );
}

@immutable
class ProxyGroupsDto {
  final List<String> order;
  final List<GroupInfo> groups;
  final List<NodeInfo> nodes;

  const ProxyGroupsDto({
    this.order = const [],
    this.groups = const [],
    this.nodes = const [],
  });

  factory ProxyGroupsDto.fromJson(JsonMap json) => ProxyGroupsDto(
    order: _strings(json['order']),
    groups: _list(json['groups'], GroupInfo.fromJson),
    nodes: _list(json['nodes'], NodeInfo.fromJson),
  );
}

@immutable
class ProxyDelta {
  final List<String>? order;
  final List<GroupInfo> groups;
  final List<NodeInfo> nodes;
  final List<String> removed;

  const ProxyDelta({
    this.order,
    this.groups = const [],
    this.nodes = const [],
    this.removed = const [],
  });

  factory ProxyDelta.fromJson(JsonMap json) => ProxyDelta(
    order: json['order'] == null ? null : _strings(json['order']),
    groups: _list(json['groups'], GroupInfo.fromJson),
    nodes: _list(json['nodes'], NodeInfo.fromJson),
    removed: _strings(json['removed']),
  );
}

@immutable
class DelayResult {
  final String name;
  final String url;

  /// Milliseconds when positive, -1 for a timeout and -2 for a failure.
  final int value;

  const DelayResult({
    required this.name,
    required this.url,
    required this.value,
  });

  factory DelayResult.fromJson(JsonMap json) => DelayResult(
    name: json['name'] as String,
    url: json['url'] as String,
    value: json['value'] as int,
  );
}

@immutable
sealed class DelayRunEvent {
  const DelayRunEvent();

  factory DelayRunEvent.fromJson(JsonMap json) => switch (json['type']) {
    'result' => DelayRunResult(DelayResult.fromJson(json)),
    _ => const DelayRunDone(),
  };
}

final class DelayRunResult extends DelayRunEvent {
  final DelayResult result;

  const DelayRunResult(this.result);
}

final class DelayRunDone extends DelayRunEvent {
  const DelayRunDone();
}

@immutable
class SubscriptionInfoDto {
  final int upload;
  final int download;
  final int total;
  final int expire;

  const SubscriptionInfoDto({
    required this.upload,
    required this.download,
    required this.total,
    required this.expire,
  });

  factory SubscriptionInfoDto.fromJson(JsonMap json) => SubscriptionInfoDto(
    upload: json['upload'] as int,
    download: json['download'] as int,
    total: json['total'] as int,
    expire: json['expire'] as int,
  );
}

enum ProviderKindDto {
  proxy,
  rule;

  static ProviderKindDto parse(Object? name) =>
      _enum(values, name, ProviderKindDto.proxy);
}

@immutable
class ProviderInfo {
  final String name;
  final ProviderKindDto type;
  final String vehicleType;
  final int count;
  final String path;
  final int? updatedAt;
  final SubscriptionInfoDto? subscriptionInfo;

  const ProviderInfo({
    required this.name,
    required this.type,
    required this.vehicleType,
    required this.count,
    required this.path,
    this.updatedAt,
    this.subscriptionInfo,
  });

  factory ProviderInfo.fromJson(JsonMap json) => ProviderInfo(
    name: json['name'] as String,
    type: ProviderKindDto.parse(json['type']),
    vehicleType: json['vehicleType'] as String,
    count: json['count'] as int,
    path: json['path'] as String,
    updatedAt: json['updatedAt'] as int?,
    subscriptionInfo: json['subscriptionInfo'] == null
        ? null
        : SubscriptionInfoDto.fromJson(_map(json['subscriptionInfo'])),
  );
}

@immutable
class RuleSetInfoDto {
  final String behavior;
  final String format;

  const RuleSetInfoDto({required this.behavior, required this.format});

  factory RuleSetInfoDto.fromJson(JsonMap json) => RuleSetInfoDto(
    behavior: json['behavior'] as String,
    format: json['format'] as String,
  );
}

@immutable
class RouteStampDto {
  final int epoch;
  final int version;
  final bool running;

  const RouteStampDto({
    required this.epoch,
    required this.version,
    this.running = false,
  });

  factory RouteStampDto.fromJson(JsonMap json) => RouteStampDto(
    epoch: json['epoch'] as int,
    version: json['version'] as int,
    running: json['running'] as bool? ?? false,
  );
}

@immutable
class RouteHitDto {
  final String host;
  final String proxy;
  final String exit;

  const RouteHitDto({required this.host, this.proxy = '', required this.exit});

  factory RouteHitDto.fromJson(JsonMap json) => RouteHitDto(
    host: json['host'] as String,
    proxy: json['proxy'] as String? ?? '',
    exit: json['exit'] as String,
  );

  JsonMap toJson() => {
    'host': host,
    if (proxy.isNotEmpty) 'proxy': proxy,
    'exit': exit,
  };
}

@immutable
class RouteCheckResult {
  final RouteStampDto stamp;
  final List<bool> held;

  const RouteCheckResult({required this.stamp, required this.held});

  factory RouteCheckResult.fromJson(JsonMap json) => RouteCheckResult(
    stamp: RouteStampDto.fromJson(json),
    held: [for (final item in json['held'] as List) item as bool],
  );
}

@immutable
class OutboundIp {
  final String url;
  final String body;
  final int delay;
  final List<String> chains;
  final String? error;
  final RouteStampDto stamp;
  final List<RouteHitDto> hits;
  final List<RouteHitDto> nodeHits;

  const OutboundIp({
    required this.url,
    required this.body,
    required this.delay,
    required this.chains,
    this.error,
    required this.stamp,
    required this.hits,
    required this.nodeHits,
  });

  factory OutboundIp.fromJson(JsonMap json) => OutboundIp(
    url: json['url'] as String,
    body: json['body'] as String,
    delay: json['delay'] as int,
    chains: _strings(json['chains']),
    error: json['error'] as String?,
    stamp: RouteStampDto.fromJson(json),
    hits: _list(json['hits'], RouteHitDto.fromJson),
    nodeHits: _list(json['nodeHits'], RouteHitDto.fromJson),
  );
}

@immutable
class ServiceItem {
  final String name;
  final String status;
  final String region;
  final String ip;
  final int delay;
  final List<String> chains;
  final int checkedAt;
  final RouteStampDto stamp;
  final List<RouteHitDto> hits;

  const ServiceItem({
    required this.name,
    required this.status,
    required this.region,
    required this.ip,
    required this.delay,
    required this.chains,
    required this.checkedAt,
    required this.stamp,
    required this.hits,
  });

  factory ServiceItem.fromJson(JsonMap json) => ServiceItem(
    name: json['name'] as String,
    status: json['status'] as String,
    region: json['region'] as String? ?? '',
    ip: json['ip'] as String? ?? '',
    delay: json['delay'] as int? ?? 0,
    chains: _strings(json['chains']),
    checkedAt: json['checkedAt'] as int,
    stamp: RouteStampDto.fromJson(json),
    hits: _list(json['hits'], RouteHitDto.fromJson),
  );
}

@immutable
class TrafficSample {
  final int up;
  final int down;
  final int totalUp;
  final int totalDown;

  const TrafficSample({
    required this.up,
    required this.down,
    required this.totalUp,
    required this.totalDown,
  });

  factory TrafficSample.fromJson(JsonMap json) => TrafficSample(
    up: json['up'] as int,
    down: json['down'] as int,
    totalUp: json['totalUp'] as int,
    totalDown: json['totalDown'] as int,
  );
}

@immutable
class ConnectionFailureDto {
  final String kind;
  final String message;

  const ConnectionFailureDto({required this.kind, required this.message});

  factory ConnectionFailureDto.fromJson(JsonMap json) => ConnectionFailureDto(
    kind: json['kind'] as String,
    message: json['message'] as String,
  );
}

@immutable
class ConnectionInfo {
  final int id;
  final int start;
  final String network;
  final String sourceIp;
  final int sourcePort;
  final String? destinationIp;
  final int destinationPort;
  final String? host;
  final String? sniffHost;
  final String inboundType;
  final String? inboundIp;
  final int? inboundPort;
  final String? inboundName;
  final String? inboundUser;
  final String? dnsMode;
  final int? uid;
  final String? process;
  final String? processPath;
  final String? remoteDestination;
  final List<String>? sourceGeoIp;
  final List<String>? destinationGeoIp;
  final String? sourceAsn;
  final String? destinationAsn;
  final String? specialRules;
  final String? specialProxy;
  final bool mitm;
  final bool mitmRefused;
  final List<String> chains;
  final List<String> providerChains;
  final String rule;
  final String rulePayload;
  final int? ruleIndex;
  final int upload;
  final int download;
  final ConnectionFailureDto? failure;
  final ConnectionTimingDto? timing;
  final List<int> dnsQueries;

  const ConnectionInfo({
    required this.id,
    required this.start,
    required this.network,
    required this.sourceIp,
    required this.sourcePort,
    this.destinationIp,
    required this.destinationPort,
    this.host,
    this.sniffHost,
    required this.inboundType,
    this.inboundIp,
    this.inboundPort,
    this.inboundName,
    this.inboundUser,
    this.dnsMode,
    this.uid,
    this.process,
    this.processPath,
    this.remoteDestination,
    this.sourceGeoIp,
    this.destinationGeoIp,
    this.sourceAsn,
    this.destinationAsn,
    this.specialRules,
    this.specialProxy,
    this.mitm = false,
    this.mitmRefused = false,
    required this.chains,
    this.providerChains = const [],
    required this.rule,
    this.rulePayload = '',
    this.ruleIndex,
    required this.upload,
    required this.download,
    this.failure,
    this.timing,
    this.dnsQueries = const [],
  });

  factory ConnectionInfo.fromJson(JsonMap json) => ConnectionInfo(
    id: json['id'] as int,
    start: json['start'] as int,
    network: json['network'] as String,
    sourceIp: json['sourceIp'] as String,
    sourcePort: json['sourcePort'] as int,
    destinationIp: json['destinationIp'] as String?,
    destinationPort: json['destinationPort'] as int,
    host: json['host'] as String?,
    sniffHost: json['sniffHost'] as String?,
    inboundType: json['inboundType'] as String,
    inboundIp: json['inboundIp'] as String?,
    inboundPort: json['inboundPort'] as int?,
    inboundName: json['inboundName'] as String?,
    inboundUser: json['inboundUser'] as String?,
    dnsMode: json['dnsMode'] as String?,
    uid: json['uid'] as int?,
    process: json['process'] as String?,
    processPath: json['processPath'] as String?,
    remoteDestination: json['remoteDestination'] as String?,
    sourceGeoIp: json['sourceGeoIp'] == null
        ? null
        : _strings(json['sourceGeoIp']),
    destinationGeoIp: json['destinationGeoIp'] == null
        ? null
        : _strings(json['destinationGeoIp']),
    sourceAsn: json['sourceAsn'] as String?,
    destinationAsn: json['destinationAsn'] as String?,
    specialRules: json['specialRules'] as String?,
    specialProxy: json['specialProxy'] as String?,
    mitm: json['mitm'] as bool? ?? false,
    mitmRefused: json['mitmRefused'] as bool? ?? false,
    chains: _strings(json['chains']),
    providerChains: _strings(json['providerChains']),
    rule: json['rule'] as String,
    rulePayload: json['rulePayload'] as String? ?? '',
    ruleIndex: json['ruleIndex'] as int?,
    upload: json['upload'] as int,
    download: json['download'] as int,
    failure: switch (_optionalMap(json['failure'])) {
      final failure? => ConnectionFailureDto.fromJson(failure),
      null => null,
    },
    timing: switch (_optionalMap(json['timing'])) {
      final timing? => ConnectionTimingDto.fromJson(timing),
      null => null,
    },
    dnsQueries: [
      for (final id in json['dnsQueries'] as List? ?? const []) id as int,
    ],
  );
}

/// [accepted] is Unix milliseconds; each step is microseconds after it.
class ConnectionTimingDto {
  final int accepted;
  final int? dnsStart;
  final int? dnsEnd;
  final int? routed;
  final int? dialStart;
  final int? connected;
  final int? tls;
  final int? dialEnd;
  final int? decrypted;

  const ConnectionTimingDto({
    required this.accepted,
    this.dnsStart,
    this.dnsEnd,
    this.routed,
    this.dialStart,
    this.connected,
    this.tls,
    this.dialEnd,
    this.decrypted,
  });

  factory ConnectionTimingDto.fromJson(JsonMap json) => ConnectionTimingDto(
    accepted: json['accepted'] as int,
    dnsStart: json['dnsStart'] as int?,
    dnsEnd: json['dnsEnd'] as int?,
    routed: json['routed'] as int?,
    dialStart: json['dialStart'] as int?,
    connected: json['connected'] as int?,
    tls: json['tls'] as int?,
    dialEnd: json['dialEnd'] as int?,
    decrypted: json['decrypted'] as int?,
  );
}

@immutable
class ConnectionCounter {
  final int id;
  final int upload;
  final int download;

  const ConnectionCounter({
    required this.id,
    required this.upload,
    required this.download,
  });

  factory ConnectionCounter.fromJson(JsonMap json) => ConnectionCounter(
    id: json['id'] as int,
    upload: json['upload'] as int,
    download: json['download'] as int,
  );
}

@immutable
class ConnectionSnapshot {
  final List<ConnectionInfo> connections;

  const ConnectionSnapshot(this.connections);

  factory ConnectionSnapshot.fromJson(JsonMap json) =>
      ConnectionSnapshot(_list(json['connections'], ConnectionInfo.fromJson));
}

@immutable
class ConnectionDelta {
  final List<ConnectionInfo> opened;
  final List<int> closed;
  final List<ConnectionCounter> counters;
  final List<ConnectionEndDto> ended;

  const ConnectionDelta({
    this.opened = const [],
    this.closed = const [],
    this.counters = const [],
    this.ended = const [],
  });

  factory ConnectionDelta.fromJson(JsonMap json) => ConnectionDelta(
    opened: _list(json['opened'], ConnectionInfo.fromJson),
    closed: [for (final id in json['closed'] as List? ?? const []) id as int],
    counters: _list(json['counters'], ConnectionCounter.fromJson),
    ended: _list(json['ended'], ConnectionEndDto.fromJson),
  );
}

class ConnectionEndDto {
  final int id;
  final String reason;
  final int endedAt;
  final String message;

  const ConnectionEndDto({
    required this.id,
    required this.reason,
    required this.endedAt,
    this.message = '',
  });

  factory ConnectionEndDto.fromJson(JsonMap json) => ConnectionEndDto(
    id: json['id'] as int,
    reason: json['reason'] as String,
    endedAt: json['endedAt'] as int,
    message: json['message'] as String? ?? '',
  );
}

@immutable
class LogEntry {
  final String level;
  final int time;
  final String text;

  const LogEntry({required this.level, required this.time, required this.text});

  factory LogEntry.fromJson(JsonMap json) => LogEntry(
    level: json['level'] as String,
    time: json['time'] as int,
    text: json['text'] as String,
  );
}

@immutable
class DnsEntry {
  final int? id;
  final String domain;
  final String type;
  final String initiator;
  final String upstream;
  final bool cached;
  final List<String> answers;
  final String rcode;
  final String error;
  final int delay;
  final int time;

  const DnsEntry({
    this.id,
    required this.domain,
    required this.type,
    required this.initiator,
    required this.upstream,
    required this.cached,
    required this.answers,
    required this.rcode,
    required this.error,
    required this.delay,
    required this.time,
  });

  factory DnsEntry.fromJson(JsonMap json) => DnsEntry(
    id: json['id'] as int?,
    domain: json['domain'] as String,
    type: json['type'] as String,
    initiator: json['initiator'] as String,
    upstream: json['upstream'] as String? ?? '',
    cached: json['cached'] as bool? ?? false,
    answers: _strings(json['answers']),
    rcode: json['rcode'] as String? ?? '',
    error: json['error'] as String? ?? '',
    delay: json['delay'] as int,
    time: json['time'] as int,
  );
}

@immutable
sealed class CoreEventDto {
  const CoreEventDto();

  factory CoreEventDto.fromJson(JsonMap json) => switch (json['type']) {
    'resourceUpdate' => ResourceUpdateEvent.fromJson(json),
    'stateChanged' => StateChangedEvent.fromJson(json),
    'dialerLoop' => DialerLoopEvent(json['name'] as String),
    'scriptNotification' => ScriptNotificationEvent.fromJson(json),
    'delay' => DelayEvent(
      DelayResult(
        name: json['name'] as String,
        url: json['url'] as String,
        value: json['value'] as int,
      ),
    ),
    _ => const UnknownCoreEvent(),
  };
}

enum ResourceKind { proxyProvider, ruleProvider, geo, mitmModule }

enum ResourcePhase { updating, updated, unchanged, failed }

const resourceSuperseded = 'superseded';

final class ResourceUpdateEvent extends CoreEventDto {
  final ResourceKind kind;
  final String name;
  final ResourcePhase phase;
  final String error;

  const ResourceUpdateEvent({
    required this.kind,
    required this.name,
    required this.phase,
    this.error = '',
  });

  static CoreEventDto fromJson(JsonMap json) {
    final kind = ResourceKind.values.asNameMap()[json['kind']];
    final phase = ResourcePhase.values.asNameMap()[json['phase']];
    if (kind == null || phase == null) {
      return const UnknownCoreEvent();
    }
    return ResourceUpdateEvent(
      kind: kind,
      name: json['name'] as String,
      phase: phase,
      error: json['error'] as String? ?? '',
    );
  }
}

enum ChangeOrigin { host, controller, core }

final class StateChangedEvent extends CoreEventDto {
  final int seq;
  final ChangeOrigin origin;
  final StateChange change;

  const StateChangedEvent({
    required this.seq,
    required this.origin,
    required this.change,
  });

  static CoreEventDto fromJson(JsonMap json) {
    final origin = ChangeOrigin.values.asNameMap()[json['origin']];
    final change = _map(json['change']);
    return StateChangedEvent(
      seq: json['seq'] as int,
      origin: origin ?? ChangeOrigin.controller,
      change: switch (change['type']) {
        'selected' => SelectedChange(
          group: change['group'] as String,
          proxy: change['proxy'] as String,
        ),
        'general' => GeneralChange.fromJson(change),
        'applied' => const AppliedChange(),
        _ => const UnknownStateChange(),
      },
    );
  }
}

@immutable
sealed class StateChange {
  const StateChange();
}

final class SelectedChange extends StateChange {
  final String group;
  final String proxy;

  const SelectedChange({required this.group, required this.proxy});
}

/// Only the settings a dashboard can change; the rest are the host's own.
final class GeneralChange extends StateChange {
  final String? mode;
  final String? logLevel;
  final bool? allowLan;
  final bool? ipv6;
  final int? mixedPort;
  final bool? tcpConcurrent;
  final String? findProcessMode;

  const GeneralChange({
    this.mode,
    this.logLevel,
    this.allowLan,
    this.ipv6,
    this.mixedPort,
    this.tcpConcurrent,
    this.findProcessMode,
  });

  factory GeneralChange.fromJson(JsonMap json) => GeneralChange(
    mode: json['mode'] as String?,
    logLevel: json['logLevel'] as String?,
    allowLan: json['allowLan'] as bool?,
    ipv6: json['ipv6'] as bool?,
    mixedPort: json['mixedPort'] as int?,
    tcpConcurrent: json['tcpConcurrent'] as bool?,
    findProcessMode: json['findProcessMode'] as String?,
  );
}

final class AppliedChange extends StateChange {
  const AppliedChange();
}

final class UnknownStateChange extends StateChange {
  const UnknownStateChange();
}

@immutable
class GeneralStateDto {
  final int seq;
  final GeneralChange general;
  final Map<String, String> selections;

  const GeneralStateDto({
    required this.seq,
    required this.general,
    required this.selections,
  });

  factory GeneralStateDto.fromJson(JsonMap json) => GeneralStateDto(
    seq: json['seq'] as int,
    general: GeneralChange.fromJson(json),
    selections: {
      for (final MapEntry(:key, :value) in _map(json['selections']).entries)
        key: value as String,
    },
  );
}

final class DialerLoopEvent extends CoreEventDto {
  final String name;

  const DialerLoopEvent(this.name);
}

/// What a MITM script posted with `$notification.post`.
final class ScriptNotificationEvent extends CoreEventDto {
  final String script;
  final String title;
  final String subtitle;
  final String body;
  final String url;

  const ScriptNotificationEvent({
    required this.script,
    required this.title,
    this.subtitle = '',
    this.body = '',
    this.url = '',
  });

  factory ScriptNotificationEvent.fromJson(JsonMap json) =>
      ScriptNotificationEvent(
        script: json['script'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        body: json['body'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  String get text =>
      [title, subtitle, body].where((part) => part.isNotEmpty).join('\n');
}

final class DelayEvent extends CoreEventDto {
  final DelayResult result;

  const DelayEvent(this.result);
}

final class UnknownCoreEvent extends CoreEventDto {
  const UnknownCoreEvent();
}

/// Marks a gap in `events.watch`: events were lost and state derived from them
/// must be read again.
final class EventsResynced extends CoreEventDto {
  const EventsResynced();
}
