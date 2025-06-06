// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/core.freezed.dart';
part 'generated/core.g.dart';

abstract mixin class AppMessageListener {
  void onLog(Log log) {}

  void onDelay(Delay delay) {}

  void onRequest(TrackerInfo connection) {}

  void onLoaded(String providerName) {}
}

// abstract mixin class ServiceMessageListener {
//   onProtect(Fd fd) {}
//
//   onProcess(ProcessData process) {}
// }

@freezed
class SetupParams with _$SetupParams {
  const factory SetupParams({
    @JsonKey(name: 'config') required Map<String, dynamic> config,
    @JsonKey(name: 'selected-map') required Map<String, String> selectedMap,
    @JsonKey(name: 'test-url') required String testUrl,
  }) = _SetupParams;

  factory SetupParams.fromJson(Map<String, dynamic> json) =>
      _$SetupParamsFromJson(json);
}

// extension SetupParamsExt on SetupParams {
//   Map<String, dynamic> get json {
//     final json = Map<String, dynamic>.from(config);
//     json["selected-map"] = selectedMap;
//     json["test-url"] = testUrl;
//     return json;
//   }
// }

@freezed
class UpdateParams with _$UpdateParams {
  const factory UpdateParams({
    required Tun tun,
    @JsonKey(name: 'mixed-port') required int mixedPort,
    @JsonKey(name: 'allow-lan') required bool allowLan,
    @JsonKey(name: 'find-process-mode')
    required FindProcessMode findProcessMode,
    required Mode mode,
    @JsonKey(name: 'log-level') required LogLevel logLevel,
    required bool ipv6,
    @JsonKey(name: 'tcp-concurrent') required bool tcpConcurrent,
    @JsonKey(name: 'external-controller')
    required ExternalControllerStatus externalController,
    @JsonKey(name: 'unified-delay') required bool unifiedDelay,
  }) = _UpdateParams;

  factory UpdateParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateParamsFromJson(json);
}

@freezed
class CoreState with _$CoreState {
  const factory CoreState({
    @JsonKey(name: 'vpn-props') required VpnProps vpnProps,
    @JsonKey(name: 'only-statistics-proxy') required bool onlyStatisticsProxy,
    @JsonKey(name: 'current-profile-name') required String currentProfileName,
    @JsonKey(name: 'bypass-domain') @Default([]) List<String> bypassDomain,
  }) = _CoreState;

  factory CoreState.fromJson(Map<String, Object?> json) =>
      _$CoreStateFromJson(json);
}

@freezed
class AndroidVpnOptions with _$AndroidVpnOptions {
  const factory AndroidVpnOptions({
    required bool enable,
    required int port,
    required AccessControl? accessControl,
    required bool allowBypass,
    required bool systemProxy,
    required List<String> bypassDomain,
    required String ipv4Address,
    required String ipv6Address,
    @Default([]) List<String> routeAddress,
    required String dnsServerAddress,
  }) = _AndroidVpnOptions;

  factory AndroidVpnOptions.fromJson(Map<String, Object?> json) =>
      _$AndroidVpnOptionsFromJson(json);
}

@freezed
class InitParams with _$InitParams {
  const factory InitParams({
    @JsonKey(name: 'home-dir') required String homeDir,
    required int version,
  }) = _InitParams;

  factory InitParams.fromJson(Map<String, Object?> json) =>
      _$InitParamsFromJson(json);
}

@freezed
class ChangeProxyParams with _$ChangeProxyParams {
  const factory ChangeProxyParams({
    @JsonKey(name: 'group-name') required String groupName,
    @JsonKey(name: 'proxy-name') required String proxyName,
  }) = _ChangeProxyParams;

  factory ChangeProxyParams.fromJson(Map<String, Object?> json) =>
      _$ChangeProxyParamsFromJson(json);
}

@freezed
class UpdateGeoDataParams with _$UpdateGeoDataParams {
  const factory UpdateGeoDataParams({
    @JsonKey(name: 'geo-type') required String geoType,
    @JsonKey(name: 'geo-name') required String geoName,
  }) = _UpdateGeoDataParams;

  factory UpdateGeoDataParams.fromJson(Map<String, Object?> json) =>
      _$UpdateGeoDataParamsFromJson(json);
}

@freezed
class AppMessage with _$AppMessage {
  const factory AppMessage({
    required AppMessageType type,
    dynamic data,
  }) = _AppMessage;

  factory AppMessage.fromJson(Map<String, Object?> json) =>
      _$AppMessageFromJson(json);
}

@freezed
class InvokeMessage with _$InvokeMessage {
  const factory InvokeMessage({
    required InvokeMessageType type,
    dynamic data,
  }) = _InvokeMessage;

  factory InvokeMessage.fromJson(Map<String, Object?> json) =>
      _$InvokeMessageFromJson(json);
}

@freezed
class Delay with _$Delay {
  const factory Delay({
    required String name,
    required String url,
    int? value,
  }) = _Delay;

  factory Delay.fromJson(Map<String, Object?> json) => _$DelayFromJson(json);
}

@freezed
class Now with _$Now {
  const factory Now({
    required String name,
    required String value,
  }) = _Now;

  factory Now.fromJson(Map<String, Object?> json) => _$NowFromJson(json);
}

// @freezed
// class ProcessData with _$ProcessData {
//   const factory ProcessData({
//     required String id,
//     required Metadata metadata,
//   }) = _ProcessData;
//
//   factory ProcessData.fromJson(Map<String, Object?> json) =>
//       _$ProcessDataFromJson(json);
// }
//
// @freezed
// class Fd with _$Fd {
//   const factory Fd({
//     required String id,
//     required int value,
//   }) = _Fd;
//
//   factory Fd.fromJson(Map<String, Object?> json) => _$FdFromJson(json);
// }

@freezed
class ProviderSubscriptionInfo with _$ProviderSubscriptionInfo {
  const factory ProviderSubscriptionInfo({
    @JsonKey(name: 'UPLOAD') @Default(0) int upload,
    @JsonKey(name: 'DOWNLOAD') @Default(0) int download,
    @JsonKey(name: 'TOTAL') @Default(0) int total,
    @JsonKey(name: 'EXPIRE') @Default(0) int expire,
  }) = _ProviderSubscriptionInfo;

  factory ProviderSubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$ProviderSubscriptionInfoFromJson(json);
}

SubscriptionInfo? subscriptionInfoFormCore(Map<String, Object?>? json) {
  if (json == null) return null;
  return SubscriptionInfo(
    upload: (json['Upload'] as num?)?.toInt() ?? 0,
    download: (json['Download'] as num?)?.toInt() ?? 0,
    total: (json['Total'] as num?)?.toInt() ?? 0,
    expire: (json['Expire'] as num?)?.toInt() ?? 0,
  );
}

@freezed
class ExternalProvider with _$ExternalProvider {
  const factory ExternalProvider({
    required String name,
    required String type,
    String? path,
    required int count,
    @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
    SubscriptionInfo? subscriptionInfo,
    @Default(false) bool isUpdating,
    @JsonKey(name: 'vehicle-type') required String vehicleType,
    @JsonKey(name: 'update-at') required DateTime updateAt,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

@freezed
class Action with _$Action {
  const factory Action({
    required ActionMethod method,
    required dynamic data,
    required String id,
  }) = _Action;

  factory Action.fromJson(Map<String, Object?> json) => _$ActionFromJson(json);
}

@freezed
class ActionResult with _$ActionResult {
  const factory ActionResult({
    required ActionMethod method,
    required dynamic data,
    String? id,
    @Default(ResultType.success) ResultType code,
  }) = _ActionResult;

  factory ActionResult.fromJson(Map<String, Object?> json) =>
      _$ActionResultFromJson(json);
}

extension ActionResultExt on ActionResult {
  Result get toResult {
    if (code == ResultType.success) {
      return Result.success(data);
    } else {
      return Result.error(data);
    }
  }
}
