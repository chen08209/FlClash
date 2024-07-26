import 'package:fl_clash/common/datetime.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'traffic.dart';

part 'generated/file.freezed.dart';

@freezed
class FileInfo with _$FileInfo {
  const factory FileInfo({
    required int size,
    required DateTime lastModified,
  }) = _FileInfo;
}


extension FileInfoExt on FileInfo{
  String get desc => "${TrafficValue(value: size).show}  ·  ${lastModified.lastUpdateTimeDesc}";
}


