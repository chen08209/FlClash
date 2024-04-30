import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/version.g.dart';

part 'generated/version.freezed.dart';

@freezed
class VersionInfo with _$VersionInfo {
  const factory VersionInfo({
    @Default("") String clashName,
    @Default("") String version,
  }) = _VersionInfo;

  factory VersionInfo.fromJson(Map<String, Object?> json) =>
      _$VersionInfoFromJson(json);
}
