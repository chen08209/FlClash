import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/dav.g.dart';

part 'generated/dav.freezed.dart';

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
