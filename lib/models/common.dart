import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/common.freezed.dart';
part 'generated/common.g.dart';

@freezed
abstract class NavigationItem with _$NavigationItem {
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
abstract class Package with _$Package {
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
abstract class Metadata with _$Metadata {
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
abstract class TrackerInfo with _$TrackerInfo {
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
      return '$process($uid)'.trim();
    }
    return process.trim();
  }
}

String _logDateTime(dynamic _) {
  return DateTime.now().showFull;
}

// String _logId(_) {
//   return utils.id;
// }

@freezed
abstract class Log with _$Log {
  const factory Log({
    // @JsonKey(fromJson: _logId) required String id,
    @JsonKey(name: 'LogLevel') @Default(LogLevel.info) LogLevel logLevel,
    @JsonKey(name: 'Payload') @Default('') String payload,
    @JsonKey(fromJson: _logDateTime) required String dateTime,
  }) = _Log;

  factory Log.app(String payload) {
    return Log(
      payload: payload,
      dateTime: _logDateTime(null),
      // id: _logId(null),
    );
  }

  factory Log.fromJson(Map<String, Object?> json) => _$LogFromJson(json);
}

@freezed
abstract class LogsState with _$LogsState {
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
    return logs.where((log) {
      final logLevelName = log.logLevel.name;
      return {logLevelName}.containsAll(keywords) &&
          ((log.payload.toLowerCase().contains(lowQuery)) ||
              logLevelName.contains(lowQuery));
    }).toList();
  }
}

@freezed
abstract class TrackerInfosState with _$TrackerInfosState {
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
      final destinationIPText = trackerInfo.metadata.destinationIP
          .toLowerCase();
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
abstract class DAV with _$DAV {
  const factory DAV({
    required String uri,
    required String user,
    required String password,
    @Default(defaultDavFileName) String fileName,
  }) = _DAV;

  factory DAV.fromJson(Map<String, Object?> json) => _$DAVFromJson(json);
}

@freezed
abstract class FileInfo with _$FileInfo {
  const factory FileInfo({required int size, required DateTime lastModified}) =
      _FileInfo;
}

extension FileInfoExt on FileInfo {
  String get desc =>
      '${size.traffic.show}  ·  ${lastModified.lastUpdateTimeDesc}';
}

@freezed
abstract class VersionInfo with _$VersionInfo {
  const factory VersionInfo({
    @Default('') String clashName,
    @Default('') String version,
  }) = _VersionInfo;

  factory VersionInfo.fromJson(Map<String, Object?> json) =>
      _$VersionInfoFromJson(json);
}

@freezed
abstract class Traffic with _$Traffic {
  const factory Traffic({@Default(0) num up, @Default(0) num down}) = _Traffic;

  factory Traffic.fromJson(Map<String, Object?> json) =>
      _$TrafficFromJson(json);
}

extension TrafficExt on Traffic {
  String get speedText {
    return '↑ ${up.traffic.show}/s   ↓ ${down.traffic.show}/s';
  }

  String get desc {
    return '${up.traffic.show} ↑ ${down.traffic.show} ↓';
  }

  num get speed => up + down;
}

@freezed
abstract class TrafficShow with _$TrafficShow {
  const factory TrafficShow({required String value, required String unit}) =
      _TrafficShow;
}

extension TrafficShowExt on TrafficShow {
  String get show => '$value$unit';
}

@freezed
abstract class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

@freezed
abstract class Group with _$Group {
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

@freezed
abstract class ColorSchemes with _$ColorSchemes {
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

@freezed
abstract class IpInfo with _$IpInfo {
  const factory IpInfo({required String ip, required String countryCode}) =
      _IpInfo;

  static IpInfo fromIpInfoIoJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'country': final String country} => IpInfo(
        ip: ip,
        countryCode: country,
      ),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpApiCoJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'country_code': final String countryCode} =>
        IpInfo(ip: ip, countryCode: countryCode),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpSbJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'country_code': final String countryCode} =>
        IpInfo(ip: ip, countryCode: countryCode),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpWhoIsJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'country_code': final String countryCode} =>
        IpInfo(ip: ip, countryCode: countryCode),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromMyIpJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'cc': final String countryCode} => IpInfo(
        ip: ip,
        countryCode: countryCode,
      ),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIpAPIJson(Map<String, dynamic> json) {
    return switch (json) {
      {'query': final String ip, 'countryCode': final String countryCode} =>
        IpInfo(ip: ip, countryCode: countryCode),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromIdentMeJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'cc': final String countryCode} => IpInfo(
        ip: ip,
        countryCode: countryCode,
      ),
      _ => throw const FormatException('invalid json'),
    };
  }
}

@freezed
abstract class HotKeyAction with _$HotKeyAction {
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
abstract class Field with _$Field {
  const factory Field({
    required String label,
    required String value,
    Validator? validator,
  }) = _Field;
}

enum PopupMenuItemType { primary, danger }

class PopupMenuItemData {
  const PopupMenuItemData({
    this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;
}

@freezed
abstract class AndroidState with _$AndroidState {
  const factory AndroidState({
    required String currentProfileName,
    required String stopText,
    required bool onlyStatisticsProxy,
  }) = _AndroidState;

  factory AndroidState.fromJson(Map<String, Object?> json) =>
      _$AndroidStateFromJson(json);
}

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result({
    required T? data,
    required ResultType type,
    required String message,
  }) = _Result;

  factory Result.success(T data) =>
      Result(data: data, type: ResultType.success, message: '');

  factory Result.error(String message) =>
      Result(data: null, type: ResultType.error, message: message);
}

extension ResultExt on Result {
  bool get isError => type == ResultType.error;

  bool get isSuccess => type == ResultType.success;
}

@freezed
abstract class Script with _$Script {
  const factory Script({
    required String id,
    required String label,
    required String content,
  }) = _Script;

  factory Script.create({required String label, required String content}) {
    return Script(id: utils.uuidV4, label: label, content: content);
  }

  factory Script.fromJson(Map<String, Object?> json) => _$ScriptFromJson(json);
}

@freezed
abstract class DelayState with _$DelayState {
  const factory DelayState({required int delay, required bool group}) =
      _DelayState;
}

extension DelayStateExt on DelayState {
  int get priority {
    if (delay > 0) return 0;
    if (delay == 0) return 1;
    return 2;
  }

  int compareTo(DelayState other) {
    if (priority != other.priority) {
      return priority.compareTo(other.priority);
    }
    if (delay != other.delay) {
      return delay.compareTo(other.delay);
    }
    if (group && !group) return -1;
    if (!group && group) return 1;
    return 0;
  }
}
