import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/common.freezed.dart';

part 'generated/common.g.dart';

@freezed
class NavigationItem with _$NavigationItem {
  const factory NavigationItem({
    required Icon icon,
    required String label,
    final String? description,
    required Widget fragment,
    @Default(true) bool keep,
    String? path,
    @Default([NavigationItemMode.mobile, NavigationItemMode.desktop])
    List<NavigationItemMode> modes,
  }) = _NavigationItem;
}

@freezed
class Package with _$Package {
  const factory Package({
    required String packageName,
    required String label,
    required bool isSystem,
    required int firstInstallTime,
  }) = _Package;

  factory Package.fromJson(Map<String, Object?> json) =>
      _$PackageFromJson(json);
}

@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    required int uid,
    required String network,
    required String sourceIP,
    required String sourcePort,
    required String destinationIP,
    required String destinationPort,
    required String host,
    required String process,
    required String remoteDestination,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, Object?> json) =>
      _$MetadataFromJson(json);
}

@freezed
class Connection with _$Connection {
  const factory Connection({
    required String id,
    num? upload,
    num? download,
    required DateTime start,
    required Metadata metadata,
    required List<String> chains,
  }) = _Connection;

  factory Connection.fromJson(Map<String, Object?> json) =>
      _$ConnectionFromJson(json);
}

@JsonSerializable()
class Log {
  @JsonKey(name: "LogLevel")
  LogLevel logLevel;
  @JsonKey(name: "Payload")
  String? payload;
  DateTime _dateTime;

  Log({
    required this.logLevel,
    this.payload,
  }) : _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  factory Log.fromJson(Map<String, dynamic> json) {
    return _$LogFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$LogToJson(this);
  }

  @override
  String toString() {
    return 'Log{logLevel: $logLevel, payload: $payload, dateTime: $dateTime}';
  }
}

@freezed
class LogsAndKeywords with _$LogsAndKeywords {
  const factory LogsAndKeywords({
    @Default([]) List<Log> logs,
    @Default([]) List<String> keywords,
  }) = _LogsAndKeywords;

  factory LogsAndKeywords.fromJson(Map<String, Object?> json) =>
      _$LogsAndKeywordsFromJson(json);
}

extension LogsAndKeywordsExt on LogsAndKeywords {
  List<Log> get filteredLogs => logs
      .where(
        (log) => {log.logLevel.name}.containsAll(keywords),
      )
      .toList();
}

@freezed
class ConnectionsAndKeywords with _$ConnectionsAndKeywords {
  const factory ConnectionsAndKeywords({
    @Default([]) List<Connection> connections,
    @Default([]) List<String> keywords,
  }) = _ConnectionsAndKeywords;

  factory ConnectionsAndKeywords.fromJson(Map<String, Object?> json) =>
      _$ConnectionsAndKeywordsFromJson(json);
}

extension ConnectionsAndKeywordsExt on ConnectionsAndKeywords {
  List<Connection> get filteredConnections => connections
      .where((connection) => {
            ...connection.chains,
            connection.metadata.process,
          }.containsAll(keywords))
      .toList();
}

const defaultDavFileName = "backup.zip";

@freezed
class DAV with _$DAV {
  const factory DAV({
    required String uri,
    required String user,
    required String password,
    @Default(defaultDavFileName) String fileName,
  }) = _DAV;

  factory DAV.fromJson(Map<String, Object?> json) => _$DAVFromJson(json);
}

@freezed
class FileInfo with _$FileInfo {
  const factory FileInfo({
    required int size,
    required DateTime lastModified,
  }) = _FileInfo;
}

extension FileInfoExt on FileInfo {
  String get desc =>
      "${TrafficValue(value: size).show}  ·  ${lastModified.lastUpdateTimeDesc}";
}

@freezed
class VersionInfo with _$VersionInfo {
  const factory VersionInfo({
    @Default("") String clashName,
    @Default("") String version,
  }) = _VersionInfo;

  factory VersionInfo.fromJson(Map<String, Object?> json) =>
      _$VersionInfoFromJson(json);
}

class Traffic {
  int id;
  TrafficValue up;
  TrafficValue down;

  Traffic({int? up, int? down})
      : id = DateTime.now().millisecondsSinceEpoch,
        up = TrafficValue(value: up),
        down = TrafficValue(value: down);

  num get speed => up.value + down.value;

  factory Traffic.fromMap(Map<String, dynamic> map) {
    return Traffic(
      up: map['up'],
      down: map['down'],
    );
  }

  @override
  String toString() {
    return '$up↑ $down↓';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Traffic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          up == other.up &&
          down == other.down;

  @override
  int get hashCode => id.hashCode ^ up.hashCode ^ down.hashCode;
}

@immutable
class TrafficValueShow {
  final String value;
  final TrafficUnit unit;

  const TrafficValueShow({
    required this.value,
    required this.unit,
  });
}

@immutable
class TrafficValue {
  final int _value;

  const TrafficValue({int? value}) : _value = value ?? 0;

  int get value => _value;

  String get show => "$showValue $showUnit";

  String get showValue => trafficValueShow.value;

  String get showUnit => trafficValueShow.unit.name;

  TrafficValueShow get trafficValueShow {
    if (_value > pow(1024, 4)) {
      return TrafficValueShow(
        value: (_value / pow(1024, 4)).fixed(),
        unit: TrafficUnit.TB,
      );
    }
    if (_value > pow(1024, 3)) {
      return TrafficValueShow(
        value: (_value / pow(1024, 3)).fixed(),
        unit: TrafficUnit.GB,
      );
    }
    if (_value > pow(1024, 2)) {
      return TrafficValueShow(
          value: (_value / pow(1024, 2)).fixed(), unit: TrafficUnit.MB);
    }
    if (_value > pow(1024, 1)) {
      return TrafficValueShow(
        value: (_value / pow(1024, 1)).fixed(),
        unit: TrafficUnit.KB,
      );
    }
    return TrafficValueShow(
      value: _value.fixed(),
      unit: TrafficUnit.B,
    );
  }

  @override
  String toString() {
    return "$showValue$showUnit";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrafficValue &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

typedef ProxyMap = Map<String, Proxy>;

@freezed
class Group with _$Group {
  const factory Group({
    required GroupType type,
    @Default([]) List<Proxy> all,
    String? now,
    bool? hidden,
    @Default("") String icon,
    required String name,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}

extension GroupExt on Group {
  String get realNow => now ?? "";

  String getCurrentSelectedName(String proxyName) {
    if (type.isURLTestOrFallback) {
      return realNow.isNotEmpty ? realNow : proxyName;
    }
    return proxyName.isNotEmpty ? proxyName : realNow;
  }
}

@freezed
class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

@immutable
class SystemColorSchemes {
  final ColorScheme? lightColorScheme;
  final ColorScheme? darkColorScheme;

  const SystemColorSchemes({
    this.lightColorScheme,
    this.darkColorScheme,
  });

  getSystemColorSchemeForBrightness(Brightness? brightness) {
    if (brightness == Brightness.dark) {
      return darkColorScheme != null
          ? ColorScheme.fromSeed(
              seedColor: darkColorScheme!.primary,
              brightness: Brightness.dark,
            )
          : ColorScheme.fromSeed(
              seedColor: defaultPrimaryColor,
              brightness: Brightness.dark,
            );
    }
    return lightColorScheme != null
        ? ColorScheme.fromSeed(seedColor: lightColorScheme!.primary)
        : ColorScheme.fromSeed(seedColor: defaultPrimaryColor);
  }
}

class IpInfo {
  final String ip;
  final String countryCode;

  const IpInfo({
    required this.ip,
    required this.countryCode,
  });

  static IpInfo fromIpInfoIoJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country": final String country,
      } =>
        IpInfo(
          ip: ip,
          countryCode: country,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  static IpInfo fromIpApiCoJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country_code": final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  static IpInfo fromIpSbJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country_code": final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  static IpInfo fromIpwhoIsJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country_code": final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  @override
  String toString() {
    return 'IpInfo{ip: $ip, countryCode: $countryCode}';
  }
}

@freezed
class HotKeyAction with _$HotKeyAction {
  const factory HotKeyAction({
    required HotAction action,
    int? key,
    @Default({}) Set<KeyboardModifier> modifiers,
  }) = _HotKeyAction;

  factory HotKeyAction.fromJson(Map<String, Object?> json) =>
      _$HotKeyActionFromJson(json);
}

typedef Validator = String? Function(String? value);

@freezed
class Field with _$Field {
  const factory Field({
    required String label,
    required String value,
    Validator? validator,
  }) = _Field;
}
