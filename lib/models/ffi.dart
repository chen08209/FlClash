// ignore_for_file: invalid_annotation_target

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/ffi.g.dart';

part 'generated/ffi.freezed.dart';

@freezed
class UpdateConfigParams with _$UpdateConfigParams {
  const factory UpdateConfigParams({
    @JsonKey(name: "profile-path") String? profilePath,
    required ClashConfig config,
    @JsonKey(name: "is-patch") required bool isPatch,
    @JsonKey(name: "is-compatible") required bool isCompatible,
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
class Message with _$Message {
  const factory Message({
    required MessageType type,
    dynamic data,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
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
    required int uid,
    required String network,
    required String source,
    required String target,
  }) = _Process;

  factory Process.fromJson(Map<String, Object?> json) =>
      _$ProcessFromJson(json);
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
