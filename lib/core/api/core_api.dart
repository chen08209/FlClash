import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';

import 'dto.dart';

/// The options `config.apply` and `config.patch` carry to the Core.
final class CoreOptionsArg {
  final String testUrl;
  final bool skipCertVerify;
  final int delayTestTimeout;
  final bool mitmCapture;

  const CoreOptionsArg({
    required this.testUrl,
    this.skipCertVerify = false,
    this.delayTestTimeout = 0,
    this.mitmCapture = false,
  });

  JsonMap toJson() => {
    'testUrl': testUrl,
    'skipCertVerify': skipCertVerify,
    'delayTestTimeout': delayTestTimeout,
    'mitmCapture': mitmCapture,
  };
}

final class TunPatchArg {
  final bool enable;
  final String? device;
  final bool? autoRoute;

  const TunPatchArg({required this.enable, this.device, this.autoRoute});

  JsonMap toJson() => {
    'enable': enable,
    'device': ?device,
    'autoRoute': ?autoRoute,
  };
}

final class ControllerCorsArg {
  final List<String> allowOrigins;
  final bool allowPrivateNetwork;

  const ControllerCorsArg({
    required this.allowOrigins,
    required this.allowPrivateNetwork,
  });

  JsonMap toJson() => {
    'allowOrigins': allowOrigins,
    'allowPrivateNetwork': allowPrivateNetwork,
  };
}

/// A field left null keeps the value in force.
final class ConfigPatch {
  final TunPatchArg? tun;
  final bool? allowLan;
  final int? mixedPort;
  final String? findProcessMode;
  final String? mode;
  final LogLevel? logLevel;
  final bool? ipv6;
  final bool? tcpConcurrent;
  final String? externalController;
  final String? secret;
  final ControllerCorsArg? externalControllerCors;
  final bool? unifiedDelay;
  final List<String>? authentication;
  final String? hostCredential;
  final bool? geoAutoUpdate;
  final int? geoUpdateInterval;
  final Map<String, String>? geoxUrl;
  final CoreOptionsArg? options;

  const ConfigPatch({
    this.tun,
    this.allowLan,
    this.mixedPort,
    this.findProcessMode,
    this.mode,
    this.logLevel,
    this.ipv6,
    this.tcpConcurrent,
    this.externalController,
    this.secret,
    this.externalControllerCors,
    this.unifiedDelay,
    this.authentication,
    this.hostCredential,
    this.geoAutoUpdate,
    this.geoUpdateInterval,
    this.geoxUrl,
    this.options,
  });

  JsonMap toJson() => {
    'tun': ?tun?.toJson(),
    'allowLan': ?allowLan,
    'mixedPort': ?mixedPort,
    'findProcessMode': ?findProcessMode,
    'mode': ?mode,
    'logLevel': ?logLevel?.name,
    'ipv6': ?ipv6,
    'tcpConcurrent': ?tcpConcurrent,
    'externalController': ?externalController,
    'secret': ?secret,
    'externalControllerCors': ?externalControllerCors?.toJson(),
    'unifiedDelay': ?unifiedDelay,
    'authentication': ?authentication,
    'hostCredential': ?hostCredential,
    'geoAutoUpdate': ?geoAutoUpdate,
    'geoUpdateInterval': ?geoUpdateInterval,
    if (geoxUrl != null && geoxUrl!.isNotEmpty) 'geoxUrl': geoxUrl,
    'options': ?options?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is ConfigPatch &&
      const DeepCollectionEquality().equals(toJson(), other.toJson());

  @override
  int get hashCode => const DeepCollectionEquality().hash(toJson());
}

sealed class ConnectionUpdate {
  const ConnectionUpdate();
}

/// The whole set, on subscribing and after a resync.
final class ConnectionsReset extends ConnectionUpdate {
  final ConnectionSnapshot snapshot;

  const ConnectionsReset(this.snapshot);
}

final class ConnectionsChanged extends ConnectionUpdate {
  final ConnectionDelta delta;

  const ConnectionsChanged(this.delta);
}

sealed class ProxyUpdate {
  const ProxyUpdate();
}

final class ProxiesReset extends ProxyUpdate {
  final ProxyGroupsDto groups;

  const ProxiesReset(this.groups);
}

final class ProxiesChanged extends ProxyUpdate {
  final ProxyDelta delta;

  const ProxiesChanged(this.delta);
}

typedef SelectResult = ({bool changed, int seq});

/// The Core as the app sees it: typed methods and streams, no transport.
/// A method answers its result or throws a `CoreMethodException` for what the
/// Core reports or a Core out of reach, and a `TimeoutException` for no answer
/// (the call is cancelled in the Core first). A stream is subscribed when
/// listened to and unsubscribed when cancelled; pausing it withholds credit, so
/// the Core stops producing for it.
abstract interface class CoreApi {
  Future<void> init({required String home, int? sdkInt});

  Future<void> releaseMemory();

  Future<CoreStats> stats();

  Future<CapabilitiesInfo> capabilities();

  Future<List<WarningInfo>> lastWarnings();

  Future<void> debugCrash();

  Future<EngineStatus> engineStatus();

  Stream<EngineStatus> watchEngineStatus();

  Future<void> startEngine();

  Future<void> stopEngine();

  /// A null [profilePath] applies the config.yaml already in the home directory.
  /// A null [host] keeps the host settings in force; [hostSettingsOf] makes one.
  Future<List<WarningInfo>> applyConfig({
    String? profilePath,
    JsonMap? overlay,
    Map<String, String> selection = const {},
    required CoreOptionsArg options,
    JsonMap? host,
  });

  /// Answers the `seq` of the change it made, or of the last change when it
  /// made none.
  Future<int> patchConfig(ConfigPatch patch);

  Future<GeneralStateDto> general();

  Future<List<IssueInfo>> validateConfig(String profilePath);

  Future<TextOutput> decryptConfig(
    String profilePath,
    String key, {
    String? outputFile,
  });

  Future<ConfigReadOutput> readConfig(String profilePath, {String? outputFile});

  Future<ProfileInspect> inspectProfile(String profilePath);

  Future<ProfileOutbounds> profileOutbounds(String profilePath);

  Future<TextOutput> buildProfile(
    String profilePath,
    JsonMap overlay, {
    String? outputFile,
  });

  Future<void> clearEffect(int profileId);

  Future<ProxyGroupsDto> proxyGroups();

  Stream<ProxyUpdate> watchProxies();

  Future<SelectResult> selectProxy(String group, String proxy);

  Future<JsonMap?> proxyDefinition(String name);

  Future<DelayResult> testDelay(String proxy, {String? url, int? timeout});

  Stream<DelayRunEvent> runDelays(
    List<String> proxies, {
    String? url,
    int? timeout,
    int? concurrency,
  });

  Future<Map<int, String>> validateProxies(List<JsonMap> proxies);

  Future<Map<int, String>> validateFilters(List<String> filters);

  Future<List<JsonMap>> convertSubscription(String profilePath);

  Future<List<String>> encodeLinks(List<JsonMap> proxies);

  Future<List<List<JsonMap>>> decodeLinks(List<String> lines);

  Future<List<ProviderInfo>> providers();

  Future<ProviderInfo?> provider(String name);

  Future<void> updateProvider(String name);

  Future<void> sideLoadProvider(String name, String data);

  Future<TextOutput> dumpRuleSet(String profilePath, {String? outputFile});

  Future<Object?> ruleList();

  Future<RuleSetInfoDto> compileRuleSet(String name, {String? url});

  Future<void> updateGeo(String kind);

  Stream<TrafficSample> watchTraffic({int? intervalMs, bool onlyProxy = false});

  Future<void> resetTraffic();

  Stream<ConnectionUpdate> watchConnections({
    int? maxBatchMs,
    bool counters = true,
  });

  Future<void> closeConnections({List<int>? ids});

  Future<void> resetNetwork();

  Future<void> updateNetwork({
    List<String>? dnsServers,
    bool interfaceChanged = false,
  });

  Future<void> clearDnsCache();

  Stream<List<LogEntry>> watchLogs({LogLevel level = LogLevel.debug});

  Stream<List<DnsEntry>> watchDns();

  Stream<RouteStampDto> watchRoute();

  Stream<List<CoreEventDto>> watchEvents({
    bool delays = false,
    bool state = false,
  });

  Future<RouteCheckResult> checkRoutes(
    List<List<RouteHitDto>> routes, {
    Duration? timeout,
  });

  Future<OutboundIp> outboundIp(
    String proxy,
    List<String> urls, {
    required int timeout,
    Duration? guard,
  });

  Future<List<ServiceItem>> checkServices(
    String proxy,
    List<String> names, {
    required int timeout,
    Duration? guard,
  });

  Future<JsonMap?> mitmCertificate();

  Future<JsonMap> generateMitmCertificate();

  Future<JsonMap> validateMitm(JsonMap config);

  Future<String> issueMitmCertificate(String host);

  Future<Object?> runMitmScript(String name, {Duration? guard});

  Future<Object?> mitmExchanges(int connectionId);

  Future<MitmQueryAnswer> mitmQuery({
    MitmFilter filter = const MitmFilter(),
    int? before,
    int? limit,
    int? since,
    bool facets = false,
    int? rateFrom,
  });

  Future<Object?> mitmExchange(int id);

  Future<Object?> mitmBody(int id, {required bool response});

  Future<JsonMap> readMitmModule(
    String text, {
    Map<String, String> arguments = const {},
    Map<String, String> attachments = const {},
    String language = '',
  });

  Future<JsonMap> mitmModuleStatus();

  Future<void> fetchMitmModule({String? name});
}
