// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:fl_clash/common/context.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/ui/color.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum SupportPlatform {
  Windows,
  MacOS,
  Linux,
  Android;

  static SupportPlatform get currentPlatform {
    if (system.isWindows) {
      return SupportPlatform.Windows;
    } else if (system.isMacOS) {
      return SupportPlatform.MacOS;
    } else if (Platform.isLinux) {
      return SupportPlatform.Linux;
    } else if (system.isAndroid) {
      return SupportPlatform.Android;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

const desktopPlatforms = [
  SupportPlatform.Linux,
  SupportPlatform.MacOS,
  SupportPlatform.Windows,
];

enum GroupName { GLOBAL }

enum GroupType {
  @JsonValue('select')
  Selector('select'),
  @JsonValue('url-test')
  URLTest('url-test'),
  @JsonValue('fallback')
  Fallback('fallback'),
  @JsonValue('load-balance')
  LoadBalance('load-balance'),
  @JsonValue('relay')
  Relay('relay');

  final String value;

  const GroupType(this.value);

  static GroupType parse(String type) {
    return switch (type.toLowerCase()) {
      'url-test' || 'urltest' => URLTest,
      'select' || 'selector' => Selector,
      'fallback' => Fallback,
      'load-balance' || 'loadbalance' => LoadBalance,
      'relay' => Relay,
      String() => throw UnimplementedError(),
    };
  }

  /// The core refuses a relay group, so it stays parseable but unofferable.
  static List<GroupType> get selectableValues =>
      values.where((item) => item != Relay).toList();
}

enum LoadBalanceStrategy {
  @JsonValue('consistent-hashing')
  consistentHashing('consistent-hashing'),
  @JsonValue('round-robin')
  roundRobin('round-robin'),
  @JsonValue('sticky-sessions')
  stickySessions('sticky-sessions');

  final String value;

  const LoadBalanceStrategy(this.value);
}

enum IpVersion {
  dual('dual'),
  ipv4('ipv4'),
  ipv6('ipv6'),
  @JsonValue('ipv4-prefer')
  ipv4Prefer('ipv4-prefer'),
  @JsonValue('ipv6-prefer')
  ipv6Prefer('ipv6-prefer');

  final String value;

  const IpVersion(this.value);
}

extension GroupTypeExtension on GroupType {
  static List<String> get valueList =>
      GroupType.values.map((e) => e.toString().split('.').last).toList();

  bool get isComputedSelected {
    return [GroupType.URLTest, GroupType.Fallback].contains(this);
  }

  static GroupType? getGroupType(String value) {
    final index = GroupTypeExtension.valueList.indexOf(value);
    if (index == -1) return null;
    return GroupType.values[index];
  }
}

enum DelayTestPhase { queued, running }

enum Mode { rule, global, direct }

enum ViewMode { mobile, laptop, desktop }

enum LogLevel { debug, info, warning, error, silent }

enum RecordTone { neutral, warning, error }

extension RecordToneExt on RecordTone {
  Color? accentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.warning => colorScheme.warning,
      RecordTone.error => colorScheme.error,
      RecordTone.neutral => null,
    };
  }

  Color labelColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.neutral => colorScheme.onSurfaceVariant,
      RecordTone.warning => colorScheme.onWarningContainer,
      RecordTone.error => colorScheme.onErrorContainer,
    };
  }

  Color labelContainerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.neutral => context.raisedSurfaceLevel.colorOf(colorScheme),
      RecordTone.warning => colorScheme.warningContainer,
      RecordTone.error => colorScheme.errorContainer,
    };
  }
}

enum MessageLevel { info, success, warning, error }

extension MessageLevelExt on MessageLevel {
  Glyph? get glyph {
    return switch (this) {
      MessageLevel.info => null,
      MessageLevel.success => AppGlyphs.checkCircle,
      MessageLevel.warning => AppGlyphs.warning,
      MessageLevel.error => AppGlyphs.error,
    };
  }

  Color containerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      MessageLevel.error => colorScheme.errorContainer,
      _ => SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme),
    };
  }

  Color contentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      MessageLevel.error => colorScheme.onErrorContainer,
      _ => colorScheme.onSurfaceVariant,
    };
  }

  Color iconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      MessageLevel.info => colorScheme.onSurfaceVariant,
      MessageLevel.success => colorScheme.success,
      MessageLevel.warning => colorScheme.warning,
      MessageLevel.error => colorScheme.onErrorContainer,
    };
  }

  Duration get duration {
    return switch (this) {
      MessageLevel.info || MessageLevel.success => const Duration(seconds: 3),
      MessageLevel.warning => const Duration(seconds: 5),
      MessageLevel.error => const Duration(seconds: 6),
    };
  }
}

enum TrafficUnit { B, KB, MB, GB, TB }

enum NavigationItemMode { mobile, desktop, more, moreFull }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed, mips }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, name, time }

enum ProfileType { file, url, custom }

enum ResultType {
  @JsonValue(0)
  success,
  @JsonValue(-1)
  error,
}

enum CoreEventType {
  log,
  delay,
  request,
  requestTraffic,
  dns,
  loaded,
  crash,
  geoUpdate,
  routeChanged,
  dialerLoop,
}

enum FindProcessMode { always, off }

enum InterfaceNameMode { clear, follow, custom }

enum RestoreOption { all, onlyProfiles }

enum ProxiesType { tab, list }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { loose, standard, compact }

enum DnsMode {
  normal,
  @JsonValue('fake-ip')
  fakeIp,
  @JsonValue('redir-host')
  redirHost,
  hosts,
}

enum DnsCacheAlgorithm { lru, arc }

enum FakeIpFilterMode { blacklist, whitelist, rule }

mixin OverrideKey on Enum {
  String get path;

  String? get parent {
    final dot = path.indexOf('.');
    return dot < 0 ? null : path.substring(0, dot);
  }

  String get field => path.substring(path.indexOf('.') + 1);
}

@JsonEnum(valueField: 'path')
enum DnsOverrideKey with OverrideKey {
  enable('enable'),
  listen('listen'),
  listenRoutingMark('listen-routing-mark'),
  useHosts('use-hosts'),
  useSystemHosts('use-system-hosts'),
  ipv6('ipv6'),
  ipv6Timeout('ipv6-timeout'),
  respectRules('respect-rules'),
  preferH3('prefer-h3'),
  cacheAlgorithm('cache-algorithm'),
  cacheMaxSize('cache-max-size'),
  enhancedMode('enhanced-mode'),
  fakeIpRange('fake-ip-range'),
  fakeIpRange6('fake-ip-range6'),
  fakeIpFilter('fake-ip-filter'),
  fakeIpFilterMode('fake-ip-filter-mode'),
  fakeIpTtl('fake-ip-ttl'),
  defaultNameserver('default-nameserver'),
  nameserverPolicy('nameserver-policy'),
  nameserver('nameserver'),
  fallback('fallback'),
  fallbackLazyQuery('fallback-lazy-query'),
  proxyServerNameserver('proxy-server-nameserver'),
  proxyServerNameserverPolicy('proxy-server-nameserver-policy'),
  directNameserver('direct-nameserver'),
  directNameserverFollowPolicy('direct-nameserver-follow-policy'),
  fallbackFilterGeoip('fallback-filter.geoip'),
  fallbackFilterGeoipCode('fallback-filter.geoip-code'),
  fallbackFilterGeosite('fallback-filter.geosite'),
  fallbackFilterIpcidr('fallback-filter.ipcidr'),
  fallbackFilterDomain('fallback-filter.domain');

  const DnsOverrideKey(this.path);

  @override
  final String path;

  static const fallbackFilterSection = 'fallback-filter';

  /// What a subscription or file profile may override: nothing that names its
  /// groups or rule sets, which change with every update.
  static const normalProfileKeys = {
    listen,
    ipv6,
    enhancedMode,
    fakeIpFilter,
    fakeIpFilterMode,
    defaultNameserver,
    nameserver,
    fallback,
    proxyServerNameserver,
    directNameserver,
  };
}

@JsonEnum(valueField: 'path')
enum NtpOverrideKey with OverrideKey {
  enable('enable'),
  server('server'),
  port('port'),
  interval('interval'),
  dialerProxy('dialer-proxy'),
  writeToSystem('write-to-system');

  const NtpOverrideKey(this.path);

  @override
  final String path;
}

@JsonEnum(valueField: 'path')
enum SnifferOverrideKey with OverrideKey {
  enable('enable'),
  overrideDest('override-destination'),
  forceDnsMapping('force-dns-mapping'),
  parsePureIp('parse-pure-ip'),
  forceDomain('force-domain'),
  skipDomain('skip-domain'),
  skipSrcAddress('skip-src-address'),
  skipDstAddress('skip-dst-address'),
  sniffHttp('sniff.HTTP'),
  sniffTls('sniff.TLS'),
  sniffQuic('sniff.QUIC');

  const SnifferOverrideKey(this.path);

  @override
  final String path;

  static const sniffSection = 'sniff';
}

/// Written over the profile's `tun` section, which Android's VPN never reads,
/// so these apply on desktop only, beside the keys of `Tun.coreJson`.
@JsonEnum(valueField: 'path')
enum TunOverrideKey with OverrideKey {
  mtu('mtu'),
  congestionController('congestion-controller'),
  strictRoute('strict-route'),
  routeAddress('route-address'),
  routeExcludeAddress('route-exclude-address'),
  dnsHijack('dns-hijack'),
  udpTimeout('udp-timeout'),
  disableIcmpForwarding('disable-icmp-forwarding'),
  gso('gso'),
  includeInterface('include-interface'),
  excludeInterface('exclude-interface'),
  includeUid('include-uid'),
  excludeUid('exclude-uid'),
  excludeSrcPort('exclude-src-port'),
  excludeDstPort('exclude-dst-port');

  const TunOverrideKey(this.path);

  @override
  final String path;
}

enum ExternalControllerStatus {
  @JsonValue('')
  close(''),
  @JsonValue('127.0.0.1:9090')
  open('127.0.0.1:9090');

  final String value;

  const ExternalControllerStatus(this.value);
}

enum KeyboardModifier {
  alt([PhysicalKeyboardKey.altLeft, PhysicalKeyboardKey.altRight]),
  capsLock([PhysicalKeyboardKey.capsLock]),
  control([PhysicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlRight]),
  fn([PhysicalKeyboardKey.fn]),
  meta([PhysicalKeyboardKey.metaLeft, PhysicalKeyboardKey.metaRight]),
  shift([PhysicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftRight]);

  final List<PhysicalKeyboardKey> physicalKeys;

  const KeyboardModifier(this.physicalKeys);
}

enum HotAction {
  start,
  view,
  mode,
  proxy,
  tun,
  ruleMode,
  globalMode,
  directMode,
  delayTest,
  updateProfiles,
  copyEnv,
  exit,
}

enum ProxiesIconStyle { filled, plain, hidden }

enum EditorFontSize {
  standard(16),
  large(18),
  extraLarge(20);

  final double value;

  const EditorFontSize(this.value);
}

enum AuthorizeCode { none, success, error }

enum TunAuthorizationState { none, authorized, unauthorized }

enum FunctionTag {
  updateConfig,
  updateGroups,
  applyProfile,
  savePreferences,
  changeProxy,
  updateDelay,
  autoLaunch,
  logs,
  requests,
  dnsQueries,
  loadedProvider,
  saveSharedFile,
  suspend,
  coreErrorNotifier,
  dialerLoopNotifier,
  reloadPackages,
}

enum DashboardWidget {
  currentOutbound,
  networkSpeed,
  outboundMode,
  vpnButton(platforms: [SupportPlatform.Android]),
  networkTakeover(platforms: desktopPlatforms),
  serviceStatus,
  profiles,
  proxyGroups,
  connectionStats,
  intranetIp,
  memoryInfo;

  final List<SupportPlatform> platforms;

  const DashboardWidget({this.platforms = SupportPlatform.values});
}

enum DnsQueryInitiator { app, rule, direct, proxy, other }

enum IpType { residential, mobile, business, hosting }

enum IpQualityLevel { good, normal, risky }

enum IpQualitySource {
  identMe('ident.me'),
  ipApiCom('ip-api.com'),
  ipQuery('ipquery.io'),
  ipLocate('iplocate.io'),
  proxyCheck('proxycheck.io'),
  ipApiIs('ipapi.is');

  const IpQualitySource(this.label);

  final String label;
}

enum IpQualitySourceStatus { noType, timeout, rateLimited, failed, ipMismatch }

enum GeodataLoader { standard, memconservative }

enum GeoResource {
  @JsonValue('mmdb')
  MMDB,
  @JsonValue('asn')
  ASN,
  @JsonValue('geoip')
  GEOIP,
  @JsonValue('geosite')
  GEOSITE;

  static GeoResource fromJson(String value) {
    return switch (value) {
      'mmdb' => GeoResource.MMDB,
      'asn' => GeoResource.ASN,
      'geo-ip' || 'geoip' => GeoResource.GEOIP,
      'geo-site' || 'geosite' => GeoResource.GEOSITE,
      _ => throw ArgumentError.value(value, 'value', 'Invalid geo resource'),
    };
  }
}

extension GeoResourceExt on GeoResource {
  String get configKey {
    return switch (this) {
      GeoResource.MMDB => 'mmdb',
      GeoResource.ASN => 'asn',
      GeoResource.GEOIP => 'geoip',
      GeoResource.GEOSITE => 'geosite',
    };
  }

  String get updatingKey => 'geo_resource_$name';
}

enum PageLabel {
  dashboard,
  proxies,
  profiles,
  tools,
  logs,
  requests,
  resources,
  connections,
  dns,
}

enum RuleAction {
  DOMAIN('DOMAIN'),
  DOMAIN_SUFFIX('DOMAIN-SUFFIX'),
  DOMAIN_KEYWORD('DOMAIN-KEYWORD'),
  DOMAIN_REGEX('DOMAIN-REGEX'),
  DOMAIN_WILDCARD('DOMAIN-WILDCARD'),
  GEOSITE('GEOSITE'),
  IP_CIDR('IP-CIDR'),
  IP_CIDR6('IP-CIDR6'),
  IP_SUFFIX('IP-SUFFIX'),
  IP_ASN('IP-ASN'),
  GEOIP('GEOIP'),
  SRC_GEOIP('SRC-GEOIP'),
  SRC_IP_ASN('SRC-IP-ASN'),
  SRC_IP_CIDR('SRC-IP-CIDR'),
  SRC_IP_SUFFIX('SRC-IP-SUFFIX'),
  DST_PORT('DST-PORT'),
  SRC_PORT('SRC-PORT'),
  IN_PORT('IN-PORT'),
  IN_TYPE('IN-TYPE'),
  IN_USER('IN-USER'),
  IN_NAME('IN-NAME'),
  REMATCH_NAME('REMATCH-NAME'),
  PROCESS_PATH('PROCESS-PATH'),
  PROCESS_PATH_REGEX('PROCESS-PATH-REGEX'),
  PROCESS_PATH_WILDCARD('PROCESS-PATH-WILDCARD'),
  PROCESS_NAME('PROCESS-NAME'),
  PROCESS_NAME_REGEX('PROCESS-NAME-REGEX'),
  PROCESS_NAME_WILDCARD('PROCESS-NAME-WILDCARD'),
  UID('UID'),
  NETWORK('NETWORK'),
  DSCP('DSCP'),
  RULE_SET('RULE-SET'),
  AND('AND'),
  OR('OR'),
  NOT('NOT'),
  SUB_RULE('SUB-RULE'),
  MATCH('MATCH');

  final String value;

  const RuleAction(this.value);

  static List<RuleAction> get addedRuleActions {
    return RuleAction.values
        .where(
          (item) => ![
            RuleAction.MATCH,
            RuleAction.RULE_SET,
            RuleAction.SUB_RULE,
          ].contains(item),
        )
        .toList();
  }
}

extension RuleActionExt on RuleAction {
  bool get hasParams => [
    RuleAction.GEOIP,
    RuleAction.IP_ASN,
    RuleAction.IP_CIDR,
    RuleAction.IP_CIDR6,
    RuleAction.IP_SUFFIX,
    RuleAction.RULE_SET,
  ].contains(this);

  bool get nestsRules => [
    RuleAction.AND,
    RuleAction.OR,
    RuleAction.NOT,
    RuleAction.SUB_RULE,
  ].contains(this);

  bool get hasCommaPayload => [
    RuleAction.AND,
    RuleAction.OR,
    RuleAction.NOT,
    RuleAction.SUB_RULE,
    RuleAction.DOMAIN_REGEX,
    RuleAction.PROCESS_NAME_REGEX,
    RuleAction.PROCESS_PATH_REGEX,
  ].contains(this);

  String getDesc(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return switch (this) {
      RuleAction.DOMAIN => appLocalizations.ruleActionDomainDesc,
      RuleAction.DOMAIN_SUFFIX => appLocalizations.ruleActionDomainSuffixDesc,
      RuleAction.DOMAIN_KEYWORD => appLocalizations.ruleActionDomainKeywordDesc,
      RuleAction.DOMAIN_REGEX => appLocalizations.ruleActionDomainRegexDesc,
      RuleAction.DOMAIN_WILDCARD =>
        appLocalizations.ruleActionDomainWildcardDesc,
      RuleAction.GEOSITE => appLocalizations.ruleActionGeositeDesc,
      RuleAction.IP_CIDR => appLocalizations.ruleActionIpCidrDesc,
      RuleAction.IP_CIDR6 => appLocalizations.ruleActionIpCidr6Desc,
      RuleAction.IP_SUFFIX => appLocalizations.ruleActionIpSuffixDesc,
      RuleAction.IP_ASN => appLocalizations.ruleActionIpAsnDesc,
      RuleAction.GEOIP => appLocalizations.ruleActionGeoipDesc,
      RuleAction.SRC_GEOIP => appLocalizations.ruleActionSrcGeoipDesc,
      RuleAction.SRC_IP_ASN => appLocalizations.ruleActionSrcIpAsnDesc,
      RuleAction.SRC_IP_CIDR => appLocalizations.ruleActionSrcIpCidrDesc,
      RuleAction.SRC_IP_SUFFIX => appLocalizations.ruleActionSrcIpSuffixDesc,
      RuleAction.DST_PORT => appLocalizations.ruleActionDstPortDesc,
      RuleAction.SRC_PORT => appLocalizations.ruleActionSrcPortDesc,
      RuleAction.IN_PORT => appLocalizations.ruleActionInPortDesc,
      RuleAction.IN_TYPE => appLocalizations.ruleActionInTypeDesc,
      RuleAction.IN_USER => appLocalizations.ruleActionInUserDesc,
      RuleAction.IN_NAME => appLocalizations.ruleActionInNameDesc,
      RuleAction.REMATCH_NAME => appLocalizations.ruleActionRematchNameDesc,
      RuleAction.PROCESS_PATH => appLocalizations.ruleActionProcessPathDesc,
      RuleAction.PROCESS_PATH_REGEX =>
        appLocalizations.ruleActionProcessPathRegexDesc,
      RuleAction.PROCESS_PATH_WILDCARD =>
        appLocalizations.ruleActionProcessPathWildcardDesc,
      RuleAction.PROCESS_NAME => appLocalizations.ruleActionProcessNameDesc,
      RuleAction.PROCESS_NAME_REGEX =>
        appLocalizations.ruleActionProcessNameRegexDesc,
      RuleAction.PROCESS_NAME_WILDCARD =>
        appLocalizations.ruleActionProcessNameWildcardDesc,
      RuleAction.UID => appLocalizations.ruleActionUidDesc,
      RuleAction.NETWORK => appLocalizations.ruleActionNetworkDesc,
      RuleAction.DSCP => appLocalizations.ruleActionDscpDesc,
      RuleAction.RULE_SET => appLocalizations.ruleActionRuleSetDesc,
      RuleAction.AND => appLocalizations.ruleActionAndDesc,
      RuleAction.OR => appLocalizations.ruleActionOrDesc,
      RuleAction.NOT => appLocalizations.ruleActionNotDesc,
      RuleAction.SUB_RULE => appLocalizations.ruleActionSubRuleDesc,
      RuleAction.MATCH => appLocalizations.ruleActionMatchDesc,
    };
  }
}

enum ProxyFieldKind { text, secret, number, toggle, choice, list, map }

/// A key of a proxy definition the form edits, at [path] since the core reads
/// transport, TLS and plugin settings from maps of their own.
enum ProxyField {
  username(['username']),
  password(['password'], ProxyFieldKind.secret),
  uuid(['uuid']),
  psk(['psk'], ProxyFieldKind.secret),
  key(['key'], ProxyFieldKind.secret),
  privateKey(['private-key'], ProxyFieldKind.secret),
  publicKey(['public-key']),
  privateKeyPassphrase(['private-key-passphrase'], ProxyFieldKind.secret),
  preSharedKey(['pre-shared-key'], ProxyFieldKind.secret),
  authStr(['auth-str'], ProxyFieldKind.secret),
  cipher(['cipher'], ProxyFieldKind.choice),
  alterId(['alterId'], ProxyFieldKind.number),
  protocol(['protocol'], ProxyFieldKind.choice),
  obfs(['obfs'], ProxyFieldKind.choice),
  transport(['transport'], ProxyFieldKind.choice),
  up(['up']),
  down(['down']),
  network(['network'], ProxyFieldKind.choice),
  flow(['flow'], ProxyFieldKind.choice),
  wsPath(['ws-opts', 'path']),
  wsHost(['ws-opts', 'headers', 'Host']),
  wsHeaders(['ws-opts', 'headers'], ProxyFieldKind.map),
  wsMaxEarlyData(['ws-opts', 'max-early-data'], ProxyFieldKind.number),
  wsEarlyDataHeaderName(['ws-opts', 'early-data-header-name']),
  wsHttpUpgrade(['ws-opts', 'v2ray-http-upgrade'], ProxyFieldKind.toggle),
  wsHttpUpgradeFastOpen([
    'ws-opts',
    'v2ray-http-upgrade-fast-open',
  ], ProxyFieldKind.toggle),
  httpMethod(['http-opts', 'method']),
  httpPath(['http-opts', 'path'], ProxyFieldKind.list),
  httpHost(['http-opts', 'headers', 'Host'], ProxyFieldKind.list),
  httpHeaders(['http-opts', 'headers'], ProxyFieldKind.map),
  h2Host(['h2-opts', 'host'], ProxyFieldKind.list),
  h2Path(['h2-opts', 'path']),
  grpcServiceName(['grpc-opts', 'grpc-service-name']),
  xhttpPath(['xhttp-opts', 'path']),
  xhttpHost(['xhttp-opts', 'host']),
  mkcpSeed(['mkcp-opts', 'seed'], ProxyFieldKind.secret),
  mkcpHeader(['mkcp-opts', 'header'], ProxyFieldKind.choice),
  mekyaUrl(['mekya-opts', 'url']),
  headers(['headers'], ProxyFieldKind.map),
  tls(['tls'], ProxyFieldKind.toggle),
  sni(['sni']),
  servername(['servername']),
  alpn(['alpn'], ProxyFieldKind.list),
  skipCertVerify(['skip-cert-verify'], ProxyFieldKind.toggle),
  clientFingerprint(['client-fingerprint'], ProxyFieldKind.choice),
  realityPublicKey(['reality-opts', 'public-key']),
  realityShortId(['reality-opts', 'short-id']),
  plugin(['plugin'], ProxyFieldKind.choice),
  pluginMode(['plugin-opts', 'mode']),
  pluginHost(['plugin-opts', 'host']),
  pluginPath(['plugin-opts', 'path']),
  pluginUsername(['plugin-opts', 'username']),
  pluginPassword(['plugin-opts', 'password'], ProxyFieldKind.secret),
  pluginVersion(['plugin-opts', 'version'], ProxyFieldKind.number),
  pluginVersionHint(['plugin-opts', 'version-hint'], ProxyFieldKind.choice),
  pluginRestlsScript(['plugin-opts', 'restls-script']),
  pluginKey(['plugin-opts', 'key'], ProxyFieldKind.secret),
  pluginCrypt(['plugin-opts', 'crypt'], ProxyFieldKind.choice),
  pluginTls(['plugin-opts', 'tls'], ProxyFieldKind.toggle),
  pluginMux(['plugin-opts', 'mux'], ProxyFieldKind.toggle),
  pluginSkipCertVerify([
    'plugin-opts',
    'skip-cert-verify',
  ], ProxyFieldKind.toggle),
  udpOverTcp(['udp-over-tcp'], ProxyFieldKind.toggle),
  protocolParam(['protocol-param']),
  obfsParam(['obfs-param']),
  obfsPassword(['obfs-password'], ProxyFieldKind.secret),
  obfsSecret(['obfs'], ProxyFieldKind.secret),
  obfsMode(['obfs-opts', 'mode'], ProxyFieldKind.choice),
  obfsHost(['obfs-opts', 'host']),
  version(['version'], ProxyFieldKind.number),
  ports(['ports']),
  hopInterval(['hop-interval']),
  congestionController(['congestion-controller'], ProxyFieldKind.choice),
  udpRelayMode(['udp-relay-mode'], ProxyFieldKind.choice),
  reduceRtt(['reduce-rtt'], ProxyFieldKind.toggle),
  ip(['ip']),
  ipv6(['ipv6']),
  allowedIps(['allowed-ips'], ProxyFieldKind.list),
  dns(['dns'], ProxyFieldKind.list),
  remoteDnsResolve(['remote-dns-resolve'], ProxyFieldKind.toggle),
  mtu(['mtu'], ProxyFieldKind.number),
  tfo(['tfo'], ProxyFieldKind.toggle),
  mptcp(['mptcp'], ProxyFieldKind.toggle),
  interfaceName(['interface-name']),
  routingMark(['routing-mark'], ProxyFieldKind.number),
  ipVersion(['ip-version'], ProxyFieldKind.choice);

  final List<String> path;
  final ProxyFieldKind kind;

  const ProxyField(this.path, [this.kind = ProxyFieldKind.text]);
}

enum RulePayloadError { network, numberRange, dscpRange }

extension RulePayloadErrorExt on RulePayloadError {
  String getMessage(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return switch (this) {
      RulePayloadError.network => appLocalizations.invalidNetworkContent,
      RulePayloadError.numberRange => appLocalizations.invalidRangeContent,
      RulePayloadError.dscpRange => appLocalizations.invalidDscpContent,
    };
  }
}

enum ExtendType { standard, script }

enum RuleTarget {
  DIRECT('DIRECT'),
  REJECT('REJECT'),
  REJECT_DROP('REJECT-DROP'),
  PASS('PASS'),
  PASS_RULE('PASS-RULE'),
  COMPATIBLE('COMPATIBLE');

  final String value;

  const RuleTarget(this.value);

  static final List<String> baseTargetNames = List.unmodifiable(
    RuleTarget.values.map((item) => item.value),
  );

  static final Set<String> baseTargets = Set.unmodifiable(baseTargetNames);

  /// The core adds GLOBAL only after it parses the groups, so a rule, a dialer
  /// or a DNS server may name it while a group may not.
  static final List<String> ruleTargetNames = List.unmodifiable([
    ...baseTargetNames,
    GroupName.GLOBAL.name,
  ]);

  static final Set<String> ruleTargets = Set.unmodifiable(ruleTargetNames);
}

enum ProviderKind { proxy, rule }

enum RuleProviderBehavior { domain, ipcidr, classical }

enum RuleProviderFormat { yaml, text, mrs }

enum RestoreStrategy { compatible, override }

enum TabAnimation { slide, fade }

enum LiquidGlassMode { none, standard, ultra }

enum Language { yaml, javaScript, json }

enum ScrollPositionCacheKey { proxiesTabList }

enum QueryTag { proxies, access }

enum LoadingTag {
  profiles,
  scripts,
  ruleProviders,
  iconSets,
  backup_restore,
  access,
  proxies,
  checkUpdate,
}

enum CoreStatus { connecting, connected, disconnected }

enum UpdatingScope { core, local }
