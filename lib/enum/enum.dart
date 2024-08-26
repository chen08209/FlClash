// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

enum GroupType { Selector, URLTest, Fallback, LoadBalance, Relay }

enum GroupName { GLOBAL, Proxy, Auto, Fallback }

extension GroupTypeExtension on GroupType {
  static List<String> get valueList => GroupType.values
      .map(
        (e) => e.toString().split(".").last,
      )
      .toList();

  static GroupType? getGroupType(String value) {
    final index = GroupTypeExtension.valueList.indexOf(value);
    if (index == -1) return null;
    return GroupType.values[index];
  }

  String get value => GroupTypeExtension.valueList[index];
}

enum UsedProxy { GLOBAL, DIRECT, REJECT }

extension UsedProxyExtension on UsedProxy {
  static List<String> get valueList => UsedProxy.values
      .map(
        (e) => e.toString().split(".").last,
      )
      .toList();

  String get value => UsedProxyExtension.valueList[index];
}

enum Mode { rule, global, direct }

enum ViewMode { mobile, laptop, desktop }

enum LogLevel { debug, info, warning, error, silent }

enum TransportProtocol { udp, tcp }

enum TrafficUnit { B, KB, MB, GB, TB }

enum NavigationItemMode { mobile, desktop, more }

enum Network { tcp, udp }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, name, time }

enum ProfileType { file, url }

enum ResultType { success, error }

enum AppMessageType {
  log,
  delay,
  request,
  started,
  loaded,
}

enum ServiceMessageType {
  protect,
  process,
  started,
  loaded,
}

enum FindProcessMode { always, off }

enum RecoveryOption {
  all,
  onlyProfiles,
}

enum ChipType { action, delete }

enum CommonCardType { plain, filled }

enum ProxiesType { tab, list }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { expand, shrink, min }


enum DnsMode {
  normal,
  @JsonValue("fake-ip")
  fakeIp,
  @JsonValue("redir-host")
  redirHost,
  hosts
}

