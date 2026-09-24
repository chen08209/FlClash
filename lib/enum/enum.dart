// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:fl_clash/common/context.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/icons/icons.dart';
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

  static LoadBalanceStrategy? parse(String? value) {
    for (final item in values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
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

enum UsedProxy { GLOBAL, DIRECT, REJECT }

extension UsedProxyExtension on UsedProxy {
  static List<String> get valueList =>
      UsedProxy.values.map((e) => e.toString().split('.').last).toList();

  String get value => UsedProxyExtension.valueList[index];
}

enum Mode { rule, global, direct }

enum ViewMode { mobile, laptop, desktop }

enum LogLevel { debug, info, warning, error, silent }

enum RecordTone { muted, neutral, warning, error }

extension RecordToneExt on RecordTone {
  Color? accentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.warning => colorScheme.tertiary,
      RecordTone.error => colorScheme.error,
      RecordTone.muted || RecordTone.neutral => null,
    };
  }

  Color? tintColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.warning => colorScheme.tertiaryContainer.withValues(
        alpha: 0.2,
      ),
      RecordTone.error => colorScheme.errorContainer.withValues(alpha: 0.2),
      RecordTone.muted || RecordTone.neutral => null,
    };
  }

  Color labelColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.muted => colorScheme.outline,
      RecordTone.neutral => colorScheme.onSurfaceVariant,
      RecordTone.warning => colorScheme.onTertiaryContainer,
      RecordTone.error => colorScheme.onErrorContainer,
    };
  }

  Color labelContainerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.muted => colorScheme.surfaceContainerHigh,
      RecordTone.neutral => colorScheme.surfaceContainerHighest,
      RecordTone.warning => colorScheme.tertiaryContainer,
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
      _ => colorScheme.surfaceContainerHigh,
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
      MessageLevel.success => colorScheme.primary,
      MessageLevel.warning => colorScheme.tertiary,
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

enum NavigationItemMode { mobile, desktop, more }

enum Network { tcp, udp }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed, mips }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, name, time }

enum ProfileType { file, url }

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
  dns,
  loaded,
  crash,
  geoUpdate,
  routeChanged,
}

enum InvokeMessageType { protect, process }

enum FindProcessMode { always, off }

enum InterfaceNameMode { clear, follow, custom }

enum RestoreOption { all, onlyProfiles }

enum CommonCardType { plain, filled }

enum ProxiesType { tab, list }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { expand, shrink, min }

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

@JsonEnum(valueField: 'path')
enum DnsOverrideKey {
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

  final String path;

  static const fallbackFilterSection = 'fallback-filter';

  bool get isFallbackFilter => path.startsWith('$fallbackFilterSection.');

  String get jsonKey => isFallbackFilter
      ? path.substring(fallbackFilterSection.length + 1)
      : path;
}

@JsonEnum(valueField: 'path')
enum NtpOverrideKey {
  enable('enable'),
  server('server'),
  port('port'),
  interval('interval'),
  dialerProxy('dialer-proxy'),
  writeToSystem('write-to-system');

  const NtpOverrideKey(this.path);

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

enum FontFamily {
  twEmoji('Twemoji'),
  jetBrainsMono('JetBrainsMono');

  final String value;

  const FontFamily(this.value);
}

enum RouteMode { bypassPrivate, config }

enum AuthorizeCode { none, success, error }

enum TunAuthorizationState { none, authorized, unauthorized }

enum FunctionTag {
  updateConfig,
  setupConfig,
  updateGroups,
  applyProfile,
  savePreferences,
  changeProxy,
  handleWill,
  updateDelay,
  vpnTip,
  autoLaunch,
  updatePageIndex,
  pageChange,
  proxiesTabChange,
  logs,
  requests,
  dnsQueries,
  autoScrollToEnd,
  loadedProvider,
  saveSharedFile,
  removeProxy,
  suspend,
  coreErrorNotifier,
  reloadPackages,
}

enum DashboardWidget {
  networkSpeed,
  outboundMode,
  trafficUsage,
  networkDetection,
  tunButton(platforms: desktopPlatforms),
  vpnButton(platforms: [SupportPlatform.Android]),
  systemProxyButton(platforms: desktopPlatforms),
  intranetIp,
  memoryInfo,
  serviceStatus,
  dnsQueries,
  requests,
  connections,
  overrideDnsButton,
  overrideNtpButton,
  runTime,
  proxyGroups,
  profiles;

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

enum OverwriteType { standard, script, custom }

enum RuleTarget {
  DIRECT('DIRECT'),
  REJECT('REJECT'),
  REJECT_DROP('REJECT-DROP');

  final String value;

  const RuleTarget(this.value);

  static final List<String> baseTargetNames = List.unmodifiable(
    RuleTarget.values.map((item) => item.value),
  );

  static final Set<String> baseTargets = Set.unmodifiable(baseTargetNames);
}

enum ProviderKind { proxy, rule }

/// Where a provider name a custom overwrite uses resolves, in lookup order.
enum ProviderSource { subscription, profile, app }

enum RuleProviderBehavior { domain, ipcidr, classical }

enum RuleProviderFormat { yaml, text, mrs }

extension RuleProviderFormatExt on RuleProviderFormat? {
  /// The core reads an mrs set only as a domain or an ipcidr one.
  List<RuleProviderBehavior> get behaviors => this == RuleProviderFormat.mrs
      ? const [RuleProviderBehavior.domain, RuleProviderBehavior.ipcidr]
      : RuleProviderBehavior.values;
}

enum RestoreStrategy { compatible, override }

enum TabAnimation { slide, fade }

enum Language { yaml, javaScript, json }

enum ScrollPositionCacheKey { tools, profiles, proxiesList, proxiesTabList }

enum QueryTag { proxies, access }

enum LoadingTag {
  profiles,
  scripts,
  backup_restore,
  access,
  proxies,
  batteryOptimization,
  checkUpdate,
}

enum CoreStatus { connecting, connected, disconnected }

enum UpdatingScope { core, local }

enum RuleScene { added, disabled, custom }

enum ItemPosition {
  start,
  middle,
  end,
  startAndEnd;

  static ItemPosition get(int index, int length) {
    ItemPosition position = ItemPosition.middle;
    if (length == 1) {
      position = ItemPosition.startAndEnd;
    } else if (index == length - 1) {
      position = ItemPosition.end;
    } else if (index == 0) {
      position = ItemPosition.start;
    }
    return position;
  }

  static ItemPosition calculateVisualPosition<T>(
    int currentIndex,
    List<T> items,
    Set<T> deletedItems,
  ) {
    if (deletedItems.isEmpty) {
      return ItemPosition.get(currentIndex, items.length);
    }
    final currentItem = items[currentIndex];
    if (deletedItems.contains(currentItem)) {
      return ItemPosition.middle;
    }
    final int visualLength = items.length - deletedItems.length;
    if (visualLength <= 0) return ItemPosition.middle;
    int deletedCountBeforeMe = 0;
    for (int i = 0; i < currentIndex; i++) {
      if (deletedItems.contains(items[i])) {
        deletedCountBeforeMe++;
      }
    }
    final int visualIndex = currentIndex - deletedCountBeforeMe;
    return ItemPosition.get(visualIndex, visualLength);
  }
}
