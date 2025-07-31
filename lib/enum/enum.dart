// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:fl_clash/common/color.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/views/dashboard/widgets/widgets.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

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
    throw 'invalid platform';
  }
}

const desktopPlatforms = [
  SupportPlatform.Linux,
  SupportPlatform.MacOS,
  SupportPlatform.Windows,
];

enum GroupType {
  Selector,
  URLTest,
  Fallback,
  LoadBalance,
  Relay;

  static GroupType parseProfileType(String type) {
    return switch (type) {
      'url-test' => URLTest,
      'select' => Selector,
      'fallback' => Fallback,
      'load-balance' => LoadBalance,
      'relay' => Relay,
      String() => throw UnimplementedError(),
    };
  }
}

enum GroupName { GLOBAL, Proxy, Auto, Fallback }

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

  String get value => GroupTypeExtension.valueList[index];
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

extension LogLevelExt on LogLevel {
  Color? get color {
    return switch (this) {
      LogLevel.silent => Colors.grey.shade700,
      LogLevel.debug => Colors.grey.shade400,
      LogLevel.info => null,
      LogLevel.warning => Colors.orangeAccent.darken(),
      LogLevel.error => Colors.redAccent,
    };
  }
}

enum TransportProtocol { udp, tcp }

enum TrafficUnit { B, KB, MB, GB, TB }

enum NavigationItemMode { mobile, desktop, more }

enum Network { tcp, udp }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, name, time }

enum ProfileType { file, url }

enum ResultType {
  @JsonValue(0)
  success,
  @JsonValue(-1)
  error,
}

enum CoreEventType { log, delay, request, loaded, crash }

enum InvokeMessageType { protect, process }

enum FindProcessMode { always, off }

enum RecoveryOption { all, onlyProfiles }

enum ChipType { action, delete }

enum CommonCardType { plain, filled }
//
// extension CommonCardTypeExt on CommonCardType {
//   CommonCardType get variant => CommonCardType.plain;
// }

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

extension KeyboardModifierExt on KeyboardModifier {
  HotKeyModifier toHotKeyModifier() {
    return switch (this) {
      KeyboardModifier.alt => HotKeyModifier.alt,
      KeyboardModifier.capsLock => HotKeyModifier.capsLock,
      KeyboardModifier.control => HotKeyModifier.control,
      KeyboardModifier.fn => HotKeyModifier.fn,
      KeyboardModifier.meta => HotKeyModifier.meta,
      KeyboardModifier.shift => HotKeyModifier.shift,
    };
  }
}

enum HotAction { start, view, mode, proxy, tun }

enum ProxiesIconStyle { standard, none, icon }

enum FontFamily {
  twEmoji('Twemoji'),
  jetBrainsMono('JetBrainsMono'),
  icon('Icons');

  final String value;

  const FontFamily(this.value);
}

enum RouteMode { bypassPrivate, config }

enum ActionMethod {
  message,
  initClash,
  getIsInit,
  forceGc,
  shutdown,
  validateConfig,
  updateConfig,
  getConfig,
  getProxies,
  changeProxy,
  getTraffic,
  getTotalTraffic,
  resetTraffic,
  asyncTestDelay,
  getConnections,
  closeConnections,
  resetConnections,
  closeConnection,
  getExternalProviders,
  getExternalProvider,
  updateGeoData,
  updateExternalProvider,
  sideLoadExternalProvider,
  startLog,
  stopLog,
  startListener,
  stopListener,
  getCountryCode,
  getMemory,
  crash,
  setupConfig,
  deleteFile,

  ///Android,
  setState,
  startTun,
  stopTun,
  getRunTime,
  updateDns,
  getAndroidVpnOptions,
  getCurrentProfileName,
}

enum AuthorizeCode { none, success, error }

enum WindowsHelperServiceStatus { none, presence, running }

enum FunctionTag {
  updateClashConfig,
  setupClashConfig,
  updateStatus,
  updateGroups,
  addCheckIpNum,
  applyProfile,
  savePreferences,
  changeProxy,
  checkIp,
  handleWill,
  updateDelay,
  vpnTip,
  autoLaunch,
  renderPause,
  updatePageIndex,
  pageChange,
  proxiesTabChange,
  logs,
  requests,
  autoScrollToEnd,
}

enum DashboardWidget {
  networkSpeed(GridItem(crossAxisCellCount: 8, child: NetworkSpeed())),
  outboundModeV2(GridItem(crossAxisCellCount: 8, child: OutboundModeV2())),
  outboundMode(GridItem(crossAxisCellCount: 4, child: OutboundMode())),
  trafficUsage(GridItem(crossAxisCellCount: 4, child: TrafficUsage())),
  networkDetection(GridItem(crossAxisCellCount: 4, child: NetworkDetection())),
  tunButton(
    GridItem(crossAxisCellCount: 4, child: TUNButton()),
    platforms: desktopPlatforms,
  ),
  vpnButton(
    GridItem(crossAxisCellCount: 4, child: VpnButton()),
    platforms: [SupportPlatform.Android],
  ),
  systemProxyButton(
    GridItem(crossAxisCellCount: 4, child: SystemProxyButton()),
    platforms: desktopPlatforms,
  ),
  intranetIp(GridItem(crossAxisCellCount: 4, child: IntranetIP())),
  memoryInfo(GridItem(crossAxisCellCount: 4, child: MemoryInfo()));

  final GridItem widget;
  final List<SupportPlatform> platforms;

  const DashboardWidget(this.widget, {this.platforms = SupportPlatform.values});

  static DashboardWidget getDashboardWidget(GridItem gridItem) {
    final dashboardWidgets = DashboardWidget.values;
    final index = dashboardWidgets.indexWhere(
      (item) => item.widget == gridItem,
    );
    return dashboardWidgets[index];
  }
}

enum GeodataLoader { standard, memconservative }

enum PageLabel {
  dashboard,
  proxies,
  profiles,
  tools,
  logs,
  requests,
  resources,
  connections,
}

enum RuleAction {
  DOMAIN('DOMAIN'),
  DOMAIN_SUFFIX('DOMAIN-SUFFIX'),
  DOMAIN_KEYWORD('DOMAIN-KEYWORD'),
  DOMAIN_REGEX('DOMAIN-REGEX'),
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
  PROCESS_PATH('PROCESS-PATH'),
  PROCESS_PATH_REGEX('PROCESS-PATH-REGEX'),
  PROCESS_NAME('PROCESS-NAME'),
  PROCESS_NAME_REGEX('PROCESS-NAME-REGEX'),
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
}

extension RuleActionExt on RuleAction {
  bool get hasParams => [
    RuleAction.GEOIP,
    RuleAction.IP_ASN,
    RuleAction.SRC_IP_ASN,
    RuleAction.IP_CIDR,
    RuleAction.IP_CIDR6,
    RuleAction.IP_SUFFIX,
    RuleAction.RULE_SET,
  ].contains(this);
}

enum OverrideRuleType { override, added }

enum RuleTarget { DIRECT, REJECT }

enum RecoveryStrategy { compatible, override }

enum CacheTag { logs, rules, requests, proxiesList }

enum Language { yaml, javaScript }

enum ImportOption { file, url }

enum ScrollPositionCacheKey { tools, profiles, proxiesList, proxiesTabList }

enum QueryTag { proxies }

enum CoreStatus { connecting, connected, disconnected }
