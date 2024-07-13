// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/connection.dart';
import 'package:fl_clash/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/ffi.g.dart';

part 'generated/ffi.freezed.dart';

@freezed
class ConfigExtendedParams with _$ConfigExtendedParams {
  const factory ConfigExtendedParams({
    @JsonKey(name: "is-patch") required bool isPatch,
    @JsonKey(name: "is-compatible") required bool isCompatible,
    @JsonKey(name: "selected-map") required SelectedMap selectedMap,
    @JsonKey(name: "test-url") required String testUrl,
  }) = _ConfigExtendedParams;

  factory ConfigExtendedParams.fromJson(Map<String, Object?> json) =>
      _$ConfigExtendedParamsFromJson(json);
}

@freezed
class UpdateConfigParams with _$UpdateConfigParams {
  const factory UpdateConfigParams({
    @JsonKey(name: "profile-path") String? profilePath,
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
class ExternalProvider with _$ExternalProvider {
  const factory ExternalProvider({
    required String name,
    required String type,
    @JsonKey(name: "vehicle-type") required String vehicleType,
    @JsonKey(name: "update-at") required DateTime updateAt,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

abstract mixin class AppMessageListener {
  void onLog(Log log) {}

  void onDelay(Delay delay) {}

  void onRequest(Connection connection) {}

  void onStarted(String runTime) {}

  void onLoaded(String groupName) {}
}

abstract mixin class ServiceMessageListener {
  onProtect(Fd fd) {}

  onProcess(Process process) {}

  onStarted(String runTime) {}

  onLoaded(String groupName) {}
}


