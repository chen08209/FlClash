import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/glyph.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';

part 'generated/common.freezed.dart';

part 'generated/common.g.dart';

@freezed
abstract class NavigationItem with _$NavigationItem {
  const factory NavigationItem({
    required Glyph glyph,
    required PageLabel label,
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

extension PackagesExt on List<Package> {
  Iterable<Package> whereVisible({
    required bool isFilterSystemApp,
    required bool isFilterNonInternetApp,
  }) {
    return where(
      (item) =>
          (isFilterSystemApp ? item.system == false : true) &&
          (isFilterNonInternetApp ? item.internet == true : true),
    );
  }

  List<Package> getViewList({
    required List<String> pinedList,
    required AccessSortType sortType,
    required bool isFilterSystemApp,
    required bool isFilterNonInternetApp,
  }) {
    final pinned = pinedList.toSet();
    return whereVisible(
      isFilterSystemApp: isFilterSystemApp,
      isFilterNonInternetApp: isFilterNonInternetApp,
    ).sorted((a, b) {
      final isSelectA = pinned.contains(a.packageName);
      final isSelectB = pinned.contains(b.packageName);

      if (isSelectA != isSelectB) {
        return isSelectA ? -1 : 1;
      }
      return switch (sortType) {
        AccessSortType.none => 0,
        AccessSortType.name => a.label.compareTo(b.label),
        AccessSortType.time => b.lastUpdateTime.compareTo(a.lastUpdateTime),
      };
    });
  }
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
  String get title {
    final host = metadata.host;
    if (host.isNotEmpty) {
      return host;
    }
    return metadata.destinationIP;
  }

  String get progressText {
    final process = metadata.process;
    final uid = metadata.uid;
    if (uid != 0) {
      return '$process($uid)'.trim();
    }
    return process.trim();
  }

  List<String> get searchFields => [
    metadata.network,
    metadata.host,
    metadata.destinationIP,
    metadata.destinationPort,
    metadata.sourceIP,
    metadata.sourcePort,
    metadata.process,
    metadata.processPath,
    metadata.remoteDestination,
    metadata.destinationIPASN,
    ...metadata.destinationGeoIP,
    metadata.specialProxy,
    metadata.specialRules,
    rule,
    rulePayload,
    ...chains,
  ];
}

String _logDateTime(dynamic _) {
  return DateTime.now().showFull;
}

@freezed
abstract class Log with _$Log {
  const factory Log({
    @JsonKey(name: 'LogLevel') @Default(LogLevel.info) LogLevel logLevel,
    @JsonKey(name: 'Payload') @Default('') String payload,
    @JsonKey(fromJson: _logDateTime) required String dateTime,
  }) = _Log;

  factory Log.app(String payload) {
    return Log(payload: payload, dateTime: _logDateTime(null));
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

final _logSearchTexts = Expando<String>();

extension LogsStateExt on LogsState {
  bool get isSearching => keywords.isNotEmpty || SearchQuery(query).isNotEmpty;

  List<Log> get list {
    final searchQuery = SearchQuery(query);
    if (keywords.isEmpty && searchQuery.isEmpty) {
      return logs;
    }
    return logs
        .where(
          (log) => keywords.every((keyword) => keyword == log.logLevel.name),
        )
        .whereMatches(
          searchQuery,
          (log) => [log.payload, log.logLevel.name],
          texts: _logSearchTexts,
        )
        .toList();
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

final _trackerInfoSearchTexts = Expando<String>();

extension TrackerInfosStateExt on TrackerInfosState {
  bool get isSearching => keywords.isNotEmpty || SearchQuery(query).isNotEmpty;

  List<TrackerInfo> get list {
    final searchQuery = SearchQuery(query);
    if (keywords.isEmpty && searchQuery.isEmpty) {
      return trackerInfos;
    }
    return trackerInfos
        .where(
          (trackerInfo) => keywords.every(
            (keyword) =>
                keyword == trackerInfo.metadata.process ||
                trackerInfo.chains.contains(keyword),
          ),
        )
        .whereMatches(
          searchQuery,
          (trackerInfo) => trackerInfo.searchFields,
          texts: _trackerInfoSearchTexts,
        )
        .toList();
  }
}

@freezed
abstract class DnsQuery with _$DnsQuery {
  const factory DnsQuery({
    required String domain,
    required String type,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    DnsQueryInitiator? initiator,
    @Default('') String upstream,
    @Default(false) bool cached,
    @Default([]) List<String> answers,
    @Default('') String rcode,
    @Default('') String error,
    @Default(0) int delay,
    required DateTime time,
  }) = _DnsQuery;

  factory DnsQuery.fromJson(Map<String, Object?> json) =>
      _$DnsQueryFromJson(json);
}

extension DnsQueryExt on DnsQuery {
  bool get hasFailureRcode => rcode.isNotEmpty && rcode != 'NOERROR';

  bool get isFailed => error.isNotEmpty || hasFailureRcode;

  List<String> get tags => [type, ...resultTags];

  List<String> get resultTags {
    final initiator = this.initiator;
    return [
      if (initiator != null) initiator.label,
      if (cached) currentAppLocalizations.cache,
      if (hasFailureRcode) rcode,
    ];
  }

  List<String> get searchFields => [
    domain,
    ...tags,
    rcode,
    upstream,
    error,
    ...answers,
  ];
}

@freezed
abstract class DnsQueriesState with _$DnsQueriesState {
  const factory DnsQueriesState({
    @Default([]) List<DnsQuery> dnsQueries,
    @Default([]) List<String> keywords,
    @Default('') String query,
    @Default(true) bool autoScrollToEnd,
  }) = _DnsQueriesState;
}

extension DnsQueriesStateExt on DnsQueriesState {
  bool get isSearching => keywords.isNotEmpty || SearchQuery(query).isNotEmpty;

  List<DnsQuery> get list {
    final searchQuery = SearchQuery(query);
    if (keywords.isEmpty && searchQuery.isEmpty) {
      return dnsQueries;
    }
    return dnsQueries
        .where((dnsQuery) => keywords.every(dnsQuery.tags.contains))
        .whereMatches(searchQuery, (dnsQuery) => dnsQuery.searchFields)
        .toList();
  }
}

const defaultDavFileName = 'backup.zip';
const _davPasswordFormatVersion = 'v1';
const _davPasswordNonceLength = 16;
const _davPasswordObfuscationMask = <int>[
  0x9d,
  0x42,
  0xe7,
  0x1b,
  0x68,
  0xb4,
  0x35,
  0xca,
  0x7f,
  0x20,
  0xd1,
  0x56,
  0x83,
  0xfa,
  0x0c,
  0xa9,
];

// This only prevents accidental plain-text disclosure. It is deliberately not
// a security boundary against reverse engineering or same-user access.
String _encodeDavPassword(String password) {
  if (password.isEmpty) {
    return '';
  }
  final random = Random.secure();
  final nonce = List<int>.generate(
    _davPasswordNonceLength,
    (_) => random.nextInt(256),
    growable: false,
  );
  final passwordBytes = utf8.encode(password);
  final obfuscated = List<int>.generate(
    passwordBytes.length,
    (index) =>
        passwordBytes[index] ^
        nonce[index % nonce.length] ^
        _davPasswordObfuscationMask[index % _davPasswordObfuscationMask.length],
    growable: false,
  );
  return [
    _davPasswordFormatVersion,
    base64UrlEncode(nonce),
    base64UrlEncode(obfuscated),
  ].join('.');
}

String _decodeDavPassword(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  final parts = value.split('.');
  if (parts.length != 3 || parts[0] != _davPasswordFormatVersion) {
    return value;
  }
  try {
    final nonce = base64Url.decode(parts[1]);
    final obfuscated = base64Url.decode(parts[2]);
    if (nonce.length != _davPasswordNonceLength) {
      return '';
    }
    final passwordBytes = List<int>.generate(
      obfuscated.length,
      (index) =>
          obfuscated[index] ^
          nonce[index % nonce.length] ^
          _davPasswordObfuscationMask[index %
              _davPasswordObfuscationMask.length],
      growable: false,
    );
    return utf8.decode(passwordBytes);
  } on FormatException {
    return '';
  }
}

@Freezed(toStringOverride: false)
abstract class DAVProps with _$DAVProps {
  const DAVProps._();

  const factory DAVProps({
    required String uri,
    required String user,
    @JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword)
    @Default('')
    String password,
    @Default(defaultDavFileName) String fileName,
  }) = _DAVProps;

  factory DAVProps.fromJson(Map<String, Object?> json) =>
      _$DAVPropsFromJson(json);

  @override
  String toString() =>
      'DAVProps(uri: $uri, user: $user, password: ***, fileName: $fileName)';
}

@freezed
abstract class FileInfo with _$FileInfo {
  const factory FileInfo({required int size, DateTime? lastModified}) =
      _FileInfo;
}

extension FileInfoFileExt on File {
  Future<FileInfo?> getFileInfo() async {
    if (!await exists()) {
      return null;
    }
    final size = await length();
    final lastModified = await _getValidLastModified();
    return FileInfo(size: size, lastModified: lastModified);
  }

  Future<DateTime?> _getValidLastModified() async {
    try {
      final value = await lastModified();
      return value.year > 1970 ? value : null;
    } on FileSystemException {
      return null;
    }
  }
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

  String get trayTitle {
    return '${up.shortTraffic.show}/s\n${down.shortTraffic.show}/s';
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
abstract class Group with _$Group {
  const factory Group({
    @JsonKey(fromJson: GroupType.parse) required GroupType type,
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
              seedColor: const Color(defaultPrimaryColor),
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
            seedColor: const Color(defaultPrimaryColor),
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

  static IpInfo fromGeoJsJson(Map<String, dynamic> json) {
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

  static IpInfo fromCountryIsJson(Map<String, dynamic> json) {
    return switch (json) {
      {'ip': final String ip, 'country': final String countryCode} => IpInfo(
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

  static IpInfo fromIpQueryJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'ip': final String ip,
        'location': {'country_code': final String countryCode},
      } =>
        IpInfo(ip: ip, countryCode: countryCode),
      _ => throw const FormatException('invalid json'),
    };
  }

  static IpInfo fromCloudflareTrace(String body) {
    final fields = <String, String>{};
    for (final line in const LineSplitter().convert(body)) {
      final separator = line.indexOf('=');
      if (separator > 0) {
        fields[line.substring(0, separator)] = line.substring(separator + 1);
      }
    }
    return switch (fields) {
      {'ip': final ip, 'loc': final countryCode} => IpInfo(
        ip: ip,
        countryCode: countryCode,
      ),
      _ => throw const FormatException('invalid trace'),
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

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

class EscapeBackIntent extends Intent {
  const EscapeBackIntent();
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
    required int id,
    required String label,
    required DateTime lastUpdateTime,
    String? url,
    int? order,
  }) = _Script;

  factory Script.fromJson(Map<String, Object?> json) => _$ScriptFromJson(json);

  factory Script.create({required String label, String? url}) {
    return Script(
      id: snowflake.id,
      label: label,
      lastUpdateTime: DateTime.now(),
      url: url,
    );
  }
}

extension ScriptsExt on List<Script> {
  Script? get(int? id) {
    if (id == null) {
      return null;
    }
    final index = indexWhere((script) => script.id == id);
    if (index != -1) {
      return this[index];
    }
    return null;
  }

  bool hasLabel(String label, {Script? except}) {
    return any((script) => script.id != except?.id && script.label == label);
  }

  String uniqueLabel(String name, {required String fallback}) {
    return uniqueLabelFor(
      name,
      fallback: fallback,
      taken: (label) => hasLabel(label),
    );
  }
}

extension ScriptExt on Script {
  String get fileName => '$id.js';

  String get updatingKey => 'script_$id';

  Future<String> get path async => appPath.getScriptPath(id.toString());

  Future<FileInfo?> get fileInfo async => File(await path).getFileInfo();

  Future<String?> get content async => readTextFileTask(await path);

  Future<Script> save(String content) async {
    final file = File(await path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(content);
    return copyWith(lastUpdateTime: DateTime.now());
  }

  Future<Script> update() async {
    final response = await request.getTextResponseForUrl(url!);
    return save(response.data ?? '');
  }

  Future<Script> saveWithPath(String copyPath) async {
    final file = File(await path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await File(copyPath).copy(copyPath);
    return copyWith(lastUpdateTime: DateTime.now());
  }
}

@freezed
abstract class ClashProvider with _$ClashProvider {
  const factory ClashProvider({
    required int id,
    required String label,
    @Default('') String url,
    @Default(RuleProviderBehavior.classical) RuleProviderBehavior behavior,
    @Default(RuleProviderFormat.yaml) RuleProviderFormat format,
    int? order,
  }) = _ClashProvider;

  factory ClashProvider.create({required String label, String url = ''}) {
    return ClashProvider(id: snowflake.id, label: label, url: url);
  }
}

typedef RuleSetInfo = ({
  RuleProviderBehavior behavior,
  RuleProviderFormat format,
});

extension ClashProviderExt on ClashProvider {
  /// Keyed by url so an edited url downloads afresh instead of reusing the
  /// cached body the old one left behind.
  String get fileName => '$id@$url'.toMd5();

  bool get isRemote => url.isNotEmpty;

  String get updatingKey => 'rule_provider_$id';

  /// An mrs set is a zstd stream, which no text editor can round-trip.
  bool get isTextContent => format != RuleProviderFormat.mrs;

  /// [format] is the source's; classical rules have no mrs form.
  bool get isCompiled =>
      isTextContent && behavior != RuleProviderBehavior.classical;

  Future<String> get path => appPath.getProviderCachePath(fileName);

  Future<String> get compiledPath async => '${await path}.mrs';

  Future<String> get corePath => isCompiled ? compiledPath : path;

  Future<FileInfo?> get fileInfo async => File(await path).getFileInfo();

  Future<String?> get content async => readTextFileTask(await path);

  ClashProvider withInfo(RuleSetInfo info) {
    return copyWith(behavior: info.behavior, format: info.format);
  }

  Map<String, dynamic> definition(String path) {
    return {
      'type': 'file',
      'path': path,
      'behavior': behavior.name,
      'format': isCompiled ? RuleProviderFormat.mrs.name : format.name,
    };
  }
}

@freezed
abstract class IconSetIcon with _$IconSetIcon {
  const factory IconSetIcon({required String name, required String url}) =
      _IconSetIcon;

  factory IconSetIcon.fromJson(Map<String, Object?> json) =>
      _$IconSetIconFromJson(json);
}

final _iconLabels = Expando<String>();
final _nonAlphanumeric = RegExp('[^a-z0-9]');

extension IconSetIconExt on IconSetIcon {
  String get label => _iconLabels[this] ??= name.fileStem.replaceAll('_', ' ');
}

String _compactIconName(String value) =>
    value.toLowerCase().replaceAll(_nonAlphanumeric, '');

typedef IconNameMatch = ({int index, int score, int length});

typedef ScoredIcon = ({IconSetIcon icon, int score, int length});

/// English only: a name with no Latin letters or digits matches nothing.
List<IconNameMatch> matchIconNames(List<String> names, String target) {
  final compactTarget = _compactIconName(target);
  if (compactTarget.isEmpty) {
    return const [];
  }
  final matches = <IconNameMatch>[];
  for (final (index, name) in names.indexed) {
    final compact = _compactIconName(name.fileStem);
    if (compact.isEmpty) {
      continue;
    }
    final score = switch (compact) {
      _ when compact == compactTarget => 3,
      _ when compact.length >= 3 && compactTarget.contains(compact) => 2,
      _ when compactTarget.length >= 3 && compact.contains(compactTarget) => 1,
      _ => 0,
    };
    if (score > 0) {
      matches.add((index: index, score: score, length: compact.length));
    }
  }
  return matches;
}

/// Keeps the first match of each image, in the order given, before ranking.
List<IconSetIcon> rankIconMatches(
  Iterable<ScoredIcon> matches, {
  int limit = 24,
}) {
  final seen = <String>{};
  final scored = [
    for (final match in matches)
      if (seen.add(match.icon.url)) match,
  ];
  mergeSort(
    scored,
    compare: (a, b) => a.score != b.score
        ? b.score.compareTo(a.score)
        : a.length.compareTo(b.length),
  );
  return scored.take(limit).map((item) => item.icon).toList();
}

extension IconSetIconsExt on List<IconSetIcon> {
  List<ScoredIcon> scoredBy(List<IconNameMatch> matches) => [
    for (final match in matches)
      (icon: this[match.index], score: match.score, length: match.length),
  ];

  List<ScoredIcon> scoreFor(String name) =>
      scoredBy(matchIconNames([for (final icon in this) icon.name], name));

  List<IconSetIcon> recommendFor(String name, {int limit = 24}) =>
      rankIconMatches(scoreFor(name), limit: limit);
}

@freezed
abstract class IconSet with _$IconSet {
  const factory IconSet({
    required int id,
    required String name,
    @Default('') String url,
    @Default([]) List<IconSetIcon> icons,
    DateTime? lastUpdateTime,
    int? order,
  }) = _IconSet;
}

extension IconSetExt on IconSet {
  bool get isRemote => url.isNotEmpty;

  String get cover => icons.firstOrNull?.url ?? '';

  String get updatingKey => 'icon_set_$id';
}

bool _isHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.isScheme('http') || uri.isScheme('https')) &&
      uri.host.isNotEmpty;
}

/// Reads the icon gallery format Quantumult X and Loon subscribe to:
/// `{"name": ..., "icons": [{"name": ..., "url": ...}]}`.
({String name, List<IconSetIcon> icons}) parseIconSet(String content) {
  final document = json.decode(content);
  if (document is! Map || document['icons'] is! List) {
    throw const FormatException('Not an icon set');
  }
  final seen = <String>{};
  final icons = <IconSetIcon>[];
  for (final item in document['icons'] as List) {
    if (item is! Map) {
      continue;
    }
    final url = item['url'];
    if (url is! String || !_isHttpUrl(url) || !seen.add(url)) {
      continue;
    }
    final name = item['name'];
    icons.add(
      IconSetIcon(
        name: name is String && name.trim().isNotEmpty
            ? name.trim()
            : url.urlFileName,
        url: url,
      ),
    );
  }
  if (icons.isEmpty) {
    throw const FormatException('An icon set without icons');
  }
  final name = document['name'];
  return (name: name is String ? name.trim() : '', icons: icons);
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
    if (delay == delayTimedOutValue) return 2;
    return 3;
  }

  int compareTo(DelayState other) {
    if (priority != other.priority) {
      return priority.compareTo(other.priority);
    }
    if (delay != other.delay) {
      return delay.compareTo(other.delay);
    }
    if (group && !other.group) return -1;
    if (!group && other.group) return 1;
    return 0;
  }
}

@freezed
abstract class UpdatingMessage with _$UpdatingMessage {
  const factory UpdatingMessage({
    required String label,
    required String message,
  }) = _UpdatingMessage;
}

@freezed
abstract class IconButtonData with _$IconButtonData {
  const factory IconButtonData({
    required Glyph glyph,
    required VoidCallback? onPressed,
    String? tooltip,
    @Default(false) bool isLoading,

    /// Non-null makes the button a toggle that shows this state.
    bool? isSelected,
  }) = _IconButtonData;
}
