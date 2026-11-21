import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart' as models;
import 'package:fl_clash/models/models.dart'
    show
        ConfigWarning,
        ConfigWarningLevel,
        ConnectionEnd,
        ConnectionFailure,
        ConnectionTiming,
        CoreCapabilities,
        CoreMemoryStats,
        Delay,
        DnsQuery,
        ExternalProvider,
        Group,
        Log,
        Metadata,
        Proxy,
        SubscriptionInfo,
        TrackerInfo,
        Traffic;

import 'core_api.dart';
import 'dto.dart';

Traffic trafficOf(int up, int down) => Traffic(up: up, down: down);

Delay delayOf(DelayResult result) =>
    Delay(name: result.name, url: result.url, value: result.value);

ConfigWarning warningOf(WarningInfo warning) => ConfigWarning(
  level: warning.level == 'warning'
      ? ConfigWarningLevel.warning
      : ConfigWarningLevel.info,
  path: warning.path,
  message: warning.message,
);

CoreCapabilities capabilitiesOf(CapabilitiesInfo info) => CoreCapabilities(
  implementation: info.implementation,
  version: info.version,
  proxyTypes: info.proxyTypes.toSet(),
  transports: info.transports.toSet(),
  ruleTypes: info.ruleTypes.toSet(),
  ssPlugins: info.ssPlugins.toSet(),
  congestionControllers: info.congestionControllers.toSet(),
);

CoreMemoryStats memoryOf(CoreStats stats) => CoreMemoryStats(rss: stats.rss);

Log logOf(LogEntry entry) => Log(
  logLevel: LogLevel.values.firstWhere(
    (level) => level.name == entry.level,
    orElse: () => LogLevel.info,
  ),
  payload: entry.text,
  dateTime: DateTime.fromMillisecondsSinceEpoch(entry.time).showFull,
);

DnsQuery dnsQueryOf(DnsEntry entry) => DnsQuery(
  id: entry.id,
  domain: entry.domain,
  type: entry.type,
  initiator: DnsQueryInitiator.values
      .where((value) => value.name == entry.initiator)
      .firstOrNull,
  upstream: entry.upstream,
  cached: entry.cached,
  answers: entry.answers,
  rcode: entry.rcode,
  error: entry.error,
  delay: entry.delay,
  time: DateTime.fromMillisecondsSinceEpoch(entry.time),
);

String _dnsModeName(DnsMode mode) => switch (mode) {
  DnsMode.fakeIp => 'fake-ip',
  DnsMode.redirHost => 'redir-host',
  _ => mode.name,
};

DnsMode? _dnsModeOf(String? name) =>
    DnsMode.values.where((mode) => _dnsModeName(mode) == name).firstOrNull;

TrackerInfo trackerOf(ConnectionInfo info) => TrackerInfo(
  id: info.id,
  upload: info.upload,
  download: info.download,
  start: DateTime.fromMillisecondsSinceEpoch(info.start),
  metadata: Metadata(
    uid: info.uid ?? 0,
    network: info.network,
    sourceIP: info.sourceIp,
    sourcePort: '${info.sourcePort}',
    destinationIP: info.destinationIp ?? '',
    destinationPort: '${info.destinationPort}',
    host: info.host ?? '',
    dnsMode: _dnsModeOf(info.dnsMode),
    process: info.process ?? '',
    processPath: info.processPath ?? '',
    remoteDestination: info.remoteDestination ?? '',
    sourceGeoIP: info.sourceGeoIp ?? const [],
    destinationGeoIP: info.destinationGeoIp ?? const [],
    destinationIPASN: info.destinationAsn ?? '',
    sourceIPASN: info.sourceAsn ?? '',
    specialRules: info.specialRules ?? '',
    specialProxy: info.specialProxy ?? '',
    mitm: info.mitm,
    mitmRefused: info.mitmRefused,
  ),
  chains: info.chains,
  rule: info.rule,
  rulePayload: info.rulePayload,
  ruleIndex: info.ruleIndex,
  dnsQueries: info.dnsQueries,
  failure: switch (info.failure) {
    final failure? => ConnectionFailure(
      kind:
          ConnectionFailureKind.values.asNameMap()[failure.kind] ??
          ConnectionFailureKind.other,
      message: failure.message,
    ),
    null => null,
  },
  timing: switch (info.timing) {
    final timing? => ConnectionTiming(
      accepted: DateTime.fromMillisecondsSinceEpoch(timing.accepted),
      dnsStart: timing.dnsStart,
      dnsEnd: timing.dnsEnd,
      routed: timing.routed,
      dialStart: timing.dialStart,
      connected: timing.connected,
      tls: timing.tls,
      dialEnd: timing.dialEnd,
      decrypted: timing.decrypted,
    ),
    null => null,
  },
);

ConnectionEnd connectionEndOf(ConnectionEndDto end) => ConnectionEnd(
  reason:
      ConnectionEndReason.values.asNameMap()[end.reason] ??
      ConnectionEndReason.error,
  endedAt: DateTime.fromMillisecondsSinceEpoch(end.endedAt),
  message: end.message,
);

models.MitmQueryPage mitmQueryPageOf(MitmQueryAnswer answer) =>
    models.MitmQueryPage(
      capturing: answer.capturing,
      since: switch (answer.since) {
        final since? => DateTime.parse(since),
        null => null,
      },
      version: answer.version,
      oldest: answer.oldest,
      held: answer.held,
      matched: answer.matched,
      exchanges: [
        for (final exchange in answer.exchanges)
          _mitmExchangeSummaryOf(exchange),
      ],
      next: answer.next,
      unmatched: answer.unmatched,
    );

models.MitmExchangeSummary _mitmExchangeSummaryOf(MitmExchangeSummaryDto dto) =>
    models.MitmExchangeSummary(
      id: dto.id,
      start: DateTime.parse(dto.start),
      pending: dto.pending,
      duration: dto.duration,
      method: dto.method,
      url: dto.url,
      status: dto.status,
      requestSize: dto.requestSize,
      responseSize: dto.responseSize,
      error: dto.error,
      host: dto.host,
      path: dto.path,
      contentType: dto.contentType,
      statusClass: dto.statusClass.wire,
      kind: dto.kind.name,
      rewritten: dto.rewritten,
      actionKinds: dto.actionKinds,
      answer: dto.answer,
      connectionId: dto.connectionId,
      app: switch (dto.app) {
        final app? => models.MitmApp(
          process: app.process,
          processPath: app.processPath,
          uid: app.uid,
        ),
        null => null,
      },
    );

ExternalProvider providerOf(ProviderInfo info) => ExternalProvider(
  name: info.name,
  type: info.type == ProviderKindDto.rule ? 'Rule' : 'Proxy',
  path: info.path,
  count: info.count,
  subscriptionInfo: switch (info.subscriptionInfo) {
    final subscription? => SubscriptionInfo(
      upload: subscription.upload,
      download: subscription.download,
      total: subscription.total,
      expire: subscription.expire,
    ),
    null => null,
  },
  vehicleType: info.vehicleType,
  updateAt: DateTime.fromMillisecondsSinceEpoch(info.updatedAt ?? 0),
);

models.RouteSnapshot routeSnapshotOf(RouteStampDto stamp) =>
    models.RouteSnapshot(
      coreEpoch: stamp.epoch,
      routeVersion: stamp.version,
      running: stamp.running,
    );

models.RouteHit routeHitOf(RouteHitDto hit) =>
    models.RouteHit(host: hit.host, proxy: hit.proxy, exit: hit.exit);

RouteHitDto routeHitDtoOf(models.RouteHit hit) =>
    RouteHitDto(host: hit.host, proxy: hit.proxy, exit: hit.exit);

models.RouteCheck routeCheckOf(RouteCheckResult result) => models.RouteCheck(
  coreEpoch: result.stamp.epoch,
  routeVersion: result.stamp.version,
  held: result.held,
);

models.OutboundIpResult outboundIpResultOf(OutboundIp result) =>
    models.OutboundIpResult(
      url: result.url,
      body: result.body,
      delay: result.delay,
      chains: result.chains,
      error: result.error,
      coreEpoch: result.stamp.epoch,
      routeVersion: result.stamp.version,
      hits: result.hits.map(routeHitOf).toList(),
      nodeHits: result.nodeHits.map(routeHitOf).toList(),
    );

models.ServiceCheckItem serviceCheckItemOf(ServiceItem item) =>
    models.ServiceCheckItem(
      name: item.name,
      status: item.status,
      region: item.region,
      ip: item.ip,
      delay: item.delay,
      chains: item.chains,
      checkedAt: item.checkedAt,
      coreEpoch: item.stamp.epoch,
      routeVersion: item.stamp.version,
      hits: item.hits.map(routeHitOf).toList(),
    );

models.ProfileBase profileBaseOf(ProfileInspect inspect) => models.ProfileBase(
  config: inspect.config,
  digest: inspect.digest,
  matchRules: inspect.matchRules,
  proxies: inspect.proxies,
  proxyGroups: inspect.proxyGroups,
  rules: inspect.rules,
);

CoreOptionsArg coreOptionsArgOf(models.CoreOptions options) => CoreOptionsArg(
  testUrl: options.testUrl,
  skipCertVerify: options.skipCertVerify,
  delayTestTimeout: options.delayTestTimeout,
  mitmCapture: options.mitmCapture,
);

/// Off is sent as an empty list, since a patch that left the field out would
/// keep a cross-origin grant in force.
ControllerCorsArg controllerCorsOf(bool allowed) => ControllerCorsArg(
  allowOrigins: allowed ? const ['*'] : const [],
  allowPrivateNetwork: allowed,
);

ExternalControllerStatus effectiveControllerOf(
  models.PatchClashConfig config, {
  required bool safeMode,
}) => safeMode || config.secret.isEmpty
    ? ExternalControllerStatus.close
    : config.externalController;

/// What a host-driven Core takes only from its host, never from a profile.
JsonMap hostSettingsOf(
  models.PatchClashConfig config, {
  required String credential,
  required bool safeMode,
}) => {
  'externalController': effectiveControllerOf(config, safeMode: safeMode).value,
  'secret': config.secret,
  'externalControllerCors': controllerCorsOf(
    config.externalControllerCors,
  ).toJson(),
  'hostCredential': credential,
};

/// What the general overrides leave of [config], as the live patch. A field
/// the user did not pick for override is left null so the profile keeps its own.
ConfigPatch configPatchOf(
  models.PatchClashConfig config, {
  required List<String> authentication,
  required String hostCredential,
  required models.CoreOptions options,
}) {
  T? picked<T>(GeneralOverrideKey key, T value) =>
      config.generalOverrideKeys.contains(key) ? value : null;
  return ConfigPatch(
    tun: TunPatchArg(
      enable: config.tun.enable,
      device: config.tun.device,
      autoRoute: true,
    ),
    allowLan: config.allowLan,
    mixedPort: config.mixedPort,
    findProcessMode: config.findProcessMode.name,
    mode: config.mode.name,
    logLevel: config.logLevel,
    ipv6: picked(GeneralOverrideKey.ipv6, config.ipv6),
    tcpConcurrent: picked(
      GeneralOverrideKey.tcpConcurrent,
      config.tcpConcurrent,
    ),
    externalController: config.externalController.value,
    secret: config.secret,
    externalControllerCors: controllerCorsOf(config.externalControllerCors),
    unifiedDelay: picked(GeneralOverrideKey.unifiedDelay, config.unifiedDelay),
    authentication: authentication,
    hostCredential: hostCredential,
    geoAutoUpdate: config.geoAutoUpdate,
    geoUpdateInterval: config.geoUpdateInterval,
    geoxUrl: config.geoXUrl.raw,
    options: coreOptionsArgOf(options),
  );
}

/// The groups of a proxy listing in display order, each with its members.
List<Group> groupsOf(ProxyGroupsDto data) {
  final nodes = {
    for (final node in data.nodes)
      node.name: Proxy(
        name: node.name,
        type: node.type,
        providerName: node.provider,
      ),
  };
  final infos = {for (final group in data.groups) group.name: group};
  Proxy? member(String name) {
    if (nodes[name] case final node?) {
      return node;
    }
    return switch (infos[name]) {
      final group? => Proxy(name: group.name, type: group.type, now: group.now),
      null => null,
    };
  }

  final groups = <Group>[];
  for (final name in data.order) {
    final info = infos[name];
    if (info == null) {
      continue;
    }
    final GroupType type;
    try {
      type = GroupType.parse(info.type);
    } on UnimplementedError {
      continue;
    }
    groups.add(
      Group(
        type: type,
        all: [for (final name in info.all ?? const <String>[]) ?member(name)],
        now: info.now,
        hidden: info.hidden,
        testUrl: info.testUrl.isEmpty ? null : info.testUrl,
        icon: info.icon,
        name: info.name,
      ),
    );
  }
  return groups;
}
