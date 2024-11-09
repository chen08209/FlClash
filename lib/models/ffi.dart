// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/ffi.freezed.dart';
part 'generated/ffi.g.dart';

@freezed
class CoreState with _$CoreState {
  const factory CoreState({
    required bool enable,
    AccessControl? accessControl,
    required String currentProfileName,
    required bool allowBypass,
    required bool systemProxy,
    required List<String> bypassDomain,
    required List<String> routeAddress,
    required bool ipv6,
    required bool onlyProxy,
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
    required List<String> routeAddress,
    required String dnsServerAddress,
  }) = _AndroidVpnOptions;

  factory AndroidVpnOptions.fromJson(Map<String, Object?> json) =>
      _$AndroidVpnOptionsFromJson(json);
}

@freezed
class ConfigExtendedParams with _$ConfigExtendedParams {
  const factory ConfigExtendedParams({
    @JsonKey(name: "is-patch") required bool isPatch,
    @JsonKey(name: "is-compatible") required bool isCompatible,
    @JsonKey(name: "selected-map") required SelectedMap selectedMap,
    @JsonKey(name: "override-dns") required bool overrideDns,
    @JsonKey(name: "test-url") required String testUrl,
  }) = _ConfigExtendedParams;

  factory ConfigExtendedParams.fromJson(Map<String, Object?> json) =>
      _$ConfigExtendedParamsFromJson(json);
}

@freezed
class UpdateConfigParams with _$UpdateConfigParams {
  const factory UpdateConfigParams({
    @JsonKey(name: "profile-id") required String profileId,
    required ClashConfig config,
    required ConfigExtendedParams params,
  }) = _UpdateConfigParams;

  factory UpdateConfigParams.fromJson(Map<String, Object?> json) =>
      _$UpdateConfigParamsFromJson(json);
}

@freezed
class ChangeProxyParams with _$ChangeProxyParams {
  const factory ChangeProxyParams({
    @JsonKey(name: "group-name") required String groupName,
    @JsonKey(name: "proxy-name") required String proxyName,
  }) = _ChangeProxyParams;

  factory ChangeProxyParams.fromJson(Map<String, Object?> json) =>
      _$ChangeProxyParamsFromJson(json);
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
class ServiceMessage with _$ServiceMessage {
  const factory ServiceMessage({
    required ServiceMessageType type,
    dynamic data,
  }) = _ServiceMessage;

  factory ServiceMessage.fromJson(Map<String, Object?> json) =>
      _$ServiceMessageFromJson(json);
}

@freezed
class Delay with _$Delay {
  const factory Delay({
    required String name,
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

@freezed
class Process with _$Process {
  const factory Process({
    required int id,
    required Metadata metadata,
  }) = _Process;

  factory Process.fromJson(Map<String, Object?> json) =>
      _$ProcessFromJson(json);
}

@freezed
class Fd with _$Fd {
  const factory Fd({
    required int id,
    required int value,
  }) = _Fd;

  factory Fd.fromJson(Map<String, Object?> json) => _$FdFromJson(json);
}

@freezed
class ProcessMapItem with _$ProcessMapItem {
  const factory ProcessMapItem({
    required int id,
    required String value,
  }) = _ProcessMapItem;

  factory ProcessMapItem.fromJson(Map<String, Object?> json) =>
      _$ProcessMapItemFromJson(json);
}

@freezed
class ProviderSubscriptionInfo with _$ProviderSubscriptionInfo {
  const factory ProviderSubscriptionInfo({
    @JsonKey(name: "UPLOAD") @Default(0) int upload,
    @JsonKey(name: "DOWNLOAD") @Default(0) int download,
    @JsonKey(name: "TOTAL") @Default(0) int total,
    @JsonKey(name: "EXPIRE") @Default(0) int expire,
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
    @JsonKey(name: "subscription-info", fromJson: subscriptionInfoFormCore)
    SubscriptionInfo? subscriptionInfo,
    @Default(false) bool isUpdating,
    @JsonKey(name: "vehicle-type") required String vehicleType,
    @JsonKey(name: "update-at") required DateTime updateAt,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

@freezed
class TunProps with _$TunProps {
  const factory TunProps({
    required int fd,
    required String gateway,
    required String gateway6,
    required String portal,
    required String portal6,
    required String dns,
    required String dns6,
  }) = _TunProps;

  factory TunProps.fromJson(Map<String, Object?> json) =>
      _$TunPropsFromJson(json);
}

abstract mixin class AppMessageListener {
  void onLog(Log log) {}

  void onDelay(Delay delay) {}

  void onRequest(Connection connection) {}

  void onStarted(String runTime) {}

  void onLoaded(String providerName) {}
}

abstract mixin class ServiceMessageListener {
  onProtect(Fd fd) {}

  onProcess(Process process) {}

  onStarted(String runTime) {}

  onLoaded(String providerName) {}
}
