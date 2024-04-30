import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/package.g.dart';
part 'generated/package.freezed.dart';

@freezed
class Package with _$Package {
  const factory Package({
    required String packageName,
    required String label,
    required bool isSystem,
  }) = _Package;

  factory Package.fromJson(Map<String, Object?> json) =>
      _$PackageFromJson(json);
}
