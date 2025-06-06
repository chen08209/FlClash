// ignore_for_file: invalid_annotation_target

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
    required PageLabel label,
    final String? description,
    required WidgetBuilder builder,
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
    required bool system,
    required bool internet,
    required int lastUpdateTime,
  }) = _Package;

  factory Package.fromJson(Map<String, Object?> json) =>
      _$PackageFromJson(json);
}

@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    @Default(0) int uid,
    @Default('') String network,
    @Default('') String sourceIP,
    @Default('') String sourcePort,
    @Default('') String destinationIP,
    @Default('') String destinationPort,
    @Default('') String host,
    DnsMode? dnsMode,
    @Default('') String process,
    @Default('') String processPath,
    @Default('') String remoteDestination,
    @Default([]) List<String> sourceGeoIP,
    @Default([]) List<String> destinationGeoIP,
    @Default('') String destinationIPASN,
    @Default('') String sourceIPASN,
    @Default('') String specialRules,
    @Default('') String specialProxy,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, Object?> json) =>
      _$MetadataFromJson(json);
}

@freezed
class TrackerInfo with _$TrackerInfo {
  const factory TrackerInfo({
    required String id,
    @Default(0) int upload,
    @Default(0) int download,
    required DateTime start,
    required Metadata metadata,
    required List<String> chains,
    required String rule,
    required String rulePayload,
    int? downloadSpeed,
    int? uploadSpeed,
  }) = _TrackerInfo;

  factory TrackerInfo.fromJson(Map<String, Object?> json) =>
      _$TrackerInfoFromJson(json);
}

extension TrackerInfoExt on TrackerInfo {
  String get desc {
    var text = '${metadata.network}://';
    final ips = [
      metadata.host,
      metadata.destinationIP,
    ].where((ip) => ip.isNotEmpty);
    text += ips.join('/');
    text += ':${metadata.destinationPort}';
    return text;
  }

  String get progressText {
    final process = metadata.process;
    final uid = metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
  }
}

String _logDateTime(dynamic _) {
  return DateTime.now().showFull;
}

// String _logId(_) {
//   return utils.id;
// }

@freezed
class Log with _$Log {
  const factory Log({
    // @JsonKey(fromJson: _logId) required String id,
    @JsonKey(name: 'LogLevel') @Default(LogLevel.info) LogLevel logLevel,
    @JsonKey(name: 'Payload') @Default('') String payload,
    @JsonKey(fromJson: _logDateTime) required String dateTime,
  }) = _Log;

  factory Log.app(
    String payload,
  ) {
    return Log(
      payload: payload,
      dateTime: _logDateTime(null),
      // id: _logId(null),
    );
  }

  factory Log.fromJson(Map<String, Object?> json) => _$LogFromJson(json);
}

@freezed
class LogsState with _$LogsState {
  const factory LogsState({
    @Default([]) List<Log> logs,
    @Default([]) List<String> keywords,
    @Default('') String query,
    @Default(true) bool autoScrollToEnd,
  }) = _LogsState;
}

extension LogsStateExt on LogsState {
  List<Log> get list {
    final lowQuery = query.toLowerCase();
    return logs.where(
      (log) {
        final logLevelName = log.logLevel.name;
        return {logLevelName}.containsAll(keywords) &&
            ((log.payload.toLowerCase().contains(lowQuery)) ||
                logLevelName.contains(lowQuery));
      },
    ).toList();
  }
}

@freezed
class TrackerInfosState with _$TrackerInfosState {
  const factory TrackerInfosState({
    @Default([]) List<TrackerInfo> trackerInfos,
    @Default([]) List<String> keywords,
    @Default('') String query,
    @Default(true) bool autoScrollToEnd,
  }) = _TrackerInfosState;
}

extension TrackerInfosStateExt on TrackerInfosState {
  List<TrackerInfo> get list {
    final lowerQuery = query.toLowerCase().trim();
    final lowQuery = query.toLowerCase();
    return trackerInfos.where((trackerInfo) {
      final chains = trackerInfo.chains;
      final process = trackerInfo.metadata.process;
      final networkText = trackerInfo.metadata.network.toLowerCase();
      final hostText = trackerInfo.metadata.host.toLowerCase();
      final destinationIPText =
          trackerInfo.metadata.destinationIP.toLowerCase();
      final processText = trackerInfo.metadata.process.toLowerCase();
      final chainsText = chains.join('').toLowerCase();
      return {...chains, process}.containsAll(keywords) &&
          (networkText.contains(lowerQuery) ||
              hostText.contains(lowerQuery) ||
              destinationIPText.contains(lowQuery) ||
              processText.contains(lowerQuery) ||
              chainsText.contains(lowerQuery));
    }).toList();
  }
}

const defaultDavFileName = 'backup.zip';

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
      '${TrafficValue(value: size).show}  ·  ${lastModified.lastUpdateTimeDesc}';
}

@freezed
class VersionInfo with _$VersionInfo {
  const factory VersionInfo({
    @Default('') String clashName,
    @Default('') String version,
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

  String toSpeedText() {
    return '↑ $up/s   ↓ $down/s';
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
  final double value;
  final TrafficUnit unit;

  const TrafficValueShow({
    required this.value,
    required this.unit,
  });
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

@freezed
class Group with _$Group {
  const factory Group({
    required GroupType type,
    @Default([]) List<Proxy> all,
    String? now,
    bool? hidden,
    String? testUrl,
    @Default('') String icon,
    required String name,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}

extension GroupsExt on List<Group> {
  Group? getGroup(String groupName) {
    final index = indexWhere((element) => element.name == groupName);
    return index != -1 ? this[index] : null;
  }
}

extension GroupExt on Group {
  String get realNow => now ?? '';

  String getCurrentSelectedName(String proxyName) {
    if (type.isComputedSelected) {
      return realNow.isNotEmpty ? realNow : proxyName;
    }
    return proxyName.isNotEmpty ? proxyName : realNow;
  }
}

@immutable
class TrafficValue {
  final int _value;

  const TrafficValue({int? value}) : _value = value ?? 0;

  int get value => _value;

  String get show => '$showValue $showUnit';

  String get shortShow =>
      '${trafficValueShow.value.fixed(decimals: 1)} $showUnit';

  String get showValue => trafficValueShow.value.fixed();

  String get showUnit => trafficValueShow.unit.name;

  TrafficValueShow get trafficValueShow {
    if (_value > pow(1024, 4)) {
      return TrafficValueShow(
        value: _value / pow(1024, 4),
        unit: TrafficUnit.TB,
      );
    }
    if (_value > pow(1024, 3)) {
      return TrafficValueShow(
        value: _value / pow(1024, 3),
        unit: TrafficUnit.GB,
      );
    }
    if (_value > pow(1024, 2)) {
      return TrafficValueShow(
          value: _value / pow(1024, 2), unit: TrafficUnit.MB);
    }
    if (_value > pow(1024, 1)) {
      return TrafficValueShow(
        value: _value / pow(1024, 1),
        unit: TrafficUnit.KB,
      );
    }
    return TrafficValueShow(
      value: _value.toDouble(),
      unit: TrafficUnit.B,
    );
  }

  @override
  String toString() {
    return '$showValue$showUnit';
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

@freezed
class ColorSchemes with _$ColorSchemes {
  const factory ColorSchemes({
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) = _ColorSchemes;
}

extension ColorSchemesExt on ColorSchemes {
  ColorScheme getColorSchemeForBrightness(
    Brightness brightness,
    DynamicSchemeVariant schemeVariant,
  ) {
    if (brightness == Brightness.dark) {
      return darkColorScheme != null
          ? ColorScheme.fromSeed(
              seedColor: darkColorScheme!.primary,
              brightness: Brightness.dark,
              dynamicSchemeVariant: schemeVariant,
            )
          : ColorScheme.fromSeed(
              seedColor: Color(defaultPrimaryColor),
              brightness: Brightness.dark,
              dynamicSchemeVariant: schemeVariant,
            );
    }
    return lightColorScheme != null
        ? ColorScheme.fromSeed(
            seedColor: lightColorScheme!.primary,
            dynamicSchemeVariant: schemeVariant,
          )
        : ColorScheme.fromSeed(
            seedColor: Color(defaultPrimaryColor),
            dynamicSchemeVariant: schemeVariant,
          );
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
        'ip': final String ip,
        'country': final String country,
      } =>
        IpInfo(
          ip: ip,
          countryCode: country,
        ),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpApiCoJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'ip': final String ip,
        'country_code': final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpSbJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'ip': final String ip,
        'country_code': final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpwhoIsJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'ip': final String ip,
        'country_code': final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException('invalid json'),
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

enum PopupMenuItemType {
  primary,
  danger,
}

class PopupMenuItemData {
  const PopupMenuItemData({
    this.icon,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
}

@freezed
class TextPainterParams with _$TextPainterParams {
  const factory TextPainterParams({
    required String? text,
    required double? fontSize,
    required double textScaleFactor,
    @Default(double.infinity) double maxWidth,
    int? maxLines,
  }) = _TextPainterParams;

  factory TextPainterParams.fromJson(Map<String, Object?> json) =>
      _$TextPainterParamsFromJson(json);
}

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

@freezed
class Result<T> with _$Result<T> {
  const factory Result({
    required T? data,
    required ResultType type,
    required String message,
  }) = _Result;

  factory Result.success(T data) => Result(
        data: data,
        type: ResultType.success,
        message: '',
      );

  factory Result.error(String message) => Result(
        data: null,
        type: ResultType.error,
        message: message,
      );
}

extension ResultExt on Result {
  bool get isError => type == ResultType.error;

  bool get isSuccess => type == ResultType.success;
}

@freezed
class Script with _$Script {
  const factory Script({
    required String id,
    required String label,
    required String content,
  }) = _Script;

  factory Script.create({
    required String label,
    required String content,
  }) {
    return Script(
      id: utils.uuidV4,
      label: label,
      content: content,
    );
  }

  factory Script.fromJson(Map<String, Object?> json) => _$ScriptFromJson(json);
}
