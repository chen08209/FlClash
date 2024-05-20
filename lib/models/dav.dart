import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/dav.g.dart';

part 'generated/dav.freezed.dart';

@freezed
class DAV with _$DAV{
  const factory DAV({
    required String uri,
    required String user,
    required String password,
  }) = _DAV;

  factory DAV.fromJson(Map<String, Object?> json) =>
      _$DAVFromJson(json);
}